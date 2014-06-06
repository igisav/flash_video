package de.axelspringer.videoplayer.controller
{
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.TrackingEventNames;
	import de.axelspringer.videoplayer.model.vo.TrackingVO;
	import de.axelspringer.videoplayer.model.vo.VideoVO;
	import de.axelspringer.videoplayer.util.PausableTimer;
	
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.utils.Timer;
	import flash.utils.escapeMultiByte;
	import flash.utils.getTimer;
	
	import tv.tvnext.stdlib.utils.StringUtils;
	
	public class TrackingController
	{
		// stati
		public static const STATUS_INIT:String 	= "init"; 	//wird einmalig versendet wenn der User initial auf das Video klickt, und nicht wie im Beispiel bereits beim Load des gesamten Players 
		public static const STATUS_PLAY:String 	= "play"; 	//wird einmalig versendet wenn der Videocontent startet, ist preoll-Werbung im Video, so wird die Aktion "play" erst nach der preroll versendet, ansonsten wird erst "init" und sofort danach "play" versendet, beides immer mit der currentVideoposition = 0 
		public static const STATUS_PAUSE:String = "pause"; 	//wir immer versendet, wenn der User den Pause Button betätigt 
		public static const STATUS_POS:String 	= "pos"; 	//das Kommando wird alle 10 Sekunden automatisch als keepalive versendet solange das Video abspielt, das Kommando gibt die aktuelle Abspielweite des Videos wieder, wird das Video pausiert, wird das Kommando natürlich nicht versendet 
		public static const STATUS_END:String 	= "eof";
		
		protected static const PROGRESS_INTERVAL_CLIP:int 	= 10000;
		protected static const PROGRESS_INTERVAL_STREAM:int = 20000;
		
		// diverse stuff
		protected var timerProgress:Timer;
		protected var progressInterval:int = PROGRESS_INTERVAL_CLIP;
		protected var lastSecond:int = 0;
		protected var lastBufferSecond:int = 0;
		protected var lastTime:int;
		protected var elapsedTime:int = 0;
		protected var clipStarted:Boolean;
		public var clipFinished:Boolean;
		protected var autoPlay:Boolean;
		
		/*		
		http://springer02.webtrekk.net/707476814322924/wt.pl?p=202,st&mi=MEDIAID&mk=init&mt1=0&mt2=120&ck1=KLICKPARA1&ck3=KLICKPARA3&ck4=KLICKPARA4&bw=0&vol=100&mut=0&x=TIMESTAMP
		
		Bsp:
		http://springer02.webtrekk.net/850416555242498/wt.pl?p=202,st&mi=%2FBILD%2Fvideo%2Fclip%2Fnews%2Fvermischtes%2F2010%2F03%2F30%2Fumfrage-bart&mk=init&mt1=0&mt2=131&ck1=preroll&ck3=%2F&ck4=Bildde%20hat%20nachgefragt%20-%20Vollbart%20oder%20glatt%20rasiert%3A%20Wen%20kuessen%20Sie%20lieber&bw=0&vol=0&mut=0&x=1270040967143
		
		mi=MEDIAID => Bezeichnung des Videos z.B.: %2FBILD%2Fvideo%2Fclip%2Fnews%2Fvermischtes%2F2010%2F03%2F30%2Fumfrage-bart
		mk=init => Media-Kommando (init, play, pos, eof)
		mt1=0 => Aktuelle Spielzeit in Sekunden
		mt2=120 => Gesamtspielzeit des Videos in Sekunden
		ck1=KLICKPARA1 => preroll / nopreroll
		ck3=KLICKPARA3 => URL der Webseite auf der der Player eingebunden ist
		ck4=KLICKPARA4 => Überschrift des Videos z.B. Bildde%20hat%20nachgefragt%20-%20Vollbart%20oder%20glatt%20rasiert%3A%20Wen%20kuessen%20Sie%20lieber
		x=TIMESTAMP => aktueller Timestamp dient dazu das Caching von Proxies oder des Browsers zu verhindern
		
		Bitte achte darauf, dass die Requests UTF8 und URL Kodiert sind, damit die Sonderzeichen korrekt angezeigt werden können. Bei den Parametern musst Du darauf achten, dass kein Semikolon im Wert vorkommt, ansonsten wird an der Stelle der Parameter-Wert getrennt und in zwei Werten gespeichert.
		*/
		
		// movieplayer only: tracking for nowtilus
		protected static const NOWTILUS_EVENT_PLAYTIME:String = "playTime";
		protected static const NOWTILUS_EVENT_ADCOUNT:String = "addCount";
		protected static const NOWTILUS_PROGRESS_INTERVAL:int = 5000;
		protected var nowtilusProgressTimer:PausableTimer;
		protected var nowtilusAdCounter:Number;
		// movieplayer only: use static path instead of website url
		protected static const MOVIEPLAYER_TRACKING_PATH:String = "unterhaltung/body/partner/appages/nowtilus/buehne/";
		
		// Clip info
		protected var clipId:String = "mediaId";		// Title of the Video
		protected var clipTitle:String = "mediaTitle";		// Title of the Video
		protected var clipPosition:Number = 0;				// Position in seconds
		protected var clipDuration:Number = 0;				// Overall length of the video in seconds
		
		protected var trackingData:TrackingVO;
		
		public function TrackingController()
		{
			this.init();
		}
		
		protected function init() :void
		{
			this.timerProgress = new Timer( this.progressInterval );
			this.timerProgress.addEventListener( TimerEvent.TIMER, sendMediaStatus );
		}
		
		public function setDuration( duration:Number ) :void
		{
			this.clipDuration = Math.round( duration );
		}
		
		public function setClip( videoData:VideoVO, trackingData:TrackingVO ) :void
		{
			
			this.clipTitle = videoData.headline;
			if( BildTvDefines.isTrailerPlayer )
			{
				this.clipTitle += "_trailer"; 
			}
			this.clipDuration = Math.round( videoData.duration );
			this.clipPosition = 0;
			this.lastSecond = 0;
			this.clipStarted = false;
			this.autoPlay = BildTvDefines.autoplay;
			
			this.trackingData = trackingData;
			
			if( videoData.videoUrl.substr( 0, 4 ) == "rtmp" || videoData.videoUrl2.substr( 0, 4 ) == "rtmp" )
			{
				this.progressInterval = PROGRESS_INTERVAL_STREAM;
			}
			else
			{
				this.progressInterval = PROGRESS_INTERVAL_CLIP;
			}
			
			if( BildTvDefines.isMoviePlayer )
			{
				this.nowtilusAdCounter = 0;
				if( this.nowtilusProgressTimer == null )
				{
					this.nowtilusProgressTimer = new PausableTimer( NOWTILUS_PROGRESS_INTERVAL );
					this.nowtilusProgressTimer.addEventListener( TimerEvent.TIMER, onNowtilusTimer );
				}
			}
		}
		
		public function setPlayingStatus( playing:Boolean ) :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
//			trace( this + " setPlayingStatus: " + playing );
			
			if( this.trackingData == null )
			{
				return;
			}
			
			if( playing )
			{
				this.clipStarted = true;
				
				if( this.elapsedTime > 0 && this.elapsedTime < this.progressInterval )
				{
					this.timerProgress.delay = this.progressInterval - this.elapsedTime;
				}
				else
				{
					this.timerProgress.delay = this.progressInterval;
				}
				this.lastTime = getTimer();
				this.timerProgress.start();
				
				// movieplayer only
				if( BildTvDefines.isMoviePlayer )
				{
					this.nowtilusProgressTimer.resume();
				}
			}
			else if( this.clipStarted )
			{
				this.timerProgress.stop();
				this.elapsedTime += getTimer() - this.lastTime;
				this.clipStarted = false;
				// movieplayer only
				if( BildTvDefines.isMoviePlayer )
				{
					this.nowtilusProgressTimer.pause();
				}
			}
			else
			{
				this.timerProgress.stop();
			}
		}
		
		public function onClipPlay() :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			this.clipPosition = 0;
			try
			{
//				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/play", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
//				ExternalInterface.call("project_objects.StateManger.trackVideoPlay",BildTvDefines.playerId, this.clipPosition, this.clipDuration);
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			
			this.track( STATUS_INIT );
			
			if( this.autoPlay )
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/play_auto_rev", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
//				this.trackPlayerEvent("PLAY_AUTOPLAY");			
			}
			else
			{
//				this.trackPlayerEvent("PLAY");
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/play", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
			}
		}
		
		public function onClipPause() :void
		{
			// workaround by Dennis
			// "video/event/..." calls are not part of the tracking
			// FIXME move into separate class
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/event/pause");
			}
			catch(e:Error)
			{
				trace("WARNING:","no ExternalInterface call possible. Message: " + e.toString());
			}
			// END workaround by Dennis
			
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			if( BildTvDefines.debugFlag ) //ExternalInterface.call("function(){if (window.console) console.log('LOG PAUSE!"+this.clipPosition+"');}");
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/pause", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
//				ExternalInterface.call("project_objects.StateManger.trackVideoPause",BildTvDefines.playerId, this.clipPosition, this.clipDuration);
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			
			this.track( STATUS_PAUSE );
			
			this.trackPlayerEvent("PAUSE");
		}
		
		public function onClipResume() :void
		{
			// workaround by Dennis
			// "video/event/..." calls are not part of the tracking
			// FIXME move into separate class
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/event/play");
			}
			catch(e:Error)
			{
				trace("WARNING:","no ExternalInterface call possible. Message: " + e.toString());
			}
			// END workaround by Dennis
			
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			//this.clipPosition = 0;
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/resume", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
//				ExternalInterface.call("project_objects.StateManger.trackVideoResume",BildTvDefines.playerId, this.clipPosition, this.clipDuration);
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			
			this.track( STATUS_PLAY );
			
			this.trackPlayerEvent("RESUME");
		}
		
		public function onClipStart() :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			this.clipPosition = 0;
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/start", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
//				ExternalInterface.call("project_objects.StateManger.trackVideoStart",BildTvDefines.playerId, this.clipPosition, this.clipDuration);
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			this.track( STATUS_PLAY );
		}
		
		public function onClipEnd() :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			if( this.clipFinished ) return; //if clip end track two times
			this.clipFinished = true;
			
			this.timerProgress.stop();
			this.clipStarted = false;
			
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/complete", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
				
