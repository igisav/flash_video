package de.axelspringer.videoplayer.view
{
    import de.axelspringer.videoplayer.util.Log;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.media.Video;

    public class PlayerView
    {
        public var stage:Sprite;
        public var display:Video;

        protected var initWidth:Number;
        protected var initHeight:Number;

        protected var ratio:Number = 16 / 9;
        protected var currentWidth:Number;
        protected var currentHeight:Number;

        public function PlayerView(stage:Sprite) {
            this.stage = stage;

            this.display = new Video();
            this.display.smoothing = true;
            this.stage.addChild(this.display);

            this.stage.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.stage.align = StageAlign.TOP_LEFT;
            this.stage.stage.addEventListener(Event.RESIZE, updateDisplaySize);

            initWidth = this.stage.stage.stageWidth;
            initHeight = this.stage.stage.stageHeight;
            setDisplaySizeDefault();
        }

        public function setDisplaySizeDefault():void {
            this.currentWidth = this.initWidth;
            this.currentHeight = this.initHeight;

            this.updateDisplaySize();
        }

        public function setVideoRatio(ratio:Number):void {
            this.ratio = ratio;

            this.updateDisplaySize();
        }


        protected function updateDisplaySize(e:Event = null):void {
            currentWidth = this.stage.stage.stageWidth;
            currentHeight = this.stage.stage.stageHeight;

            display.height = this.currentHeight;
            display.width = this.currentHeight * this.ratio;
            if (display.width > this.currentWidth)
            {
                display.width = this.currentWidth;
                display.height = this.currentWidth / this.ratio;
            }

            display.x = Math.round(( this.currentWidth - display.width ) / 2);
            display.y = Math.round(( this.currentHeight - display.height ) / 2);

            //Log.info("Resize: width=" + currentWidth + ", height=" + currentHeight);
        }

    }
}