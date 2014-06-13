package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.util.Log;
    import flash.external.ExternalInterface;


    /********************************************************************************************************
     *                  EXTERNAL CALLBACKS
     *******************************************************************************************************/

    public class ExternalController
    {
        /*          METHODS
                FROM JAVASCRIPT TO FLASH
        */
        public static const LOAD:String			= "load";
        public static const PLAY:String			= "play";
        public static const PAUSE:String		= "pause";
        public static const MUTED:String		= "muted";
        public static const VOLUME:String		= "volume";
        public static const CURRENT_TIME:String	= "currentTime";
        public static const DURATION:String		= "getDuration";
        public static const BUFFED:String		= "getBuffed";
        public static const DESTROY:String		= "destroy";

        /*          EVENTS
                FROM FLASH TO JAVASCRIPT
         */
        public static const EVENT_INITIALIZED:String		= "initialized";
        public static const EVENT_LOADED_METADATA:String	= "loadedmetadata";
        public static const EVENT_WAITING:String	        = "waiting";
        public static const EVENT_PLAY:String	            = "play";
        public static const EVENT_PLAYING:String	        = "playing";
        public static const EVENT_PAUSE:String	            = "pause";
        public static const EVENT_TIMEUPDATE:String	        = "timeupdate";
        public static const EVENT_ENDED:String	            = "ended";
        public static const EVENT_VOLUME_CHANGE:String	    = "volumechange";
        public static const EVENT_EMPTIED:String	        = "eptied";
        public static const EVENT_SEEKED:String         	= "seeked";
        public static const EVENT_ERROR:String              = "error";

        protected var mainController:MainController;
        protected var playerController:PlayerController;

        private static var jsEventCallback:String;

        public function init(mainController:MainController, playerController:PlayerController, jsCallback:String):Boolean
        {
            this.mainController = mainController;
            this.playerController = playerController;

            jsEventCallback = jsCallback;

            if (ExternalInterface.available)
            {
                try
                {
                    bind();
                }
                catch(e:Error)
                {
                    Log.error("Error by adding callback");
                    return false;
                }
            }
            else
            {
                Log.error("ExternalInterface is not available!");
                return false;
            }
            return true;
        }

        public static function dispatch(eventName:String, value:String = ""):void
        {
            if (value == "") {
                ExternalInterface.call(jsEventCallback, eventName);
            } else {
                var msg:Object =  {};
                msg[eventName] = value;
                ExternalInterface.call(jsEventCallback, msg.toString());
            }
        }

        private function bind():void {
            ExternalInterface.addCallback(LOAD, mainController.loadXML);
            ExternalInterface.addCallback(PLAY, playerController.play);
            ExternalInterface.addCallback(PAUSE, playerController.pause);
            ExternalInterface.addCallback(VOLUME, playerController.volume);
            ExternalInterface.addCallback(MUTED, playerController.mute);
        }
    }
}
