package de.axelspringer.videoplayer.controller
{
	//import com.akamai.hd.HDNetStream;
	//import com.akamai.hd.HDNetStream;
    import com.akamai.net.f4f.ZStream;

    import de.axelspringer.videoplayer.event.AdEvent;
    import de.axelspringer.videoplayer.event.ControlEvent;
    import de.axelspringer.videoplayer.event.XmlEvent;
    import de.axelspringer.videoplayer.model.vo.AdVO;
    import de.axelspringer.videoplayer.model.vo.BildTvDefines;
    import de.axelspringer.videoplayer.model.vo.ConfigVO;
    import de.axelspringer.videoplayer.model.vo.FilmVO;
    import de.axelspringer.videoplayer.model.vo.FullscreenData;
    import de.axelspringer.videoplayer.model.vo.StreamingVO;
    import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.util.Log;
    import de.axelspringer.videoplayer.util.XmlLoader;
    import de.axelspringer.videoplayer.vast.VastController;
    import de.axelspringer.videoplayer.vast.VastDefines;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.events.AsyncErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.media.SoundTransform;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.navigateToURL;
    import flash.utils.Timer;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;

    //import de.axelspringer.videoplayer.model.vo.TrackingVO;
//	import de.axelspringer.videoplayer.view.SubtitleView;

    public class PlayerController extends EventDispatcher
	{
		private static const CLIP_BUMPER_PREROLL:String="CLIP_BUMPER_PREROLL";
		private static const CLIP_BUMPER_POSTROLL:String="CLIP_BUMPER_POSTROLL";
		private static const CLIP_CONTENT:String="CLIP_CONTENT";
		private static const CLIP_NONE:String="CLIP_NONE";
		private static const TIMER_DELAY:Number=500;

		// movieplayer only
		private static const MOVIE_JINGLE_PREROLL_MOVIE:String="MOVIE_JINGLE_PREROLL_MOVIE";
		private static const MOVIE_JINGLE_PREROLL_TRAILER:String="MOVIE_JINGLE_PREROLL_TRAILER";
		private static const MOVIE_JINGLE_MIDROLL:String="MOVIE_JINGLE_MIDROLL";
		private static const MOVIE_JINGLE_POSTROLL:String="MOVIE_JINGLE_POSTROLL";
		
		// track
		//public var trackingController:TrackingController;

		// gui
		protected var playerView:PlayerView;
		//protected var controlsView:ControlsView;
		//protected var subtitleView:SubtitleView;

		// netstream stuff
		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var soundTransform:SoundTransform;

		//protected var hdRenderer:HDVideoRenderer;
		protected var nsHD:ZStream;
		// data
		protected var videoVO:VideoVO;
		protected var videoUrl:String;
		protected var videoSrcPosition:Number=1;
		protected var videoServer:String;
		protected var videoFile:String;
		protected var videoIsStream:Boolean;
		protected var streamConnects:uint;
		protected var adData:AdVO;
		protected var bumperVO:VideoVO;
		protected var clip2play:String;
		protected var hdContent:Boolean=false;
		protected var startBitrateSetted:Boolean=false;

		// stream status
		protected var isPlaying:Boolean=false;
		protected var videoStarted:Boolean=false;
		protected var videoStopped:Boolean=false;
		protected var videoLoaded:Number=0;
		protected var videoBufferEmptyStatus:Boolean=false;
		protected var videoBufferFlushStatus:Boolean=false;
		protected var videoIsBuffering:Boolean=false;
		protected var videoIsPublished:Boolean=false;
		protected var videoReached50:Boolean=false;
		protected var paused:Boolean=false;
		protected var contentStarted:Boolean=false;
		protected var metadata:Object;
		protected var duration:Number;
		protected var playtime:Number = 0; // currentTime
		protected var savedVolume:Number=0;
		protected var savedPosition:Number = 0;
		protected var savedBitrate:Number = 0;
		protected var muted:Boolean=false;
		
		private static const CALLBACK_VOLUME_ON:String			= "VOLUME_ON";
		private static const CALLBACK_VOLUME_OFF:String			= "VOLUME_OFF";
		private static const CALLBACK_VOLUME_UP:String			= "VOLUME_UP";
		private static const CALLBACK_VOLUME_DOWN:String		= "VOLUME_DOWN";
		private static const CALLBACK_VOLUME_UPDATE:String		= "VOLUME_UPDATE";
		private static const CALLBACK_HD_ON:String				= "HD_ON";
		private static const CALLBACK_HD_OFF:String				= "HD_OFF";
		private static const CALLBACK_PLAY_WITH_PREROLL:String	= "PLAY_WITH_PREROLL";
		private static const CALLBACK_PLAY_WITHOUT_PREROLL:String= "PLAY_WITHOUT_PREROLL";
		private static const CALLBACK_PAUSE:String				= "PAUSE";
		private static const CALLBACK_RESUME:String				= "RESUME";
		private static const CALLBACK_AD_CLICK:String			= "AD_CLICK";
		private static const CALLBACK_SEEK:String				= "SEEK";

		//Variables to finish a Video which can't be flushed
		protected var previousVideoTime:Number;
		protected var offsetVideoTime:int;
		protected var videoTimer:Timer;
		protected var checkEndOfVideoTimer:Timer;
		protected var reconnectLivestreamTimer:Timer;

		//ads
		protected var vastController:VastController;
		protected var isAdPlaying:Boolean;
		protected var showAds:Boolean;
		protected var overlayTimeout:int;

		// movieplayer & liveplayer only
		protected var filmVO:FilmVO;
		protected var streamingVO:StreamingVO;
		protected var akamaiController:AkamaiController;

		//protected var akamaiHDController:AkamaiHDController;
		private var _cachedVideoUrl:String;

		public function PlayerController(playerView:PlayerView) //, controlsView:ControlsView, subtitleView:SubtitleView
		{
			super(this);

			//// this.trackingController=new TrackingController();
            // TODO Selim - vast brauchen?
            // TODO Log messages to JS (see util.Log),
			this.vastController=new VastController(playerView.adContainer);
			this.vastController.addEventListener(AdEvent.ERROR, onAdError);
			this.vastController.addEventListener(AdEvent.LINEAR_START, onAdLinearStart);
			this.vastController.addEventListener(AdEvent.LINEAR_STOP, onAdLinearStop);
			this.vastController.addEventListener(AdEvent.FINISH, onAdFinish);
			// this.vastController.addEventListener(ControlEvent.LOADERANI_CHANGE, forwardEvent);


			this.playerView=playerView;
			//this.controlsView=controlsView;
			//this.subtitleView=subtitleView;
			this.initPlayer()
		}

		protected function initPlayer():void
		{
			this.nc=new NetConnection();
			this.nc.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			this.nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
			this.nc.addEventListener(IOErrorEvent.IO_ERROR, onError);

			//checkEndOfVideoTimer init
			this.checkEndOfVideoTimer = new Timer(TIMER_DELAY);
			this.checkEndOfVideoTimer.addEventListener(TimerEvent.TIMER, checkEndOfVideo);
			
			this.videoTimer = new Timer(1000);
			this.videoTimer.addEventListener(TimerEvent.TIMER, checkVideoPos);
			
			this.reconnectLivestreamTimer = new Timer(2000,10);
			this.reconnectLivestreamTimer.addEventListener(TimerEvent.TIMER, onReconnectLivestream);
			this.reconnectLivestreamTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onReconnectLivestreamLimitReached);

			var client:Object=new Object();
			client.onBWCheck=this.emptyCallback;
			client.onBWDone=this.emptyCallback;
			this.nc.client=client;

			this.soundTransform=new SoundTransform();

			this.playerView.addEventListener(ControlEvent.RESIZE, onDisplayResize);

			/*this.controlsView.addEventListener(ControlEvent.PLAYPAUSE_CHANGE, onPlayPauseChange);
			this.controlsView.addEventListener(ControlEvent.PROGRESS_CHANGE, onProgressChange);
			this.controlsView.addEventListener(ControlEvent.VOLUME_CHANGE, onVolumeChange);*/

			this.playerView.dispatchEvent(new ControlEvent(ControlEvent.RESIZE));
		}
		
		protected function onReconnectLivestream(event:TimerEvent):void
		{
			this.playClip();
		}
		
		protected function onReconnectLivestreamLimitReached(event:TimerEvent):void
		{
			this.reconnectLivestreamTimer.removeEventListener(TimerEvent.TIMER, onReconnectLivestream);
			this.reconnectLivestreamTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onReconnectLivestreamLimitReached);
			
			this.playing=false;
			this.videoStopped=true;
			this.showAvailableMessage();
		}
		
		public function setVolume(volume:Number):void
		{
			if (volume <= 0)
			{
				//// this.trackingController.trackPlayerEvent("VOLUME_OFF");
				this.savedVolume=this.soundTransform.volume;
				this.muted=true;
				//if(this.controlsView.controls.muteBtn)this.controlsView.controls.muteBtn.phase= 1;
				volume=Math.min(1, Math.max(0, volume));
			}
			else
			{
				//if( this.muted ) // this.trackingController.trackPlayerEvent("VOLUME_ON");
				this.muted=false;
				
				volume=Math.min(1, Math.max(0, volume));
				//if(this.controlsView.controls.muteBtn) this.controlsView.controls.muteBtn.phase= 0;
				
				//if(this.savedVolume < volume) // this.trackingController.trackPlayerEvent("VOLUME_UP");
				//else // this.trackingController.trackPlayerEvent("VOLUME_DOWN");
				
				this.savedVolume = volume;
			}

			if (this.hdContent == false )
			{
				if ((BildTvDefines.isMoviePlayer || BildTvDefines.isStreamPlayer )&& akamaiController != null)
				{
					this.akamaiController.setVolume(volume);
				}
				else
				{
					//this.controlsView.setVolume(volume);
					this.soundTransform.volume=volume;

					if (this.ns != null)
					{
						this.ns.soundTransform=this.soundTransform;
					}
				}
			}
			else
			{
				//this.controlsView.setVolume(volume);
				this.soundTransform.volume=volume;

				if (this.nsHD != null)
				{
					this.nsHD.soundTransform=this.soundTransform;
				}
			}

            ExternalController.dispatch(ExternalController.EVENT_VOLUME_CHANGE);
		}
        
        //trackingData:TrackingVO,
		public function setClip(videoVO:VideoVO,  adData:AdVO):void
		{
			//trace("---------------------setclip-----------------------");
			if(videoVO.videoUrl == "")
			{
				return;
			}
			this.videoVO=videoVO;
			this.playing=false;
			this.videoStarted=false;
			this.contentStarted=false;
			BildTvDefines.isBumper=false;
			//this.playerView.setDisplayButtonAsPlayPauseButton(true);

			this.adData=adData;
			
			if( true == this.videoVO.mute )
			{
				this.setVolume( 0 );
				if(this.vastController) this.vastController.setVolume(0);
			}
			
			this.showAds = this.adData != null;

			if ( videoVO.videoUrl.indexOf(".f4m") != -1 || videoVO.videoUrl.indexOf(".smil") != -1 )
			{
				this.hdContent=true;
					//trace("set HD Content..");
			}
			 
			this.playerView.display.clear();
			
			/*if(BildTvDefines.isLivePlayer)
			{
				// this.trackingController.trackPlayerEvent("LIVE_ON");				
			}
			else
			{
				// this.trackingController.trackPlayerEvent("LIVE_OFF");			
			}*/
			
			//this.controlsView.updateTime(0);
			//this.controlsView.updatePlayProgress(0);
			//this.controlsView.setDuration(this.videoVO.duration);

			//// this.trackingController.setClip(videoVO, trackingData);

			// check autoplay
			trace("autoplay = " + videoVO.autoplay + ":::" + BildTvDefines.autoplay);
			if (BildTvDefines.autoplaySet == false)
			{
				BildTvDefines.autoplay=videoVO.autoplay;
				BildTvDefines.autoplaySet=true;
			}

			if (BildTvDefines.autoplay)
			{
				this.play();
			}
		}

		public function pause():void
		{
			this.videoTimer.stop();
            ExternalController.dispatch(ExternalController.EVENT_PAUSE);
			if (this.videoStarted)
			{
				if (this.hdContent == false)
				{
					if (this.ns) this.ns.pause();
				}
				else
				{
					if (this.nsHD) this.nsHD.pause();
				}

				this.playing=false;
				this.paused=true;
				//// this.trackingController.onClipPause();
			}
		}

		public function resume():void
		{
			this.videoTimer.start();
			ExternalInterface.call("com.xoz.flash_logger.logTrace","------------RESUME STREAM!----------------");
			if (this.isAdPlaying)
			{
				this.vastController.resume();
			}
			else if (this.videoStarted)
			{
				if (this.hdContent == false)
				{
					this.ns.bufferTime=BildTvDefines.buffertimeMinimum;

					trace(this + " set buffertime to " + this.ns.bufferTime);

					this.ns.resume();
						// sometimes the stream just won't resume, so force it with a seek to the current position - not sure why but it works
						//this.ns.seek( this.ns.time );			
				}
				else
				{
//					this.nsHD.bufferTimeMax= BildTvDefines.buffertimeMinimum;
					
					ExternalInterface.call("com.xoz.flash_logger.logTrace","DVR Availability:"+this.nsHD.dvrAvailability);
					
					if( BildTvDefines.isLivePlayer && this.nsHD.dvrAvailability != "none")
					{
						
						//seek first and then resume, only in livestream
						ExternalInterface.call("com.xoz.flash_logger.logTrace","first seek, then resume, because DVR is available");
						this.nsHD.seek(this.nsHD.duration);
						//this.nsHD.resume();		
						//this.nsHD.play( this.videoFile, this.nsHD.durationAsUTC );
					}
					else
					{
						ExternalInterface.call("com.xoz.flash_logger.logTrace","only resume, because DVR is not available");
						
						this.nsHD.resume();					
					}
				}

				// set lower buffer here to enable fast video start after pause
				this.playing=true;
				this.paused=false;
			//	// this.trackingController.onClipResume();
			}
		}

		public function replay():void
		{
			//trace( "replay" );
			//// this.trackingController.trackPlayerEvent("PLAY_AUTOREPLAY");
			this.play();
		}

		public function play(considerAds:Boolean=true):void
		{
			//trace( this + " play: " + this.videoVO.videoUrl );

			// track init, but not when autoplay
			// 12.01.11 - exception for welt			
			// 17.01.11 - disabled permanently for bild too
//			if( !this.videoVO.autoplay || BildTvDefines.isWeltPlayer )
//			{	
			ExternalController.dispatch(ExternalController.EVENT_PLAY);
			//// this.trackingController.onClipPlay();
//			}						

            // ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
			this.clip2play=CLIP_BUMPER_PREROLL;
			

			/* TODO: brauche ich das?
			if (this.showAds && considerAds)
			{
				//this.adPlaying = true;

				if (BildTvDefines.adType == "preroll")
				{
					this.vastController.load(this.adData.preroll, VastDefines.ADTYPE_PREROLL);
				}
				else if (BildTvDefines.adType == "midroll")
				{
					this.vastController.load(this.adData.midroll, VastDefines.ADTYPE_MIDROLL);
				}
				else if (BildTvDefines.adType == "overlay")
				{
					this.vastController.load(this.adData.overlay, VastDefines.ADTYPE_OVERLAY);
				}
				else if (BildTvDefines.adType == "postroll")
				{
					this.vastController.load(this.adData.postroll, VastDefines.ADTYPE_POSTROLL);
				}
				else
				{
					BildTvDefines.adType = "preroll";
					this.vastController.load(this.adData.preroll, VastDefines.ADTYPE_PREROLL);
				}
			}
			else
			{
				this.playClip();
			}*/

            if (this.videoStarted)
            {

                this.resume();
            }
            else
            {
                this.playClip();
            }
		}

		protected function playClip():void
		{			
			this.adPlaying=false;
			this.previousVideoTime = this.savedPosition;
			// refresh clip info
			/*this.controlsView.updateTime(this.savedPosition);
			this.controlsView.updatePlayProgress(this.savedPosition);
			this.controlsView.setDuration(this.savedPosition);*/
			this.videoLoaded=0;
			this.videoReached50=false;
			this.onContentStart();
			//trace(this.videoVO.videoUrl);
			// check bumpers
			// if bumper is set in the video XML, we will come here 2 times
			// first time, there's no bumperVO, so the bumper XML gets loaded
			// second time, when the bumper XML was loaded, bumperVO exists and will be played
			// if no bumper is set in the video XML, continue with content clip
//			ExternalInterface.call("function(){if (window.console) console.log('clipType:::"+this.clip2play+"');}");
			switch (this.clip2play)
			{
				case CLIP_BUMPER_PREROLL:
				{
                    // ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
					if (this.bumperVO != null)
					{
						this.currentClip=this.bumperVO;
					}
					/*else if (this.videoVO.bumperPrerollXml != "")
					{
						this.loadBumperXml(this.videoVO.bumperPrerollXml);

						// avoid playstart now
						return;
					}*/
					else
					{
						this.clip2play=CLIP_CONTENT;
						this.currentClip = this.videoVO;
					}

					break;
				}
				case CLIP_BUMPER_POSTROLL:
				{
					if (this.bumperVO != null)
					{
						this.currentClip=this.bumperVO;
					}
					/*else if (this.videoVO.bumperPostrollXml != "")
					{
						this.loadBumperXml(this.videoVO.bumperPostrollXml);
						// avoid playstart now
						return;
					}*/
					else
					{
						this.clip2play=CLIP_NONE;
						this.finishPlay();
						// avoid playstart now
						return;
					}

					break;
				}
				case CLIP_CONTENT:
				{
					this.currentClip = this.videoVO;

					break;
				}
				case CLIP_NONE:
				{
					this.finishPlay();
					// avoid playstart now
					return;
				}
			}

			/*if( true == BildTvDefines.isSingleVastPlayer )
			{
				this.vastController.load(this.videoVO.videoUrl, VastDefines.ADTYPE_NONE);
				return;
			}*/
			
			// start playing!
			this.playing = this.clip2play != CLIP_NONE;
			
			if (this.videoSrcPosition == 2)
			{
				this.playing=true;
				//this.controlsView.showAdControls(false);
				this.playerView.setPlayingStatus(true);
			}
			/*this.controlsView.setDuration(this.duration);
			this.controlsView.updateTime(0);*/

			
			if (this.videoIsStream)
			{
				// disable seeking for livestreams -> duration is -1
				if (this.videoVO.videoUrl.substr(0, 4) == "rtmp" || this.videoVO.videoUrl2.substr(0, 4) == "rtmp")
				{
					if( BildTvDefines.isLivePlayer )
					{
					//	// this.trackingController.trackPlayerEvent("LIVE_ON");
						
						if(!BildTvDefines.isBumper ) 
						{
							this.duration = -1;
						}						
					}
					else
					{
				//		// this.trackingController.trackPlayerEvent("LIVE_OFF");
					}
					
					//this.controlsView.enableSeeking(this.duration != -1);
					this.streamConnects=1;
					this.playStream();
				}
				else
				{
					/* this.controlsView.enableSeeking( true );
					this.nc.connect( null ); */
				}
			}
			else
			{
				if( BildTvDefines.isLivePlayer )
				{
					if(!BildTvDefines.isBumper ) 
					{
						//this.controlsView.enableSeeking( false );
						this.duration = -1;
					}
					//else this.controlsView.enableSeeking( true );
					
				}
				//else this.controlsView.enableSeeking(true);
				//check if nc is already connected
				if( this.nc.connected && this.nc.uri == "null" )
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","POST REQUEST @ playClip if noStream and this.nc.connected && this.nc.uri == null");
					onNetConnectionSucces();
				}
				else
				{
					this.nc.connect(null);	
				}
				
			}

			// load overlay
			if (!BildTvDefines.isBumper && this.showAds)
			{
				this.overlayTimeout=setTimeout(this.vastController.load, VastDefines.OVERLAY_DELAY, this.adData.overlay, VastDefines.ADTYPE_OVERLAY);
			}
		}

		protected function playStream():void
		{
			if (this.parseStreamUrl())
			{
                ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
				if( this.nc.connected && this.nc.uri == this.videoServer )
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","POST REQUEST @ playClip if Stream and this.nc.connected && this.nc.uri != null");
					onNetConnectionSucces();
				}
				else
				{
					this.nc.connect(this.videoServer);
				}
			}
		}

		protected function setNextClip():void
		{
			switch (this.clip2play)
			{
				case CLIP_BUMPER_PREROLL:
				{
					this.clip2play=CLIP_CONTENT;

					break;
				}
				case CLIP_BUMPER_POSTROLL:
				{
					this.clip2play=CLIP_NONE;

					break;
				}
				case CLIP_CONTENT:
				{
					if (BildTvDefines.isMoviePlayer || BildTvDefines.isStreamPlayer)
					{
						this.clip2play=CLIP_NONE;
					}
					else
					{
						this.hdContent = false;
						this.clip2play=CLIP_BUMPER_POSTROLL;
					}

					break;
				}
			}
		}

		protected function finishPlay(event:Event=null):void
		{
			this.videoTimer.stop();
			this.playerView.supressPlayDisplayButton(false);
			trace(this + " finishPlay");

			if (this.hdContent == false)
			{
				if (this.ns != null)
				{
					this.ns.close();
					this.ns=null;
				}
			}
			else
			{
				if (this.nsHD != null)
				{
					this.nsHD.closeAndDestroy(); //new
					this.nsHD=null;
				}
					//this.akamaiHDController.close();
			}

			// hide ad overlay
			this.vastController.showOverlay(false);
			clearTimeout(this.overlayTimeout);

			this.setNextClip();
			this.bumperVO=null;

			// check if there is another clip
			if (this.clip2play != CLIP_NONE)
			{
				this.playClip();
			}
			// all content finished, now play postroll ad
			else if (this.showAds)
			{
				// clear overlay timeout
				clearTimeout(this.overlayTimeout);
				//this.playerView.adLabel.visible = false;
				this.adPlaying=true;
				this.vastController.load(this.adData.postroll, VastDefines.ADTYPE_POSTROLL);
			}
			else
			{
				this.onVideoFinish();
			}
		}

		/**
		 * general flag - true if anything is playing (content or ad)
		 */
		protected function set playing(value:Boolean):void
		{
			trace(this + " ------ set playing  " + value);
			this.isPlaying=value;
			//this.controlsView.setPlayingStatus(value);
			this.playerView.setPlayingStatus(value);
			//// this.trackingController.setPlayingStatus(value && !this.adPlaying && !BildTvDefines.isBumper);
		}

		protected function get playing():Boolean
		{
			return this.isPlaying;
		}

		/**
		 * special flag - true if ad is current clip
		 */
		protected function set adPlaying(value:Boolean):void
		{
			trace(this + "  +++++ adPlaying:  " + value + "::" + this.videoStopped);
			this.isAdPlaying=value;
			this.playerView.videoBtn.visible=!value;
			//this.playerView.adLabel.text=(value) ? this.adData.adText : "";

			//this.playerView.setDisplayButtonVisible( !value );	
			this.playing=value;

			/*if (!value)
			{
				this.controlsView.showAdControls(false);
			}*/
		}

		protected function get adPlaying():Boolean
		{
			return this.isAdPlaying;
		}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// STREAM EVENTS HANDLER
