package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.SkinVO;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	[Embed(source="/embed/assets.swf", symbol="SeekControl")]
	public class ProgressBar extends Sprite
	{
		private var ui:Sprite;
		
		public var bar:MovieClip;		
		public var playhead:Sprite;
		
		public var preloadBar:Sprite;
		public var progressBar:Sprite;
		public var seekBar:Sprite;
		public var background:Sprite;
		
		public var seekedElement:Sprite;
		
		
		protected var dragging:Boolean;
		
		public function ProgressBar()
		{
			this.ui = this.bar;
			
			this.preloadBar = this.ui.getChildByName( "preloadBar" ) as Sprite;
			this.progressBar = this.ui.getChildByName( "progressBar" ) as Sprite;
			this.seekBar = this.ui.getChildByName( "seekBar" ) as Sprite;
			this.background = this.ui.getChildByName( "background" ) as Sprite;
			
			this.seekBar.buttonMode = true;
			this.seekBar.addEventListener( MouseEvent.MOUSE_DOWN, startingDrag ); 
			this.playhead.buttonMode = true;
			this.playhead.addEventListener( MouseEvent.MOUSE_DOWN, startingDrag );
		}
		
		/**
		 * loadProgress is between 0 and 1
		 */
		public function set loadProgress( value:Number ) :void
		{
			//trace( "load: " + value );
			
			this.preloadBar.scaleX = value;
		}
		
		/**
		 * playProgress is between 0 and 1
		 */
		public function set playProgress( value:Number ) :void
		{
//			trace("upgrade: " + this.bar.width + "    " + this.progressBar.width);
			
			if( isNaN( value ) )
			{
				return; 
			}
			this.progressBar.scaleX = value;
			if( !this.dragging )
			{
				this.playhead.x = Math.round( value * this.bar.width ) - this.playhead.width/2;
			}
		}
		
		public override function set width( value:Number ) :void
		{
			this.bar.width = value;
//			trace(this.bar.width + "    " + this.progressBar.width);
			// adjust  dragger position
			if( !this.dragging )
			{
				this.playhead.x = Math.round( this.progressBar.scaleX * this.bar.width );
			}
		}
		
		public function enableSeeking( enable:Boolean ) :void
		{
			this.seekBar.mouseEnabled = enable;
			this.playhead.mouseEnabled = enable;
			if( this.playhead.numChildren != 0 ) 
			{
				SimpleButton(this.playhead.getChildAt(0)).mouseEnabled = enable;
			}
		}
		
		public function startingDrag( e:MouseEvent ) :void 
		{
			this.dragging = true;
			
			this.seekedElement = e.currentTarget as Sprite;
			
			this.ui.stage.addEventListener( MouseEvent.MOUSE_UP, endDrag );
			this.playhead.startDrag( true, new Rectangle( this.bar.x, this.playhead.y, this.bar.width, 0 ) );
			this.ui.addEventListener( Event.ENTER_FRAME, changeProgressByPosition );
		}
		
		protected function endDrag( e:MouseEvent ):void 
		{
			if( this.dragging == true )
			{
				this.dragging = false;
				
				this.playhead.stopDrag();
				this.ui.stage.removeEventListener( MouseEvent.MOUSE_UP, endDrag );
				this.ui.removeEventListener( Event.ENTER_FRAME, changeProgressByPosition );
				
				if(this.seekedElement == this.playhead)
				{
				}
				this.seekedElement = new Sprite();
				this.changeProgressByPosition( null );	
				
			}
		}
		
		
		public function changeProgressByExtern( percent:Number ):void 
		{				
			this.ui.dispatchEvent( new ControlEvent( ControlEvent.PROGRESS_CHANGE, { seekPoint:percent, dragging:this.dragging }, true, true ) );				
		}
		
		protected function changeProgressByPosition( e:Event ):void 
		{
			var seekPoint:Number = this.playhead.x / this.bar.width;
						
			this.ui.dispatchEvent( new ControlEvent( ControlEvent.PROGRESS_CHANGE, { seekPoint:seekPoint, dragging:this.dragging }, true, true ) );				
		}
	}
}