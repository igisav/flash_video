package de.axelspringer.videoplayer.controller
{
    import com.akamai.net.f4f.ZStream;

    import de.axelspringer.videoplayer.event.ControlEvent;
    import de.axelspringer.videoplayer.model.vo.Const;
    import de.axelspringer.videoplayer.model.vo.FilmVO;
    import de.axelspringer.videoplayer.model.vo.StreamingVO;
    import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.util.Log;
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
    import flash.utils.Timer;
    import flash.utils.setTimeout;

    public class PlayerController extends EventDispatcher
	{
		private static const TIMER_DELAY:Number=500;

		// gui
		protected var playerView:PlayerView;

		// netstream stuff
		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var soundTransform:SoundTransform;

		protected var nsHD:ZStream;
		// data
		protected var videoVO:VideoVO = new VideoVO();
		protected var videoUrl:String;
		protected var videoSrcPosition:Number=1;
		protected var videoServer:String;
		protected var videoFile:String;
		protected var videoIsStream:Boolean;
		protected var streamConnects:uint;
		protected var hdContent:Boolean=false;
		protected var startBitrateSetted:Boolean=false;

		// stream status
		protected var isPlaying:Boolean=false;

        /* Video playtime > 0, means it's received Net.Status.Play
         * It can be paused. */
 		protected var videoStarted:Boolean=false;

        /* NetStream.Play.Stop
         * Video is stopped by user, error or reached the end */
		protected var videoStopped:Boolean=false;

		protected var videoLoaded:Number=0;
		protected var videoBufferEmptyStatus:Boolean=false;
		protected var videoBufferFlushStatus:Boolean=false;
		protected var videoIsPublished:Boolean=false;
		protected var paused:Boolean=false;
		protected var metadata:Object;
		protected var duration:Number;
		protected var playtime:Number = 0; // currentTime
		protected var savedVolume:Number=0;
		protected var savedPosition:Number = 0;
		protected var muted:Boolean=false;

		//Variables to finish a Video which can't be flushed
		protected var previousVideoTime:Number;
		protected var offsetVideoTime:int;
		protected var videoTimer:Timer;
		protected var checkEndOfVideoTimer:Timer;
		protected var reconnectLivestreamTimer:Timer;

		// movieplayer & liveplayer only
		protected var filmVO:FilmVO;
		protected var akamaiController:AkamaiController;

		public function PlayerController(playerView:PlayerView)
		{
			super(this);

			this.playerView=playerView;
			this.initPlayer()
		}

		protected function initPlayer():void
		{
			this.nc=new NetConnection();
			this.nc.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus, false, 0, true);
			this.nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true);
			this.nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError, false, 0, true);
			this.nc.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
            var client:Object={};
            client.onBWCheck=this.emptyCallback;
            client.onBWDone=this.emptyCallback;
            this.nc.client=client;

			//checkEndOfVideoTimer init
			this.checkEndOfVideoTimer = new Timer(TIMER_DELAY);
			this.checkEndOfVideoTimer.addEventListener(TimerEvent.TIMER, checkEndOfVideo);
			
			this.videoTimer = new Timer(1000);
			this.videoTimer.addEventListener(TimerEvent.TIMER, checkVideoPos);
			
			this.reconnectLivestreamTimer = new Timer(2000,10);
			this.reconnectLivestreamTimer.addEventListener(TimerEvent.TIMER, onReconnectLivestream);
			this.reconnectLivestreamTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onReconnectLivestreamLimitReached);



			this.soundTransform=new SoundTransform();

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
		}
		
		public function setVolume(volume:Number):void
		{
			if (volume <= 0)
			{
				this.savedVolume=this.soundTransform.volume;
				this.muted=true;
				volume=Math.min(1, Math.max(0, volume));
			}
			else
			{
				this.muted=false;
				volume=Math.min(1, Math.max(0, volume));
				this.savedVolume = volume;
			}

			if (this.hdContent == false )
			{
				if ((Const.isMoviePlayer || Const.isStreamPlayer )&& akamaiController != null)
				{
					this.akamaiController.setVolume(volume);
				}
				else
				{
					this.soundTransform.volume=volume;

					if (this.ns != null)
					{
						this.ns.soundTransform=this.soundTransform;
					}
				}
			}
			else
			{
				this.soundTransform.volume=volume;

				if (this.nsHD != null)
				{
					this.nsHD.soundTransform=this.soundTransform;
				}
			}

            ExternalController.dispatch(ExternalController.EVENT_VOLUME_CHANGE);
		}
        
		public function setClip(videoVO:VideoVO):void
		{
			if(!videoVO)
			{
                Log.error(Const.ERROR_EMPTY_VIDEOCLIP);
				return;
			}
			this.videoVO=videoVO;
			this.playing=false;
			this.videoStarted=false;
			Const.isBumper=false;

			if( this.videoVO.mute )
			{
				this.setVolume( 0 );
			}
			
			if ( videoVO.videoUrl.indexOf(".f4m") != -1 || videoVO.videoUrl.indexOf(".smil") != -1 )
			{
				this.hdContent=true;
			}
			 
			this.playerView.display.clear();
			
			// check autoplay
			trace("autoplay = " + videoVO.autoplay + ":::" + Const.autoplay);
			if (Const.autoplaySet == false)
			{
				Const.autoplay=videoVO.autoplay;
				Const.autoplaySet=true;
			}

			if (Const.autoplay)
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
			}
		}

		public function resume():void
		{
			this.videoTimer.start();
			ExternalInterface.call("com.xoz.flash_logger.logTrace","------------RESUME STREAM!----------------");
			 if (this.videoStarted)
			{
				if (this.hdContent == false)
				{
					this.ns.bufferTime=Const.buffertimeMinimum;

					trace(this + " set buffertime to " + this.ns.bufferTime);

					this.ns.resume();
						// sometimes the stream just won't resume, so force it with a seek to the current position - not sure why but it works
						//this.ns.seek( this.ns.time );			
				}
				else
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","DVR Availability:"+this.nsHD.dvrAvailability);
					
					if( Const.isLivePlayer && this.nsHD.dvrAvailability != "none")
					{
						
						//seek first and then resume, only in livestream
						ExternalInterface.call("com.xoz.flash_logger.logTrace","first seek, then resume, because DVR is available");
						this.nsHD.seek(this.nsHD.duration);
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
			}
		}

		public function play():void
		{
			ExternalController.dispatch(ExternalController.EVENT_PLAY);

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
            if (this.videoVO.videoUrl == "") {
                Log.error(Const.ERROR_NO_URL_FOUND, Const.ERROR_TYPE_SOURCE);
                return;
            }

			this.previousVideoTime = this.savedPosition;
			this.videoLoaded=0;

            this.currentClip = this.videoVO;

			// start playing!
			this.playing = true;
			
			if (this.videoIsStream)
			{
				// disable seeking for livestreams -> duration is -1
				if (this.videoVO.videoUrl.substr(0, 4) == "rtmp")
				{
					if( Const.isLivePlayer )
					{

						if(!Const.isBumper )
						{
							this.duration = -1;
						}						
					}
					this.streamConnects=1;
					this.playStream();
				}
			}
			else
			{
				if( Const.isLivePlayer )
				{
					if(!Const.isBumper )
					{
						this.duration = -1;
					}

				}
				//check if nc is already connected
				if( this.nc.connected && this.nc.uri == "null" )
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","POST REQUEST @ playClip if noStream and this.nc.connected && this.nc.uri == null");
					redirectConnection();
				}
				else
				{
					this.nc.connect(null);	
				}
				
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
					redirectConnection();
				}
				else
				{
					this.nc.connect(this.videoServer);
				}
			}
		}

		public function destroy():void
		{
            Log.info(this + " destroy stream connection");
            this.videoTimer.stop();

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
                    this.nsHD.closeAndDestroy();
                    //this.nsHD=null;
                }
            }
        }

		/**
		 * general flag - true if anything is playing (content or ad)
		 */
		protected function set playing(value:Boolean):void
		{
			trace(this + " ------ set playing  " + value);
			this.isPlaying=value;
		}

		protected function get playing():Boolean
		{
			return this.isPlaying;
		}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// STREAM EVENTS HANDLER
