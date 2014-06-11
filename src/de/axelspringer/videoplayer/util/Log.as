package de.axelspringer.videoplayer.util
{
    import flash.external.ExternalInterface;

    public class Log
    {
        public static var level:String = "none";
        public static const TRACE:String = "trace";
        public static const JS_LOGGER:String = "js_logger";

        public static function error(msg:String):void {
            log("[ERROR]" + msg + level);
        }

        public static function info(msg:String):void {
            log("[INFO]" + msg + level);
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
