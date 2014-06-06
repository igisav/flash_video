package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.FilmChapterVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	[Embed(source="/embed/assets.swf", symbol="ChapterListUi")]
	public class ChapterListUi extends Sprite
	{
		public static const WIDTH:uint 	= 654;
		public static const HEIGHT:uint = 56;
		
		protected static const ITEMS_MARGIN:uint = 3;
		protected static const VISIBLE_TIME:uint = 3000;
		
		public var listContent:Sprite;
		public var listContentMask:Sprite;
		public var btnLeft:Sprite;
		public var btnRight:Sprite;
		
		protected var chapters:Array;
		protected var currentChapter:ChapterListItemUi;
		
		protected var contentXMin:Number;
		protected var contentXMax:Number;
		protected var visibleTimer:Timer;
		protected var isVisible:Boolean;
		protected var isMouseOver:Boolean;
		
		public function ChapterListUi()
		{
			super();
			
			this.init();
		}
		
		protected function init() :void
		{
			this.btnLeft.mouseChildren = false;
			this.btnLeft.buttonMode = true;
			this.btnLeft.addEventListener( MouseEvent.CLICK, onButtonLeftClick );
			
			this.btnRight.mouseChildren = false;
			this.btnRight.buttonMode = true;
			this.btnRight.addEventListener( MouseEvent.CLICK, onButtonRightClick );
			
			this.chapters = new Array();
			
			this.visibleTimer = new Timer( VISIBLE_TIME, 1 );
			this.visibleTimer.addEventListener( TimerEvent.TIMER, onVisibleTimer );
			
			this.addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
			this.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			this.visible = false;
		}
		
		public function create( data:Array ) :void
		{
			var chapterUi:ChapterListItemUi;
			var chapterData:FilmChapterVO;
			var xPos:uint = 0;
			var yPos:uint = 2;
			
			for( var i:uint = 0; i < data.length; i++ )
			{
				chapterData = data[i];
				chapterUi = new ChapterListItemUi();
				chapterUi.imageUrl = chapterData.thumbnailUrl;
				chapterUi.timestamp = chapterData.chapterTime;
				chapterUi.index = i;
				chapterUi.addEventListener( MouseEvent.CLICK, onChapterClick, false, 0, true );
				
				chapterUi.x = xPos;
				chapterUi.y = yPos;
				this.listContent.addChild( chapterUi );
				this.chapters.push( chapterUi );
				
				xPos += ChapterListItemUi.WIDTH + ITEMS_MARGIN;
			}
			
			this.contentXMin = this.listContentMask.x + this.listContentMask.width - xPos + ITEMS_MARGIN;
			this.contentXMax = this.listContentMask.x;
			
			this.selectChapter( 0, false );
			this.visible = true;
			super.visible = true;
		}
		
		public function updateTime( newTime:Number ) :void
		{
//			trace( this + " updateTime: " + newTime );
			
			if( this.currentChapter == null )
			{
				return;
			}
			
			// make sure it's positive
			newTime = Math.max( 0, newTime );
			
			var time1:Number = this.currentChapter.timestamp;
			
			// if new time is smaller than the current chapter's time, find the right chapter
			if( newTime < time1 )
			{
				this.findChapterByTime( newTime );
			}
			// if it's not the last chapter, check if new time is still inside the current chapter
			else if( this.currentChapter.index < this.chapters.length - 1 )
			{
				var time2:Number = this.chapters[ this.currentChapter.index + 1 ].timestamp;
				if( newTime > time2 )
				{
					this.findChapterByTime( newTime );
				}
			}
		}
		
		public override function set visible( value:Boolean ) :void
		{
			this.isVisible = value;
			
			if( this.isVisible )
			{
				this.startVisibleTimer();
			}
			else
			{
				super.visible = false;
			}
		}
		
		protected function findChapterByTime( time:Number ) :void
		{
//			trace( this + " findChapterByTime: " + time );
			
			var i:int = this.chapters.length;
			while( i-- )
			{
				if( time >= this.chapters[i].timestamp )
				{
					this.selectChapter( i, false );
					break;
				}
			}
		}
		
		protected function onChapterClick( event:MouseEvent ) :void
		{
			var chapterUi:ChapterListItemUi = event.target as ChapterListItemUi;
			if( chapterUi != null )
			{
				this.selectChapter( chapterUi.index );
			}
		}
		
		protected function onButtonLeftClick( event:MouseEvent ) :void
		{
			var newX:Number = Math.round( this.listContent.x + ChapterListItemUi.WIDTH + ITEMS_MARGIN );
			this.listContent.x = Math.min( newX, this.contentXMax );
			
			this.updateButtons();
		}
		
		protected function onButtonRightClick( event:MouseEvent ) :void
		{
			var newX:Number = Math.round( this.listContent.x - ChapterListItemUi.WIDTH - ITEMS_MARGIN );
			this.listContent.x = Math.max( newX, this.contentXMin );
			
			this.updateButtons();
		}
		
		protected function selectChapter( index:uint, seekToChapterTime:Boolean = true ) :void
		{
			if( this.currentChapter != null )
			{
				this.currentChapter.selected = false;
			}
			
			this.currentChapter = this.chapters[ index ];
			this.currentChapter.selected = true;
			
			if( seekToChapterTime )
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.PROGRESS_CHANGE, { seekPoint:this.currentChapter.timestamp } ) );
			}
		}
		
		protected function updateButtons() :void
		{
			this.btnLeft.mouseEnabled = ( this.listContent.x < this.contentXMax );
			this.btnRight.mouseEnabled = ( this.listContent.x > this.contentXMin );
		}
		
		protected function startVisibleTimer() :void
		{
			this.visibleTimer.reset();
			this.visibleTimer.start();
		}
		
		protected function onVisibleTimer( event:TimerEvent ) :void
		{
			super.visible = false;
		}
		
		protected function onAddedToStage( event:Event ) :void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			this.parent.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		}
		
		protected function onMouseMove( event:MouseEvent ) :void
		{
			if( !this.isMouseOver && this.isVisible && !super.visible )
			{
				super.visible = true;
				this.startVisibleTimer();
				
			}
		}
		
		protected function onMouseOver( event:MouseEvent ) :void
		{
			this.isMouseOver = true;
			this.visibleTimer.reset();
		}
		
		protected function onMouseOut( event:MouseEvent ) :void
		{
			this.isMouseOver = false;
			
			if( this.isVisible )
			{
				this.startVisibleTimer();
			}
		}
	}
}