///////////////////////////////////////////////////////////////////////////////////////////////////////

		protected function onNetConnectionConnect():void
		{
			//trace( this + " onNetConnectionConnect" );

			this.ns=new NetStream(this.nc);
			this.ns.soundTransform=this.soundTransform;
			if( isLivestream )
			{
				this.ns.bufferTime=BildTvDefines.liveBuffertimeMinimum;
			}
			else
			{
				this.ns.bufferTime=BildTvDefines.buffertimeMinimum;
			}

			trace(this + " set buffertime to " + this.ns.bufferTime);

			var metaHandler:Object=new Object();
			metaHandler.onMetaData=this.onMetaData;
			this.ns.client=metaHandler;

			this.ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus, false, 0, true);

			this.playerView.display.attachNetStream(this.ns);

			// play!
			// for akamai live streams
			if (this.videoIsStream)
			{
				this.nc.call("FCSubscribe", null, this.videoFile);
			}

			// action!
             ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
			
//			ExternalInterface.call("function(){if (window.console) console.log('play: "+ this.videoFile+"');}");
			if( isLivestream || BildTvDefines.startTime == 0 )
			{
				this.ns.play( this.videoFile );
			}
			else
			{			
				this.ns.play(this.videoFile, BildTvDefines.startTime);
			}
			this.videoTimer.start();
			this.offsetVideoTime = 0;
		}
		
		protected function onHDNetConnectionConnect(savedPosition:Number = 0, statusLoad:Boolean = false):void
		{
			trace( this + " onNetConnectionConnect: " + this.videoFile );
		
			/*if(this.controlsView.controls.hdBtn)
			{
				if( this.videoVO.startHDQuality )
				{
					 this.controlsView.controls.hdBtn.phase = 1;
				}
				else
				{
					 this.controlsView.controls.hdBtn.phase = 0;
				}	
			}*/
			
			this.nc = new NetConnection();
			this.nc.connect(null);
			
			if ( this.nsHD ) 
			{
				this.nsHD.closeAndDestroy();				
			}
			
			this.nsHD=new ZStream(this.nc);	
					
			this.nsHD.soundTransform=this.soundTransform;
//			this.nsHD.bufferTime= BildTvDefines.buffertimeMinimum;

			if( true == this.isLivestream || true == this.videoVO.hdAdaptive )
			{
				this.nsHD.manualSwitchMode = false;
				this.startBitrateSetted = true;
			}
			else
			{
				this.nsHD.manualSwitchMode = true;
					
				if(false == this.videoVO.startHDQuality )
				{
					this.nsHD.startingIndex = 0;
				}				
			}

			var metaHandler2:Object=new Object();
			this.nsHD.addClientHandler( "onMetaData", this.onMetaData);
			this.nsHD.addClientHandler( "onPlayStatus", this.onPlayStatusHD);
			this.nsHD.addClientHandler( "dvrAvailabilityChange", this.onDvrAvailabilityChange);
			this.nsHD.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus, false, 0, true);
			this.nsHD.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				
				this.playerView.display.attachNetStream(this.nsHD);
				this.playerView.display.smoothing = true;
				this.playerView.display.deblocking = 0;
				
                ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
				this.savedPosition = BildTvDefines.startTime;
				
	//			trace("starttime: " + this.savedPosition);
				ExternalInterface.call("com.xoz.flash_logger.logTrace","FLASH PLAY: "+ this.videoFile);
				//this.nsHD.play( this.videoFile,this.savedPosition );
				
				this.nsHD.play( this.videoFile );
				this.videoTimer.start();
				this.offsetVideoTime = 0;
				
				if(BildTvDefines.startTime != 0) 
				{			
					this.playing=true;
					this.paused=false;		
				}			
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{		
			if(this.nsHD && ZStream(event.currentTarget).duration != 0)
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace"," +++ kein nächstes Segment in der bitrate gefunden, ERROR 403 im HDCore +++" );
				trace("kein nächstes Segment in der bitrate gefunden...type: " + event.type);
				return;
			}
			
			trace( "isPlaying: " + this.isPlaying + "  playing:" + this.playing + " videoStarted:" + this.videoStarted )
			if( this.videoUrl != videoVO.videoUrl2 )
			{
				this.videoVO.videoUrl = this.videoVO.videoUrl2;
				this.videoFile = this.videoVO.videoUrl;
				this.videoUrl = this.videoVO.videoUrl;
				_cachedVideoUrl = null;
				
				this.playClip();							
			}
			
			else
			{
				//						trace(this.adPlaying + ":::" + BildTvDefines.adType + "::::" + this.vastController.currentAdType);
				this.playing=false;
				//this.videoStarted=false;
				this.videoStopped=true;
				this.showAvailableMessage();	
			}
