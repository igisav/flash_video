package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.event.*;
    import de.axelspringer.videoplayer.model.vo.*;
    import de.axelspringer.videoplayer.util.Log;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.*;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.net.*;

    // TODO: rufe destroy() und töte den NetStream, wenn der Benutzer flash schliesst

    // TODO: keine Unterstützung für AMD live stream H.264
    // Beispiel: http://multiplatform-f.akamaihd.net/z/multi/companion/big_bang_theory/big_bang_theory.mov_,300,600,800,1000,2500,4000,9000,k.mp4.csmil/manifest.f4m
    // siehe: http://support.akamai.com/flash/

    public class MainController
	{
		protected var root:Sprite;
		protected var stage:Sprite;
		protected var config:ConfigVO;

		// controller
		protected var playerController:PlayerController;
		protected var viewController:ViewController;
			
		public function MainController( root:Sprite )
		{
			this.root = root;
			this.stage = new Sprite();
			this.stage.addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			
			this.root.addChild( this.stage );			
		}
		
		protected function addedToStage( e:Event ) :void
		{
			this.stage.removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
			
			this.setSize();
			
			/*this.loaderAni = new LoaderAni();
			this.root.addChild( this.loaderAni );*/
			
			this.root.stage.addEventListener( Event.RESIZE, onStageResize );
		}
		
		protected function forwardControlEvent( e:ControlEvent ) :void
		{
			this.viewController.dispatchEvent( new ControlEvent( e.type, e.data ) );
		}
		
		public function init( flashVars:Object ) :void
		{
            var startXmlURL:String = flashVars.xmlurl;
            var autoplay:String = flashVars.autoplay;
            var time:Number = flashVars.time;

			this.config = new ConfigVO();

            this.initController();

            var external:ExternalController = new ExternalController();
            var externalSuccess:Boolean = external.init(this, this.playerController, flashVars.cb);
			if (!externalSuccess) {
                return;
            }

			// to load relative linked stuff in the embed-player, we need absolute urls
			// bild.de wants us to use the url of the xml to generate absolute links
			// as this url may also be relative, let LinkUtil decide what to use
			trace(this + " XML: " + startXmlURL);
			
			//set type of Ad, playing first,
			BildTvDefines.adType = flashVars.adType;
			
			if(!isNaN(time))
			{
				BildTvDefines.startTime = time;			
			}
			
			//Prio1: get Autoplay from Flashvars, Prio2: get Autoplay from video.xml if autoplaySet is false
			if(autoplay != null)
			{
				BildTvDefines.autoplay = (autoplay == "true") ? true : false;	
				BildTvDefines.autoplaySet= true;	
			}			
			
            this.start();
            ExternalController.dispatch( ExternalController.EVENT_INITIALIZED );
    }
        // TODO: move this to playerController
        public function loadURL(url:String):void{
            this.config.videoVO.videoUrl = this.config.videoVO.videoUrl2 = url ;

            // TODO: hdAdaptive wird über flashvars gesetzt. Überprüfen ob default=true nicht gefährlich ist.
            this.config.videoVO.hdAdaptive = true;
            this.start();
        }


/************************************************************************************************
 * APP CONTROL
 ************************************************************************************************/
		
		//private var readySignalsended:Boolean = false;
		// private var readytimer:Timer = new Timer(2000,5);
		
		protected function start() :void
		{
				if( true == BildTvDefines.isEmbedPlayer )
				{
					var id:String 		= BildTvDefines.playerId;
					try
					{
						ExternalInterface.call("project_objects.StateManger.setWidth", id, root.stage.stageWidth);		
					}
					catch(e:Error)
					{
					}
				}
			
				this.initMode();
				
				for (var i:int = 0; i < this.config.ads.length; i++) 
				{	
					if( this.config.ads[i].club == "default" )
					{
						this.config.adVO = this.config.ads[i];
						break;
					}
					else
					{
						var adPossible:Boolean = ExternalInterface.call("de.bild.user.userHasClub",this.config.ads[i].club);
						
						//ExternalInterface.call("function(){if (window.console) console.log('club is ok? : "+this.config.ads[i].club + ": " + adPossible+"');}");
						if( adPossible )
						{
							this.config.adVO = this.config.ads[i];
							break;
						}					
					}
				}
//				if( this.config.adVO ) ExternalInterface.call("com.xoz.flash_logger.logTrace","AD CALL CHOOSEN: id:" + this.config.adVO.club);

				this.update();	
		//	}
			
		}
		
		protected function setSize() :void
		{
			BildTvDefines.width = this.stage.stage.stageWidth;
			BildTvDefines.height = this.stage.stage.stageHeight;
			
			if( BildTvDefines.width < BildTvDefines.WIDTH_MINIMUM )
			{
				BildTvDefines.size = BildTvDefines.SIZE_MICRO;
			}
			else if( BildTvDefines.width < BildTvDefines.WIDTH_ARTICLE )
			{
				BildTvDefines.size = BildTvDefines.SIZE_MINI;
			}
			else if( BildTvDefines.width < BildTvDefines.WIDTH_BIG)
			{ 
				BildTvDefines.size = BildTvDefines.SIZE_MEDIUM;
			}
			else
			{
				BildTvDefines.size = BildTvDefines.SIZE_BIG;
			}
		}
		
		protected function initMode() :void
		{
			if( BildTvDefines.isEmbedPlayer )
			{
				BildTvDefines.mode = BildTvDefines.MODE_EMBED;
			}
			else
			{
				BildTvDefines.mode = BildTvDefines.MODE_STAGE;
			}
	
			trace( this + " mode => " + BildTvDefines.mode );
		}
		
		protected function initController() :void
		{
			this.viewController = new ViewController( this.stage );
			this.viewController.addEventListener( ControlEvent.REPLAY, onReplayClick );
			
			this.playerController = new PlayerController( this.viewController.playerView); //, this.viewController.controlsView, this.viewController.subtitleView
            this.playerController.addEventListener( ControlEvent.ERROR, onError );
			this.playerController.addEventListener( ControlEvent.ERROR_AVAILABLE, onErrorAvailable );
			this.playerController.addEventListener( ControlEvent.ERROR_GEO, onErrorGeo );
			this.playerController.setVolume( 0.5 );
		}
		
		protected function update() :void
		{ 
			this.viewController.showView( PlayerView.NAME );
			this.viewController.setConfig( this.config );
			

			// different action depending on type of player - video player vs. movie player vs. live player
			if( this.config.filmVO != null )
			{
				BildTvDefines.isMoviePlayer = true;
				BildTvDefines.isTrailerPlayer = this.config.filmVO.isTrailer();
				// force STAGE mode to enable correct tracking
				BildTvDefines.mode = BildTvDefines.MODE_STAGE;
				this.playerController.setMovie( this.config.filmVO );
			}
			else if( this.config.streamingVO != null )
			{
				BildTvDefines.isStreamPlayer = true;
				BildTvDefines.isLivePlayer = this.config.streamingVO.isLivestream;
				// force STAGE mode to enable correct tracking
				BildTvDefines.mode = BildTvDefines.MODE_STAGE;
				//this.playerController.setStream( this.config.streamingVO );
				
				var videoVO:VideoVO=new VideoVO();
				videoVO.videoUrl=this.config.streamingVO.streamUrl;
				videoVO.videoUrl2=this.config.streamingVO.streamUrl2;
				videoVO.duration=this.config.streamingVO.duration;
				videoVO.autoplay=this.config.streamingVO.autoplay;
				
				this.playerController.setClip( videoVO, this.config.adVO );
			}
			else
			{
				/*
				*
				* To Do
				* check if videoURL Exception Handling is implemented. 
				* for example if the videoURl Param is not set but the videoULR2 Param is set. 
				* how does the script handle that issue
				*
				*/
				
				//Call Error when videoUrl and videoUrl2 is not set
				if(this.config.videoVO.videoUrl == "" && this.config.videoVO.videoUrl2 == "")
				{
                    Log.error( BildTvDefines.TEXT_ERROR_INFO_INVALID);
					return;
				}
				
				//set videoURL2 for videoURL when videoURL2 is set and and videoURL not
				if(this.config.videoVO.videoUrl == "" && this.config.videoVO.videoUrl2 != "")
				{
					this.config.videoVO.videoUrl = this.config.videoVO.videoUrl2;
				}
				 
				this.playerController.setClip( this.config.videoVO, this.config.adVO );
			}
		}
				


// TODO: Selim: was ist mit setzen von HD
        // var phase:Number = e.data.phase;
        // this.playerController.setHDBitrate(phase);

		protected function onReplayClick( e:ControlEvent ) :void
		{
			this.playerController.replay();
		}

		protected function onError( e:ControlEvent ):void
		{

			var header:String = ( e.data.header == null ) ? BildTvDefines.TEXT_ERROR_HEADER : e.data.header;
			var info:String = ( e.data.info == null ) ? BildTvDefines.TEXT_ERROR_INFO_DEFAULT : e.data.info;
			var button:Boolean = ( e.data.button == null ) ? true : e.data.button;

			this.showError( true, header, info );
		}

		protected function onErrorAvailable( e:ControlEvent ):void
		{

			var header:String = ( e.data.header == null ) ? BildTvDefines.TEXT_ERROR_HEADER : e.data.header;
			var info:String = ( e.data.info == null ) ? BildTvDefines.TEXT_ERROR_INFO_DEFAULT : e.data.info;
			var button:Boolean = ( e.data.button == null ) ? true : e.data.button;

			this.showError( true, header, info );
		}

		protected function onErrorGeo( e:ControlEvent) :void
		{
			var header:String = BildTvDefines.TEXT_ERROR_HEADER;
			var info:String = BildTvDefines.TEXT_ERROR_INFO_GEO;
			this.showError( true, header, info, "GEO" );
		}

		protected function showError( show:Boolean = true, headerText:String = "", infoText:String = "", errorType:String = "") :void
		{
			try
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","Show Errorscreen :: Error String :: show Boolean = " + show.toString() + " ::  headerText = " + headerText + " :: infoText = " + infoText + " :: errorType = " + errorType);
				ExternalInterface.call("com.xoz.events.publish","videoplayer/video/error", {'id': BildTvDefines.playerId, 'message': infoText, 'type':errorType});
				//this.playerController.trackingController.trackPlayerEvent("ERRORSCREEN");
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}

			/* if(BildTvDefines.size == BildTvDefines.SIZE_MICRO)
			{
				this.errorUi.setText( headerText, infoText, false);
			}
			else
			{
				this.errorUi.setText( headerText, infoText, relatedClips);
			}  */


			//this.errorUi.btnReplay.visible = showButton;
			//this.errorUi.visible = show;
		}

		protected function onErrorClick( e:MouseEvent ) :void
		{
			var js:String = "javascript:location.reload();";
			try
			{
				navigateToURL( new URLRequest( js ), "_self" );
			}
			catch( oops:Error )
			{
				// nix
			}
		}
		
		protected function onStageResize( e:Event ) :void
		{
			this.setSize();
			
			//this.errorUi.resize();
			if( this.viewController != null )
			{
				this.viewController.resize();
			}
			//this.loaderAni.resize();
		}
	}
}