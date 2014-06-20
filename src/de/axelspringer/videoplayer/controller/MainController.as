package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.model.vo.ConfigVO;
    import de.axelspringer.videoplayer.model.vo.Const;
    import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;

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
		protected var viewController:PlayerView;
			
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
			
			this.onStageResize();
			
			this.root.stage.addEventListener( Event.RESIZE, onStageResize );
		}
		
		public function init( flashVars:Object ) :void
		{
            var autoplay:String = flashVars.autoplay;

			this.config = new ConfigVO();

            this.initController();

            var external:ExternalController = new ExternalController();
            var externalSuccess:Error = external.init(this, this.playerController, flashVars.cb);

            if (externalSuccess != null) {
                postDebugText(externalSuccess.message);
                return;
            }

			//Prio1: get Autoplay from Flashvars, Prio2: get Autoplay from video.xml if autoplaySet is false
			if(autoplay != null)
			{
				Const.autoplay = autoplay == "true";
				Const.autoplaySet= true;
			}
			
            this.start();
            ExternalController.dispatch( ExternalController.EVENT_INITIALIZED );
        }

        // TODO: move this to playerController
        public function loadURL(url:String):void{
            this.playerController.destroy();
            this.config.videoVO.videoUrl = url ;

            // TODO: hdAdaptive wird über flashvars gesetzt. Überprüfen ob default=true nicht gefährlich ist.
            this.config.videoVO.hdAdaptive = true;
            this.start();
        }


/************************************************************************************************
 * APP CONTROL
 ************************************************************************************************/

		protected function initController() :void
		{
			this.viewController = new PlayerView( this.stage );

			this.playerController = new PlayerController( this.viewController); //, this.viewController.controlsView, this.viewController.subtitleView
		}
		
		protected function start() :void
		{ 
            this.playerController.setVolume( 0.5 );

			// different action depending on type of player - video player vs. movie player vs. live player
			if( this.config.filmVO != null )
			{
				Const.isMoviePlayer = true;
				Const.isTrailerPlayer = this.config.filmVO.isTrailer();
				this.playerController.setMovie( this.config.filmVO );
			}
			else if( this.config.streamingVO != null )
			{
				Const.isStreamPlayer = true;
				Const.isLivePlayer = this.config.streamingVO.isLivestream;

				var videoVO:VideoVO=new VideoVO();
				videoVO.videoUrl=this.config.streamingVO.streamUrl;
				videoVO.duration=this.config.streamingVO.duration;
				videoVO.autoplay=this.config.streamingVO.autoplay;
				
				this.playerController.setClip( videoVO );
			}
			else
			{
				this.playerController.setClip( this.config.videoVO);
			}
		}

// TODO: Selim: was ist mit setzen von HD
        // var phase:Number = e.data.phase;
        // this.playerController.setHDBitrate(phase);

		protected function onStageResize( e:Event = null ) :void
		{
            Const.width = this.stage.stage.stageWidth;
            Const.height = this.stage.stage.stageHeight;
		}

        private var debug:TextField;
        public function postDebugText(msg:String) :void
        {
            if (!debug) {
                debug = new TextField();
                this.stage.addChild(debug);
            }
            debug.appendText(msg);
        }
	}
}