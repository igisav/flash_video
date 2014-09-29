/*
     @author: Igor Savchenko
     Axel Springer ideAS Engineering GmbH
 */
package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.util.Log;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.Sprite;

    public class MainController
    {

        private var player:IVideoPlayer;

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
           /* if (!(player && player is OSMFPlayer))
            {
                player = new OSMFPlayer(view.stage);
            }*/


            if (akamai)
            {
                if (!(player && player is AkamaiPlayer))
                {
                    player = new AkamaiPlayer(view);
                }
            }
            else
            {
                if (!(player && player is NormalPlayer))
                {
                    player = new NormalPlayer(view);
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
            try {
                player.loadURL(url);
            } catch (e:Error) {
                Log.warn("Flash: Can't load url " + e.toString());
            }

        }

        public function play():void
        {
            if (player) {
                ExternalController.dispatch(ExternalController.EVENT_PLAY);
                player.play();
            }
        }

        public function pause():void
        {
            if (player) {
                ExternalController.dispatch(ExternalController.EVENT_PAUSE);
                player.pause();
            }
        }

        public function volume(value:Number = NaN):Number
        {
            return player ? player.volume(value) : 0;
        }

        public function muted(value:String = ""):Boolean
        {
            return player ? player.muted(value) : false;
        }

        public function currentTime(value:Number = NaN):Number
        {
            return player ? player.currentTime(value) : 0;
        }

        public function getDuration():String
        {
            return player ? player.getDuration() : "0";
        }

        public function getBufferTime():Number
        {
            return player ? player.getBufferTime() : 0;
        }

        public function destroy():void
        {
            if (player) {
                player.destroy();
            }
        }

        public function enableHD(value:String = ""):void
        {
            if (player) {
                player.enableHD(value);
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