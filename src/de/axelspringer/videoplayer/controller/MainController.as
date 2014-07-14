package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.Sprite;

    public class MainController
    {

        private var controller:IVideoController;

        private var view:PlayerView;

        public function MainController(stage:Sprite) {
            this.view = new PlayerView(stage);
        }

        public function init(flashVars:Object):void {

            createController(false);

            var externalSuccess:Error = ExternalController.init(this, flashVars.cb);

            if (externalSuccess != null)
            {
                //postDebugText(externalSuccess.message);
                return;
            }

            ExternalController.dispatch(ExternalController.EVENT_INITIALIZED);
        }

        protected function createController(akamai:Boolean):void
        {
            if (akamai)
            {
                if (!(controller && controller is AkamaiController))
                {
                    controller = new AkamaiController(view);
                }
            }
            else
            {
                if (!(controller && controller is PlayerController))
                {
                    controller = new PlayerController(view);
                }
            }
        }

        /************************************************************************************************
         *          EXTERNAL JAVASCRIPT CONTROL
         ************************************************************************************************/
        public function loadURL(url:String):void
        {
            destroy();

            var isRTMP:Boolean = url.substr(0, 4) == "rtmp";
            createController(isRTMP);

            controller.loadURL(url);
        }

        public function play():void
        {
            if (controller) {
                controller.play();
            }
        }

        public function pause():void
        {
            if (controller) {
                controller.pause();
            }
        }

        public function volume(value:Number = NaN):Number
        {
            return controller ? controller.volume(value) : 0;
        }

        public function muted(value:String = ""):Boolean
        {
            return controller ? controller.muted(value) : false;
        }

        public function currentTime(value:Number = NaN):Number
        {
            return controller ? controller.currentTime(value) : 0;
        }

        public function getDuration():Number
        {
            return controller ? controller.getDuration() : 0;
        }

        public function getBufferTime():Number
        {
            return controller ? controller.getBufferTime() : 0;
        }

        public function destroy():void
        {
            if (controller) {
                controller.destroy();
            }
        }

        public function enableHD(value:String = ""):void
        {
            if (controller) {
                controller.enableHD(value);
            }
        }

        /*private var debug:TextField;

        public function postDebugText(msg:String):void {
            if (!debug)
            {
                debug = new TextField();
                this.root.stage.addChild(debug);
            }
            debug.appendText(msg);
        }*/
    }
}