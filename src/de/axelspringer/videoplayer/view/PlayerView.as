package de.axelspringer.videoplayer.view
{
    import de.axelspringer.videoplayer.event.ControlEvent;
    import de.axelspringer.videoplayer.model.vo.BildTvDefines;
    import de.axelspringer.videoplayer.model.vo.FullscreenData;
    import de.axelspringer.videoplayer.view.base.BaseView;

    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.media.Video;

    public class PlayerView extends BaseView
	{
		public static const NAME:String = "PlayerView";
		
		public var background:Sprite;
		public var display:Video;
		public var videoBtn:Sprite;
		
		protected var initWidth:Number;
		protected var initHeight:Number;
		
		protected var ratio:Number = 16 / 9;
		protected var currentWidth:Number;
		protected var currentHeight:Number;
		protected var isFullscreen:Boolean;
		protected var wasFullscreen:Boolean;

		public function PlayerView( stage:Sprite )
		{
			super( stage );
			
			this.init();
		}
		
		protected function init() :void
		{
			this.setSize();
			
			this.background = new Sprite();
			this.background.graphics.beginFill( 0 );
			this.background.graphics.drawRect( 0, 0, 1, 1 );
			this.background.graphics.endFill();
			this.stage.addChild( this.background );
			
			
			this.display = new Video();
			this.display.smoothing = true;
			this.stage.addChild( this.display );
			
			this.videoBtn = new Sprite();
			this.videoBtn.graphics.beginFill( 0, 0 );
			this.videoBtn.graphics.drawRect( 0, 0, BildTvDefines.width, BildTvDefines.height );
			this.videoBtn.graphics.endFill();
			this.videoBtn.buttonMode = true;
			this.stage.addChild(this.videoBtn);
			
			this.setDisplaySizeDefault();
		}
		
		public override function resize() :void
		{
			this.setSize();
			this.setDisplaySizeDefault();
		}

		public function setPlayingStatus( playing:Boolean ) :void
		{
			// for ViewController
			if( playing )
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.PLAY ) );
			}
		}

		public function setDisplaySizeDefault() :void
		{
			this.currentWidth = this.initWidth;
			this.currentHeight = this.initHeight;
			
			this.isFullscreen = false;
			
			this.updateDisplaySize();
			
			this.wasFullscreen = false;
		}
		
		public function setDisplaySizeFullscreen() :void
		{
			this.currentWidth = this.stage.stage.stageWidth;
			this.currentHeight = this.stage.stage.stageHeight;
			
			this.isFullscreen = true;
			
			this.updateDisplaySize();
			
			this.wasFullscreen = true;
		}
		
		public function setVideoRatio( ratio:Number ) :void
		{
			this.ratio = ratio;
			
			this.updateDisplaySize();
		}
		
		public function getPlayerSize() :Rectangle
		{
			return new Rectangle( 0, 0, this.currentWidth, this.currentHeight );
		}
		
		protected function setSize() :void
		{
			this.initWidth = BildTvDefines.width;
		    this.initHeight = BildTvDefines.height;
		}
		
		protected function updateDisplaySize() :void
		{
			display.height = this.currentHeight;
			display.width = this.currentHeight * this.ratio;
			if( display.width > this.currentWidth )
			{
				display.width = this.currentWidth;
				display.height = this.currentWidth / this.ratio;
			}
			
			display.x = Math.round( ( this.currentWidth - display.width ) / 2 );
			display.y = Math.round( ( this.currentHeight - display.height ) / 2 );
			
			this.background.width = this.currentWidth;
			this.background.height = this.currentHeight;
			this.videoBtn.width = this.currentWidth;
			this.videoBtn.height = this.currentHeight;

			// notify PlayerController to change size of Ad
			this.dispatchEvent( new ControlEvent( ControlEvent.RESIZE, new FullscreenData( this.isFullscreen, this.wasFullscreen ) ) );
		}
		
	}
}