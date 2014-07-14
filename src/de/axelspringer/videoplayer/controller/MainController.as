package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.Sprite;
    import flash.text.TextField;

    // TODO: rufe destroy() und töte den NetStream, wenn der Benutzer flash schliesst

    public class MainController
    {
        protected var stage:Sprite;

        // controller
        protected var playerController:PlayerController;
        protected var viewController:PlayerView;

        public function MainController(stage:Sprite) {
            this.stage = stage;
        }

        public function init(flashVars:Object):void {
            var video:VideoVO = new VideoVO();

            this.initController();

            var externalSuccess:Error = ExternalController.init(this.playerController, flashVars.cb);

            if (externalSuccess != null)
            {
                postDebugText(externalSuccess.message);
                return;
            }

            var autoplay:String = flashVars.autoplay;
            if (autoplay && autoplay != "")
            {
                video.autoplay = true;
            }

            var hdAdaptive:String = flashVars.hdAdaptive;
            if (hdAdaptive && hdAdaptive != "")
            {
                video.hdAdaptive = true;
            }

            this.playerController.setVolume(0.5);
            this.playerController.setClip(video);
            ExternalController.dispatch(ExternalController.EVENT_INITIALIZED);
        }

        /************************************************************************************************
         * APP CONTROL
         ************************************************************************************************/

        protected function initController():void {
            this.viewController = new PlayerView(this.stage);

            this.playerController = new PlayerController(this.viewController);
        }


        private var debug:TextField;

        public function postDebugText(msg:String):void {
            if (!debug)
            {
                debug = new TextField();
                this.stage.addChild(debug);
            }
            debug.appendText(msg);
        }
    }
}