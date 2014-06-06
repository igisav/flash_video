package de.axelspringer.videoplayer.vast.loader
{
	import de.axelspringer.videoplayer.event.AdEvent;
	import de.axelspringer.videoplayer.event.XmlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.util.XmlLoader;
	import de.axelspringer.videoplayer.vast.VastController;
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.vast.media.VASTMediaGenerator;
	import de.axelspringer.videoplayer.vast.model.VAST2Translator;
	import de.axelspringer.videoplayer.vast.model.VASTAd;
	import de.axelspringer.videoplayer.vast.model.VASTDataObject;
	import de.axelspringer.videoplayer.vast.model.VASTDocument;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2TrackingData;
	import de.axelspringer.videoplayer.vast.vo.VastAd;
	import de.axelspringer.videoplayer.vast.vo.VastNonLinear;
	import de.axelspringer.videoplayer.vast.vo.VastVideo;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	[Event(name="error", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="loaded", type="de.axelspringer.videoplayer.event.AdEvent")]
	
	public class VASTLoader extends EventDispatcher
	{
		private var maxNumWrapperRedirects:int;
		private var xmlLoader:XmlLoader;
		private var trackingData:VAST2TrackingData;
		
		protected var loadTimer:Timer;
		protected var currentUrl:String;
		protected var wrapperAd:VastAd;
		
		public function VASTLoader()
		{
			super( this );
			
			this.maxNumWrapperRedirects = VastDefines.MAX_REDIRECTS;
			
			this.xmlLoader = new XmlLoader();
			this.xmlLoader.addEventListener( XmlEvent.XML_LOADED, onXmlLoaded );
			this.xmlLoader.addEventListener( XmlEvent.XML_ERROR, onXmlError );
			
			this.loadTimer = new Timer( VastDefines.LOADER_TIMEOUT, 1 );
			this.loadTimer.addEventListener( TimerEvent.TIMER, onLoadTimeout );
		}
		
		public function load( url:String, isFirstLoad:Boolean = false ) :void
		{
			/* check if the url contains placeholder for timestamp
			 * check for url-encoded or plain placeholders
			 * if no placeholder is found, add cachebuster to the end of the url
			 */
			if( BildTvDefines.debugFlag ) //ExternalInterface.call("function(){if (window.console) console.log('"+this+" load xml from: "+url+"      but replace some stuff before...');}");
//			trace( this + " load: " + url );
			
			if( url == null || url == "" )
			{
				this.onError( "no url found" );
				return;
			}
			
			var cachebuster:String = new Date().time.toString();
			
			if( url.indexOf( "[TIMESTAMP]" ) > -1 )
			{
				url = url.split( "[TIMESTAMP]" ).join( cachebuster );
			}
			else if( url.indexOf( "%5BTIMESTAMP%5D" ) > -1 )
			{
				url = url.split( "%5BTIMESTAMP%5D" ).join( cachebuster );
			}
			else if( url.indexOf( "[timestamp]" ) > -1 )
			{
				url = url.split( "[timestamp]" ).join( cachebuster );
			}
			else if( url.indexOf( "%5Btimestamp%5D" ) > -1 )
			{
				url = url.split( "%5Btimestamp%5D" ).join( cachebuster );
			}
			else if( isFirstLoad && BildTvDefines.develMode == BildTvDefines.DEVELMODE_NONE )
			{
				if( url.indexOf( "?" ) > -1 )
				{
					// insert cachebuster before the ?
					var separator:String = "%3B"; // url encoded ";"
					var index:Number = url.indexOf( "?" );
					url = url.substring( 0, index ) + separator + cachebuster + url.substring( index );
				}
			}
			
			trace( this + " loading document from: " + url + ", redirects left: " + maxNumWrapperRedirects );
			VastController.traceToHtml( "loading document from: " + url + ", redirects left: " + maxNumWrapperRedirects );
			
			if( BildTvDefines.debugFlag ) //ExternalInterface.call("function(){if (window.console) console.log('"+this+" now load xml from: "+url+"');}");
			this.currentUrl = url;
			this.xmlLoader.loadXml( url );
			this.loadTimer.start();
		}
		
		public function reset() :void
		{
			this.trackingData = null;
			this.maxNumWrapperRedirects = VastDefines.MAX_REDIRECTS;
			this.currentUrl = "";
			this.wrapperAd = null;
		}
		
		protected function onXmlLoaded( event:XmlEvent ) :void
		{
//			trace( this + " onXmlLoaded" );
//			trace( "\n-----------------------------------------------\n" + event.xml.toXMLString() + "\n-----------------------------------------------" );
			VastController.traceToHtml( "~~~~~~~~~~~~~ xml loaded ~~~~~~~~~~~~~" );
			var output:String = event.xml.toXMLString();
			output = output.split( "<" ).join( "&lt;" );
			output = output.split( ">" ).join( "&gt;" );
			output = output.split( "\r\n" ).join( "<br/>" );
			output = output.split( "\r" ).join( "<br/>" );
			output = output.split( "\n" ).join( "<br/>" );
			output = output.split( "\t" ).join( "&nbsp;&nbsp;&nbsp;&nbsp;" );
			output = output.split( " " ).join( "&nbsp;" );
			VastController.traceToHtml( output );
			VastController.traceToHtml( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
			
			this.loadTimer.stop();
			
			var processor:VASTDocumentProcessor = new VASTDocumentProcessor();
			processor.addEventListener( VASTDocumentProcessedEvent.PROCESSED, onDocumentProcessed, false, 0, true );
			processor.addEventListener( VASTDocumentProcessedEvent.PROCESSING_FAILED, onDocumentProcessFailed, false, 0, true );
						
			processor.processVASTDocument( event.xml, this.trackingData );
		}
		
		protected function onXmlError( event:XmlEvent ) :void
		{
//			trace( this + " onXmlError: " + event.text );
			
			this.loadTimer.stop();
			
			this.onError( event.text );
		}
		
		protected function onLoadTimeout( event:TimerEvent ) :void
		{
			this.xmlLoader.cancelXml( this.currentUrl );
			this.onError( "Error: VAST XML loading timed out." );
		}
		
		protected function onDocumentProcessed( event:VASTDocumentProcessedEvent ) :void
		{
			var vastData:VASTDataObject = event.vastDocument as VASTDataObject;
			var wrapperAd:VastAd;
			
			// check for wrapper
			switch( vastData.vastVersion )
			{
				case VASTDataObject.VERSION_1_0:
				{
					var vast1Document:VASTDocument = vastData as VASTDocument;
					
					// only check first ad 
					var vastAd:VASTAd = vast1Document.ads[0];
					if( vastAd == null )
					{
						this.onError( "Error: no ad found" );
					}
					// load wrapper
					else if( vastAd.wrapperAd != null && ( this.maxNumWrapperRedirects > 0 || this.maxNumWrapperRedirects == -1 ) )
					{
						// store wrapper for merging it later
						wrapperAd = VASTMediaGenerator.getWrapper( vastData );
						if( this.wrapperAd != null )
						{
							wrapperAd = this.mergeAds( wrapperAd, this.wrapperAd );
						}
						this.wrapperAd = wrapperAd;
						
						// load 
						this.maxNumWrapperRedirects = Math.max( -1, this.maxNumWrapperRedirects - 1 );
						
//						trace( this + " loading wrapper, redirects left: " + this.maxNumWrapperRedirects );
						VastController.traceToHtml( "document is wrapper, loading next" );
						
						this.load( vastAd.wrapperAd.vastAdTagURL );
					}
					else
					{
						// finished loading, make final check
						this.finalizeLoading( vastData );
					}
					
					break;
				}
				case VASTDataObject.VERSION_2_0:
				{
					var vast2Document:VAST2Translator = vastData as VAST2Translator;
					
					// load wrapper
					if( vast2Document.vastParser.isVASTXMLWRAPPER && ( this.maxNumWrapperRedirects > 0 || this.maxNumWrapperRedirects == -1 ) )
					{
//						trace( this + " " + vast2Document.vastParser.adTagTitle + " is a VAST wrapper.")
						
						// store wrapper for merging it later
						wrapperAd = VASTMediaGenerator.getWrapper( vastData );
						if( this.wrapperAd != null )
						{
							wrapperAd = this.mergeAds( wrapperAd, this.wrapperAd );
						}
						this.wrapperAd = wrapperAd;
						
						// load
						this.maxNumWrapperRedirects = Math.max( -1, this.maxNumWrapperRedirects - 1 );
						
//						trace( this + " loading wrapper, redirects left: " + this.maxNumWrapperRedirects );
						VastController.traceToHtml( "document is wrapper, loading next" );
						
						this.load( vast2Document.vastParser._Wrapper.VASTAdTagURL );
					}
					else
					{
						// finished loading, make final check
						this.finalizeLoading( vastData );
					}
					
					break;
				}
			}
		}
		
		protected function finalizeLoading( vastData:VASTDataObject ) :void
		{
			var finalAd:VastAd = VASTMediaGenerator.getAds( vastData )[0];
			
			// no inline > error
			if( finalAd == null )
			{
				this.onError( "Error: no inline found" );
			}
			else
			{
				// merge with wrapper
				if( this.wrapperAd != null )
				{
					finalAd = this.mergeAds( finalAd, this.wrapperAd );
					this.wrapperAd = null;
				}
				
				this.dispatchEvent( new AdEvent( AdEvent.LOADED, finalAd ) );
			}
		}
		
		protected function onDocumentProcessFailed( event:VASTDocumentProcessedEvent ) :void
		{
			this.onError( "Error: processing vast document failed" );
		}
		
		protected function onError( text:String ) :void
		{
			this.dispatchEvent( new AdEvent( AdEvent.ERROR, text ) );
		}
		
		protected function mergeAds( inlineAd:VastAd, wrapperAd:VastAd ) :VastAd
		{
			var finalAd:VastAd = new VastAd();
			
			finalAd.companions = inlineAd.companions.concat( wrapperAd.companions );
			finalAd.errors = inlineAd.errors.concat( wrapperAd.errors );
			finalAd.extensions = inlineAd.extensions.concat( wrapperAd.extensions );
			finalAd.id = wrapperAd.id;
			finalAd.impressions = inlineAd.impressions.concat( wrapperAd.impressions );
			finalAd.survey = inlineAd.survey.concat( wrapperAd.survey );
			finalAd.duration = ( wrapperAd.duration > 0 ) ? wrapperAd.duration : inlineAd.duration;
			
			finalAd.nonLinears = inlineAd.nonLinears;
			var inlineNonLinear:VastNonLinear = finalAd.nonLinears[0];
			var wrapperNonLinear:VastNonLinear = wrapperAd.nonLinears[0];
			// VAST 2 wrapper can contain complete nonLinears, so check if we have a complete one
			// if so, put it in front of array
			// if not, merge tracking infos if present 
			if( wrapperNonLinear != null )
			{
				// do we have a complete nonLinear?
				if( wrapperNonLinear.resourceType != "" )
				{
					// yes, insert wrapper nonLinear into array
					finalAd.nonLinears.splice( 0, 0, wrapperNonLinear );
				}
				else if( inlineNonLinear != null )
				{
					// no, merge data
					inlineNonLinear.addTrackingEvents( wrapperNonLinear.trackingEvents );
					inlineNonLinear.clickTrackings = inlineNonLinear.clickTrackings.concat( wrapperNonLinear.clickTrackings );
				}
			}
			
			finalAd.videos = inlineAd.videos;
			var inlineVideo:VastVideo = finalAd.videos[0];
			var wrapperVideo:VastVideo = wrapperAd.videos[0];
			if( inlineVideo != null && wrapperVideo != null )
			{
				inlineVideo.addTrackingEvents( wrapperVideo.trackingEvents );
				inlineVideo.videoClicks.clickTrackings = inlineVideo.videoClicks.clickTrackings.concat( wrapperVideo.videoClicks.clickTrackings );
				if( inlineVideo.videoClicks.clickThru == null || inlineVideo.videoClicks.clickThru.url == null || inlineVideo.videoClicks.clickThru.url == "" )
				{
					inlineVideo.videoClicks.clickThru = wrapperVideo.videoClicks.clickThru;
				}
				
				// check for duration - inline may overwrite the wrapper value
				if( wrapperVideo.duration > 0 )
				{
					inlineVideo.duration = wrapperVideo.duration;
				}
			}
			
			return finalAd;
		}
	}
}
