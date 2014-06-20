package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.util.Log;

    import flash.external.ExternalInterface;
    import flash.utils.getTimer;

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
        public static const BUFFERED:String		= "getBuffered";
        // public static const DESTROY:String		= "destroy";

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
        public static const EVENT_PROGRESS:String	        = "progress";
        public static const EVENT_ENDED:String	            = "ended";
        public static const EVENT_VOLUME_CHANGE:String	    = "volumechange";
        public static const EVENT_EMPTIED:String	        = "emptied";
        public static const EVENT_SEEKED:String         	= "seeked";
        public static const EVENT_ERROR:String              = "error";
        public static const EVENT_WARN:String               = "warn";

        public static const DISPATCH_EVENT_DELAY:int        = 200; // time interval for several events, in ms

        private static var jsEventCallback:String;
        private static var lastProgressTime:int = 0;
        private static var lastTimeUpdateTime:int = 0;

        public static function init(playerController:PlayerController, jsCallback:String):Error
        {
            jsEventCallback = jsCallback;

            if (ExternalInterface.available)
            {
                try
                {
                    bind(playerController);
                }
                catch(e:Error)
                {
                    Log.error("Error by adding callback. Not all JS-Functions are available.");
                    return e;
                }
            }
            else
            {
                Log.error("ExternalInterface is not available!");
                return new Error("ExternalInterface is not available!");
            }
            return null;
        }

        public static function dispatch(eventName:String, value:* = null):void
        {

            if (!ExternalInterface.available) {
                return;
            }
            /*var supress:Array = [EVENT_PROGRESS, EVENT_TIMEUPDATE, EVENT_LOADED_METADATA];
            if (supress.indexOf(eventName) >= 0) {return}*/

            var time:int = getTimer();

            // dispatch event in defined period of time only
            if (eventName == EVENT_PROGRESS) {
                if (time - lastProgressTime < DISPATCH_EVENT_DELAY) {
                    return
                }
                lastProgressTime = time;
            }
            else if (eventName == EVENT_TIMEUPDATE) {
                if (time - lastTimeUpdateTime < DISPATCH_EVENT_DELAY) {
                    return
                }
                lastTimeUpdateTime = time;
            }

            var msg:Object =  {
                'type': eventName,
                'value': value
            };
            ExternalInterface.call(jsEventCallback, msg);
        }

        private static function bind(playerController:PlayerController):void {
            ExternalInterface.addCallback(LOAD, playerController.loadURL);
            ExternalInterface.addCallback(PLAY, playerController.play);
            ExternalInterface.addCallback(PAUSE, playerController.pause);
            ExternalInterface.addCallback(VOLUME, playerController.volume);
            ExternalInterface.addCallback(MUTED, playerController.mute);
            ExternalInterface.addCallback(CURRENT_TIME, playerController.currentTime);
            ExternalInterface.addCallback(DURATION, playerController.getDuration);
            ExternalInterface.addCallback(BUFFERED, playerController.getBufferTime);
        }
    }
}
