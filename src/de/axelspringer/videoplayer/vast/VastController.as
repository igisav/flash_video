package de.axelspringer.videoplayer.vast
{
	import de.axelspringer.videoplayer.event.AdEvent;
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.FullscreenData;
	import de.axelspringer.videoplayer.model.vo.VolumeData;
	import de.axelspringer.videoplayer.vast.controller.VastPlayerController;
	import de.axelspringer.videoplayer.vast.controller.VastTrackingController;
	import de.axelspringer.videoplayer.vast.loader.VASTLoader;
	import de.axelspringer.videoplayer.vast.view.VastPlayerView;
	import de.axelspringer.videoplayer.vast.vo.VastAd;
	import de.axelspringer.videoplayer.vast.vo.VastMedium;
	import de.axelspringer.videoplayer.vast.vo.VastNonLinear;
	import de.axelspringer.videoplayer.vast.vo.VastVideo;
	import de.axelspringer.videoplayer.vast.vo.VastVideoClicks;
	import de.axelspringer.videoplayer.view.ControlsView;
	import de.axelspringer.videoplayer.vpaid.controller.VPaidController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	[Event(name="loaderaniChange", type="de.axelspringer.videoplayer.event.ControlEvent")]
	[Event(name="error", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="linearStart", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="finish", type="de.axelspringer.videoplayer.event.AdEvent")]
	
	public class VastController extends EventDispatcher
	{
		private static const ADCALL:String	= "http://ww251.smartadserver.com/call/pubx/21009/(video)/[format]/S/[timestamp]?";
		
		private static const VAST1_INLINE:String								= "xml/vast/vast1inline.xml";
		private static const VAST1_REDIRECT_VAST1_INLINE:String					= "xml/vast/vast1redirect-vast1inline.xml";
		private static const VAST1_REDIRECT_VAST1_REDIRECT_VAST1_INLINE:String	= "xml/vast/vast1redirect-vast1redirect-vast1inline.xml";
		private static const VAST1_REDIRECT_VAST2_INLINE:String					= "xml/vast/vast1redirect-vast2inline.xml";
		private static const VAST1_OVERLAY:String								= "xml/vast/vast1overlay.xml";
		private static const VAST2_INLINE:String								= "xml/vast/vast2inline.xml";
		private static const VAST2_REDIRECT_VAST1_INLINE:String					= "xml/vast/vast2redirect-vast1inline.xml";
		private static const VAST2_REDIRECT_VAST2_INLINE:String					= "xml/vast/vast2redirect-vast2inline.xml";
		private static const VAST2_LINEAR_NONLINEAR_VPAID:String				= "xml/vast/vast2linear+nonlinearVpaid.xml";
		
		private static const VAST2_LINEAR_NONLINEAR_VPAID_EW:String	= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_linear_flv_nonlinear_vpaid.xml";		
		private static const VAST1_LINEAR_EW:String					= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_1_linear_flv.xml";		
		private static const TEST_71_PREROLL:String					= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D10x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_preroll%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D";
		private static const TEST_71_MIDROLL:String					= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D20x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_midroll%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0A";
		private static const TEST_71_TANDEM:String					= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D10x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_prerolloverlay%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0A";
		private static const TEST_71_OVERLAY:String					= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D30x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_overlay%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0AD";
		private static const TEST_71_POSTROLL:String 				= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D40x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_postroll%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0A";
		private static const TEST_71_VPAID:String					= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D10x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_vpaid%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0A";
		
		private static const VAST1_ERROR_INLINE_NONLINEAR:String	= "http://ad.de.doubleclick.net/adx/DE_AS.bildde/_default;dcmt=text/xml;sz=30x1;pos=1;vpos=1;showroom=asmi_overlay;u=pos=1,vpos=1,tile=1,nuggpso=6&nuggbid=1&nuggdfp=d1=1;d15=4;d18=1;d4=1;d8=1;d9=4;d10=2;d12=3;i2=4;i3=4;i7=3;i8=3;i12=4;i13=3;i26=4;i41=4;i19=4;i42=1;i44=4;d13=16;d14=1;f1=6;f2=1;d16=1;d17=1;c1=1;c2=0;c3=0;c4=0;c5=0;c6=1;c7=0;c8=0&n_cid=r0=0;vi=1;tile=1;ord=[TIMESTAMP]";
		private static const VAST2_OVERLAY_VPAID:String				= "xml/vast/vast2overlay_vpaid.xml";
		private static const VAST2_OVERLAY_VPAID_71:String			= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fpfadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D30x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_vpaid_overlay%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0AD";
		private static const VAST2_OVERLAY_VPAID_EW:String			= "xml/vast/vast2overlay_vpaid_ew.xml";
		private static const VAST2_OVERLAY_VPAID_TEST:String		= "xml/vast/vast2overlay_vpaid_test.xml";
		private static const VAST2_WRAPPER_LINEAR_VPAID:String		= "http://ad.de.doubleclick.net/adx/DE_AS.bildde/_default;dcmt=text/xml;sz=10x1;pos=1;vpos=1;showroom=asmi_vpaid;u=pos=1,vpos=1,tile=1,nuggpso=6&nuggbid=1&nuggdfp=d1=1;d15=3;d18=1;d4=1;d8=1;d9=4;d10=2;d12=3;i2=4;i3=4;i8=3;i12=4;i13=3;i26=4;i41=4;i16=4;i19=4;i42=2;i44=4;d13=16;d14=1;f1=6;f2=1;d16=1;d17=1;c1=1;c2=0;c3=0;c4=0;c5=1;c6=1;c7=0;c8=0&n_cid=r0=0;vi=1;tile=1;ord=[TIMESTAMP]";
		private static const VAST2_WRAPPER_LINEAR_VPAID_71:String	= "http://71i.nuggad.net/bk?nuggn=1272195681&nuggsid=1340051439&nuggtg=sevenonede_home_home_home&nuggl=http%3A%2F%2Fad.de.doubleclick.net%2Fadx%2FDE_AS.bildde%2F_default%3Bdcmt%3Dtext%2Fxml%3Bsz%3D10x1%3Bpos%3D1%3Bvpos%3D1%3Bshowroom%3Dasmi_vpaid%3Bu%3Dpos%3D1%2Cvpos%3D1%2Ctile%3D1%2CNUGGVARS%3Bvi%3D1%3Btile%3D1%3Bord%3D%5BTIMESTAMP%5D%0A";
		private static const VAST2_WRAPPER_LINEAR_VPAID_TEST:String	= "xml/vast/vast2redirect_vast2vpaid_roll.xml";
		private static const VAST2_LINEAR_VPAID:String				= "xml/vast/vast2linear_vpaid.xml";
		private static const VAST2_LINEAR_VPAID_TEST:String			= "xml/vast/vast2linear_vpaid_test.xml";
		private static const VAST1_OVERLAY_2:String					= "xml/vast/vast1overlay2.xml";
		
		private static const VAST_FLV_VPAID:String					= "xml/vast/vast_flv_vpaid.xml";
		private static const VAST1_TANDEM:String					= "xml/vast/vast1tandem.xml";
		private static const VPAID_TEST:String						= "xml/vast/vpaid_test.xml";
		private static const DOUBLECLICK:String						= "http://ad.doubleclick.net/pfadx/N270.126913.6102203221521/B3876671.212;dcadv=2215309;sz=0x0;ord=[timestamp];dcmt=text/xml";
		
		protected var playerController:VastPlayerController;
		protected var trackingController:VastTrackingController;
		protected var vastLoader:VASTLoader;
		protected var vpaidController:VPaidController;
		
		protected var currentAd:VastAd;
		protected var currentAdPlacement:String;
		protected var currentVolume:Number;
		protected var currentAdIsTandem:Boolean;
		
		// movieplayer only: ad is started manually after jingle
		protected var startAdOnLoad:Boolean;
		
		// not a real timestamp but instead some kind of site id, retrieved from the website
		protected var timestamp:String;
		
		// the movieplayer can be paused by external JS - remember the state in case of asynchronous events
		protected var paused:Boolean;
		
		// TEST STUFF
		protected var url2load:String = VAST2_LINEAR_NONLINEAR_VPAID;
		protected static const testing:Boolean = false;
		//
		
		public function VastController( adContainer:Sprite )
		{
			super( this );
			
			//controlsView.addEventListener( ControlEvent.VOLUME_CHANGE, onVolumeChange );
			
			var playerView:VastPlayerView = new VastPlayerView( adContainer );
			this.playerController = new VastPlayerController( playerView );
			this.vpaidController = new VPaidController( playerView );
			
			this.init();
		}
		
		protected function init() :void
		{
			this.playerController.addEventListener( AdEvent.ERROR, forwardEvent );
			this.playerController.addEventListener( AdEvent.FINISH, forwardEvent );
			this.playerController.addEventListener( AdEvent.CLICK, onAdClick );
			this.playerController.addEventListener( ControlEvent.LOADERANI_CHANGE, forwardEvent );
			
			this.vastLoader = new VASTLoader();
			this.vastLoader.addEventListener( AdEvent.LOADED, onAdLoaded );
			this.vastLoader.addEventListener( AdEvent.ERROR, forwardEvent );
			
			this.vpaidController.addEventListener( AdEvent.ERROR, forwardEvent );
			this.vpaidController.addEventListener( AdEvent.LINEAR_START, forwardEvent );
			this.vpaidController.addEventListener( AdEvent.LINEAR_STOP, forwardEvent );
			this.vpaidController.addEventListener( AdEvent.FINISH, forwardEvent );
			this.vpaidController.addEventListener( AdEvent.CLICK, onVpaidClick );
			this.vpaidController.addEventListener( ControlEvent.LOADERANI_CHANGE, forwardEvent );
			
			this.trackingController = new VastTrackingController( this.playerController, this.vpaidController );
			
			try
			{
				this.timestamp = ExternalInterface.call( "function(){ return sas_tmstp; }" );
				if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('timestamp is: "+this.timestamp+"');}");
			}
			catch( error:Error )
			{
				this.timestamp = "";
			}
			trace( this + " timestamp = " + this.timestamp );
			VastController.traceToHtml( "sas_tmstp = " + this.timestamp );
			
			this.showDisplay( false );
			this.currentVolume = 1;
			this.paused = false;
		}
		
		public function get isAdPlaying() :Boolean
		{
			return this.playerController.isPlaying;
		}
		
		public function load( url:String, adType:String, startAdOnLoad:Boolean = true ) :void
		{
			this.reset();
			this.currentAdPlacement = adType;
			
			if(url == "") 
			{
				this.forwardEvent( new AdEvent( AdEvent.ERROR, "VAST: no URL found" ) );
				return;
			}
			
			this.startAdOnLoad = startAdOnLoad;
			
			// if we had a tandem ad, continue with already loaded ad
			if( this.currentAdPlacement == VastDefines.ADTYPE_OVERLAY && this.currentAdIsTandem )
			{
				trace( this + " tandem ad, not loading XML" );
				
				this.onAdLoaded( new AdEvent( AdEvent.LOADED, this.currentAd ) );
				this.currentAdIsTandem = false;
				return;
			}
			
			// test
			if( testing )
			{
				url = this.url2load;
			}
			
			url = url.replace( "[timestamp]", this.timestamp );
			url = url.replace( "[format]", this.currentAdPlacement );
			if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('----------------------------------------------------------------------');}");
			if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('"+this+" load Ad from URL: "+url+"');}");
			this.vastLoader.load( url, true );
		}
		
		public function setSize( size:Rectangle, fullscreenData:FullscreenData ) :void
		{
//			trace( this + " setSize" );
			
			this.playerController.setSize( size, fullscreenData );
			this.vpaidController.setSize( size, fullscreenData );
			
			// track
			if( fullscreenData != null )
			{
				this.trackingController.trackFullscreen( fullscreenData );
			}
		}
		
		public function get currentAdType() :String
		{
			return this.currentAdPlacement;
		}
		
		public function reset() :void
		{
			this.playerController.enableDisplayButton( false );
			this.playerController.showOverlay( false );
			this.currentAdPlacement = VastDefines.ADTYPE_NONE;
			this.trackingController.reset();
			this.vastLoader.reset();
			this.paused = false;
		}
		
		public function showDisplay( show:Boolean ) :void
		{
			this.playerController.showDisplay( show );
		}
		
		public function showOverlay( show:Boolean ) :void
		{
			this.vpaidController.stopAd();
			this.playerController.showOverlay( show );
		}
		
