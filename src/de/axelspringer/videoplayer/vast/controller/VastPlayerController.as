package de.axelspringer.videoplayer.vast.controller
{
	import de.axelspringer.videoplayer.controller.PlayerController;
	import de.axelspringer.videoplayer.event.AdEvent;
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.FullscreenData;
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEventType;
	import de.axelspringer.videoplayer.vast.view.VastPlayerView;
	import de.axelspringer.videoplayer.vast.vo.VastMedium;
	import de.axelspringer.videoplayer.vast.vo.VastNonLinear;
	import de.axelspringer.videoplayer.view.ControlsView;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	[Event(name="loaderaniChange", type="de.axelspringer.videoplayer.event.ControlEvent")]
	[Event(name="error", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="finish", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="click", type="de.axelspringer.videoplayer.event.AdEvent")]
	
	public class VastPlayerController extends EventDispatcher
	{
		private static const CHECK_END_TIMER_INTERVAL:Number = 500;
		
		// gui
		protected var playerView:VastPlayerView;
		protected var controlsView:ControlsView;
		
		// netstream stuff
		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var soundTransform:SoundTransform;

		// stream status
//		protected var videoStarted:Boolean=false;
		protected var videoStopped:Boolean=false;
		protected var videoLastTime:Number = 0;
		protected var videoBufferEmptyStatus:Boolean = false;
		protected var videoBufferFlushStatus:Boolean = false;
		protected var checkEndOfVideoTimer:Timer;
		
		// data
		protected var videoFile:String;
		protected var duration:Number;
		protected var adType:String;
		protected var nonLinear:VastNonLinear;
		protected var _savedVolume:Number=0;
		
		// stuff
		protected var loader:Loader;
		protected var loadTimer:Timer;
		
		// for external pause (movieplayer only)
		protected var paused:Boolean = false;
		protected var started:Boolean = false;
		
		public function VastPlayerController( playerView:VastPlayerView, controlsView:ControlsView )
		{
			super( this );
			
			this.playerView = playerView;
			this.controlsView = controlsView;
			
			this.initPlayer();
		}
		
		protected function initPlayer() :void
		{
			this.nc = new NetConnection();
			this.nc.addEventListener( NetStatusEvent.NET_STATUS, onNetConnectionStatus );
			this.nc.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
			this.nc.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onError );
			this.nc.addEventListener( IOErrorEvent.IO_ERROR, onError );
			
			//checkEndOfVideoTimer init
			this.checkEndOfVideoTimer = new Timer( CHECK_END_TIMER_INTERVAL );
			this.checkEndOfVideoTimer.addEventListener( TimerEvent.TIMER, checkEndOfVideo );
		
			var client:Object = new Object();
			client.onBWCheck = this.emptyCallback;
			client.onBWDone = this.emptyCallback;
			this.nc.client = client;
			
			this.soundTransform = new SoundTransform();
			
			this.playerView.addEventListener( AdEvent.CLICK, onDisplayClick );
			/*if(BildTvDefines.isSingleVastPlayer)
			{
				this.controlsView.addEventListener( ControlEvent.PLAYPAUSE_CHANGE, onPlayPauseChange );
				this.controlsView.addEventListener(ControlEvent.PROGRESS_CHANGE, onProgressChange);	
			}*/
			this.playerView.addEventListener( AdEvent.TRACK, onTrackAd );

			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onError, false, 0, true );
			this.loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true );
			this.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onNonLinearLoadComplete, false, 0, true );
			
			this.loadTimer = new Timer( VastDefines.LOADER_TIMEOUT, 1 );
			this.loadTimer.addEventListener( TimerEvent.TIMER, onNonLinearLoadTimeout );
		}
		
		protected function onNetConnectionStatus( e:NetStatusEvent ):void
		{
//			trace( this + " onNetConnectionStatus: " + e.info.code );
			
			switch( e.info.code )
			{
				case "NetConnection.Connect.Success":
				{
					this.onNetConnectionConnect();
					
					break;
				}
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Refused":
				case "NetConnection.Connect.Failed":
				{
					setTimeout( onNetConnectionFail, 100 );
					
					break;
				}
			}	
        }
        
