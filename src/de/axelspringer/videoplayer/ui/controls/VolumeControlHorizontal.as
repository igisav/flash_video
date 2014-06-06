package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	[Embed(source="/embed/assets.swf", symbol="VolumeControlHorizontal")]
	public class VolumeControlHorizontal extends Sprite
	{
		protected var STEPS:Number = 8;
		public static const NAME:String = "VolumeControlHorizontal";
		
		public var volumeBar:MovieClip;
		//public var mcMinus:MovieClip;
		//public var mcPlus:MovieClip;
		
		/* public var btnPlus:ControlButton;
		public var btnMinus:ControlButton;
		public var btnMute:ControlButton; */
		public var volumeProgressBar:Sprite;
		public var mcDragger:Sprite;

		protected var _volume:Number;
		protected var muted:Boolean = false;
		protected var savedVolume:Number;
		protected var dragging:Boolean;
		protected var dragBounds:Rectangle;
		
		public function VolumeControlHorizontal()
		{
			this.volumeProgressBar = this.volumeBar.getChildByName( "volumePane" ) as Sprite;
			this.mcDragger = this.volumeBar.getChildByName( "dragger" ) as Sprite;
			
			/* this.btnPlus = new ControlButton( this.mcPlus );
			this.btnMinus = new ControlButton( this.mcMinus ); */
			this.dragBounds = new Rectangle( 0, this.mcDragger.y, this.volumeBar.width, 0 );
			
			this.addEventListener( ControlEvent.BUTTON_CLICK, onVolumeButtonClick );
			this.volumeBar.addEventListener( MouseEvent.MOUSE_DOWN, startDragging );
			this.volumeBar.mouseChildren = false;
			this.volumeBar.buttonMode = true; 
		}
		
		public function setSkin( skin:SkinBaseVO ) :void
		{
			if( true )
			{
				var ct:ColorTransform = this.volumeBar.volumePane.transform.colorTransform;
				ct.color = skin.color;
				this.volumeBar.volumePane.transform.colorTransform = ct; 
				
				//this.btnMute.setSkin( skin );
				
				// don't use icon colors for those, create new skinVO and use the other colors
			
				//this.btnPlus.setSkin( skin );
				//this.btnMinus.setSkin( skin ); 
			} 
		}
		
		public function set widthScale(scale:Number):void
		{
			this.volumeBar.scaleX = scale;
			//this.btnPlus.x = this.volumeBar.x + this.volumeBar.width + 4;
		}
		
		public function set volume( value:Number ) :void
		{
			trace(value);
			this._volume = value;
			this.volumeProgressBar.scaleX = value;
			/* this.btnPlus.enabled = ( value < 1 );
			this.btnMinus.enabled = ( value > 0 ); */
			this.muted = ( value <= 0 );
			//this.mcMuted.visible = this.muted;
		}

		public function get volume() :Number
		{
			return this._volume;
		}
		
		protected function onVolumeButtonClick( e:ControlEvent ) :void
		{
			var vol:Number = this.volume;
			
			switch( e.data.button )
			{
				/* case this.btnPlus:
				{
					vol += 1 / STEPS;
					
					break;
				}
				case this.btnMinus:
				{
					vol -= 1 / STEPS;
					
					break;
				}
				case this.btnMute:
				{
					this.muted = !this.muted;
					
					if( this.muted )
					{
						this.savedVolume = vol;
						vol = 0;
					}
					else
					{
						vol = this.savedVolume;
					}
					
					break;
				} */
			}
			
			e.stopPropagation();
			this.dispatchEvent( new ControlEvent( ControlEvent.VOLUME_CHANGE, { volume:vol }, true, true ) );
		}
		
		protected function startDragging( e:MouseEvent ) :void 
		{
			this.dragging = true;
			
			this.mcDragger.startDrag( true, this.dragBounds );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, endDrag );
			this.addEventListener( Event.ENTER_FRAME, changeVolumeByPosition );
		}
		
		protected function endDrag( e:MouseEvent ):void 
		{
			if( this.dragging == true )
			{
				this.dragging = false;
				
				this.mcDragger.stopDrag();
				this.stage.removeEventListener( MouseEvent.MOUSE_UP, endDrag );
				this.removeEventListener( Event.ENTER_FRAME, changeVolumeByPosition );
				
				this.changeVolumeByPosition( new Event( "" ) );
			}
		}
		
		protected function changeVolumeByPosition( e:Event ):void 
		{
			var vol:Number = this.mcDragger.x / this.dragBounds.width;
						
			this.dispatchEvent( new ControlEvent( ControlEvent.VOLUME_CHANGE, { volume:vol }, true, true ) );
		} 
		
		public function className():String
		{
			return NAME;
		}
	}
}