//			this.videoStopped=true;
//			this.showAvailableMessage();
		}
		
		protected function onNetConnectionFail():void
		{
			// connection was refused, probably bad parsing - retry if possible
			this.streamConnects++;
			this.playStream();
		}
		
		protected function onNetConnectionRefused():void
		{
			// no, we really can't play this - stop trying	
			trace(this + " onNetConnectionRefused");

			this.playing=false;
			this.videoStarted=false;
			this.showGeoMessage();
		}

		protected function onNetConnectionStatus(e:NetStatusEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","onNetConnectionStatus" + e.info);
			ExternalInterface.call("com.xoz.flash_logger.logTrace","onNetConnectionStatus" + e.info.code);
			ExternalInterface.call("com.xoz.flash_logger.logTrace","onNetConnectionStatus" + e.info.description);
			ExternalInterface.call("com.xoz.flash_logger.logTrace","...........................');}");

			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
				{
					//this.onNetConnectionRefused(); //GEO ERROR TEST
					//check if videoFile is a token for ... switch the Listener for hd Cotent and normal Content
					//Loading file via URLLoader maybe causes crossdomain and Security Issues ... plz check
					ExternalInterface.call("com.xoz.flash_logger.logTrace","onNetConnectionStatus - NetConnection.Connect.Success");
					this.onNetConnectionSucces();
					
					break;
				}
				case "NetConnection.Connect.Rejected":
				{
					if (e.info.ex)
					{
						if (e.info.ex.code == 302)
						{
							this.videoUrl=e.info.ex.redirect + "/" + this.videoFile;
							this.streamConnects=1;
							setTimeout(playStream, 100);
							return;
						}
					}

					//this.onNetConnectionRefused(e.info.ex.redirect); //GEO ERROR TEST
					break;
				}
				case "NetConnection.Connect.Refused":
				case "NetConnection.Connect.Failed":
				{
					setTimeout(onNetConnectionFail, 100);
					break;
				}
			}
		}
		
		private function tryRedirectUrl():void
		{
			if( BildTvDefines.isBumper )
			{
				this.onNetConnectionConnect();
			}
			if( this.videoFile.indexOf("http://cmbildde-preview/tok.ak/") == -1 && 
				this.videoFile.indexOf(".ak.token.bild.de/") == -1 && 
				( this.videoFile.indexOf( ".ak.token.") == -1 && this.videoFile.indexOf( ".bdedev.de/") == -1 ) )
			{
				if(this.hdContent)
				{
					this.onHDNetConnectionConnect();
				}
				else
				{
					this.onNetConnectionConnect();			
				}
			}
			else
			{
				var scriptRequest:URLRequest 	= new URLRequest(this.videoFile);
				var scriptLoader:URLLoader 		= new URLLoader();
					
				ExternalInterface.call("com.xoz.flash_logger.logTrace","POST REQUEST @ X-NoRedirect REDIRECT");
					
					
				scriptRequest.requestHeaders.push(new URLRequestHeader("X-NoRedirect", "false"));
				scriptRequest.method = URLRequestMethod.POST;
				scriptRequest.data = new URLVariables("NoRedirect=false");
					
				ExternalInterface.call("com.xoz.flash_logger.logTrace","TRY REDIRECT IN FLASH");
					
				if( this.hdContent == false ) 
				{				
					//toDo ... check Problesm with Security and crossdomain.xml if content can't be loaded
						
					scriptLoader.addEventListener(Event.COMPLETE, rDLoaded);
					scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					scriptLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError2);
					try
					{
						scriptLoader.load(scriptRequest);
					}
					catch( sec:SecurityError )
					{
						this.onNetConnectionConnect();
					}
				}
				else 
				{	
					scriptLoader.addEventListener(Event.COMPLETE, rHDLoaded);
					scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadHDError);
					scriptLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadHDError2);
					scriptLoader.load(scriptRequest);
				}
			}
		}
		
		private function onNetConnectionSucces():void
		{
			if( BildTvDefines.isEmbedPlayer &&  _cachedVideoUrl == null && !BildTvDefines.isBumper)
			{
				_cachedVideoUrl = this.videoFile;
			}
			else if( BildTvDefines.isEmbedPlayer && _cachedVideoUrl != null && (this.clip2play != CLIP_BUMPER_POSTROLL || this.clip2play != CLIP_BUMPER_PREROLL))
			{
				this.videoFile = _cachedVideoUrl;
			}
			
			trace("play: redirect davor: "+ this.videoFile+"  hd? "+this.hdContent);

			this.tryRedirectUrl();
		}
		
		protected function onLoadHDError2(event:SecurityErrorEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","HD REDIRECT SECURE ERROR");
		}
		
		protected function onLoadHDError(event:IOErrorEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","HD REDIRECT IO ERROR, CONTINIUE WITH OLD URL");
			this.onHDNetConnectionConnect();
			
		}
		
		protected function rHDLoaded(event:Event):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","HD REDIRECT FINISHED");
			this.videoFile = event.currentTarget.data;
		
			if(event.currentTarget.data as XML)
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","redirect complete! but its an XML and no URL " + this.videoFile);
				this.playing=false;
				this.videoStopped=true;
				this.showAvailableMessage();
			}
			else
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","redirect complete! " + this.videoFile);
				this.onHDNetConnectionConnect();		
			}		
			
		}
		
		protected function onLoadError(event:IOErrorEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","REDIRECT IO ERROR , NO REDIRECT FOR THIS URL. PLAY FIRST URL");
			//this.playing=false;
			//this.videoStopped=true;
			//this.showAvailableMessage();
//			ExternalInterface.call("function(){if (window.console) console.log('play: redirect error: "+ this.videoFile+"');}");
			this.onNetConnectionConnect();
		}
		
		protected function onLoadError2(event:SecurityErrorEvent):void
		{
//			ExternalInterface.call("function(){if (window.console) console.log('play: redirect error: "+ this.videoFile+"');}");
			ExternalInterface.call("com.xoz.flash_logger.logTrace","REDIRECT SECURE ERROR, NO REDIRECT FOR THIS URL. PLAY FIRST URL");
//			trace("redirect laden ging schief security!!");
			this.onNetConnectionConnect();
			
//			this.playing=false;
			//this.videoStarted=false;
//			this.videoStopped=true;
//			this.showGeoMessage();
		}
		
		protected function rDLoaded(event:Event):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","REDIRECT FINISHED");
			