///////////////////////////////////////////////////////////////////////////////////////////////////////
// STREAM EVENTS HANDLER
///////////////////////////////////////////////////////////////////////////////////////////////////////

		protected function onNetConnectionConnect() :void
		{
//			trace( this + " onNetConnectionConnect" );
			
			this.ns = new NetStream( this.nc );
			this.ns.soundTransform = this.soundTransform;
			this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
			
			trace( this + " set buffertime to " + this.ns.bufferTime );
			
			var metaHandler:Object = new Object();
			metaHandler.onMetaData = this.onMetaData;
			this.ns.client = metaHandler;
			
			this.ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus, false, 0, true );
			
			this.playerView.display.attachNetStream( this.ns );
			
			// play!
			if( !this.paused )
			{
				this.started = true;
				this.dispatchEvent( new ControlEvent( ControlEvent.LOADERANI_CHANGE, { visible:true, stream:this.ns } ) );
				this.ns.play( this.videoFile );
				this.checkEndOfVideoTimer.start();
			}
		}
		
		protected function onNetConnectionFail() :void
		{
//			trace( this + " onNetConnectionFail" );
			
			this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "NetConnection failed" ) );
		}
		
		protected function onMetaData( data:Object ):void
		{
//			trace( this + " onMetaData" );
//			trace( data );
			
			// check ratio
			var ratio:Number = 16 / 9;
			
			if( data.width != null && data.height != null )
			{
				ratio = parseFloat( data.width ) / parseFloat( data.height );
			}
			
			this.playerView.setVideoRatio( ratio );
			
			// check duration
			if( data.duration != null )
			{
				this.duration = Number( data.duration );
				this.controlsView.setDuration( this.duration );
				this.controlsView.updateTime( this.ns.time );
			}
		}
		
		protected function onNetStreamStatus( e:NetStatusEvent ):void
		{
//			trace( this + " onNetStreamStatus: " + e.info.code );
			
			switch( e.info.code )
			{
				case "NetStream.Buffer.Flush":
				{
					this.videoBufferFlushStatus = true;
					break;
				}
				case "NetStream.Seek.Notify":
				{
					this.videoBufferEmptyStatus = false;
					
					// set lower buffer here to enable fast video start after pause
					this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
					
					trace( this + " set buffertime to " + this.ns.bufferTime );
						
					break;
				}
				case "NetStream.Buffer.Full":
				{
					this.videoBufferEmptyStatus = false;
					
					this.dispatchEvent( new ControlEvent( ControlEvent.LOADERANI_CHANGE, { visible:false } ) );
					
					// set higher buffer now to enable constant playback
					this.ns.bufferTime = BildTvDefines.buffertimeMaximum;
					
					trace( this + " set buffertime to " + this.ns.bufferTime );
					
					break;
				}
				case "NetStream.Buffer.Empty":
				{
					this.videoBufferEmptyStatus = true;
					if( !this.videoBufferFlushStatus )
					{
						this.dispatchEvent( new ControlEvent( ControlEvent.LOADERANI_CHANGE, { visible:true, stream:this.ns } ) );
						
						// set lower buffer here to enable fast video start
						this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
						
						trace( this + " set buffertime to " + this.ns.bufferTime );
					}
					
					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "StreamNotFound" ) );
					
					break;
				}
				case "NetStream.Play.Start":
				{
//					this.videoStarted = true;
					this.videoStopped = false;
					this.videoBufferEmptyStatus = false;
					this.videoBufferFlushStatus = false;
					
//					this.controlsView.setPlayingStatus( true );
					this.videoLastTime = 0;
					
					if( !this.playerView.display.hasEventListener( Event.ENTER_FRAME ) )
					{
						this.playerView.display.addEventListener( Event.ENTER_FRAME, onVideoEnterFrame, false, 0, true );
					}
					
					// track
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.START ) );
					
					break;
				}
				case "NetStream.Play.Stop":
				{
					this.videoStopped = true;
					
//					this.controlsView.setPlayingStatus( false );
					
					break;
				}
			}
		}
		
		protected function emptyCallback( ...args ) :void
		{
			// nix drin
		}
		
		protected function onError( e:ErrorEvent ) :void
		{
			trace( this + " onError: " + e.type + ", " + e.text );
			
			this.started = false;
			this.dispatchEvent( new AdEvent( AdEvent.ERROR, e.text ) );
			
			this.loadTimer.stop();
		}
		
		protected function checkEndOfVideo( event:TimerEvent ) :void
		{
			var timeHasntChanged:Boolean = (this.ns.time == this.videoLastTime);
			
			if( this.videoStopped == true && this.videoBufferFlushStatus == true && /*this.videoPaused == false &&*/ timeHasntChanged == true)
			{
				this.videoStopped = false;
				this.videoBufferEmptyStatus = false;
				this.videoBufferFlushStatus = false;
				this.controlsView.removeEventListener( ControlEvent.PLAYPAUSE_CHANGE, onPlayPauseChange );
				this.playerView.display.removeEventListener( Event.ENTER_FRAME, onVideoEnterFrame, false );
				this.ns.removeEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus, false );
				
				this.checkEndOfVideoTimer.stop();
				
				this.finishPlay();
			}
		}
		
		protected function onVideoEnterFrame( e:Event ) :void
		{
			if( true)//this.ns.time > this.videoLastTime )
			{
				
				this.videoLastTime = this.ns.time;
				
				//trace( "progress: " + this.ns.time );
				
				this.controlsView.updateTime( this.ns.time );
//				this.trackingController.updatePlayProgress( this.ns.time );
				
				if( this.duration > 0 )
				{
					var progress:Number = this.ns.time / this.duration;
					//trace(this + " progress in Vast: " + progress + ":::" + this.ns.time + "::" + this.duration);
					this.controlsView.updatePlayProgress( progress );
					
					// track
					this.dispatchEvent( new AdEvent( AdEvent.PROGRESS, progress ) );
				}
			}
		}
		
		protected function onProgressChange(e:ControlEvent):void
		{
			trace(this + " onProgressChange - seekPoint: " + e.data.seekPoint);
			
			/*if( BildTvDefines.isSingleVastPlayer == false )
			{
				return;
			}
			// seeking is allowed for akamai streams if they are movies (Movieplayer) or VOD (StreamPlayer)
			// livestreams are StreamPlayer too, but seeking is not active, so we should never get here in that case 
			if (this.ns != null )
			{
			// set lower buffer time to enable fast video start after seeking
				this.ns.bufferTime=BildTvDefines.buffertimeMinimum;
						
				trace(this + " set buffertime to " + this.ns.bufferTime);
						
				var newTime:Number=e.data.seekPoint * this.duration;
				this.ns.seek(newTime);		
			}*/
		}
		
		protected function onPlayPauseChange(e:ControlEvent):void
		{
			//if( !BildTvDefines.isSingleVastPlayer ) return;
			if ( this.paused == false )
			{
				this.dispatchEvent(new ControlEvent(ControlEvent.LOADERANI_CHANGE, {visible: false}));
				this.pause();
			}
			else if ( this.started )
			{
				
				this.dispatchEvent(new ControlEvent(ControlEvent.LOADERANI_CHANGE, {visible: true, stream: this.ns}));
				
				this.resume();
			}
			else
			{
				this.play();
			}
		}
		
		protected function play() :void
		{
			this.controlsView.enableSeeking( false );
			//this.controlsView.enableSeeking( BildTvDefines.isSingleVastPlayer );
			
			// refresh clip info
			this.controlsView.setDuration( this.duration );
			this.controlsView.updateTime( 0 );
			this.controlsView.updatePlayProgress( 0 );
			
			this.controlsView.showAdControls( true, this.adType );
			
			this.started = false;
			
			this.nc.connect( null );
		}
		
		protected function finishPlay() :void
		{
//			trace( this + " finishPlay" );
			
			// track
			this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.COMPLETE ) );
			this.playerView.clear();
			this.playerView.enableDisplayButton( false );
			
			this.started = false;
			
			this.dispatchEvent( new AdEvent( AdEvent.FINISH ) );
		}
		
		protected function onDisplayClick( e:AdEvent ) :void
		{
//			trace( this + " onDisplayClick" );
			
			this.dispatchEvent( e.clone() );
		}

		protected function onNonLinearLoadComplete( event:Event ) :void
		{
			this.loadTimer.stop();
			
			try
			{
				var graphic:DisplayObject = LoaderInfo( event.target ).content;
				if( graphic == null )
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "Error: could not create DisplayObject from loaded nonlinear content" ) );
				}
				else
				{
//					graphic.width = this.nonLinear.width;
//					graphic.height = this.nonLinear.height;
					this.playerView.setNonLinearSize();
					
					if( BildTvDefines.isWidgetPlayer )
					{
						var yOffset:Number = this.controlsView.controls.background.height - this.controlsView.controls.background.y + 5;
						this.playerView.overlay.y -= yOffset; 
						
					}
//					this.playerView.setNonLinear( graphic, 
//												this.nonLinear.width, 
//												this.nonLinear.height,
//												this.nonLinear.duration, 
//												this.nonLinear.scalable, 
//												this.nonLinear.minSuggestedDuration, 
//												( this.nonLinear.clickThru.url != null && this.nonLinear.clickThru.url != "" )
//												);
				}
			}
			catch( error:Error )
			{
				this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, error.message ) );
			}
			
		}
		
		protected function onNonLinearLoadTimeout( event:TimerEvent ) :void
		{
			this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "Error: nonlinear loading timed out." ) );
			try
			{
				this.loader.close();
			}
			catch( error:Error )
			{
				// ignore
			}
		}
		
		protected function onTrackAd( event:AdEvent ) :void
		{
			this.dispatchEvent( event.clone() );
		}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// PUBLIC
