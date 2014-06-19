package
{
    import de.axelspringer.videoplayer.controller.MainController;
    import de.axelspringer.videoplayer.model.vo.BildTvDefines;
    import de.axelspringer.videoplayer.util.Log;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.system.Security;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;

    public class VideoplayerMain extends Sprite
    {
        protected var mainController:MainController;

        public function VideoplayerMain() {
            BildTvDefines.versionNumber = "1.0";

            Log.level = Log.TRACE;

            Security.allowDomain("*");

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
            menu.customItems.push(new ContextMenuItem(BildTvDefines.playerName + " " + BildTvDefines.versionNumber, true, false));
            this.contextMenu = menu;
        }

    }
}