//			ExternalInterface.call("function(){if (window.console) console.log('play: redirect fertig: "+ this.videoFile+"');}");
			if(this.videoFile.indexOf("localhost") != -1 ) 
			{
				this.onNetConnectionConnect();	
			}
			else if(event.currentTarget.data != "")
			{
				
				ExternalInterface.call("com.xoz.flash_logger.logTrace","AFTER TRY REDIRECT IN FLASH, VALIDATE "+ event.currentTarget.data);
				
				var pattern:RegExp = new RegExp("^http[s]?\:\\/\\/([^\\/]+)\\/");
				
				var urls:Array = String(event.currentTarget.data).match(pattern);
				var isUrl:Boolean = (urls && urls.length > 0 );
				
				ExternalInterface.call("com.xoz.flash_logger.logTrace","URL PASSED THE VALIDATOR: "+isUrl);
				// run the pattern, but don't error if there is no value and this is not required
				/*if (!(!required && !value) && !pattern.exec(String(event.currentTarget.data))) {
					results.push(new ValidationResult(true, null, "notURL", 
						"You must enter a valid URL."));
					return results;
				}*/
				
				
				if( isUrl )
				{
					this.videoFile = event.currentTarget.data;
					ExternalInterface.call("com.xoz.flash_logger.logTrace","AFTER VALIDATE, PLAY  "+ this.videoFile);					
					this.onNetConnectionConnect();		
				}				
				else
				{
					urls = this.videoFile.match(pattern);
					isUrl = (urls && urls.length > 0 );
					
					ExternalInterface.call("com.xoz.flash_logger.logTrace","THEN VALIDATE OLD URL : "+ isUrl);
					
					if( isUrl )
					{
						ExternalInterface.call("com.xoz.flash_logger.logTrace","AFTER VALIDATE, PLAY  "+ this.videoFile);
						this.onNetConnectionConnect();		
					}
					else
					{
						this.playing=false;
						//this.videoStarted=false;
						this.videoStopped=true;
						this.showAvailableMessage();					
					}
	//				ExternalInterface.call("function(){if (window.console) console.log('redirect complete! but its an XML and no URL " + this.videoFile+"');}");
				}		
			}
			else
			{
//				ExternalInterface.call("function(){if (window.console) console.log('AFTER TRY REDIRECT IN FLASH, PLAY MP4  "+ this.videoFile +"');}");
				this.onNetConnectionConnect();		
			}

//			ExternalInterface.call("function(){if (window.console) console.log('redirect complete!Type is XML? " + (event.currentTarget.data as XML)+"');}");
		}
				
		protected function onNetStreamStatus(e:NetStatusEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","NETSTREAM STATUS: "+e.info.code);
			switch (e.info.code)
			{
				case "NetStream.Buffer.Flush":
				{
					this.videoBufferFlushStatus=true;
					break;
				}
				case "NetStream.Seek.Notify":
				{
					this.videoBufferEmptyStatus=false;

					// set lower buffer here to enable fast video start after pause
					if (this.hdContent == false)
					{
						this.ns.bufferTime= BildTvDefines.buffertimeMinimum;
					}
					else 
					{
						//this.nsHD.bufferTime= BildTvDefines.buffertimeMinimum;
						
						if( BildTvDefines.isLivePlayer && this.nsHD.dvrAvailability != "none" )
						{
							trace("-------------seeked and now resume the stream!");
							this.nsHD.resume();			
						}
					}
                    ExternalController.dispatch(ExternalController.EVENT_SEEKED);

					break;
				}
				case "NetStream.Buffer.Full":
				{
					this.videoBufferEmptyStatus=false;

                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

					// set higher buffer now to enable constant playback
					if (this.hdContent == false) this.ns.bufferTime = BildTvDefines.buffertimeMaximum;
//					else this.nsHD.bufferTime = BildTvDefines.buffertimeMaximum;

					break;
				}
				case "NetStream.Buffer.Empty":
				{
					this.videoBufferEmptyStatus=true;
					if (!this.videoBufferFlushStatus)
					{
						// set lower buffer here to enable fast video start
						if (this.hdContent == false)
						{
							this.ns.bufferTime=BildTvDefines.buffertimeMinimum;
						}
                     //   ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
					}
                    ExternalController.dispatch(ExternalController.EVENT_EMPTIED);

					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
					/*trace("...............................................................");
					trace("...................Stream not found Error at Livestream "+this.videoFile+".....................");
					trace("...............................................................");*/
					
//					ExternalInterface.call("function(){if (window.console) console.log('STREAM NOT FOUND ERROR AT: "+this.videoFile+"  : "+e.type +"');}");
					ExternalInterface.call("com.xoz.flash_logger.logTrace","STREAM NOT FOUND ERROR AT: "+this.videoFile+"  : "+e.type);
					
					//if AdBlocker is blocking bumber or Bumber url is incorrect coninue with conten Clip
					if( this.clip2play == CLIP_BUMPER_POSTROLL)
					{
						this.playing=false;
						this.videoStopped=true;
						this.videoBufferFlushStatus=true;
						this.videoBufferEmptyStatus = true;
						this.setNextClip();
						
					}
					else if(this.clip2play == CLIP_BUMPER_PREROLL)
					{
						this.playing=false;
						this.videoStopped=true;
						this.setNextClip();
						playClip();
						
					}
					else if ( BildTvDefines.isLivePlayer ) //this.videoSrcPosition == 1)
					{
//						this.videoSrcPosition=2;
						if( this.hdContent )
						{
							this.onHDNetConnectionConnect();	
						}
						else
						{
							this.playing=false;
							//this.videoStarted=false;
							this.videoStopped=true;
							this.showAvailableMessage();
						}
					}
					else
					{
						if( this.videoUrl != videoVO.videoUrl2 )
						{
							this.videoVO.videoUrl = this.videoVO.videoUrl2;
							this.videoFile = this.videoVO.videoUrl;
							this.videoUrl = this.videoVO.videoUrl;
							_cachedVideoUrl = null;
							
							this.playClip();							
						}
						else
						{
	//						trace(this.adPlaying + ":::" + BildTvDefines.adType + "::::" + this.vastController.currentAdType);
							this.playing=false;
							//this.videoStarted=false;
							this.videoStopped=true;
							this.showAvailableMessage();	
						}
					}
					break;
				}
				case "NetStream.Play.Start":
				{
					/*if (!BildTvDefines.isBumper && ( this.ns && this.ns.time < 1 ) || ( this.nsHD && this.nsHD.time < 1 ))
					{
						// this.trackingController.onClipStart();
					}*/
                    ExternalController.dispatch(ExternalController.EVENT_PLAYING);

					if( this.nsHD )
					{
						if( this.nsHD.isLiveStream )
						{
							this.duration = -1;
							BildTvDefines.isLivePlayer = true;
							
						//	// this.trackingController.trackPlayerEvent("LIVE_ON");
							
							this.videoVO.duration=Number(this.duration);
						//	// this.trackingController.setDuration( this.duration );
							/*this.controlsView.setDuration( this.duration );
							this.controlsView.enableSeeking(false);*/
						}	
					}
					// seeking in streams may trigger Play.Start, so check paused state
					if (!this.paused)
					{
						this.videoStarted=true;
						this.videoStopped=false;
						this.videoBufferEmptyStatus=false;
						this.videoBufferFlushStatus=false;
						
					
						//this.controlsView.setPlayingStatus(true);

						if (!this.playerView.display.hasEventListener(Event.ENTER_FRAME))
						{
							this.playerView.display.addEventListener(Event.ENTER_FRAME, onVideoEnterFrame, false, 0, true);
						}
					}

					break;
				}
				case "NetStream.Play.Stop":
				{
					this.videoStopped=true;
					if( this.clip2play == CLIP_BUMPER_POSTROLL ) this.clip2play = CLIP_NONE;
					//this.controlsView.setPlayingStatus( false );

					break;
				}
				case "NetStream.Play.UnpublishNotify":
				{
					ExternalInterface.call("com.xoz.flash_logger.logInfo"," Stream not live at the Moment...so try to reconnect");
					this.videoIsPublished = false;
					this.reconnectLivestreamTimer.start();

					break;
				}
				case "NetStream.Play.PublishNotify":
				{
					Log.info(this + " Stream is live again...");
					if( this.videoIsPublished == false ) 
					{
						this.reconnectLivestreamTimer.stop();
						this.videoIsPublished = true;
					}
					
					break;
				}
				case "NetStream.Play.Transition":
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","Bitratetransition: time:" + this.nsHD.time + "   index:"+e.info);		
					/*if(this.controlsView.controls.hdBtn)
					{
						//// this.trackingController.trackPlayerEvent("BITRATESWITCH_FINISH");
						this.controlsView.controls.hdBtn.disabled = false;
					}*/
					break;
				}		
			}

			// check for clip end
