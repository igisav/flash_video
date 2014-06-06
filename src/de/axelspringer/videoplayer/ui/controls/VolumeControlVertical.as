/*  */package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	[Embed(source="/embed/assets.swf", symbol="VolumeControl")]
	public class VolumeControlVertical extends Sprite
	{
		protected var STEPS:Number = 8;
		public static const NAME:String = "VolumeControlVertical";
		
		public var bar:Sprite;
		
		public var btn:Sprite;
		public var dragger:Sprite;
		public var volumePane:Sprite;
		public var volumePaneBg:Sprite;
		public var paneMask:Sprite;
		public var background:Sprite;
		
		protected var _volume:Number;
		protected var muted:Boolean = false;
		protected var savedVolume:Number = 0;
		protected var dragging:Boolean;
		public var dragBounds:Rectangle;
		
		public function VolumeControlVertical(height:Number = 60)
		{
			
			this.btn = this.bar.getChildByName( "btn" ) as Sprite; 
			this.dragger = this.bar.getChildByName( "dragger" ) as Sprite; 
			this.volumePane = this.bar.getChildByName( "volumePane" ) as Sprite; 
			this.paneMask = this.bar.getChildByName( "paneMask" ) as Sprite; 
			this.volumePaneBg = this.bar.getChildByName( "volumePaneBg" ) as Sprite; 
			this.background = this.bar.getChildByName( "background" ) as Sprite; 
			
			this.dragBounds = new Rectangle( 0,0, 0, height);
			
			//this.ui.addEventListener( ControlEvent.BUTTON_CLICK, onVolumeButtonClick );
			this.btn.addEventListener( MouseEvent.MOUSE_DOWN, startDragging );
			this.btn.mouseChildren = false;
			this.btn.buttonMode = true;
		}
				
		public function set widthScale(scale:Number):void
		{
			this.volumePane.scaleY = scale;
		}
		
		public function set volume( value:Number ) :void
		{
			if(value == 0)
			{
				if( this.muted )
				{
					this.muted = false;
					_volume = this.savedVolume;
				}
				else
				{
					this.savedVolume = _volume;
					this.muted = true;
					_volume = 0;
				}
				
			}
			this.volumePane.scaleX = _volume;
		}

		public function setSkin(skin:SkinBaseVO = null):void
		{
			
		}
		
		public function get volume() :Number
		{
			return this._volume;
		}
		
		protected function startDragging( e:MouseEvent ) :void 
		{
			this.dragging = true;
			
			this.dragger.startDrag(true,this.dragBounds );
			this.bar.stage.addEventListener( MouseEvent.MOUSE_UP, endDrag );
			this.bar.addEventListener( Event.ENTER_FRAME, changeVolumeByPosition );
		}
		
		public function endDrag( e:MouseEvent ):void 
		{
			if( this.dragging == true )
			{
				this.dragging = false;
				
				this.dragger.stopDrag();
				this.bar.stage.removeEventListener( MouseEvent.MOUSE_UP, endDrag );
				this.bar.removeEventListener( Event.ENTER_FRAME, changeVolumeByPosition );
				
				this.changeVolumeByPosition( new Event( "" ) );
			}
		}
		
		protected function changeVolumeByPosition( e:Event ):void 
		{
			var vol:Number = 1 -(this.dragger.y / this.dragBounds.height);
						
			this.bar.dispatchEvent( new ControlEvent( ControlEvent.VOLUME_CHANGE, { volume:vol }, true, true ) );
		}
	}
}