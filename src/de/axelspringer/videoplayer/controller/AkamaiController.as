


package de.axelspringer.videoplayer.controller
{
	import com.akamai.net.AkamaiConnection;
	import com.akamai.net.AkamaiDynamicNetStream;
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.Const;
	import de.axelspringer.videoplayer.model.vo.FilmVO;
	import de.axelspringer.videoplayer.model.vo.StreamingVO;
	import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.util.Log;
    import de.axelspringer.videoplayer.util.PausableTimer;
	import de.axelspringer.videoplayer.util.SessionPinger;
	import de.axelspringer.videoplayer.view.PlayerView;
	
	import flash.display.StageDisplayState;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.utils.setTimeout;
	
	import org.openvideoplayer.events.OvpError;
	import org.openvideoplayer.events.OvpEvent;
	
	public class AkamaiController extends EventDispatcher
	{
		private static const CLIP_CONTENT:String 					= "CLIP_CONTENT";
		private static const CLIP_NONE:String 						= "CLIP_NONE";

		// gui
		protected var playerView:PlayerView;
		// protected var controlsView:ControlsView;
		// protected var trackingController:TrackingController;
		
		// stream
		protected var connection:AkamaiConnection;
		protected var netstream:AkamaiDynamicNetStream;
		protected var soundTransform:SoundTransform;
		
		// midrolls
		protected var midrollTimer:PausableTimer;
		// protected var jingleController:JinglePlayerController;
		
		// data
		protected var filmVO:FilmVO;
		protected var liveVO:StreamingVO;
		protected var streamUrl:String;
		protected var streamServer:String;
		protected var streamName:String;
		protected var streamParameters:String;
		protected var streamAuthentification:String;
		protected var streamFingerprint:String;
		protected var streamSList:String;
		
		// status
		protected var isPlaying:Boolean;
		protected var isAdPlaying:Boolean;
		//protected var isJinglePlaying:Boolean;
		protected var paused:Boolean;
		protected var videoBufferEmptyStatus:Boolean;
		protected var videoBufferFlushStatus:Boolean;
		protected var videoStarted:Boolean;
		protected var videoStopped:Boolean;
		protected var duration:Number = 0;
		protected var initializingMovieStream:Boolean = false;
		protected var trackReplay:Boolean = false;
		protected var doRewind:Boolean = false;
		protected var streamStartWaiting:Boolean = false;
		protected var errorOccured:Boolean = false;
		
		// livestreams: check session periodically to avoid multiple logins
		protected var sessionPinger:SessionPinger;
		
		public function AkamaiController( playerView:PlayerView)
		{
			super( this );
			
			this.playerView = playerView;
			this.init();
		}

		protected function init() :void
		{
			this.soundTransform = new SoundTransform();

			// midrolls every 10 minutes
			this.midrollTimer = new PausableTimer( 10 * 60 * 1000 );
			this.midrollTimer.addEventListener( TimerEvent.TIMER, onMidrollTimer );

		}

		public function setMovie( filmVO:FilmVO ) :void
		{
			trace( this + " setMovie: " + filmVO.streamUrl );

			this.resetStatus();

			this.filmVO = filmVO;
			this.streamUrl = filmVO.streamUrl;
			this.parseStreamUrl( this.streamUrl );

			// preload stream to get duration
			this.initMovieStream();
		}

		/*public function startPlaying() :void
		{
			this.dispatchEvent( new ControlEvent( ControlEvent.CONTENT_START ) );

			// start jingle, movie starts automatically in onJingleFinished
			if( BildTvDefines.isTrailerPlayer )
			{
				this.playMovieJingle( this.filmVO.jingleFilePrerollTrailer, MOVIE_JINGLE_PREROLL_MOVIE );
			}
			else
			{
				this.playMovieJingle( this.filmVO.jingleFilePrerollMovie, MOVIE_JINGLE_PREROLL_MOVIE );
			}
		}*/

		public function setStream( liveVO:StreamingVO ) :void
		{
			trace( this + " setStream: " + liveVO.streamUrl );

			this.resetStatus();

			this.liveVO = liveVO;
			this.streamUrl = liveVO.streamUrl;
			this.duration = liveVO.duration;

			var videoVO:VideoVO = new VideoVO();
			videoVO.videoUrl = liveVO.streamUrl;
			videoVO.duration = liveVO.duration;
			videoVO.autoplay = liveVO.autoplay;

			this.parseStreamUrl( this.streamUrl );

			// create session pinger
			if( this.sessionPinger == null )
			{
				this.sessionPinger = new SessionPinger();
				this.sessionPinger.addEventListener( ControlEvent.SESSION_OK, onSessionOk );
				this.sessionPinger.addEventListener( ControlEvent.ERROR_SESSION, onSessionError );
			}

			this.sessionPinger.init( liveVO.pingUrl, liveVO.pingSession, liveVO.pingInterval );
		}

		public function startLivestream() :void
		{
			this.initializingMovieStream = false;
            ExternalController.dispatch(ExternalController.EVENT_WAITING, true);

			// geoblock test
//			this.onConnectionStatus( new NetStatusEvent( "", false, false, {code:"NetConnection.Connect.Rejected", description:"geoblock"} ) );

			// if we have a session check url, ping once to check session before the stream starts
			// otherwise start playing now
			if( this.sessionPinger.isInitialized )
			{
				this.streamStartWaiting = true;
				this.sessionPinger.pingOnce();
			}
			else
			{
				this.startStream();
			}
		}


        // TODO: wird nicht benutzt?
		public function onPlayPauseChange() :void
		{
			trace( this + " onPlayPauseChange - current state: " + this.playing );

			if( this.playing )
			{
				this.pause();
				// this.trackingController.onClipPause();
                ExternalController.dispatch(ExternalController.EVENT_WAITING, false);
			}
			else if( this.videoStarted )
			{
				if( this.trackReplay )
				{
					// if( BildTvDefines.debugFlag )
					// this.trackingController.onClipPlay();
				}

                ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
				this.resume();
				// this.trackingController.onClipResume();
			}
			else
			{
                ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
				this.startStream();
			}
		}

		public function onProgressChange( seekPoint:Number ) :void
		{
			trace( this + " onProgressChange - seekPoint: " + seekPoint );

			if( this.netstream != null && !isNaN( seekPoint ) )
			{
                ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
				var newTime:Number = seekPoint * this.duration;

				// set lower buffer time to enable fast video start after seeking
				this.netstream.bufferTime = Const.buffertimeMinimum;

				trace( this + " set buffertime to " + this.netstream.bufferTime );

				this.netstream.seek( newTime );
				//this.playerView.chapterList.updateTime( newTime );
			}
		}

		public function setVolume( volume:Number ) :void
		{
			// this.controlsView.setVolume( volume );
			this.soundTransform.volume = volume;

			if( this.netstream != null )
			{
				this.netstream.soundTransform = this.soundTransform;
			}
		}

		public function pause( track:Boolean = true ) :void
		{
			this.paused = true;

			if( this.videoStarted )
			{
				this.netstream.pause();
				this.playing = false;

				if( Const.isMoviePlayer && !Const.isTrailerPlayer )
				{
					this.midrollTimer.pause();
				}
			}
		}

		public function resume() :void
		{
			if( this.videoStarted )
			{
				this.paused = false;
//				this.playing = true;

				// set lower buffer here to enable fast video start after pause
                this.netstream.bufferTime = Const.buffertimeMinimum;

				trace( this + " set buffertime to " + this.netstream.bufferTime );

				this.netstream.resume();
			}
		}

		public function resumeAfterMidroll() :void
		{
			// refresh clip info
			// this.controlsView.setDuration( this.duration );

			this.resume();

			// re-attach netstream
			this.playerView.display.attachNetStream( this.netstream );
		}

		public function finishPlay() :void
		{
			trace( this + " finishPlay" );

			// minimize in case of fullscreen
			if( this.playerView.display.stage.displayState == StageDisplayState.FULL_SCREEN )
			{
				this.playerView.display.stage.dispatchEvent( new Event( Event.RESIZE ) );
			}

			if( Const.isMoviePlayer )
			{
				// this.playMovieJingle( filmVO.jingleFilePostroll, MOVIE_JINGLE_POSTROLL );
			}
			else	// streamplayer
			{
				// livestreams
				if( Const.isLivePlayer )
				{
					// this.controlsView.enable( false );
					// this.playerView.setDisplayButtonVisible( false );
				}
				// vod
				else
				{
					this.rewindStream( 0 );
				}
			}
		}

		public function set adPlaying( value:Boolean ) :void
		{
			this.isAdPlaying = value;
		}

		protected function set playing( value:Boolean ) :void
		{
			this.isPlaying = value;
		}

		protected function get playing() :Boolean
		{
			return this.isPlaying;
		}

		/**
		 * start and stop stream to get duration
		 */
		protected function initMovieStream() :void
		{
			trace( this + " initMovieStream" );

			this.initializingMovieStream = true;

			this.startStream();
		}

		protected function startStream() :void
		{
			trace( this + " startStream" );
			trace( this + " ---> server: " + this.streamServer );
			trace( this + " ---> parameters: " + this.streamParameters );

			if( !this.initializingMovieStream )
			{
				this.playing = true;
				this.paused = false;
				// this.controlsView.setDuration( this.duration );
				// this.controlsView.updateTime( 0 );
				// this.controlsView.updatePlayProgress( 0 );

				/*if( BildTvDefines.isMoviePlayer && this.filmVO.chapters.length > 1 )
				{
					this.playerView.createChapterlist( this.filmVO.chapters );
				}*/
				if( Const.isLivePlayer )
				{
					// this.controlsView.enableSeeking( false );
				}
			}

			this.connection = new AkamaiConnection();
			this.connection.addEventListener( NetStatusEvent.NET_STATUS, onConnectionStatus );
			this.connection.addEventListener( OvpEvent.ERROR, onError );
			this.connection.requestedPort = "any";
			this.connection.requestedProtocol = "rtmpe,rtmpte";

			if( this.streamParameters != "" )
			{
			    this.connection.connectionAuth = this.streamParameters;
			}

			this.connection.connect( this.streamServer );
		}

		/**
		 * rewinds the stream first and then updates the display with the first frame
		 */
		protected function rewindStream( toPosition:Number ) :void
		{
			trace( this + " rewindStream to " + toPosition );

			// re-attach netstream
			this.playerView.display.attachNetStream( null );
			this.playerView.display.attachNetStream( this.netstream );

			this.netstream.seek( toPosition );
			this.netstream.resume();

			this.trackReplay = true;
		}

		protected function onConnectionStatus( e:NetStatusEvent ):void
		{
			trace( this + " onConnectionStatus: " + e.info.code );

			switch( e.info.code )
			{
				case "NetConnection.Connect.Success":
				{
					this.onConnectionConnect();

					break;
				}
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Refused":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Closed":
				{
					if( Const.isStreamPlayer )
					{
						this.onLivestreamError( e );
					}
					else
					{
						this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, e.info.code ) );
					}

					break;
				}
			}
        }

        protected function onConnectionConnect() :void
		{
			trace( this + " onConnectionConnect" );

			this.netstream = new AkamaiDynamicNetStream( this.connection );
			this.netstream.bufferTime = Const.buffertimeMinimum;

			trace( this + " set buffertime to " + this.netstream.bufferTime );

			this.netstream.addEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus );
			this.netstream.addEventListener( OvpEvent.ERROR, onError );
			this.netstream.addEventListener( OvpEvent.COMPLETE, onStreamFinished );
			this.netstream.addEventListener( OvpEvent.NETSTREAM_METADATA, onMetaData );
			this.netstream.createProgressivePauseEvents = true;

			// initializing?
			if( this.initializingMovieStream )
			{
				var muteSound:SoundTransform = new SoundTransform();
				muteSound.volume = 0;
				this.netstream.soundTransform = muteSound;
			}
			else
			{
				this.netstream.soundTransform = this.soundTransform;

				this.playerView.display.attachNetStream( null );
				this.playerView.display.attachNetStream( this.netstream );
			}

            ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
			this.netstream.play( this.streamName, 0 );
		}

        protected function onMetaData( e:OvpEvent ):void
		{
			trace( this + " onMetaData" );
			trace( e.data );

			// check ratio
			var ratio:Number = 16 / 9;

			if( e.data.width != null && e.data.height != null )
			{
				ratio = parseFloat( e.data.width ) / parseFloat( e.data.height );
			}

			this.playerView.setVideoRatio( ratio );

			// check duration
			if( e.data.duration != null )
			{
				this.duration = Number( e.data.duration );
				if( !this.initializingMovieStream )
				{
					// this.controlsView.setDuration( this.duration );
				}
			}

			if( this.initializingMovieStream )
			{
				this.netstream.close();
				this.connection.close();
				this.initializingMovieStream = false;

				// set tracking info here because now we have the duration
				var videoVO:VideoVO = new VideoVO();
				videoVO.videoUrl = this.filmVO.streamUrl;
				videoVO.duration = this.duration;
				videoVO.autoplay = true;
				// this.trackingController.setClip( videoVO, this.filmVO.trackingVO );

				// track playClick

				/*if( BildTvDefines.debugFlag )
				this.trackingController.onClipPlay();*/
			}
		}

        protected function onNetStreamStatus( e:NetStatusEvent ):void
		{
			trace( this + " onNetStreamStatus: " + e.info.code );

			var bufferTime:uint;

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
					this.netstream.bufferTime = Const.buffertimeMinimum;

					trace( this + " set buffertime to " + this.netstream.bufferTime );
                    ExternalController.dispatch(ExternalController.EVENT_SEEKED);

					break;
				}
				case "NetStream.Buffer.Full":
				{
					this.videoBufferEmptyStatus = false;

                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

					// set higher buffer now to enable constant playback
					this.netstream.bufferTime = Const.buffertimeMaximum;

					trace( this + " set buffertime to " + this.netstream.bufferTime );

					break;
				}
				case "NetStream.Buffer.Empty":
				{
					this.videoBufferEmptyStatus = true;
					if( !this.videoBufferFlushStatus )
					{
                        ExternalController.dispatch(ExternalController.EVENT_WAITING, true);

						// set lower buffer here to enable fast video start
                        this.netstream.bufferTime = Const.buffertimeMinimum;

						trace( this + " set buffertime to " + this.netstream.bufferTime );
					}

                    ExternalController.dispatch(ExternalController.EVENT_EMPTIED);

					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "NetStream.Play.StreamNotFound" ) );

					break;
				}
				case "NetStream.Play.Start":
				{
					this.onStreamStarted();
                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

					break;
				}
				case "NetStream.Play.Stop":
				{
					this.videoStopped = true;

					break;
				}
				case "NetStream.Failed":
				case "NetStream.Play.Failed":
				{
					this.onLivestreamError( e );

					break;
				}
			}

			// check for clip end
