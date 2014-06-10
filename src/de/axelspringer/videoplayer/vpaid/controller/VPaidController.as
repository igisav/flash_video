package de.axelspringer.videoplayer.vpaid.controller
{
	import de.axelspringer.videoplayer.event.AdEvent;
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.FullscreenData;
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEventType;
	import de.axelspringer.videoplayer.vast.view.VastPlayerView;
	import de.axelspringer.videoplayer.vast.vo.IVpaidAd;
	import de.axelspringer.videoplayer.view.ControlsView;
	import de.axelspringer.videoplayer.vpaid.event.VPaidEvent;
	import de.axelspringer.videoplayer.vpaid.model.VPaidWrapper;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	
	[Event(name="loaderaniChange", type="de.axelspringer.videoplayer.event.ControlEvent")]
	[Event(name="error", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="finish", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="click", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="track", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="trackCustom", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="start", type="de.axelspringer.videoplayer.event.AdEvent")]
	
	
	public class VPaidController extends EventDispatcher
	{
		protected var playerView:VastPlayerView;
		// protected var controlsView:ControlsView;
		
		protected var vpaid:VPaidWrapper;
		protected var ad:IVpaidAd;
		protected var adPlacement:String;
		protected var adDuration:Number;
		
		protected var vpaidInitialized:Boolean;
		protected var vpaidShowing:Boolean;
		protected var vpaidStarted:Boolean;
		
		protected var loader:Loader;
		protected var timeoutTimer:Timer;
		
		protected var volume:Number = 1;
		protected var currentLinearState:Boolean = false;
		
		protected var hideTimer:Timer;
		
		public function VPaidController( playerView:VastPlayerView )
		{
			super( this );
			
			this.playerView = playerView;
			// this.controlsView = controlsView;
			
			this.init();
		}
		
		protected function init() :void
		{
			// not really necessary, but avoids error messages
			Security.allowDomain( "*" );
			
			this.playerView.addEventListener( AdEvent.NONLINEAR_START, onDisplayStart );
			
			this.vpaid = new VPaidWrapper();
			
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onError, false, 0, true );
			this.loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true );
			this.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onSwfLoadComplete, false, 0, true );
			
			this.timeoutTimer = new Timer( VastDefines.LOADER_TIMEOUT, 1 );
			this.timeoutTimer.addEventListener( TimerEvent.TIMER, onTimeout );
			
			this.hideTimer = new Timer( 30000, 1 );	// real delay will be set later
			this.hideTimer.addEventListener( TimerEvent.TIMER, onHideTimer );
		}
		
		public function setAd( ad:IVpaidAd, adPlacement:String, duration:Number ) :void
		{
//			trace( this + " setAd: " + ad + ", placement: " + adPlacement );
			
			this.ad = ad;
			this.adPlacement = adPlacement;
			this.adDuration = duration;
			
			trace(this + " load swf: " + ad.swfUrl);
			this.loadAd( ad.swfUrl );
			
			/*if( BildTvDefines.isWidgetPlayer )
			{	
				var yOffset:Number = this.controlsView.controls.background.height - this.controlsView.controls.background.y + 5;
				this.playerView.overlay.y -= yOffset;
			}*/
		}
		
		public function setSize( size:Rectangle, fullscreenData:FullscreenData ) :void
		{
//			trace( this + " setSize: " + size.width + " x " + size.height );
			
			var mode:String = VPaidWrapper.VIEWMODE_NORMAL;
			if( fullscreenData != null && fullscreenData.isFullscreen )
			{
//				trace( this + " setSize: is fullscreen" );
				mode = VPaidWrapper.VIEWMODE_FULLSCREEN;
			}
			
			this.vpaid.resizeAd( size.width, size.height, mode );
		}
		
		public function setVolume( volume:Number ) :void
		{
//			trace( this +  " setVolume: " + volume );
			
			this.volume = volume;
			this.vpaid.adVolume = volume;
		}
		
		public function stopAd() :void
		{
//			trace( this + " stopAd" );
			
			if( this.vpaidInitialized )
			{
				this.startTimeout();
				this.vpaid.stopAd();
			}
		}
		
		protected function loadAd( url:String ) :void
		{
//			trace( this + " loadAd: " + url );
			
			this.resetWrapper();
			
			try
			{
				this.startTimeout();
				trace(this + " " + url);
				this.loader.load( new URLRequest( url ), new LoaderContext( true, new ApplicationDomain(), SecurityDomain.currentDomain ) );				
			}
			catch( error:Error )
			{
				this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, error.message ) );
			}
		}
		
		protected function onSwfLoadComplete( event:Event ) :void
		{
//			trace( this + " onSwfLoadComplete" );
			
			this.stopTimeout();
			
			try
			{
				var success:Boolean = this.vpaid.setSwf( LoaderInfo( event.target ).content );
				
				if( !success )
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "Error: loaded ad doesn't support getVPAID()" ) );
				}
				else
				{
					this.startTimeout();
					this.addWrapperListeners();
					this.playerView.setVPaid( this.vpaid.getSwf(), ( this.adPlacement == VastDefines.ADTYPE_OVERLAY ) );
					
					var environmentVars:String = "frameRate=" + this.playerView.overlay.stage.frameRate ;
					
					this.vpaid.initAd( this.playerView.getSize().width, this.playerView.getSize().height, VPaidWrapper.VIEWMODE_NORMAL, VastDefines.BITRATE_OPTIMUM, this.ad.adParameters, environmentVars );
				}
			}
			catch( error:Error )
			{
				this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, error.message ) );
			}
			
		}
		
		protected function startTimeout() :void
		{
			this.stopTimeout();
			this.timeoutTimer.start();
		}
		
		protected function stopTimeout() :void
		{
			this.timeoutTimer.stop();
		}
		
		protected function onTimeout( event:TimerEvent ) :void
		{
//			trace( this + " onTimeout" );
			
			this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "Error: vpaid timed out." ) );
			
			try
			{
				this.loader.close();
			}
			catch( error:Error )
			{
				// ignore
			}
		}
		
		protected function onError( e:ErrorEvent ) :void
		{
//			trace( this + " onError: " + e.type + ", " + e.text );
			
			this.stopTimeout();
			this.playerView.removeOverlay();
			this.resetWrapper();
			
			this.dispatchEvent( new AdEvent( AdEvent.ERROR, e.text, false, false, this.adPlacement  ) );
		}
		
		/**
		 * eventhandler - called if display delay is finished and the ad graphics is made visible
		 * tries to start the ad
		 */
		protected function onDisplayStart( event:AdEvent ) :void
		{
//			trace( this + " onDisplayStart" );
			
			this.vpaidShowing = true;
			
			this.startAd();
		}
		
		/**
		 * starts the ad if graphics are visible and ad is initialized
		 */
		protected function startAd() :void
		{
//			trace( this + " startAd - initialized: " + this.vpaidInitialized + ", showing: " + this.vpaidShowing + ", started: " + this.vpaidStarted );
			
			if( this.vpaidShowing && this.vpaidInitialized && !this.vpaidStarted )
			{
//				trace( this + " calling startAd()" );
				
				this.vpaidStarted = true;
				this.vpaid.adVolume = this.volume;
				this.startTimeout();
				this.vpaid.startAd();
			}
		}
		
		/**
		 * removes listeners and resets the wrapper
		 */
		protected function resetWrapper() :void
		{
			if( this.vpaid.isInitialized() )
			{
				this.removeWrapperListeners();
				this.vpaid.reset();
			}
			
			this.vpaidInitialized = false;
			this.vpaidShowing = false;
			this.vpaidStarted = false;
		}
		
		protected function addWrapperListeners() :void
		{
			this.vpaid.addEventListener( VPaidEvent.LOADED, onAdLoaded );
			this.vpaid.addEventListener( VPaidEvent.STARTED, onAdStarted );
			this.vpaid.addEventListener( VPaidEvent.STOPPED, onAdStopped );
			this.vpaid.addEventListener( VPaidEvent.LINEARCHANGE, onAdLinearChanged );
			this.vpaid.addEventListener( VPaidEvent.EXPANDEDCHANGE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.REMAININGTIMECHANGE, onAdRemainingTimeChanged );
			this.vpaid.addEventListener( VPaidEvent.VOLUMECHANGE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.IMPRESSION, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.VIDEOSTART, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.VIDEOFIRSTQUARTILE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.VIDEOMIDPOINT, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.VIDEOTHIRDQUARTILE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.VIDEOCOMPLETE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.CLICKTHRU, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.USERACCEPTINVITATION, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.USERMINIMIZE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.USERCLOSE, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.PAUSED, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.PLAYING, onAdEvent );
			this.vpaid.addEventListener( VPaidEvent.LOG, onAdLog );
			this.vpaid.addEventListener( VPaidEvent.ERROR, onAdError );
			this.vpaid.addEventListener( VPaidEvent.CREATIVEVIEW, onAdEvent );
		}
		
		protected function removeWrapperListeners() :void
		{
			this.vpaid.removeEventListener( VPaidEvent.LOADED, onAdLoaded );
			this.vpaid.removeEventListener( VPaidEvent.STARTED, onAdStarted );
			this.vpaid.removeEventListener( VPaidEvent.STOPPED, onAdStopped );
			this.vpaid.removeEventListener( VPaidEvent.LINEARCHANGE, onAdLinearChanged );
			this.vpaid.removeEventListener( VPaidEvent.EXPANDEDCHANGE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.REMAININGTIMECHANGE, onAdRemainingTimeChanged );
			this.vpaid.removeEventListener( VPaidEvent.VOLUMECHANGE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.IMPRESSION, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.VIDEOSTART, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.VIDEOFIRSTQUARTILE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.VIDEOMIDPOINT, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.VIDEOTHIRDQUARTILE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.VIDEOCOMPLETE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.CLICKTHRU, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.USERACCEPTINVITATION, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.USERMINIMIZE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.USERCLOSE, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.PAUSED, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.PLAYING, onAdEvent );
			this.vpaid.removeEventListener( VPaidEvent.LOG, onAdLog );
			this.vpaid.removeEventListener( VPaidEvent.ERROR, onAdError );
			this.vpaid.removeEventListener( VPaidEvent.CREATIVEVIEW, onAdEvent );
		}
		
		protected function onAdEvent( event:Object ) :void
		{
//			trace( this + " onAdEvent: " + event );
			
			switch( event.type )
			{
				case VPaidEvent.EXPANDEDCHANGE:
				{
					if( this.vpaid.adExpanded )
					{
						this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.EXPAND ) );
					}
					else
					{
						this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.COLLAPSE ) );
					}
					
					break;
				}
				case VPaidEvent.VIDEOSTART:
				case VPaidEvent.IMPRESSION:
				case VPaidEvent.CREATIVEVIEW:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.START ) );
					
					break;
				}
				case VPaidEvent.VIDEOFIRSTQUARTILE:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.FIRST_QUARTILE ) );
					
					break;
				}
				case VPaidEvent.VIDEOMIDPOINT:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.MIDPOINT ) );
					
					break;
				}
				case VPaidEvent.VIDEOTHIRDQUARTILE:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.THIRD_QUARTILE ) );
					
					break;
				}
				case VPaidEvent.VIDEOCOMPLETE:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.COMPLETE ) );
					
					break;
				}
				case VPaidEvent.USERACCEPTINVITATION:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.ACCEPT_INVITATION ) );
					
					break;
				}
				case VPaidEvent.USERCLOSE:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.CLOSE ) );
					
					break;
				}
				case VPaidEvent.USERMINIMIZE:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.USER_MINIMIZE ) );
					
					break;
				}
				case VPaidEvent.PAUSED:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.PAUSE ) );
					
					break;
				}
				case VPaidEvent.PLAYING:
				{
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.RESUME ) );
					
					break;
				}
				case VPaidEvent.CLICKTHRU:
				{
					this.dispatchEvent( new AdEvent( AdEvent.CLICK, event.data ) );
					
					break;
				}
			}
		}
		
		protected function onAdError( event:Object ) :void
		{
//			trace( this + " onAdError: " + event.data.message );
			
			this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, event.data.message ) );
		}
		
		protected function onAdLoaded( event:Object ) :void
		{
//			trace( this + " onAdLoaded" );
			
			this.stopTimeout();			
			this.vpaidInitialized = true;			
			this.startAd();
		}
		
		protected function onAdStarted( event:Object ) :void
		{
//			trace( this + " onAdStarted" );
			
			this.stopTimeout();
			
			this.dispatchEvent( new ControlEvent( ControlEvent.LOADERANI_CHANGE, { visible:false } ) );
			
			if( this.adPlacement != VastDefines.ADTYPE_OVERLAY )
			{
				this.playerView.showBackground( true );
				// this.controlsView.showAdControls( true, this.adPlacement );
			}
			
			if( this.vpaid.adLinear )
			{
				this.onAdLinearChanged( event );
			}
			
			// start duration timer
			if( this.adDuration > 0 )
			{
				this.hideTimer.stop();
				this.hideTimer.delay = this.adDuration * 1000;
				this.hideTimer.start();
			}
		}
		
		protected function onAdStopped( event:Object ) :void
		{
//			trace( this + " onAdStopped" );
			
			this.playerView.removeOverlay();
			this.playerView.showBackground( false );
			this.stopTimeout();
			this.hideTimer.stop();
			this.resetWrapper();
			
			this.dispatchEvent( new AdEvent( AdEvent.FINISH ) );
		}
		
		/**
		 * this event is mis-used by sevenone to enable custom tracking
		 * the data property is said to be always a string, and not an object with message property as the documentation says
		 * be careful on the data, it may still be an object, or even number instead of string
		 */
		protected function onAdLog( event:Object ) :void
		{
//			trace( this + " ADLOG: " + event.data );
			
			var info:String = "";
			
			info = event.data;
						
			if( info != null && info != "" )
			{
				this.dispatchEvent( new AdEvent( AdEvent.TRACK_CUSTOM, info ) );
			}
		}
		
		protected function onAdLinearChanged( event:Object ) :void
		{
//			trace( this + " onAdLinearChanged" );
			
			if( this.vpaid.adLinear == this.currentLinearState )
			{
				return;
			}
			
			this.currentLinearState = this.vpaid.adLinear;
			
			if( this.vpaid.adLinear )
			{
				// this.controlsView.showAdControls( true, VastDefines.ADTYPE_OVERLAY );
				// this.controlsView.updateTime( 0 );
				// this.controlsView.updatePlayProgress( 0 )
				// this.controlsView.setDuration( isNaN( this.vpaid.adRemainingTime ) ? 0 : this.vpaid.adRemainingTime );
				// this.controlsView.enableSeeking( false );
				
				this.playerView.showBackground( true );
				
				this.dispatchEvent( new AdEvent( AdEvent.LINEAR_START ) );
			}
			else
			{
				this.dispatchEvent( new AdEvent( AdEvent.LINEAR_STOP ) );
			}
		}
		
		protected function onAdRemainingTimeChanged( event:Object ) :void
		{
//			trace( this + " onAdRemainingTimeChanged" );
			
			/*if( this.vpaid.adLinear )
			{
				this.controlsView.setDuration( this.vpaid.adRemainingTime );
			}*/
		}
		
		protected function onHideTimer( event:TimerEvent ) :void
		{
			this.hideTimer.stop();
			this.stopAd();
		}
	}
}