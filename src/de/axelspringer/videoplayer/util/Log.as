package de.axelspringer.videoplayer.util
{
    import de.axelspringer.videoplayer.controller.ExternalController;

    public class Log
    {
        public static var level:String = "none";
        public static const TRACE:String = "trace";
        public static const JS_LOGGER:String = "js_logger";

        public static const ERROR_NETWORK:String   = "Network Error";
        public static const ERROR_RUNTIME:String   = "Runtime Error";
        public static const ERROR_SOURCE:String    = "Source Unsupported";
        public static const ERROR_OTHER:String     = "Other Error";

        public static function error(msg:String, type:String = ""):void {
            log("[ERROR]" + msg);

            var error:Object = {
                'type': type ? type : ERROR_OTHER,
                'value': msg
            };
            ExternalController.dispatch(ExternalController.EVENT_ERROR, error);
        }

        public static function warn(msg:String):void {
            log("[WARN]" + msg);
            ExternalController.dispatch(ExternalController.EVENT_WARN, msg);
        }

        public static function info(msg:String):void {
            log("[INFO]" + msg);
        }

        private static function log(msg:String):void {
            if (level == JS_LOGGER) {
               // ExternalInterface.call("ddd", msg);
            } else if (level == TRACE) {
                trace ( msg );
            }
        }
    }
}