//			trace(this + " this.videoStopped == " + this.videoStopped + " || this.videoBufferEmptyStatus == " + this.videoBufferEmptyStatus  + " || this.videoBufferFlushStatus == " + this.videoBufferFlushStatus);
			if (this.videoStopped == true && this.videoBufferEmptyStatus != true && this.videoBufferFlushStatus == true)
			{
				//trace( "---- videoBufferEmptyStatus = false" );
				this.checkEndOfVideoTimer.start();
			}

			if (this.videoStopped == true && this.videoBufferEmptyStatus == true && this.videoBufferFlushStatus == true)
			{
				//trace( "---- videoBufferEmptyStatus = true" );
				if (this.checkEndOfVideoTimer.running)
				{
					this.checkEndOfVideoTimer.stop();
				}
				this.videoStopped=false;
				this.videoBufferEmptyStatus=false;
				this.videoBufferFlushStatus=false;

				this.playerView.display.removeEventListener(Event.ENTER_FRAME, onVideoEnterFrame, false);
			
				if (this.clip2play != CLIP_BUMPER_POSTROLL )
				{
					//trace("no bumper");
					ExternalInterface.call("com.xoz.flash_logger.logTrace","Send finishPlayer signal from CheckEndOfVideoTimer when no bumper");
					if( true == this.videoStarted )
					{
						this.finishPlay();
					}
                    ExternalController.dispatch(ExternalController.EVENT_ENDED);
					//// this.trackingController.onClipEnd();
				}

			}
		}

		protected function onContentStart(event:ControlEvent=null):void
		{
			if (!this.contentStarted)
			{
				trace(this + " onContentStart");

				this.contentStarted=true;

				// call JS function, used for player branding ads
				try
				{
					ExternalInterface.call("onVideoStart");
				}
				catch (error:Error)
				{
					// ignore
					trace(this + " Error calling JS 'onVideoStart': " + error.message);
				}
			}
		}

		protected function onDvrAvailabilityChange(evt:Object):void
		{
			trace("HD event: " + evt.code);
			ExternalInterface.call("com.xoz.flash_logger.logTrace","Changed DVR Availibilty Changed to :: " + evt.code);
		}
		
		protected function onPlayStatusHD(evt:Object):void
		{
			trace( this + " onPlayStatusHD :: " + evt.code );
			switch( evt.code )
			{
				case "NetStream.Play.Empty": 
				{
					//this.resume();
					break;
				}
				case "NetStream.Play.Complete": 
				{
					this.videoBufferFlushStatus=true;
					this.finishPlay();		
					break;
				}
				case "NetStream.Play.TransitionComplete":
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","Bitratetransition changed...finish: " + evt.index + " time:" + this.nsHD.time);
					/*if(this.controlsView.controls.hdBtn)
					{
						this.controlsView.controls.hdBtn.disabled = false;
					}*/
					break;
				}
				case "NetStream.Seek.Notify":
				{
                    ExternalController.dispatch(ExternalController.EVENT_SEEKED);
					if( BildTvDefines.isLivePlayer )
					{
						this.nsHD.resume();			
					}
					break;
				}				
				default:break;
			}
		}
		
		protected function onMetaData(data:Object):void
		{
            var dataObj:Object = {};
            for(var key:String in data) {
                dataObj[key] = data[key];
            }
			ExternalController.dispatch(ExternalController.EVENT_LOADED_METADATA, dataObj);
            Log.info( this + " onMetaData" );
			//this.dispatchEvent(new ControlEvent(ControlEvent.LOADERANI_CHANGE, {visible: false}));
			
			
			if( this.startBitrateSetted == false && this.nsHD )
			{
				this.startBitrateSetted = true;
				
				var highestIndex:Number = this.nsHD.maxAllowedIndex;
				if(false == this.videoVO.startHDQuality )
				{
					this.nsHD.startingIndex = 0;
					
				}
				else
				{	
					try
					{						
			//			// this.trackingController.trackPlayerEvent("HD_ON");
						this.nsHD.startingIndex = highestIndex;
						//if(this.controlsView.controls.hdBtn) this.controlsView.controls.hdBtn.phase = 1;
					}
					catch(e:Error)
					{
					}
				}
				
				/*if( highestIndex < 1 )
				{
					this.controlsView.getSkin().styleHDBtn = null;							
					
					if ( this.controlsView.controls.hdBtn && this.controlsView.controls.hdBtn.parent)
					{
						this.controlsView.controls.removeChild(this.controlsView.controls.hdBtn);
					}
					this.controlsView.controls.hdBtn = null; 
					this.controlsView.controls.setBtnBackground();
					this.controlsView.controls.resize();
				}*/
			}
			
			if(BildTvDefines.startTime != 0) 
			{
				this.nsHD.seek(BildTvDefines.startTime);
				this.savedPosition = 0;
				BildTvDefines.startTime = 0;
				
				this.playing=true;
				this.paused=false;
			}
			
			if (data != this.metadata)
			{
				this.metadata=data;

				// check ratio
				var ratio:Number=16 / 9;

				if (data.width != null && data.height != null)
				{
					ratio=parseFloat(data.width) / parseFloat(data.height);
				}

				this.playerView.setVideoRatio(ratio);

				// check duration
				// 23.3.11 - deactivated to avoid alternating time displays - 1st from XML, 2nd from MetaData, 3rd from XML (after Midroll)
				// 05.12.11 - activated again but only set if duration is not set in xml

				if (data.duration != null )
				{
					if( this.duration != -1)
					{			
						this.videoVO.duration=Number(data.duration);
						this.duration=Number(data.duration);
						//this.controlsView.setDuration( this.duration );
						
						//trace(this + "  setze falsche zeit aus der xml: " + videoVO.duration);
						// deactivate midrolls if video is under 5 minutes
						this.videoReached50 = this.duration < 300;
					}
				}
				else
				{
					this.duration = -1;
					BildTvDefines.isLivePlayer = true;
					//this.controlsView.setDuration( this.duration );
					//this.controlsView.enableSeeking(false);
				}
				
				//// this.trackingController.updateMetaData( this.duration );
			}
		}

		protected function onError(e:Event):void
		{
			//trace( this + " onError: " + e.type );
//			if( e is ErrorEvent )
//			{
//				trace( this + " error info: " + ErrorEvent( e ).text );
//			}

			// stop trackingTimer
			this.playing=false;
			this.videoStarted=false;

			// if it was a bumper, try to continue
			if (BildTvDefines.isBumper)
			{
				this.setNextClip();
				this.playClip();
			}
			// otherwise show message
			else
			{
				// stop overlay timer
				clearTimeout(this.overlayTimeout);

				if (e is ControlEvent && e.type == ControlEvent.ERROR)
				{
					this.dispatchEvent(e.clone());
				}
				else
				{
					this.dispatchEvent(new ControlEvent(ControlEvent.ERROR));
				}
			}
		}

		protected function onVideoEnterFrame(e:Event):void
		{

			if (this.playing)
			{
				this.playtime = -1;
				if( this.hdContent == false) 
				{
					if( this.ns ) this.playtime = this.ns.time;
				}
				else if(this.nsHD && this.duration != -1) 
				{
					if( this.nsHD.time == 0 && ( this.videoVO.duration - this.nsHD.duration ) != 0)
					{
						//mit bitratenwechsel, ins negative spulen
						if(this.nsHD.duration < 0)
						{
							this.playtime = this.savedPosition + this.offsetVideoTime + this.nsHD.duration;
						}
						else
						{
							this.playtime = this.savedPosition + this.offsetVideoTime /*- ( this.videoVO.duration - this.nsHD.duration )*/;
						}
					}
					else if( this.nsHD.time == 0 && ( this.videoVO.duration - this.nsHD.duration ) == 0)
					{
						//mit oder ohne bitratenwechsel, gesamte länge, spuelen nach vorn
						this.playtime = this.nsHD.time + this.savedPosition;
					}
					else
					{
						//normal, mit oder ohne bitratenwechsel ohne spulen
						this.playtime = this.nsHD.time + ( this.videoVO.duration - this.nsHD.duration );
					}
					
					// this.controlsView.updatePlayProgress(this.playtime);
				}
				
				//trace(this + "  " + this.playtime);
				// this.controlsView.updateTime(this.playtime);
				//trace("this.showAds: " + this.showAds + "   this.isBumper: "+ this.isBumper + "   BildTvDefines.adType: " + BildTvDefines.adType);
				/*if (this.subtitleView && !BildTvDefines.isBumper) //BildTvDefines.adType
				{
					this.subtitleView.updateTime(this.playtime);
				}*/

				// this.trackingController.updatePlayProgress(this.playtime);
                ExternalController.dispatch(ExternalController.EVENT_TIMEUPDATE, this.playtime);

				if (this.duration > 0)
				{
					var progress:Number=this.playtime / this.duration;
					//trace(this + " progress: " + progress + ":::"+ this.ns.time + "::" + this.duration);
					// this.controlsView.updatePlayProgress(progress);

					if (!BildTvDefines.isBumper && this.showAds && !this.videoReached50 && progress > 0.5)
					{
						//trace( this + " reached 50 %" );

						// clear overlay timeout
						clearTimeout(this.overlayTimeout);
						this.videoReached50=true;
						this.vastController.load(this.adData.midroll, VastDefines.ADTYPE_MIDROLL);
					}
				}
			}
			
			if (!this.videoIsStream && this.videoLoaded < 1)
			{
				if (this.hdContent == false)
				{
					if( this.ns ) this.videoLoaded=this.ns.bytesLoaded / this.ns.bytesTotal;
				}
				else if(this.nsHD)
				{
					this.videoLoaded=this.nsHD.bytesLoaded / this.nsHD.bytesTotal;
					if(this.nsHD.bytesTotal == 0) this.videoLoaded = 0;
				}
					
				// this.controlsView.updateLoadProgress(this.videoLoaded);
				// this.trackingController.updateBufferProgress(this.videoLoaded);
                ExternalController.dispatch(ExternalController.EVENT_PROGRESS, this.videoLoaded);
				
			}
		}

		protected function checkVideoPos(event:TimerEvent):void
		{
			
			if(Timer(event.currentTarget).currentCount  != this.offsetVideoTime )
			{
				this.offsetVideoTime ++;		
			}
		}
		
		
		protected function checkEndOfVideo(event:TimerEvent):void
		{
            var currentVideoTime:Number = this.hdContent == false ? this.ns.time : this.nsHD.time;

			
			//trace(this + " :: currentTime = " + this.currentVideoTime + " :: lastTime = " + this.previousVideoTime);

			var timeHasntChanged:Boolean=(currentVideoTime == this.previousVideoTime);

			if (this.videoStopped == true && this.videoBufferEmptyStatus != true && this.videoBufferFlushStatus == true && this.playing == true && timeHasntChanged == true)
			{
				this.videoStopped=false;
				this.videoBufferEmptyStatus=false;
				this.videoBufferFlushStatus=false;
				this.playerView.display.removeEventListener(Event.ENTER_FRAME, onVideoEnterFrame, false);

				this.finishPlay();
				if (!BildTvDefines.isBumper)
				{
                    ExternalController.dispatch(ExternalController.EVENT_ENDED);
					// this.trackingController.onClipEnd();
				}


				if (this.checkEndOfVideoTimer.running)
				{
					this.checkEndOfVideoTimer.stop();
				}
			}
			
			if( BildTvDefines.isLivePlayer && this.videoIsPublished == false )
			{
				this.playClip();
				this.reconnectLivestreamTimer.stop();
			}

			this.previousVideoTime=currentVideoTime;
		}

		protected function onVideoFinish():void
		{
            ExternalController.dispatch(ExternalController.EVENT_ENDED);

			// live player: let akamaiController finish
			if (BildTvDefines.isStreamPlayer || BildTvDefines.isMoviePlayer)
			{
				this.akamaiController.finishPlay();
				return;
			}

			if (this.hdContent == false)
			{
				if (this.ns != null) this.ns.pause();
			}
			else
			{
				if (this.nsHD != null) this.nsHD.pause();
			}

			this.adPlaying=false;
			this.playing=false;
			this.videoStarted=false;
			this.showAds=false;
			BildTvDefines.isBumper=false;
			this.contentStarted=false;

			// reset time and progress
			// this.controlsView.setDuration(this.videoVO.duration);
			// this.controlsView.updateTime(0);
			// this.controlsView.updatePlayProgress(0);
			
			if (this.videoVO.autorepeat)
			{
				this.play();
			}
		}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// CONTROL EVENTS HANDLER