//			trace(this + " this.videoStopped == " + this.videoStopped + " || this.videoBufferEmptyStatus == " + this.videoBufferEmptyStatus  + " || this.videoBufferFlushStatus == " + this.videoBufferFlushStatus);

			// if stopped, check buffer stati for OnDemandStreams
			// for LiveStreams, this is the end
			if( this.videoStopped == true &&
					( ( this.videoBufferEmptyStatus == true && this.videoBufferFlushStatus == true && !this.paused )
					||
					( Const.isStreamPlayer && this.playing ) )
				)
			{
				this.onStreamFinished();
			}
		}

		protected function onVideoEnterFrame( e:Event ):void
		{
			//trace( "progress: " + this.netstream.time );

			if( this.paused )
			{
				return;
			}

			// this.controlsView.updateTime( this.netstream.time );
			// this.trackingController.updatePlayProgress( this.netstream.time );
            ExternalController.dispatch(ExternalController.EVENT_TIMEUPDATE, this.netstream.time);

			if( this.duration > 0 )
			{
				var progress:Number = this.netstream.time / this.duration;

				// this.controlsView.updatePlayProgress( progress );
				//this.playerView.chapterList.updateTime( this.netstream.time );
			}
		}

		protected function onStreamStarted() :void
		{
			if( this.initializingMovieStream )
			{
				return;
			}

			// for refreshing the display after the rewind, stream should start in pause mode and then stop
			if( this.paused )
			{
				setTimeout( this.netstream.pause, 200 );

				// if teaser, rewind now
				if( this.doRewind )
				{
					this.doRewind = false;
					setTimeout( this.netstream.seek, 300, 0 );
				}

				return;
			}

			if( !this.videoStarted || this.trackReplay )
			{
				// this.trackingController.onClipStart();
                ExternalController.dispatch(ExternalController.EVENT_PLAYING);
				this.trackReplay = false;
			}

			this.resetStatus();
			this.videoStarted = true;

			// start midroll timer
			if( Const.isMoviePlayer && !Const.isTrailerPlayer )
			{
				this.midrollTimer.start();
			}

			if( ! this.playerView.display.hasEventListener( Event.ENTER_FRAME ) )
			{
				this.playerView.display.addEventListener( Event.ENTER_FRAME, onVideoEnterFrame, false, 0, true );
			}

			this.playing = true;
		}

        protected function onStreamFinished( e:Event = null ) :void
		{
			trace( this + " onStreamFinished" );

			this.playerView.display.removeEventListener( Event.ENTER_FRAME, onVideoEnterFrame, false );

			this.pause( false );

			this.midrollTimer.stop();

			if( Const.isStreamPlayer )
			{
				// stop session pinger
				if( this.sessionPinger != null )
				{
					this.sessionPinger.stop();
				}
			}

			if( ! this.errorOccured )
			{
                ExternalController.dispatch(ExternalController.EVENT_ENDED);
			}
		}

        protected function resetStatus() :void
		{
			this.videoStarted = false;
			this.videoBufferEmptyStatus = false;
			this.videoBufferFlushStatus = false;
			this.videoStopped = false;
			this.paused = false;
			this.errorOccured = false;
		}

        protected function onError( e:Event ):void
		{
			if( !this.initializingMovieStream )
			{
				Log.error( this + " onError: " + e.type );

				if( e is ErrorEvent )
				{
					Log.error( this + " error info: " + ErrorEvent( e ).text );
				}
				else if( e is OvpEvent )
				{
					Log.error( this + " error info: " + OvpError( OvpEvent( e ).data ).errorDescription );
				}

				this.errorOccured = true;
			}
		}

		protected function onLivestreamError( e:NetStatusEvent ) :void
		{
			Log.error( this + " onLivestreamError: " + e.info.code + ", description: " + e.info.description );

			// stop session pinger
			if( this.sessionPinger != null && !this.liveVO.pingDebug )
			{
				this.sessionPinger.stop();
			}

			this.errorOccured = true;
		}

		protected function parseStreamUrl( url:String ) :void
		{
			// on demand:
			// rtmpte://cp100638.edgefcs.net/ondemand/mp4:secure/flash/16195/16195_38427.mp4?auth=daEdtd.d2b_b7d8aHcTajb.ambTdcd5dvau-bnnfOo-4q-4qounWmBCF1noFFn7Bzotvs&aifp=v001&slist=secure/flash/16195/16195_38427

			var index:Number = url.indexOf( "://" );
			url = url.substring( index + 3 );
			index = url.indexOf( "/", url.indexOf( "/" ) + 1 );

			this.streamServer = url.substring( 0, index );

			var file:String = url.substring( index + 1 );

			// default values without authentification - if authentifications is used they will be overwritten
			this.streamName = file;
			this.streamParameters = "";
			this.streamAuthentification = "";
			this.streamFingerprint = "";
			this.streamSList = "";

			index = file.indexOf( "?" );

			if( index > -1 )
			{
				this.streamName = file.substring( 0, index );
				this.streamParameters = file.substring( index + 1 );
				var paramArray:Array = this.streamParameters.split( "&" );
				var param:String;

				for( var i:uint = 0; i < paramArray.length; i++ )
				{
					param = paramArray[i];
					if( param.substring( 0, 5 ) == "auth=" )
					{
						this.streamAuthentification = param.substring( 5 );
					}
					if( param.substring( 0, 5 ) == "aifp=" )
					{
						this.streamFingerprint = param.substring( 5 );
					}
					if( param.substring( 0, 6 ) == "slist=" )
					{
						this.streamSList = param.substring( 6 );
					}
				}
			}

			if( this.streamParameters != "" )
			{
				this.streamName = this.streamName + "?" + this.streamParameters;
			}
		}

		protected function onChapterChange( e:ControlEvent ) :void
		{
			trace( this + " onChapterChange - seekPoint: " + e.data.seekPoint );

			// event's seekpoint is in seconds, convert to ratio number to use the onProgressChange handler
			var seekPoint:Number = e.data.seekPoint / this.duration;
			this.onProgressChange( seekPoint );

			// play midroll
			this.onMidrollTimer( null );
		}

		protected function onMidrollTimer( event:TimerEvent ) :void
		{
			trace( this + " onMidrollTimer" );

			this.midrollTimer.stop();
		}

		protected function playMovieJingle( url:String, type:String ) :void
		{
			trace( this + " playMovieJingle: " + url + ", type: " + type );

			// pause stream
			this.pause( false );
		}

		protected function forwardEvent( event:Event ) :void
		{
			this.dispatchEvent( event.clone() );
		}
		