///////////////////////////////////////////////////////////////////////////////////////////////
		
		protected function onAdLoaded( event:AdEvent ) :void
		{
			trace( this + " onAdLoaded" );
			
			if( this.paused )
			{
				return;
			}
			
			var vastAd:VastAd = event.data as VastAd;
			
//			trace( "++++++++++++++++++++++++++++++++++++++++++++++++++++++" );
//			trace( vastAd );
//			trace( "++++++++++++++++++++++++++++++++++++++++++++++++++++++" );
			
			VastController.traceToHtml( "-------- ad loaded ------------" );
			
			var adFound:Boolean = false;
			
			switch( this.currentAdType )
			{
				case VastDefines.ADTYPE_PREROLL:
				case VastDefines.ADTYPE_MIDROLL:
				//case VastDefines.ADTYPE_NONE:
				case VastDefines.ADTYPE_POSTROLL:
				{
					trace( "pre/post/midroll" );
					VastController.traceToHtml( "current placement: pre/post/midroll" );
					
					// for testing
					//break;
					
					if( vastAd.videos.length > 0 && vastAd.videos[0].mediaFiles.length > 0  )
					{
						adFound = true;
						this.currentAd = vastAd;
						this.trackingController.setAd( vastAd, this.currentAdType );
						
						// check if we have a "tandem" - preroll + overlay
						if( this.currentAdType == VastDefines.ADTYPE_PREROLL && vastAd.nonLinears.length > 0 && vastAd.nonLinears[0].width > 0 )
						{
							this.currentAdIsTandem = true;
						}
						
						// tell PlayerController that an ad roll is gonna start
						this.dispatchEvent( new AdEvent( AdEvent.LINEAR_START ) );
						
						if( this.startAdOnLoad )
						{
							this.setLinearAd( vastAd.videos[0] );
						}
					}
					
					break;
				}
				case VastDefines.ADTYPE_OVERLAY:
				{
					trace( "overlay" );
					VastController.traceToHtml( "current placement: overlay" );
					
					// reset tandem state
					this.currentAdIsTandem = false;
					
					if( vastAd.nonLinears.length > 0 && vastAd.nonLinears[0].width > 0 )
					{
						adFound = true;
						this.currentAd = vastAd;
						this.trackingController.setAd( vastAd, this.currentAdType );
						
						this.setNonLinearAd( vastAd.nonLinears[0] );
					}
					
					break;
				}
			}
			
			if( !adFound )
			{
				this.forwardEvent( new AdEvent( AdEvent.ERROR, "VAST: no ad found" ) );
			}
		}
		
		public function startAd() :void
		{
			if( this.currentAd != null && this.currentAd.videos.length > 0 && this.currentAd.videos[0].mediaFiles.length > 0  )
			{
				this.setLinearAd( this.currentAd.videos[0] );
			}
			else
			{
				this.forwardEvent( new AdEvent( AdEvent.ERROR, "VAST: no ad found" ) );
			}
		}
		
		public function pause() :void
		{
			this.paused = true;
			
			if( this.playerController != null )
			{
				this.playerController.pause();
			}
		}
		
		public function resume() :void
		{
			this.paused = false;
			
			if( this.playerController != null )
			{
				this.playerController.resume();
			}
		}
		
		public function setVolume(value:Number) :void
		{
			this.paused = false;
			this.currentVolume = value;
			if( this.playerController != null )
			{
				this.playerController.setVolume(value);
			}
		}
		
		protected function setLinearAd( vastVideo:VastVideo ) :void
		{
//			trace( this + " setLinearAd" );
			
			var medium:VastMedium = this.getBestMedium( vastVideo.mediaFiles );
			if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('"+this+" try to play Advideo :"+medium.url+"');}");
			if( medium == null || medium.url == null || medium.url == "" )
			{
				this.forwardEvent( new AdEvent( AdEvent.ERROR, "VAST: ad does not contain valid medium" ) );
			}
			else
			{
				if( medium.apiFramework == VastDefines.API_FRAMEWORK_VPAID )
				{
					this.showDisplay( false );
					this.playerController.enableDisplayButton( false );
					medium.adParameters = vastVideo.adParameters;
					this.vpaidController.setAd( medium, this.currentAdPlacement, 0 );
				}
				else
				{
					this.showDisplay( true );
					var hasClickThru:Boolean = ( vastVideo.videoClicks.clickThru != null && vastVideo.videoClicks.clickThru.url != null );
					this.playerController.enableDisplayButton( hasClickThru );
					
					trace(this + " play: " + medium.url);
					
					this.playerController.playAd( medium, vastVideo.duration, this.currentAdType );		
				}
			}
		}
		
		protected function setNonLinearAd( nonLinear:VastNonLinear ) :void
		{
//			trace( this + " setNonLinearAd - is VPAID: " + ( nonLinear.apiFramework == VastDefines.API_FRAMEWORK_VPAID ) );
			
			if( nonLinear.apiFramework == VastDefines.API_FRAMEWORK_VPAID )
			{
				this.vpaidController.setAd( nonLinear, this.currentAdPlacement, nonLinear.duration );
			}
			else
			{
				this.playerController.setNonLinearAd( nonLinear );
			}
		}
		
		public function erternalAdClick():void
		{
			this.onAdClick();
		}
		
		protected function onAdClick( event:AdEvent = null ) :void
		{
			trace( this + " onAdClick" );
			VastController.traceToHtml( "ad clicked" );
			
			switch( this.currentAdType )
			{
				case VastDefines.ADTYPE_PREROLL:
				case VastDefines.ADTYPE_MIDROLL:
				//case VastDefines.ADTYPE_NONE:
				case VastDefines.ADTYPE_POSTROLL:
				{
					try
					{
						var videoClicks:VastVideoClicks = VastVideo( this.currentAd.videos[0] ).videoClicks;
						
//						trace( this + " clickThru url: " + videoClicks.clickThru.url );
						VastController.traceToHtml( "clickThru url: " + videoClicks.clickThru.url );
						
						if( videoClicks.clickThru.url != "" )
						{
							navigateToURL( new URLRequest( videoClicks.clickThru.url ), "_blank" );
							this.trackingController.trackUrls( videoClicks.clickTrackings );
							
							// pause ad
							this.playerController.pause();
						}
					}
					catch( error:Error )
					{
//						trace( this + " Error opening clickThru: " + error.message );
						VastController.traceToHtml( "error opening clickThru: " + error.message );
					}
					
					break;
				}
				case VastDefines.ADTYPE_OVERLAY:
				{
					try
					{
						var nonLinear:VastNonLinear = this.currentAd.nonLinears[0] as VastNonLinear;
						
//						trace( this + " clickThru url: " + nonLinear.clickThru.url );
						VastController.traceToHtml( "clickThru url: " + nonLinear.clickThru.url );
						
						navigateToURL( new URLRequest( nonLinear.clickThru.url ), "_blank" );
						this.trackingController.trackUrls( nonLinear.clickTrackings );
					}
					catch( error:Error )
					{
//						trace( this + " Error opening clickThru: " + error.message );
						VastController.traceToHtml( "error opening clickThru: " + error.message );
					}
					
					break;
				}
			}
		}
		
		protected function onVpaidClick( event:AdEvent ) :void
		{
//			trace( this + " onVpaidClick - data:" );
//			trace( event.data );
			
			if( this.paused )
			{
				return;
			}
			
			var playerHandles:Boolean = true;
			if( event.data != null && event.data.playerHandles != null )
			{
				playerHandles = Boolean( event.data.playerHandles );
			}
			
//			trace( "player handles: " + playerHandles );
			VastController.traceToHtml( "onVpaidClick - player handles: " + playerHandles );
			
			var clickThruUrl:String;
			
			switch( this.currentAdType )
			{
				case VastDefines.ADTYPE_PREROLL:
				case VastDefines.ADTYPE_MIDROLL:
				case VastDefines.ADTYPE_POSTROLL:
				{
					try
					{
						var videoClicks:VastVideoClicks = VastVideo( this.currentAd.videos[0] ).videoClicks;
						
						if( playerHandles )
						{
							if( event.data.url != null )
							{
								clickThruUrl = event.data.url;
							}
							else
							{
								clickThruUrl = videoClicks.clickThru.url;
							}
							
//							trace( this + " clickThru url: " + clickThruUrl );
							VastController.traceToHtml( "clickThru url: " + clickThruUrl );
							
							if( clickThruUrl != null && clickThruUrl != "" )
							{
								navigateToURL( new URLRequest( clickThruUrl ), "_blank" );
								this.trackingController.trackUrls( videoClicks.clickTrackings );
							}
						}
						// if ad handled click, just do tracking
						else
						{
							this.trackingController.trackUrls( videoClicks.clickTrackings );
						}
					}
					catch( error:Error )
					{
//						trace( this + " Error opening clickThru: " + error.message );
						VastController.traceToHtml( "error opening clickThru: " + error.message );
					}
					
					break;
				}
				case VastDefines.ADTYPE_OVERLAY:
				{
					try
					{
						var nonLinear:VastNonLinear = this.currentAd.nonLinears[0] as VastNonLinear;
						
						if( playerHandles )
						{
							if( event.data.url != null )
							{
								clickThruUrl = event.data.url;
							}
							else
							{
								clickThruUrl = nonLinear.clickThru.url;
							}
							
//							trace( this + " clickThru url: " + clickThruUrl );
							VastController.traceToHtml( "clickThru url: " + clickThruUrl );
							
							navigateToURL( new URLRequest( clickThruUrl ), "_blank" );
							this.trackingController.trackUrls( nonLinear.clickTrackings );
						}
						// if ad handled click, just do tracking
						else
						{
							this.trackingController.trackUrls( nonLinear.clickTrackings );
						}
					}
					catch( error:Error )
					{
//						trace( this + " Error opening clickThru: " + error.message );
						VastController.traceToHtml( "error opening clickThru: " + error.message );
					}
					
					break;
				}
			}
		}
		
		protected function forwardEvent( event:Event ) :void
		{
			if( !this.paused )
			{
				this.dispatchEvent( event.clone() );
			}
		}
		
		protected function getBestMedium( mediaFiles:Array ) :VastMedium
		{
			var bestMedium:VastMedium = mediaFiles[0];
			var deltaBitrate:Number = Math.abs( VastDefines.BITRATE_OPTIMUM - bestMedium.bitrate );
			var delta:Number;
			/*
			1. Wahl: .flv
			2. Wahl: .mp4
			3. Wahl: .mov
			*/
			
			// check each available medium if it:
			// - has a better bitrate
			// - is not streaming
			for each( var mediaFile:VastMedium in mediaFiles )
			{
				if( mediaFile.mimeType.indexOf("flv") != -1 )
				{
					bestMedium = mediaFile;				
				}
				else if( mediaFile.mimeType.indexOf("mp4") != -1 && bestMedium.mimeType.indexOf("flv") == -1 )
				{
					bestMedium = mediaFile;					
				}
				else if( mediaFile.mimeType.indexOf("quicktime") != -1 &&  (bestMedium.mimeType.indexOf("flv") == -1 && bestMedium.mimeType.indexOf("mp4") == -1 ))
				{
					bestMedium = mediaFile;				
				}
			}
			
			return bestMedium;
		}
		
		protected function onVolumeChange( e:ControlEvent ) :void
		{
//			trace( this +  " onVolumeChange: " + e.data.volume );
			
			var volume:Number = Math.min( 1, Math.max( 0, e.data.volume ) );
			
			if( volume == 0 && this.currentVolume == 0 )
			{
				volume = this.playerController.savedVolume;
			}
			
			this.playerController.setVolume( volume );
			this.vpaidController.setVolume( volume );
			
			// track
			this.trackingController.trackVolumeChange( new VolumeData( volume, this.currentVolume ) );
			
			this.currentVolume = volume;
		}
		
///////////////////////////////////////////////////////////////////////////////////////////////////////////

		static public function traceToHtml( text:String ) :void
		{
//			if( !testing )
//			{
//				ExternalInterface.call( "trackVast", text );
//			}
		}
	}
}