///////////////////////////////////////////////////////////////////////////////////////////////////////

		protected function onPlayPauseChange():void
		{

			//trace( this + " onPlayPauseChange - current state: " + this.playing );
			
			if ( false )//BildTvDefines.isMoviePlayer || BildTvDefines.isStreamPlayer)
			{
				//this.vastController.onPlayPauseChange();
			}
			else
			{
				if (this.playing)
				{
                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);
					this.pause();
					// this.trackingController.onClipPause();
				}
				else if (this.adPlaying || this.videoStarted)
				{
					if (this.videoIsStream)
					{
						ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
					}
					this.resume();
					// this.trackingController.onClipResume();
				}
				else
				{
					this.play();
				}
			}
		}

        /* Igor: alte Methodename onProgressChange
         Benutzer ändert position des Videos
          */
		protected function setCurrentTime(time:Number):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logInfo"," onProgressChange - seekPoint: " + time);

			// seeking is allowed for akamai streams if they are movies (Movieplayer) or VOD (StreamPlayer)
			// livestreams are StreamPlayer too, but seeking is not active, so we should never get here in that case 
			/*if (this.subtitleView)
			{
				this.subtitleView.updateSrtPosition(e.data.seekPoint * this.duration);				
			}*/
            if (BildTvDefines.isMoviePlayer || BildTvDefines.isStreamPlayer)
            {
                this.akamaiController.onProgressChange(time);
            }
            else {
                if (this.hdContent == false)
                {
                    if (this.ns != null && !this.adPlaying && (this.videoIsStream || time <= this.videoLoaded * this.duration))
                    {
                        // set lower buffer time to enable fast video start after seeking
                        this.ns.bufferTime=BildTvDefines.buffertimeMinimum;

                        trace(this + " set buffertime to " + this.ns.bufferTime);

                        var newTime:Number=time ;

                        //						ExternalInterface.call("function(){if (window.console) console.log('SEEK TO Sec: "+newTime+"');}");
                        this.ns.seek(newTime);
                    }
                }
                else
                {
                    if (this.nsHD != null && !this.adPlaying)
                    {
                        // set lower buffer time to enable fast video start after seeking
//						this.nsHD.bufferTime= BildTvDefines.buffertimeMinimum * 100;

                        var newHDTime:Number=time * this.duration;

                        this.savedPosition = newHDTime;
                        ExternalInterface.call("com.xoz.flash_logger.logTrace","new time: " + newHDTime + "   saved:" + this.savedPosition );

                        trace("-------------------------");
                        trace(" längediff:" + (this.nsHD.duration - this.videoVO.duration) + "  newpos:" + newHDTime + "  längOrgi:" + this.videoVO.duration);
                        trace("-------------------------");
                        this.offsetVideoTime = 0;
                        this.nsHD.seek( newHDTime + (this.nsHD.duration - this.videoVO.duration) );
                    }
                }
            }


		}
/*
        Igor: Die alte Methode, wenn der Benutzer änderte Volume per Button Klick

		protected function onVolumeChange(e:ControlEvent):void
		{
			var vol:Number = e.data.volume;
			if(vol < 0) vol = 0;
			if(vol > 1) vol = 1;
			
			if(this.muted && vol == 0 )
			{
				//trace("ist mute und neue Vol ist:" + vol);
				vol = this.savedVolume;
				// if( this.controlsView.controls.muteBtn.phase == 0) this.setVolume(vol);
			}
			else
			{
				this.setVolume(vol);
				//trace("ist nicht mute und neues vol ist: " + vol);
			}
		}*/

///////////////////////////////////////////////////////////////////////////////////////////////////////
// AD EVENTS HANDLER
///////////////////////////////////////////////////////////////////////////////////////////////////////

		protected function onAdLinearStart(event:AdEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","onAdLinearStart");
			
			// movieplayer only: start jingle
			if (BildTvDefines.isMoviePlayer)
			{
				this.akamaiController.adPlaying=true;

				if (this.vastController.currentAdType == VastDefines.ADTYPE_MIDROLL)
				{
					this.akamaiController.playMidrollJingle();
				}
			}
			else if (BildTvDefines.isStreamPlayer)
			{
				this.akamaiController.adPlaying=true;
			}
			else
			{
				// pause mainclip (for midrolls)
				if (this.playing)
				{
					if( this.hdContent == false )
					{
						if (this.ns != null)
						{
							this.ns.pause();
						}
					}
					else
					{
						if (this.nsHD != null)
						{
							this.nsHD.pause();
						}			
					}
					this.playing=true;
					//this.paused=true;
					
					//this.playerView.adLabel.visible = true;
					
				}
			}
		}

		protected function onAdLinearStop(event:AdEvent):void
		{
			// called if VPAID ad changed it's playing mode - does not mean that the ad finished displaying
			// do not remove overlay here

			ExternalInterface.call("com.xoz.flash_logger.logTrace"," onAdLinearStop");

			// this.controlsView.showAdControls(false);
			// this.controlsView.enableSeeking(!this.isLivestream);
			// refresh clip info
			// this.controlsView.setDuration(this.videoVO.duration);
			if (!this.paused)
			{
				this.resume();
			}
		}

		protected function onAdError(event:AdEvent):void
		{
			//this.adPlaying = false;
			ExternalInterface.call("com.xoz.flash_logger.logTrace","onAdErrorEvent: "+event.data+" vom Typ:"+event.adPlacement);
			
			//trace(this + " onAdErrorEvent: " + event.data);
			VastController.traceToHtml("++++++++++++ error +++++++++++++++");
			VastController.traceToHtml(event.data as String);

			
			//trace("onAdError:" + event.data + " this.playing=true;" + this.playing );
			/*if( !this.playing ) */this.onAdEnd( event.adPlacement ); //check if timeout with no following adEnd Event has sideeffects
		}

		protected function onAdFinish(event:AdEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","onAdFinish");
			
			this.onAdEnd();
		}

		protected function onAdEnd( adPlacement:String = "" ):void
		{
			var adType:String=this.vastController.currentAdType;
			
			if( adPlacement == VastDefines.ADTYPE_OVERLAY )
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","Overlay end: reset controls and display');}");		
			}
			if( adPlacement != VastDefines.ADTYPE_OVERLAY )
			{
				this.vastController.reset();
				this.vastController.showDisplay(false);
				this.vastController.showOverlay(false);
				// this.controlsView.showAdControls(false, adType);
				// this.controlsView.enableSeeking(!BildTvDefines.isLivePlayer);
				
			}
			else
			{
				adType = adPlacement;
			}
			
			//this.playerView.adLabel.text="";

			ExternalInterface.call("com.xoz.flash_logger.logTrace","onAdEnd: type from VAST:"+adType);
			
			if (BildTvDefines.isMoviePlayer || BildTvDefines.isStreamPlayer)
			{
				//this.akamaiController.adPlaying=false;
			}

			switch (adType)
			{
				case VastDefines.ADTYPE_PREROLL:
				{
					trace(this + " onAdEnd: preroll");

                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

					if (BildTvDefines.isMoviePlayer)
					{
						this.playClip();
						//this.akamaiController.startPlaying();
					}
					//else if( BildTvDefines.isLivePlayer )
					else if (BildTvDefines.isStreamPlayer)
					{
						//this.akamaiController.startLivestream();
						this.playClip();
					}
					else
					{
						this.playClip();
					}

					break;
				}
				case VastDefines.ADTYPE_MIDROLL:
				{
					trace(this + " onAdEnd: midroll");
					this.isAdPlaying = false;

                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

					if (BildTvDefines.isMoviePlayer)
					{
						this.akamaiController.resumeAfterMidroll();
					}
					else
					{
						// refresh clip info
						// this.controlsView.setDuration(this.videoVO.duration);
						//trace("type:" + BildTvDefines.adType +"   playing:" +  this.playing +"  paused:"+ this.paused);
						if ( !this.paused )
						{
							ExternalInterface.call("com.xoz.flash_logger.logTrace","onAdEnd: type from defines: "+BildTvDefines.adType);
							
							if(BildTvDefines.adType != "" && BildTvDefines.adType != null)
							{
								//this.playClip();
								this.resume();		
							}
							else
							{
								this.resume();		
							}
						}
					}

					break;
				}
				case VastDefines.ADTYPE_POSTROLL:
				{
					trace(this + " onAdEnd: postroll");

                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);
					this.onVideoFinish();

					break;
				}
				case VastDefines.ADTYPE_OVERLAY:

				{
					trace(this + " onAdEnd: overlay");

					// refresh clip info
					//this.controlsView.setDuration(this.videoVO.duration);
					if (!this.playing && !this.paused)
					{
						ExternalInterface.call("com.xoz.flash_logger.logTrace","Overlay end: resume Clip now...");
						
						//this.resume();
					}

					break;
				}
				case VastDefines.ADTYPE_NONE:
				{
					//trace("Single Vast Clip finishes, finish the Player now!" + BildTvDefines.isSingleVastPlayer);
					//if( BildTvDefines.isSingleVastPlayer ) this.onVideoFinish();
					break;
				}
				default:
				{
					trace(this + " onAdEnd: other - " + this.vastController.currentAdType);

					break;
				}
			}
		}

		protected function onDisplayResize(e:ControlEvent):void
		{
			//trace( this + " onDisplayResize" );
			/*if (this.subtitleView)
				this.subtitleView.updateSize();*/
			this.vastController.setSize(this.playerView.getPlayerSize(), e.data as FullscreenData);
		}

		protected function showGeoMessage():void
		{
			this.dispatchEvent(new ControlEvent(ControlEvent.ERROR_GEO));
		}

		protected function showAvailableMessage():void
		{
			this.dispatchEvent(new ControlEvent(ControlEvent.ERROR_AVAILABLE, {header: BildTvDefines.TEXT_ERROR_HEADER, info: BildTvDefines.TEXT_ERROR_INFO_AVAILABLE, button: false}));
		}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// DIVERSE STUFF