//				ExternalInterface.call("project_objects.StateManger.trackVideoPlayComplete",BildTvDefines.playerId, Math.ceil((this.clipDuration / this.clipPosition ) * 100) , this.clipDuration);
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			this.track( STATUS_END );
			
			this.trackPlayerEvent("STOP");
			
			// movieplayer only
			if( BildTvDefines.isMoviePlayer )
			{
				this.nowtilusProgressTimer.stop();
			}
		}
		
		public function updatePlayProgress( position:Number ) :void
		{
//			trace( "updatePlayProgress() id: " + BildTvDefines.playerId + "  duration: " + this.clipDuration + "  pos: " + this.clipPosition + "  lastsec: " + this.lastSecond );
			if( this.clipDuration == -1 ) return;
			this.clipPosition = Math.ceil((position / this.clipDuration ) * 100);
			if( this.lastSecond != Math.floor( position ))
			{
				this.lastSecond = Math.floor(position);
//				trace("Position: " + position);
				// workaround by Dennis
				// "video/event/..." calls are not part of the tracking
				// FIXME move into separate class
				try
				{
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/event/timeupdate", {'id': BildTvDefines.playerId, current_time: position, duration: this.clipDuration});
				}
				catch(e:Error)
				{
					trace("WARNING:","no ExternalInterface call possible. Message: " + e.toString());
				}
				// END workaround by Dennis
			}
		}
			
		
		public function updateBufferProgress( position:Number ) :void
		{
			if( this.lastBufferSecond != Math.floor(  (position * this.clipDuration) ) )
			{
				this.lastBufferSecond = Math.floor( (position * this.clipDuration));
//				ExternalInterface.call("function(){if (window.console) console.log('FLASH TRACK: BUFFER -->"+(position * this.clipDuration)+"');}");
				// workaround by Dennis
				// "video/event/..." calls are not part of the tracking
				// FIXME move into separate class
				try
				{
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/event/bufferupdate", {'id': BildTvDefines.playerId, buffered: this.lastBufferSecond, duration: this.clipDuration});
				}
				catch(e:Error)
				{
					trace("WARNING:","no ExternalInterface call possible. Message: " + e.toString());
				}
				// END workaround by Dennis
			}
		}
		
		public function updateMetaData( duration:Number ) :void
		{
			// workaround by Dennis
			// "video/event/..." calls are not part of the tracking
			// FIXME move into separate class
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/event/loadedmetadata", {'id': BildTvDefines.playerId, 'duration': duration});
			}
			catch(e:Error)
			{
				trace("WARNING:","no ExternalInterface call possible. Message: " + e.toString());
			}
			// END workaround by Dennis
		}

		
		
		/*
		 * Is invoked by the timer instance every 10 seconds
		 */
		protected function sendMediaStatus( e:TimerEvent ):void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			try
			{
				ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/timeupdate", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
//				ExternalInterface.call("project_objects.StateManger.trackVideoTimeupdate",BildTvDefines.playerId, Math.ceil((this.clipPosition / this.clipDuration ) * 100) , this.clipDuration);
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			this.track( STATUS_POS );
			
			this.lastTime = getTimer();
			if( this.elapsedTime > 0 )
			{
				this.elapsedTime = 0;
				this.timerProgress.stop();
				this.timerProgress.delay = this.progressInterval;
				this.timerProgress.start();
			}
		}
		
		protected function track( status:String ) :void
		{
			
			if( this.trackingData == null || !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			if( BildTvDefines.mode == BildTvDefines.MODE_EMBED )
			{
				this.trackEmbedPlayer( status );
				//trace( this + " ----------- track embed: " + status );
			}
			else
			{
				//if( !BildTvDefines.isMoviePlayer && !this.autoPlay )
				//{
				//	this.trackIvw( status );
				//}
				//this.trackCorporatePlayer( status );
			}
		}
		
		protected function trackEmbedPlayer( status:String ) :void
		{		
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			var trackfunction:String = this.trackingData.trackEmbedFunction;
			
			//TODO Not final!! only for the moment
			var startPos:Number = this.trackingData.trackFunction.indexOf( "('") + 2;
			var endPos:Number = this.trackingData.trackFunction.indexOf( ",%EVENT%")-1;
			
			this.clipId = this.trackingData.trackFunction.substring( startPos , endPos );
			//video/flashvideo/clip/fallback fallback für clipId
			/*http://springer02.webtrekk.net/707476814322924/wt.pl?p=202,st&	mi=%MEDIAID%&	
																				mk=%ACTION%&	
																				mt1=%POSITION%&		
																				mt2=%DURATION%&		
																				ck1=%PLAYERTYPE%&	
																				ck2=%PARTNER%&		
																				ck3=%URL%&		
																				ck4=%TITLE%&		
																				ck5=%TEASERLOCATION%&		
																				bw=0&vol=100&	mut=0&	
																				x=%TIMESTAMP%*/
			
			trackfunction = trackfunction.replace( "%MEDIAID%", escapeMultiByte( this.clipId ) );
			trackfunction = trackfunction.replace( "%ACTION%", status );
			trackfunction = trackfunction.replace( "%POSITION%", this.clipPosition );
			trackfunction = trackfunction.replace( "%DURATION%", this.clipDuration );
			trackfunction = trackfunction.replace( "%PARTNER%", (BildTvDefines.width+"x"+BildTvDefines.height) );//ck2
			trackfunction = trackfunction.replace( "%URL%", escapeMultiByte( BildTvDefines.url ) );				//ck3
			trackfunction = trackfunction.replace( "%TITLE%", escapeMultiByte( this.clipTitle ) );				//ck4
			trackfunction = trackfunction.replace( "%TIMESTAMP%", new Date().valueOf().toString() );
			trackfunction = trackfunction.replace( "ck1=%PLAYERTYPE%&", "" );							//ck1
			trackfunction = trackfunction.replace( "ck5=%TEASERLOCATION%&","" );										//ck5
			
			this.doTracking( trackfunction );
		}
		
		protected function trackCorporatePlayer( status:String ) :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			if( this.trackingData != null && this.trackingData.trackFunction != "" )
			{
				var url:String = this.trackingData.trackFunction;
				
				var event:String = "'" + TrackingEventNames.getEventName( status ) + "'";
				var timestamp:String = Math.round( this.clipPosition ).toString();
				var percent:String = ( status != STATUS_POS ) ? TrackingEventNames.EMPTY_TRACK : this.getPercent();
				
				// movieplayer only
				url = StringUtils.replace( url, "%TITLE%", "'" + this.clipTitle + "'" );
				url = StringUtils.replace( url, "%LENGTH%", this.clipDuration );
				url = StringUtils.replace( url, "%URL%", "'" + MOVIEPLAYER_TRACKING_PATH + this.clipTitle + "'" );
				//
				url = StringUtils.replace( url, "%EVENT%", event );
				url = StringUtils.replace( url, "%DURATION%", timestamp );
				url = StringUtils.replace( url, "%PERCENT%", percent );
				url = StringUtils.replace( url, "%COOKIE%", TrackingEventNames.EMPTY_TRACK );
				url = StringUtils.replace( url, "%SEARCH%", TrackingEventNames.EMPTY_TRACK );

				this.doTracking( url );
			}
		}
		
		protected function trackIvw( status:String ) :void
		{		
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			if( this.trackingData != null && this.trackingData.ivw != "" )
			{
				switch( status )
				{
					case STATUS_INIT:
					{
//						trace( this + " trackIvw - url: " + this.trackingData.ivw );
						
						var url:String = this.trackingData.ivw;
						
						if( url.toLowerCase().substr( 0, 11 ) == "javascript:" )
						{
							this.doTracking( url );
						}
						else
						{
							url += "?r=&d=" + ( Math.round( Math.random() * 99999 ) );
							this.doTracking( url );
						}
						
						break;
					}
				}
			}
		}
		
		public function trackExtern(str:String):void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			try
			{
				ExternalInterface.call("track",str);		
			}
			catch(e:Error)
			{
				trace("------Kein Scriptaccess!");
			}
		}
		
		protected function doTracking( url:String ) :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			try
			{
				if( url.toLowerCase().substr( 0, 11 ) == "javascript:" )
				{
					url = url.substr( 11 );
					if( url.toLowerCase().substr( 0, 4 ) == "void" )
					{
						url = url.substr( 4 );
					}
					if( url.toLowerCase().substr( 0, 3 ) == "%20" )
					{
						url = url.substr( 3 );
					}
					if( url.toLowerCase().substr( 0, 1 ) == " " )
					{
						url = url.substr( 1 );
					}
					
					var func:String = "function(){ " + url + " }";
					
					//trace( this + " doTracking: ExternalInterface.call -> " + func );
					
					try
					{		
						this.trackExtern(func);
						//ExternalInterface.call( func );
					}
					catch (e:Error)
					{
						//trace( this + " doTracking:  " + e.message );
					}
				}
				else
				{
					//trace( this + " doTracking: sendToURL -> " + url );
					this.trackExtern("tracke diese URL:" + url);
					if(BildTvDefines.isEmbedPlayer) sendToURL( new URLRequest( url ) );
				}
			}
			catch( e:Error )
			{
				//trace( this + " doTracking: " + e.message );
			}
		}
		
		protected function getPercent() :String
		{
			var percent:Number = 0;
			
			if( this.clipDuration > 0 )
			{
				// only track 10 values -> 0 - 4.9 = 0, 5 - 14.9 = 10 etc.
				percent = this.clipPosition * 100 / this.clipDuration;
				percent = Math.floor( (percent + 5) / 10 ) * 10;
			}
			
			return percent.toString();
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////
// movieplayer only - tracking for nowtilus
//////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * movieplayer only
		 */
		protected function onNowtilusTimer( event:TimerEvent ) :void
		{
			this.trackNowtilus( NOWTILUS_EVENT_PLAYTIME );
		}
		
		/**
		 * movieplayer only
		 */
		protected function trackNowtilus( event:String ) :void
		{
			if( this.trackingData != null && !this.trackingData.trackingEnabled )
			{
				return;
			}
			
			var param:Object;
			
			switch( event )
			{
				case NOWTILUS_EVENT_PLAYTIME:
				{
					try
					{
						ExternalInterface.call("project_objects.StateManger.trackNowtilusTimeupdate",BildTvDefines.playerId, this.clipPosition );
					}
					catch(e:Error)
					{
						trace("Kein Scriptaccess!");
					}
			
					param = Math.ceil( this.clipPosition );
					break;
				}
				case NOWTILUS_EVENT_ADCOUNT:
				{
					try
					{
						ExternalInterface.call("project_objects.StateManger.trackNowtilusAdCount",BildTvDefines.playerId, this.nowtilusAdCounter );
					}
					catch(e:Error)
					{
						trace("Kein Scriptaccess!");
					}
					
					param = this.nowtilusAdCounter;
					break;
				}
			}
			
			/* if( this.trackingData )
			{
				var url:String = this.trackingData.ivw;
				url = url.replace( "%EVENT%", "'" + event + "'" );
				url = url.replace( "%PARAM%", param );
				this.doTracking( url );	
			} */
		}
		
		/**
		 * movieplayer only
		 */
		public function trackAd() :void
		{
			this.nowtilusAdCounter++;
			this.trackNowtilus( NOWTILUS_EVENT_ADCOUNT );
		}
		
		
//////////////////////////////////////////////////////////////////////////////////////////////////
// tracking for Selenium tests
//////////////////////////////////////////////////////////////////////////////////////////////////
		public function trackPlayerEvent(type:String) :void
		{
//			ExternalInterface.call("function(){if (window.console) console.log('FLASH TRACK: "+type+"');}");
			trace(type);
			switch(type)
			{
				case "HD_ON":
				{
					//ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/track/hq", {'id': BildTvDefines.playerId, 'percent': this.clipPosition, 'duration': this.clipDuration});
					break;
				}
				case "BITRATESWITCH_FINISH":
				{
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/controls/enable_hd_button", {'id': BildTvDefines.playerId});
					break;
				}
				case "ENDSCREEN":
				{
					ExternalInterface.call("com.xoz.events.publish","videoplayer/video/finish", {'id': BildTvDefines.playerId});
					break;
				}
				case "LIVE_ON":
				{
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/livemodus/enable", {'id': BildTvDefines.playerId});
					break;
				}
				case "LIVE_OFF":
				{
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/livemodus/disable", {'id': BildTvDefines.playerId});
					break;
				}
					default:break;
			}
		}
	}
}