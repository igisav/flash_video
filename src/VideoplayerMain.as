package
{
    import de.axelspringer.videoplayer.controller.MainController;
    import de.axelspringer.videoplayer.model.vo.Const;
    import de.axelspringer.videoplayer.model.vo.VideoVO;
    import de.axelspringer.videoplayer.util.Log;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.UncaughtErrorEvent;
    import flash.system.Security;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;

    public class VideoplayerMain extends Sprite
    {
        protected var mainController:MainController;

        public function VideoplayerMain() {
            Const.versionNumber = "1.0";

            Log.level = Log.TRACE;

            Security.allowDomain("*");

            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);

            if (this.stage == null)
            {
                this.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
            }
            else
            {
                this.init();
            }
        }


        protected function addedToStage(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            this.init();
        }

        protected function init():void {
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.align = StageAlign.TOP_LEFT;

            this.mainController = new MainController(this);
            this.mainController.init(this.loaderInfo.parameters);

            // add release number to context menu
            var menu:ContextMenu = new ContextMenu();
            menu.hideBuiltInItems();
            menu.customItems.push(new ContextMenuItem(Const.playerName + " " + Const.versionNumber, true, false));
            this.contextMenu = menu;
        }

        private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
        {
            if (event.error is Error)
            {
                var error:Error = event.error as Error;
                Log.error(error.message, Log.ERROR_RUNTIME);
            }
            else if (event.error is ErrorEvent)
            {
                var errorEvent:ErrorEvent = event.error as ErrorEvent;
                Log.error(errorEvent.toString(), Log.ERROR_RUNTIME);
            }
            else
            {
                Log.error(Const.ERROR_RUNTIME_UNKNOWN, Log.ERROR_RUNTIME);
            }
        }

    }
}