///////////////////////////////////////////////////////////////////////////////////////////////////////

		protected function parseStreamUrl():Boolean
		{
			/* links may be:
			 * rtmp://cp34973.live.edgefcs.net/live/Flash_Live_Benchmark@632
			 * rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/ovp/content/test/video/spacealonehd_sounas_640_300.mp4
			 * rtmp://pssimn24livefs.fplive.net/pssimn24live-live/n24livestream1/n24livestream1
			 *
			 */

			trace(this + " parseStreamUrl - try #" + this.streamConnects);

			var result:Boolean=true;
			var x:int=this.videoUrl.indexOf("://"); // get the protocol and save it to videoServer, omit it in the urlParts
			this.videoServer=this.videoUrl.substring(0, x + 2); // omit the last /, it gets added in the loop
			this.videoFile="";
			var urlParts:Array=this.videoUrl.substring(x + 3).split("/");

			if (this.streamConnects < urlParts.length)
			{
				// check for a ":" in the url, if so, we have our streamfile ("mp4:...")
				var points:int=this.videoUrl.indexOf(":", x + 3);
				if (points != -1)
				{
					this.streamConnects=urlParts.length; // set to maxTries, so we don't try again if connection is refused
					var slash:int=this.videoUrl.lastIndexOf("/", points);
					this.videoServer=this.videoUrl.substring(0, slash);
					this.videoFile=this.videoUrl.substring(slash + 1);
				}
				// go backwards through url and try every server / file combination
				else
				{
					for (var i:uint=0; i < urlParts.length; i++)
					{
						if (i < urlParts.length - this.streamConnects)
						{
							this.videoServer+="/" + urlParts[i];
						}
						else
						{
							this.videoFile+="/" + urlParts[i];
						}
					}

					// remove first / in videoFile
					this.videoFile=this.videoFile.substring(1);

					// check for mp4 files - first check if it has an extension, then check if it's another than ".flv", finally check if we don't already start with "mp4:"
					if (this.videoFile.substr(-4, 1) == "." && this.videoFile.substr(-4) != ".flv" && this.videoFile.substr(0, 4) != "mp4:")
					{
						this.videoFile="mp4:" + this.videoFile;
					}
				}
			}
			// max tries reached, we cannot connect, very probably geo targeted
			else
			{
//				ExternalInterface.call("function(){if (window.console) console.log('"+this + " Connection refused after try to build Streampath');}");
				this.onNetConnectionRefused();
				result=false;
			}
			
//			ExternalInterface.call("function(){if (window.console) console.log('"+this + " Connection try to build Streampath- connect:"+this.streamConnects+"   url:"+this.videoFile+"');}");

			trace(this + "--> server: " + this.videoServer + ", file: " + this.videoFile);

			return result;
		}

		protected function set currentClip(videoVO:VideoVO):void
		{
			//trace( this + " currentClip: " + videoVO.videoUrl );

			this.duration=videoVO.duration;
			//trace(this + "  setze falsche zeit aus der xml: " + videoVO.duration);
			// deactivate midrolls if video is under 5 minutes
			if (this.duration < 5 * 60)
			{
				this.videoReached50=true;
			}

			// if bumper or linked video, hide the big play/pause button and disable double-click timer
			BildTvDefines.isBumper = (videoVO == this.bumperVO);

			//this.playerView.setDisplayButtonAsPlayPauseButton(!BildTvDefines.isBumper);

			//trace(videoVO.videoUrl + "::::" + videoVO.videoUrl.indexOf("smil"));
			//HDNetwork content
			if ( videoVO.videoUrl.indexOf(".f4m") != -1 || videoVO.videoUrl.indexOf(".smil") != -1 )
			{
				this.hdContent = true;
				//this.videoIsStream=true;
				//this.hdRenderer.ns.maximumBitrateAllowed = bitrateLimit;
				this.videoUrl=videoVO.videoUrl;
				this.videoFile=videoVO.videoUrl;
			}
			else
			{
				this.hdContent=false;
				// streaming
				if (videoVO.videoUrl.substr(0, 4) == "rtmp" || videoVO.videoUrl2.substr(0, 4) == "rtmp")
				{
					if (videoVO.videoUrl.substr(0, 4) == "rtmp")
					{
						this.videoUrl=videoVO.videoUrl;
					}
					else if (videoVO.videoUrl2.substr(0, 4) == "rtmp")
					{
						this.videoUrl=videoVO.videoUrl2;
					}
					this.videoIsStream=true;

					this.videoServer="";
					this.videoFile="";
				}
				// progressive
				else
				{
					this.videoIsStream=false;

					this.videoServer=null;
					if (videoVO.videoUrl.substr(0, 4) != "rtmp" && this.videoSrcPosition == 1)
					{
						this.videoUrl=videoVO.videoUrl;
					}
					else if (videoVO.videoUrl2.substr(0, 4) != "rtmp" && this.videoSrcPosition == 2)
					{
						this.videoUrl=videoVO.videoUrl2;
					}
					this.videoFile=this.videoUrl;
				}

			}
		}

		// checks if we have a stream and no duration -> standard livestream (no akamai)
		protected function get isLivestream():Boolean
		{
			return (this.videoIsStream && ( this.duration == -1 || this.duration == 1 || this.duration == 1000 ));
		}

		/********************************************************************************************************
		 * EXTERNAL CALLBACKS
		 *******************************************************************************************************/

        public function volume(value:Number = NaN):Number {
            if (!isNaN(value)) {
                this.setVolume( value );
                if(this.vastController) this.vastController.setVolume(this.savedVolume);
            }

            return this.soundTransform ? this.soundTransform.volume : 0;
        }

        public function mute(param:String = ""):Boolean
        {
            if (param != "") {
                var muteValue:Number = param == "false" ? this.savedVolume : 0;
                volume( muteValue );
            }

            return this.muted
        }

        public function currentTime(value:Number = NaN):Number
        {
            if (!isNaN(value)) {
                this.setCurrentTime( value );
            }

            return this.playtime
        }

        public function getDuration():Number
        {
            return this.duration
        }

        public function getBufferTime():Number
        {
            var bufferTime:Number = 0;
            if (!hdContent)
            {
                if (ns) bufferTime = this.playtime + ns.bufferLength;
            }
            else if (nsHD)
            {
                bufferTime = this.playtime + nsHD.bufferLength;
            }
            return bufferTime
        }

		
		/*public function apiCall(type:String, params:Object):void
		{
			switch(type)
			{
				case CALLBACK_VOLUME_ON:
				{
					this.setVolume( this.savedVolume );
					if(this.vastController) this.vastController.setVolume(this.savedVolume);
					break;
				}
				case CALLBACK_VOLUME_OFF:
				{
					this.setVolume( 0 );
					if(this.vastController) this.vastController.setVolume(0);
					break;
				}
				case CALLBACK_VOLUME_UP:
				{
					var up:Number = params.volumeChange;
					this.setVolume( this.savedVolume + up );
					if(this.vastController) this.vastController.setVolume(this.savedVolume + up);
					break;
				}
				case CALLBACK_VOLUME_DOWN:
				{
					var down:Number = params.volumeChange;
					this.setVolume( this.savedVolume - down );
					if(this.vastController) this.vastController.setVolume(this.savedVolume - down);
					break;
				}
				case CALLBACK_VOLUME_UPDATE:
				{
					var volume:Number = params.volume;
					this.savedVolume = volume;
					this.setVolume( this.savedVolume );
					if(this.vastController) this.vastController.setVolume(this.savedVolume);
					break;
				}
				case CALLBACK_HD_ON:
				{
					// if(this.controlsView.controls.hdBtn)this.controlsView.controls.hdBtn.phase= 1;
					this.videoVO.startHDQuality = true;
					this.setHDBitrate();
					break;
				}
				case CALLBACK_HD_OFF:
				{
					// if(this.controlsView.controls.hdBtn)this.controlsView.controls.hdBtn.phase= 0;
					this.videoVO.startHDQuality = false;
					this.setHDBitrate();
					break;
				}
				case CALLBACK_PLAY_WITHOUT_PREROLL:
				{
					this.play(false);
					break;
				}
				case CALLBACK_PLAY_WITH_PREROLL:
				{
					this.play();
					break;
				}
				case CALLBACK_PAUSE:
				{
					this.pause();
					break;
				}
				case CALLBACK_RESUME:
				{
					this.resume();
					break;
				}
				case CALLBACK_AD_CLICK:
				{
					if( this.vastController ) this.vastController.erternalAdClick();
					
					if( BildTvDefines.isBumper)
					{
						this.onDisplayClick();
					}
					break;
				}
				case CALLBACK_SEEK:
				{			
					var percent:Number = params.seekTime /this.duration;
//					ExternalInterface.call("function(){if (window.console) console.log('SEEK TO : "+percent+"');}");
					// this.controlsView.controls.progressBar.changeProgressByExtern(percent);
					//this.controlsView.updateTime( params.seekTime );
					//this.controlsView.updatePlayProgress( percent );
					//this.playerController.s ();
					// this.trackingController.trackPlayerEvent("BITRATESWITCH_FINISH");
					break;
				}
					default:break;
			}
		}
*/
		/********************************************************************************************************
		 * BUMPER STUFF
		 *******************************************************************************************************/

	/*	protected function loadBumperXml(url:String):void
		{
			trace(this + " loadBumperXml: " + url);

//			ExternalInterface.call("function(){if (window.console) console.log('"+this + " loadBumperXml: " + url+"');}");
            ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
			this.playerView.supressPlayDisplayButton(true);
			var xmlLoader:XmlLoader=new XmlLoader();
			xmlLoader.addEventListener(XmlEvent.XML_LOADED, onBumperXmlLoaded, false, 0, true);
			xmlLoader.addEventListener(XmlEvent.XML_ERROR, onBumperXmlError, false, 0, true);
			xmlLoader.loadXml(url);
		}

		protected function onBumperXmlLoaded(e:XmlEvent):void
		{
			trace("onBumperXmlLoaded");
			this.dispatchEvent(new ControlEvent(ControlEvent.LOADERANI_CHANGE, {visible: false}));
			// to get to the "link" node we have to create a temp config object
			var config:ConfigVO=new ConfigVO();
			config.hydrate(e.xml);
			this.bumperVO=config.videoVO;
//			ExternalInterface.call("function(){if (window.console) console.log('onBumperXmlLoaded:::"+config.videoVO.videoUrl+"');}");
			this.playClip();
			this.playerView.supressPlayDisplayButton(false);
		}

		protected function onBumperXmlError(e:XmlEvent):void
		{
			trace("onBumperXmlError: " + e.text);
//			ExternalInterface.call("function(){if (window.console) console.log('onBumperXmlError: "+ e.text+"');}");
			this.playerView.supressPlayDisplayButton(false);
            ExternalController.dispatch(ExternalController.EVENT_WAITING, false);
			this.setNextClip();
			this.playClip();
		}

		*/

        protected function emptyCallback(... args):void
        {
            // nix drin
        }

		/*protected function forwardEvent(event:Event):void
		{
			this.dispatchEvent(event.clone());
			if (this.adPlaying == false && event.type == ControlEvent.LOADERANI_CHANGE) //toDelete  richtiges Event muss noch weitergereicht werden!!!-->AdStart oder so..
			{
				this.adPlaying=true;
			}
		}*/