///////////////////////////////////////////////////////////////////////////////////////////////////////

		protected function onNetConnectionConnect():void
		{
			this.ns=new NetStream(this.nc);
			this.ns.soundTransform=this.soundTransform;
			if( isLivestream )
			{
				this.ns.bufferTime=Const.liveBuffertimeMinimum;
			}
			else
			{
				this.ns.bufferTime=Const.buffertimeMinimum;
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
			
            this.ns.play( this.videoFile );
			this.videoTimer.start();
			this.offsetVideoTime = 0;
		}
		
		protected function onHDNetConnectionConnect():void
		{
			trace( this + " onNetConnectionConnect: " + this.videoFile );

            // TODO: check what this for???
			this.nc = new NetConnection();
			this.nc.connect(null);
			
			if ( this.nsHD && !isNaN(this.nsHD.time) )
			{
				this.nsHD.closeAndDestroy();
			}
			
			this.nsHD=new ZStream(this.nc);	
					
			this.nsHD.soundTransform=this.soundTransform;

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

			this.nsHD.addClientHandler( "onMetaData", this.onMetaData);
			this.nsHD.addClientHandler( "onPlayStatus", this.onPlayStatusHD);
			this.nsHD.addClientHandler( "dvrAvailabilityChange", onDvrAvailabilityChange);
			this.nsHD.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus, false, 0, true);
			this.nsHD.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				
            this.playerView.display.attachNetStream(this.nsHD);
            this.playerView.display.smoothing = true;
            this.playerView.display.deblocking = 0;

            ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
            ExternalInterface.call("com.xoz.flash_logger.logTrace","FLASH PLAY: "+ this.videoFile);

            this.nsHD.play( this.videoFile );
            this.videoTimer.start();
            this.offsetVideoTime = 0;
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
            var msg:String = event.type + ": " + event.toString();
			if(this.nsHD && ZStream(event.currentTarget).duration != 0)
			{
                msg = Const.ERROR_HD_CORE;
                Log.error(msg, Const.ERROR_TYPE_NETWORK);
                return;
            }
            Log.error(msg, Const.ERROR_TYPE_NETWORK);

            this.playing=false;
            this.videoStopped=true;
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
		}

		protected function onNetConnectionStatus(e:NetStatusEvent):void
		{
			Log.info (e.info.code)
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
				{
					this.redirectConnection();
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
                    Log.error(e.info.code, Const.ERROR_TYPE_NETWORK);
					break;
				}
				case "NetConnection.Connect.Refused":
				case "NetConnection.Connect.Failed":
				{
                    Log.error(e.info.code, Const.ERROR_TYPE_NETWORK);
					setTimeout(onNetConnectionFail, 100);
					break;
				}
			}
		}
		
		private function redirectConnection():void
		{
            trace("play: redirect davor: "+ this.videoFile+"  hd? "+this.hdContent);

			if( Const.isBumper )
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
					
				trace("POST REQUEST @ X-NoRedirect REDIRECT");
					
					
				scriptRequest.requestHeaders.push(new URLRequestHeader("X-NoRedirect", "false"));
				scriptRequest.method = URLRequestMethod.POST;
				scriptRequest.data = new URLVariables("NoRedirect=false");
					
				ExternalInterface.call("com.xoz.flash_logger.logTrace","TRY REDIRECT IN FLASH");
					
				if( this.hdContent == false ) 
				{				
					//toDo ... check Problesm with Security and crossdomain.xml if content can't be loaded
						
					scriptLoader.addEventListener(Event.COMPLETE, rDLoaded);
					scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, onRedirectError);
					scriptLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRedirectError);
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
					scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, onRedirectHDError);
					scriptLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRedirectHDError);
					scriptLoader.load(scriptRequest);
				}
			}
		}

        protected function onRedirectError(event:Error):void
        {
            Log.error(Const.ERROR_REDIRECT + event.type, Const.ERROR_TYPE_NETWORK);
            this.onNetConnectionConnect();
        }

		protected function onRedirectHDError(event:Error):void
		{
            Log.error(Const.ERROR_REDIRECT + event.type, Const.ERROR_TYPE_NETWORK);
			this.onHDNetConnectionConnect();
			
		}
		
		protected function rHDLoaded(event:Event):void
		{
			this.videoFile = event.currentTarget.data;
            Log.error(Const.ERROR_REDIRECT + event.type, Const.ERROR_TYPE_NETWORK);
		
			if(event.currentTarget.data as XML)
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","redirect complete! but its an XML and no URL " + this.videoFile);
				this.playing=false;
				this.videoStopped=true;
			}
			else
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","redirect complete! " + this.videoFile);
				this.onHDNetConnectionConnect();		
			}		
			
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
				
				trace("AFTER TRY REDIRECT IN FLASH, VALIDATE "+ event.currentTarget.data);
				
				var pattern:RegExp = new RegExp("^http[s]?\:\\/\\/([^\\/]+)\\/");
				
				var urls:Array = String(event.currentTarget.data).match(pattern);
				var isUrl:Boolean = (urls && urls.length > 0 );
				
				ExternalInterface.call("com.xoz.flash_logger.logTrace","URL PASSED THE VALIDATOR: "+isUrl);
				if( isUrl )
				{
					this.videoFile = event.currentTarget.data;
					trace("AFTER VALIDATE, PLAY  "+ this.videoFile);
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
					}
				}
			}
			else
			{
//				'AFTER TRY REDIRECT IN FLASH, PLAY MP4  "+ this.videoFile +"');}");
				this.onNetConnectionConnect();		
			}
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
						this.ns.bufferTime= Const.buffertimeMinimum;
					}
					else 
					{
						if( Const.isLivePlayer && this.nsHD.dvrAvailability != "none" )
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
					if (this.hdContent == false) this.ns.bufferTime = Const.buffertimeMaximum;

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
							this.ns.bufferTime=Const.buffertimeMinimum;
						}
					}
                    ExternalController.dispatch(ExternalController.EVENT_EMPTIED);

					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
                    Log.error(e.info.code, Const.ERROR_TYPE_SOURCE);
					
					if ( Const.isLivePlayer )
					{
						if( this.hdContent )
						{
							this.onHDNetConnectionConnect();	
						}
						else
						{
							this.playing=false;
							this.videoStopped=true;
						}
					}
					else
					{
                        this.playing=false;
                        this.videoStopped=true;
					}
					break;
				}
				case "NetStream.Play.Start":
				{
                    ExternalController.dispatch(ExternalController.EVENT_PLAYING);

					if( this.nsHD )
					{
						if( this.nsHD.isLiveStream )
						{
							this.duration = -1;
							Const.isLivePlayer = true;
							this.videoVO.duration=Number(this.duration);
						}
					}
					// seeking in streams may trigger Play.Start, so check paused state
					if (!this.paused)
					{
						this.videoStarted=true;
						this.videoStopped=false;
						this.videoBufferEmptyStatus=false;
						this.videoBufferFlushStatus=false;

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
					onFinishPlay();
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
					break;
				}		
			}

			// check for clip end
			if (this.videoStopped == true && this.videoBufferEmptyStatus != true && this.videoBufferFlushStatus == true)
			{
				this.checkEndOfVideoTimer.start();
			}

			if (this.videoStopped == true && this.videoBufferEmptyStatus == true && this.videoBufferFlushStatus == true)
			{
				if (this.checkEndOfVideoTimer.running)
				{
					this.checkEndOfVideoTimer.stop();
				}
				this.videoStopped=false;
				this.videoBufferEmptyStatus=false;
				this.videoBufferFlushStatus=false;

				this.playerView.display.removeEventListener(Event.ENTER_FRAME, onVideoEnterFrame, false);
			
                if( this.videoStarted )
                {
                    this.onFinishPlay();
                }
                ExternalController.dispatch(ExternalController.EVENT_ENDED);
			}
		}

		protected static function onDvrAvailabilityChange(evt:Object):void
		{
			Log.info("Changed DVR Availibilty Changed to :: " + evt.code);
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
					this.onFinishPlay();
					break;
				}
				case "NetStream.Play.TransitionComplete":
				{
					ExternalInterface.call("com.xoz.flash_logger.logTrace","Bitratetransition changed...finish: " + evt.index + " time:" + this.nsHD.time);
					break;
				}
				case "NetStream.Seek.Notify":
				{
                    ExternalController.dispatch(ExternalController.EVENT_SEEKED);
					if( Const.isLivePlayer )
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
						this.nsHD.startingIndex = highestIndex;
					}
					catch(e:Error)
					{
                        Log.error("OnMetaData Error: " + e.toString(), Const.ERROR_TYPE_NETWORK);
					}
				}
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
				if (data.duration != null )
				{
					if( this.duration != -1)
					{			
						this.videoVO.duration=Number(data.duration);
						this.duration=Number(data.duration);
					}
				}
				else
				{
					this.duration = -1;
					Const.isLivePlayer = true;
				}
			}
		}

		protected function onError(e:Event):void
		{
            // TODO : playing anhalten !!!
			this.playing=false;
			this.videoStarted=false;
            var msg:String = e.type + ": " + e;
            Log.error(msg, Const.ERROR_TYPE_NETWORK);
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
				}
                ExternalController.dispatch(ExternalController.EVENT_TIMEUPDATE, this.playtime);
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
			var timeHasntChanged:Boolean=(currentVideoTime == this.previousVideoTime);

			if (this.videoStopped == true && this.videoBufferEmptyStatus != true && this.videoBufferFlushStatus == true && this.playing == true && timeHasntChanged == true)
			{
				this.videoStopped=false;
				this.videoBufferEmptyStatus=false;
				this.videoBufferFlushStatus=false;
				this.playerView.display.removeEventListener(Event.ENTER_FRAME, onVideoEnterFrame, false);

				this.onFinishPlay();
				if (!Const.isBumper)
				{
                    ExternalController.dispatch(ExternalController.EVENT_ENDED);
				}


				if (this.checkEndOfVideoTimer.running)
				{
					this.checkEndOfVideoTimer.stop();
				}
			}
			
			if( Const.isLivePlayer && this.videoIsPublished == false )
			{
				this.playClip();
				this.reconnectLivestreamTimer.stop();
			}

			this.previousVideoTime=currentVideoTime;
		}

		protected function onFinishPlay():void
		{
            ExternalController.dispatch(ExternalController.EVENT_ENDED);

			// live player: let akamaiController finish
			if (Const.isStreamPlayer || Const.isMoviePlayer)
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

			this.playing=false;
			this.videoStarted=false;
			Const.isBumper=false;

			if (this.videoVO.autorepeat)
			{
				this.play();
			}
		}


        /*
         Benutzer ändert position des Videos
          */
		protected function setCurrentTime(time:Number):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logInfo"," onProgressChange - seekPoint: " + time);
            if (Const.isMoviePlayer || Const.isStreamPlayer)
            {
                this.akamaiController.onProgressChange(time);
            }
            else {
                if (this.hdContent == false)
                {
                    if (this.ns != null && (this.videoIsStream || time <= this.videoLoaded * this.duration))
                    {
                        // set lower buffer time to enable fast video start after seeking
                        this.ns.bufferTime=Const.buffertimeMinimum;

                        trace(this + " set buffertime to " + this.ns.bufferTime);

                        this.ns.seek(time);
                    }
                }
                else
                {
                    if (this.nsHD != null )
                    {
                        var newHDTime:Number=time * this.duration;

                        this.savedPosition = newHDTime;
                        this.offsetVideoTime = 0;
                        this.nsHD.seek( newHDTime + (this.nsHD.duration - this.videoVO.duration) );
                    }
                }
            }


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
				this.onNetConnectionRefused();
				result=false;
			}
			return result;
		}

		protected function set currentClip(videoVO:VideoVO):void
		{
			this.duration=videoVO.duration;

			//HDNetwork content
			if ( videoVO.videoUrl.indexOf(".f4m") != -1 || videoVO.videoUrl.indexOf(".smil") != -1 )
			{
				this.hdContent = true;
				this.videoUrl=videoVO.videoUrl;
				this.videoFile=videoVO.videoUrl;
			}
			else
			{
				this.hdContent=false;
				// streaming
				if (videoVO.videoUrl.substr(0, 4) == "rtmp")
				{
				    this.videoUrl=videoVO.videoUrl;
					this.videoIsStream=true;
					this.videoServer="";
					this.videoFile="";
				}
				// progressive
				else
				{
					this.videoIsStream=false;
					this.videoServer=null;
					this.videoUrl=videoVO.videoUrl;
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
				case CALLBACK_HD_ON:
				{
					this.videoVO.startHDQuality = true;
					this.setHDBitrate();
					break;
				}
				case CALLBACK_HD_OFF:
				{
					this.videoVO.startHDQuality = false;
					this.setHDBitrate();
					break;
				}
		}
*/

        protected function emptyCallback(... args):void
        {
            // nix drin
        }


////////////////////////////////////////////////////////////////////////////////////////////
// Akamai HD Module only
////////////////////////////////////////////////////////////////////////////////////////////
		public function setHDBitrate() :void
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
				}
				else
				{
					this.doSwitchBitrate(-1);
				}
			}
			catch(error:Error)
			{
                var msg:String = error.message == "" ? Const.ERROR_HD_BITRATE : error.message;
                Log.error(msg, Const.ERROR_TYPE_NETWORK);
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
					this.offsetVideoTime = 0;
					
					if (time<10)	
					{
						this.savedPosition = 0;
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
			this.videoVO.duration=filmVO.duration;
			this.videoVO.autoplay=true;

			// controller for akamai streams
			this.akamaiController=new AkamaiController(this.playerView); // , this.controlsView
			this.akamaiController.setMovie(filmVO);
			this.akamaiController.setVolume(this.soundTransform.volume);
		}

	}
}
