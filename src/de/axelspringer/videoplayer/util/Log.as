package de.axelspringer.videoplayer.util
{
    import de.axelspringer.videoplayer.controller.ExternalController;
    import de.axelspringer.videoplayer.model.vo.Const;

    public class Log
    {
        public static var level:String = "none";
        public static const TRACE:String = "trace";
        public static const JS_LOGGER:String = "js_logger";

        public static function error(msg:String, type:String = ""):void {
            trace("[ERROR] " + msg);

            var error:Object = {
                'type' : type ? type : Const.ERROR_TYPE_OTHER,
                'value': msg
            };
            ExternalController.dispatch(ExternalController.EVENT_ERROR, error);
        }

        public static function warn(msg:String):void {
            trace("[WARN] " + msg);
            ExternalController.dispatch(ExternalController.EVENT_WARN, msg);
        }

        public static function info(msg:String):void {
            msg = "[LOG] " + msg;
            if (level == JS_LOGGER)
            {
                ExternalController.dispatch(ExternalController.EVENT_LOG, msg);
            } else if (level == TRACE)
            {
                trace(msg);
            }
        }
    }
}
