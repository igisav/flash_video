package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.event.XmlEvent;
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.XmlLoader;

	public class StreamingVO extends BaseVO
	{
		
		public var ns:Namespace = new Namespace("http://www.w3.org/2001/SMIL20/Language");
			
		public var streamUrl:String 	= "";
		public var streamUrl2:String 	= "";
		public var duration:Number		= -1;
		public var autoplay:Boolean 	= true;
		public var isLivestream:Boolean = false;
		
		public var functionNameStreamEnd:String 		= "onStreamEnd";
		public var functionNameConnectionClose:String 	= "location.reload";
		
		// ads
		public var adVO:AdVO;
		
		// tracking
		//public var trackingVO:TrackingVO;
		
		// session pinger
		public var pingUrl:String 		= "";
		public var pingSession:String	= "";
		public var pingInterval:uint	= 10 * 60 * 1000;	// in ms
		public var pingText:String		= "";
		public var pingDebug:Boolean	= false;
		
		public function StreamingVO()
		{
			super();
			
			this.adVO = new AdVO();
			//this.trackingVO = new TrackingVO();
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				this.streamUrl = hasAttribute( xml, "src" ) ? xml.@src : this.streamUrl;
				this.streamUrl2 = hasAttribute( xml, "src2" ) ? xml.@src2 : this.streamUrl2;	
				
				BildTvDefines.buffertimeMaximum = hasAttribute( xml.buffer[0], "dynbuffer" ) ? xml.buffer[0].@dynbuffer : BildTvDefines.buffertimeMaximum;
				BildTvDefines.buffertimeMinimum = hasAttribute( xml.buffer[0], "startbuffer" ) ? xml.buffer[0].@startbuffer : BildTvDefines.buffertimeMinimum;
			
				this.adVO.hydrate( xml.ad[0] );
				// no midrolls or overlays
				this.adVO.midroll = "";
				this.adVO.overlay = "";
				
				/*this.trackingVO.trackingEnabled = hasAttribute( xml, "tracking" ) ? ( xml.@tracking == "true" ? true : false ) : true;
				this.trackingVO.trackFunction = hasAttribute( xml, "track" ) ? xml.@track : this.trackingVO.trackFunction;*/
				
				// session pinger
				if( xml.ping[0] != null )
				{
					var pingXml:XML = xml.ping[0];
					this.pingUrl = pingXml.@url;
					this.pingSession = pingXml.@session;
					var interval:Number = parseInt( pingXml.@interval, 10 );
					if( !isNaN( interval ) && interval > 0 )
					{
						this.pingInterval = interval * 1000;
					}
					this.pingText = pingXml.@text;
					this.pingDebug = ( pingXml.@debug == "true" || pingXml.@debug == "1" );
				}
			}
		}
			
		protected function loadSmil() :void
		{
			var xmlLoader:XmlLoader = new XmlLoader();
			xmlLoader.addEventListener( XmlEvent.XML_LOADED, onSmilLoaded, false, 0, true );
			xmlLoader.addEventListener( XmlEvent.XML_ERROR, onSmilError, false, 0, true );
			xmlLoader.loadXml( this.streamUrl );
		}
		
		protected function onSmilLoaded( e:XmlEvent ) :void
		{
			var loadedXml:XML = e.xml;
			this.hydrateSmil( loadedXml.ns::head, loadedXml.ns::body );
		}
		
		protected function onSmilError( e:XmlEvent ) :void
		{
			trace( "onXmlError: " + e.text );
		}
		
		public function hydrateSmil( smilHead:XMLList, smilBody:XMLList ) :void
		{
			if( smilHead != null )
			{
				var metaList:XMLList = smilHead.children();
				for each (var metaElement:* in metaList)
				{
					if( metaElement.@name == "rtmpPlaybackBase" )     
	              	{
	                 	trace("connectionUrl:" + metaElement.@content);
	                 	break;
	                } 
				}       
	  		} 
	  		 
			if( smilBody != null )
			{
				var videoList:XMLList = smilBody.children().children();
				for each (var videoElement:* in videoList)
				{
	               //	trace("connectionUrl:" + videoElement.@src + "        " + videoElement.@system-bitrate);
				}          
	  		}  			
		}
	}
}