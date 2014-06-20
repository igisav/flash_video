package de.axelspringer.videoplayer.view
{
    import de.axelspringer.videoplayer.event.ControlEvent;
    import de.axelspringer.videoplayer.model.vo.Const;
    import de.axelspringer.videoplayer.model.vo.FullscreenData;
    import de.axelspringer.videoplayer.view.base.BaseView;

    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.media.Video;

    public class PlayerView extends BaseView
	{
		public var display:Video;

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
			this.display = new Video();
			this.display.smoothing = true;
			this.stage.addChild( this.display );
			
            resize();
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
			this.initWidth = Const.width;
		    this.initHeight = Const.height;
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

			// notify PlayerController to change size of Ad
			this.dispatchEvent( new ControlEvent( ControlEvent.RESIZE, new FullscreenData( this.isFullscreen, this.wasFullscreen ) ) );
		}

	}
}