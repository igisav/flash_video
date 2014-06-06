package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import nhe.ui.MultiIconButton;
	

	public class DisplayButton extends MultiIconButton
	{
		protected static const MOUSETIMEOUT:uint = 2000;
		protected static const CLICKDELAY:uint = 200;
		
		public var mcPlayOver:Sprite;
		public var mcPlayOut:Sprite;
		public var mcPause:Sprite;
		
		protected var playOver:ImageContainer;
		protected var playOut:ImageContainer;
		protected var pause:ImageContainer;
		
		protected var doNotShow:Boolean = false;
		protected var _playing:Boolean = false;
		protected var _mouseOver:Boolean = false;
		protected var _isPlayPauseButton:Boolean = true;
		
		protected var mouseTimer:Timer;
		protected var clickTimer:Timer;
		
		public function DisplayButton(bitmapData:BitmapData,width:uint,height:uint, x:int, y:int, sourceAlignment:uint=0)
		{
			super(bitmapData,width,height, x, y, sourceAlignment);
			this.addEventListener( MouseEvent.CLICK, onClick );
			this.addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
			
			this.mouseTimer = new Timer( MOUSETIMEOUT, 1 );
			this.mouseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onMouseTimeout );
			
			this.clickTimer = new Timer( CLICKDELAY, 1 );
			this.clickTimer.addEventListener( TimerEvent.TIMER_COMPLETE, dispatchClickEvent );
			

			this.update();
		}
		
		public function setSkin( skin:SkinBaseVO ) :void
		{
			if( true)//skin.skinStatus )
			{
				//this.playOut.setSkin( skin.imgPlayOut );
				//this.playOver.setSkin( skin.imgPlayOver );
				//this.pause.setSkin( skin.imgPause ); 
			}	
		}
		
		public function set isPlayPauseButton( value:Boolean ) :void
		{
			this._isPlayPauseButton = value;
			this.update();
		}
		
		public function supressShow( value:Boolean ) :void
		{
			this.doNotShow = value;			
			this.hideButton();			
		}
		
		public function set playing( value:Boolean ) :void
		{
			this._playing = value;
			this.update();
		}
		
		public function onMouseOver( e:MouseEvent = null ) :void
		{
			this._mouseOver = true;
			this.update();
		}
		
		public function onMouseOut( e:MouseEvent = null ) :void
		{
			this._mouseOver = false;
			this.update();
		}
		
		public function onMouseMove( e:MouseEvent = null ) :void
		{
			this.update();
		}
		
		protected function onClick( e:MouseEvent ) :void
		{
			//trace("CLICK if double click is enabled, we need a timer to check if 2nd click occurs. if not, dispatch event directly to avoid popup blocker");
			if( this._isPlayPauseButton )
			{
				this.clickTimer.start();
			}
			else
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK ) );
			}
		}
		
		protected function onDoubleClick( e:MouseEvent ) :void
		{
			if( this._isPlayPauseButton )
			{
				this.clickTimer.reset();
				this.dispatchEvent( new ControlEvent( ControlEvent.DOUBLE_CLICK ) );
			}
		}
		
		protected function dispatchClickEvent( e:TimerEvent ) :void
		{
			this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK ) );
		}
		
		protected function update() :void
		{
			if( !BildTvDefines.isEmbedPlayer)
			{
				return;
			}
			
			this.mouseTimer.stop();			
			//if(this.doNotShow)return;
			
			//trace("this._isPlayPauseButton: " + this._isPlayPauseButton);
			if( this._isPlayPauseButton )
			{
				//trace(" yes...then this._mouseOver: " + this._mouseOver);
				
				if( this._mouseOver )
				{
					//trace(" if yes... this._playing: " + this._playing);
					if( this._playing )
					{
						this.showButton();
					//trace("show and start timer..");
						this.mouseTimer.reset();
						this.mouseTimer.start();
					}
					else
					{
						this.showButton();
						//trace("show");
					} 
				}
				else
				{
					//trace("nooooo...else this._playing: " + this._playing);
					 if( this._playing )
					{
						//trace("hide");
						this.hideButton();
					}
					else
					{
						//trace("show");
						this.showButton();
					} 
				} 
			}
			else
			{
				//trace("no ist not a playbuttons..else");
				this.hideButton( );
			}
		}
		
		public function hideButton() :void
		{
			this.visible = false;
		}
		
		public function showButton() :void
		{	
			this.visible = true;
		}
		
		protected function onMouseTimeout( e:TimerEvent ) :void
		{
			this.hideButton();
		}
		
		protected function onSkinComplete( e:Event ) :void
		{
			//this.width = this.btnMc.width;
			//this.height = this.btnMc.height;
		}
	}
}