/////////////////////////////////////////////////////////////////////////////////////////
// external callbacks
/////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * for MoviePlayer
		 */
		protected function externalPlay() :void
		{
            this.resume();
		}
		
		/**
		 * for MoviePlayer
		 */
		protected function externalPause() :void
		{
            this.pause( false );
		}
		
		/**
		 * for LivePlayer
		 */
		protected function gameOver() :void
		{
			trace( this + " gameOver" );
			
			if( this.playing )
			{
				this.onStreamFinished();
			}
			else if( !this.isAdPlaying )
			{
				this.finishPlay();
			}
		}
		
		protected function onSessionError( event:ControlEvent ) :void
		{
			Log.error( this + " onSessionError" );
			
			this.streamStartWaiting = false;
			
			this.playerView.display.removeEventListener( Event.ENTER_FRAME, onVideoEnterFrame, false );
			
			this.pause( false );

            ExternalController.dispatch(ExternalController.EVENT_WAITING, false);
			
			// dispatch error event to show error view in MainController
			// use text from XML, if present, otherwise use fallback text from BildTvDefines
			var text:String = ( this.liveVO.pingText != null && this.liveVO.pingText.split( " " ).join("") != "" ) ? this.liveVO.pingText : Const.ERROR_SESSION_INFO;
		}
		
		protected function onSessionOk( event:ControlEvent ) :void
		{
			trace( this + " onSessionOk" );
			
			if( this.streamStartWaiting )
			{
				this.streamStartWaiting = false;
				
				// start session pinger
				this.sessionPinger.start();
				
				// go!
				this.startStream();
			}
		}
		
		/**
		 * for testing only
		 */
		protected function stopStream() :void
		{
			trace( this + " +++++++++++++++ stopStream" );
			
			if( this.netstream != null )
			{
				setTimeout( this.netstream.close, 2000 );
				//this.netstream.close();
			}
		}
	}
}