////////////////////////////////////////////////////////////////////////////////////////////
// Akamai HD Module only
////////////////////////////////////////////////////////////////////////////////////////////
		public function setHDBitrate(phase:Number = 0) :void
		{
			if(this.nsHD == null ) return;
			try
			{
				this.videoVO.startHDQuality = !this.videoVO.startHDQuality;
				
				if(this.savedPosition != this.nsHD.time)
				{
					this.savedPosition = /*this.savedPosition +*/ this.nsHD.time;				
				}
				else
				{
					this.savedPosition = this.nsHD.time;			
				}
	
				if( this.videoVO.startHDQuality )
				{
					this.doSwitchBitrate(1);
					
					// this.trackingController.trackPlayerEvent("HD_ON");
				}
				else
				{
					this.doSwitchBitrate(-1);
					
					// this.trackingController.trackPlayerEvent("HD_OFF");
				}
			}
			catch(e:Error)
			{
				trace( e.message );
			}
		}
				
		private function doSwitchBitrate(step:Number) : void {
			if ( this.nsHD && this.nsHD.manualSwitchMode == true ) {
				trace(" doSwitchBitrate : "+step);
				var time:Number = this.savedPosition;
//				if (this.nsHD.isLiveStream)time = this.nsHD.duration;
				if (this.nsHD.isLiveStream)time = this.nsHD.timeAsUTC;
				
				var index:int;
				if( step == 1 ) index= this.nsHD.maxAllowedIndex;
				if( step == -1 ) index= 0;
				
				if (index<= this.nsHD.maxAllowedIndex && index>=0) 
				{
					this.nsHD.startingIndex = index;
					
					// if(this.controlsView.controls.hdBtn) this.controlsView.controls.hdBtn.disabled = true;
					
					this.offsetVideoTime = 0;
					
					if (time<10)	
					{
						this.savedPosition = 0;
						// this.controlsView.updateTime(0);
						// this.controlsView.updatePlayProgress(0);
						this.nsHD.play(this.videoFile);
					}
					else
					{
						this.nsHD.play(this.videoFile, time);			
					}
				}
			}
		}
		


////////////////////////////////////////////////////////////////////////////////////////////
// movieplayer only
////////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * movieplayer only
		 */
		public function setMovie(filmVO:FilmVO):void
		{
			this.filmVO=filmVO;

			this.videoVO=new VideoVO();
			this.videoVO.videoUrl=filmVO.streamUrl;
			this.videoVO.videoUrl2=filmVO.streamUrl2;
			this.videoVO.duration=filmVO.duration;
			this.videoVO.autoplay=true;

			this.adData=filmVO.adVO;
			this.showAds=true;

			// controller for akamai streams
			this.akamaiController=new AkamaiController(this.playerView); // , this.controlsView
			//this.akamaiController.addEventListener(ControlEvent.LOADERANI_CHANGE, forwardEvent);
			this.akamaiController.addEventListener(ControlEvent.PAUSE, externalPause);
			this.akamaiController.addEventListener(ControlEvent.RESUME, externalResume);
			this.akamaiController.addEventListener(ControlEvent.LOAD_MIDROLL, loadMidroll);
			this.akamaiController.addEventListener(ControlEvent.LOAD_POSTROLL, loadPostroll);
			this.akamaiController.addEventListener(ControlEvent.JINGLE_FINISHED, onJingleFinished);
			this.akamaiController.addEventListener(ControlEvent.CONTENT_START, onContentStart);
			this.akamaiController.addEventListener(ControlEvent.ERROR, onError);
			this.akamaiController.setMovie(filmVO);
			this.akamaiController.setVolume(this.soundTransform.volume);


			// autoplay
			this.clip2play=CLIP_CONTENT;

			// start stream
			//this.akamaiController.startPlaying();
			// start preroll
			this.adPlaying=true;
			this.vastController.load(filmVO.adVO.preroll, VastDefines.ADTYPE_PREROLL);
		}

		protected function externalPause(event:ControlEvent):void
		{
			this.vastController.pause();
		}

		protected function externalResume(event:ControlEvent):void
		{
			this.vastController.resume();
		}

		protected function loadMidroll(event:ControlEvent):void
		{
			// clear overlay timeout
			clearTimeout(this.overlayTimeout);
			this.vastController.load(this.adData.midroll, VastDefines.ADTYPE_MIDROLL, false);
		}

		protected function onJingleFinished(event:ControlEvent):void
		{
			trace(this + " onJingleFinished");

			this.vastController.startAd();
		}

////////////////////////////////////////////////////////////////////////////////////////////
// liveplayer only
////////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * liveplayer only
		 */
		public function setStream(streamingVO:StreamingVO):void
		{
			this.streamingVO=streamingVO;

			this.videoVO=new VideoVO();
//			this.videoVO.headline = streamingVO.title;
			this.videoVO.videoUrl=streamingVO.streamUrl;
			this.videoVO.videoUrl2=streamingVO.streamUrl2;
//			this.videoVO.imageUrl = streamingVO.thumbnailUrl;
			this.videoVO.duration=streamingVO.duration;
			this.videoVO.autoplay=streamingVO.autoplay;

			this.adData=streamingVO.adVO;
			this.showAds=true;

			// controller for akamai streams
			/*this.akamaiController=new AkamaiController(this.playerView, this.controlsView, // this.trackingController);
			this.akamaiController.addEventListener(ControlEvent.LOADERANI_CHANGE, forwardEvent);
			this.akamaiController.addEventListener(ControlEvent.LOAD_POSTROLL, loadPostroll);
			this.akamaiController.addEventListener(ControlEvent.VIDEO_FINISH, finishPlay);
			this.akamaiController.addEventListener(ControlEvent.JINGLE_FINISHED, onJingleFinished);
			this.akamaiController.addEventListener(ControlEvent.ERROR, onError);
			this.akamaiController.setStream(streamingVO);
			this.akamaiController.setVolume(this.soundTransform.volume);*/

			// autoplay
			this.clip2play=CLIP_CONTENT;
			// track playClick
			
//			if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('LOG SSTART ON STARTSTEAM!');}");
			// this.trackingController.onClipPlay();

			// start stream
//			this.akamaiController.startLivestream();
			// start preroll
			this.adPlaying=true;
			this.vastController.load(streamingVO.adVO.preroll, VastDefines.ADTYPE_PREROLL);
		}

		/**
		 * only for Movie- or LivePlayer
		 */
		protected function loadPostroll(event:ControlEvent):void
		{
			var url:String="";
			if (BildTvDefines.isMoviePlayer)
			{
				url=this.filmVO.adVO.postroll;
			}
			if (BildTvDefines.isStreamPlayer)
			{
				url=this.streamingVO.adVO.postroll;
			}

			// clear overlay timeout
			clearTimeout(this.overlayTimeout);
			this.vastController.load(url, VastDefines.ADTYPE_POSTROLL);
		}
	}
}