///////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function playAd( medium:VastMedium, duration:Number, placement:String ) :void
		{
			
			
				if(medium.url.indexOf("1_sek.flv") != -1) 
				{
					trace("ungültig");
					// track
					this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.START ) );
					this.dispatchEvent( new AdEvent( AdEvent.ERROR, "0 Sekunden Clip" ) );
				}
				else
				{
					this.playerView.removeOverlay();
					this.videoFile = medium.url;
					this.duration = isNaN(duration)? 0:duration;
					this.adType = placement;
					this.play();	
				}
		}
		
		public function setNonLinearAd( nonLinear:VastNonLinear ) :void
		{
			this.nonLinear = nonLinear;
			this.enableDisplayButton( false );
			trace(this + "Click URL:" + this.nonLinear.clickThru.url);
			
			try
			{
				// add overlay here because later it's not allowed for AVM 1 content
				this.playerView.setNonLinear( this.loader, 
												this.nonLinear.width, 
												this.nonLinear.height,
												this.nonLinear.duration, 
												this.nonLinear.scalable, 
												this.nonLinear.minSuggestedDuration, 
												( this.nonLinear.clickThru.url != null && this.nonLinear.clickThru.url != "" )
												);
				
				this.loadTimer.stop();
				if( BildTvDefines.debugFlag ) //ExternalInterface.call("function(){if (window.console) console.log('"+this+" load Overlay from "+nonLinear.staticResource+"');}");
				if( BildTvDefines.debugFlag ) //ExternalInterface.call("function(){if (window.console) console.log('----------------------------------------------------------------------');}");
					trace(this + " " + nonLinear.staticResource);
				this.loader.load( new URLRequest( nonLinear.staticResource ), new LoaderContext( true, new ApplicationDomain(), SecurityDomain.currentDomain ) );				
				this.loadTimer.start();
				
				if( BildTvDefines.isWidgetPlayer )
				{
					var yOffset:Number = this.controlsView.controls.background.height - this.controlsView.controls.background.y + 10;
					this.playerView.overlay.y -= yOffset; 
					
				}
			}
			catch( error:Error )
			{
				this.dispatchEvent( new AdEvent( AdEvent.ERROR, error.message ) );
			}
		}
		
		public function showDisplay( show:Boolean ) :void
		{
			this.playerView.showDisplay( show );
		}
		
		public function showOverlay( show:Boolean ) :void
		{
			if( !show )
			{
				this.playerView.removeOverlay();
			}
		}
		
		public function setSize( size:Rectangle, fullscreenData:FullscreenData ) :void
		{
			this.playerView.setSize( size, fullscreenData );
		}
		
		public function setVolume( volume:Number ) :void
		{
			trace( this +  " setVolume: " + volume );
			
			this._savedVolume = this.soundTransform.volume;
			this.soundTransform.volume = volume;
			
			if( this.ns != null )
			{
				this.ns.soundTransform = this.soundTransform;
			}
		}
		
		public function enableDisplayButton( enable:Boolean ) :void
		{
			this.playerView.enableDisplayButton( enable );
		}
		
		public function pause() :void
		{
			/*this.paused = true;
			
			if( this.checkEndOfVideoTimer != null )
			{
				this.checkEndOfVideoTimer.stop();
			}
			
			if( this.ns != null )
			{
				this.ns.pause();
			}
			this.controlsView.setPlayingStatus(false);*/
			//this.controlsView.enable(true);
			//this.controlsView.showAdControls( false );
			//this.controlsView.updateTime( 0 );
			//this.controlsView.setDuration( 0 );
		}
		
		public function resume() :void
		{
			this.paused = false;
			
			if( this.ns != null )
			{
				// set lower buffer here to enable fast video start after pause
				this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
				
				trace( this + " set buffertime to " + this.ns.bufferTime );
				
				if( this.started )
				{
					this.ns.resume();
				}
				else
				{
					this.started = true;
					this.ns.play( this.videoFile );
				}
				
				this.checkEndOfVideoTimer.start();
				
				this.controlsView.showAdControls( true, this.adType );
				this.controlsView.setDuration( this.duration );
			}
		}
		
		/**
		 * shows if an ad is currently in playback, regardless of paused state
		 */
		public function get isPlaying() :Boolean
		{
			return this.started;
		}
		
		public function get savedVolume() :Number
		{
			return this._savedVolume;
		}
	}
}