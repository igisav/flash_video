package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.model.vo.Const;
    import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;

    // TODO: rufe destroy() und töte den NetStream, wenn der Benutzer flash schliesst

    public class MainController
    {
        protected var root:Sprite;
        protected var stage:Sprite;

        // controller
        protected var playerController:PlayerController;
        protected var viewController:PlayerView;

        public function MainController(root:Sprite) {
            this.root = root;
            this.stage = new Sprite();
            this.stage.addEventListener(Event.ADDED_TO_STAGE, addedToStage);

            this.root.addChild(this.stage);
        }

        protected function addedToStage(e:Event):void {
            this.stage.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            this.onStageResize();

            this.root.stage.addEventListener(Event.RESIZE, onStageResize);
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

            this.playerController = new PlayerController(this.viewController); //, this.viewController.controlsView, this.viewController.subtitleView
        }

        protected function onStageResize(e:Event = null):void {
            Const.width = this.stage.stage.stageWidth;
            Const.height = this.stage.stage.stageHeight;
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