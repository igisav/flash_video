package de.axelspringer.videoplayer.view
{
//	import com.akamai.display.AkamaiVideoSurface;
    import de.axelspringer.videoplayer.event.ControlEvent;
    import de.axelspringer.videoplayer.model.vo.BildTvDefines;
    import de.axelspringer.videoplayer.model.vo.FullscreenData;
    import de.axelspringer.videoplayer.model.vo.SkinVO;
    import de.axelspringer.videoplayer.view.base.BaseView;

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.media.Video;

    public class PlayerView extends BaseView
	{
		public static const NAME:String = "PlayerView";
		
		public var background:Sprite;
		public var display:Video;
//		public var displayHD:AkamaiVideoSurface;
		public var adContainer:MovieClip;
		//public var adLabel:AdLabel;
		public var videoBtn:Sprite;
		
		// movieplayer only
		//public var chapterList:ChapterListUi;
		//
		
		protected var skin:SkinVO;
		
		//protected var displayBtn:DisplayButton;

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
			
//			this.displayHD = new AkamaiVideoSurface(true);
//			this.stage.addChild( this.displayHD );

			// movieplayer only
			/*this.chapterList = new ChapterListUi();
			this.chapterList.addEventListener( ControlEvent.PROGRESS_CHANGE, onMovieProgressChange );
			this.chapterList.visible = false;
			this.stage.addChild( this.chapterList );*/
			
			this.adContainer = new MovieClip();
			this.stage.addChild( this.adContainer );
			
			/*this.adLabel = new AdLabel();
			this.stage.addChild( this.adLabel );

			if(!BildTvDefines.isEmbedPlayer)
			{
				this.adLabel.visible = false;
			}*/
			
			this.videoBtn = new Sprite();
			this.videoBtn.graphics.beginFill( 0, 0 );
			this.videoBtn.graphics.drawRect( 0, 0, BildTvDefines.width, BildTvDefines.height );
			this.videoBtn.graphics.endFill();
		//	this.videoBtn.addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
		//	this.videoBtn.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			this.videoBtn.buttonMode = true;
			//this.videoBtn.visible = false;
			this.stage.addChild(this.videoBtn);
			
			this.setDisplaySizeDefault();
		}
		
		public function setSkin( skin:SkinVO ) :void
		{
			this.skin = skin;
		/*	this.displayBtn = new DisplayButton(this.skin.cssSprite,this.skin.styleBigPlay.skinWidth, this.skin.styleBigPlay.skinHeight,this.skin.styleBigPlay.skinX, this.skin.styleBigPlay.skinY, 2);

			if(true == BildTvDefines.isEmbedPlayer)
			{
				this.displayBtn.phase++;
			}*/
			
			/*this.displayBtn.addEventListener( MouseEvent.ROLL_OVER, onDisplayMouseOver );
			this.displayBtn.addEventListener( MouseEvent.ROLL_OUT, onDisplayMouseOut );
			this.displayBtn.addEventListener( MouseEvent.MOUSE_MOVE, onDisplayMouseMove );
			this.displayBtn.addEventListener( ControlEvent.BUTTON_CLICK, onDisplayClick );
			this.displayBtn.addEventListener( ControlEvent.DOUBLE_CLICK, onDisplayDoubleClick );
			this.stage.addChild( this.displayBtn );
			
			if( !BildTvDefines.isEmbedPlayer)
			{
				this.displayBtn.visible = false;
			}
			
			this.displayBtn.onMouseOut();*/
		}
		
		public override function resize() :void
		{
//			trace( this + " onResize" );
			this.setSize();
			this.setDisplaySizeDefault();
		}
		
		public function clearDisplay( val:Boolean ) :void
		{
			if( val == true )
			{
//				this.displayHD.clear();
			}
			else
			{
				this.display.clear();
			}
		}
		
		public function supressPlayDisplayButton( val:Boolean ) :void
		{			
			//if(this.displayBtn)this.displayBtn.supressShow(val);
		}
		
		public function setPlayingStatus( playing:Boolean ) :void
		{
			trace(this+" setPlayingSatus "+playing);
			/*if(this.displayBtn)
			{
				if(playing == true)this.displayBtn.phase = 1;
				if(playing == false)this.displayBtn.phase = 0;
				this.displayBtn.playing = playing;
			} */
		
			// for ViewController
			if( playing )
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.PLAY ) );
			}
		}

		/*public function setDisplayButtonVisible( visible:Boolean = true ) :void
		{
		trace( this + " ~~~~~~~~~~~~~~~~~~~~~~~ setDisplayButtonVisible: " + visible + " ~~~~~~~~~~~~~~~~~~~~~~" );
			if(this.displayBtn && BildTvDefines.isEmbedPlayer)
			{
				this.displayBtn.visible = visible;
			}
		}*/
		
		/*public function setDisplayButtonAsPlayPauseButton( isPlayPauseBtn:Boolean = true ) :void
		{
		trace( this + " ~~~~~~~~~~~~~~~~~~~~~~~ isPlayPauseBtn: " + isPlayPauseBtn + " ~~~~~~~~~~~~~~~~~~~~~~" );
		//	if(this.displayBtn)this.displayBtn.isPlayPauseButton = isPlayPauseBtn;
		}*/
				
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
//			trace( this + " setVideoRatio: " + ratio );
			
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
//			trace( this + " updateDisplaySize" );
			
			var display:*;
			
			if( BildTvDefines.playsHDContent )
			{
//				display = this.displayHD;
			}
			else
			{
				display = this.display;			
			}
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
			/*if(this.displayBtn)
			{
				this.displayBtn.x = Math.round( ( this.currentWidth - this.displayBtn.width ) / 2 );
				this.displayBtn.y = Math.round( ( this.currentHeight - this.displayBtn.height ) / 2 );
			}*/
			

//			if( BildTvDefines.isMoviePlayer )
//			{
				/*this.chapterList.x = Math.round( ( this.currentWidth - ChapterListUi.WIDTH ) / 2 );
				this.chapterList.y = Math.round( this.currentHeight - ChapterListUi.HEIGHT );*/
//			}
			
			// notify PlayerController to change size of Ad
			this.dispatchEvent( new ControlEvent( ControlEvent.RESIZE, new FullscreenData( this.isFullscreen, this.wasFullscreen ) ) );
		}
		
	}
}