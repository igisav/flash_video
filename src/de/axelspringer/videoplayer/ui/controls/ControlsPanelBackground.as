package de.axelspringer.videoplayer.ui.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
/*toDelete  */
	public class ControlsPanelBackground extends ImageContainer
	{
		protected var bg:Sprite;
		
		public var separator1:Sprite;
		public var separator2:Sprite;
		public var separator3:Sprite;
		
		public function ControlsPanelBackground( containerUi:Sprite )
		{
			super( containerUi );
			
			this.bg = this.fallbackUi.getChildByName( "bg" ) as Sprite;
			this.separator1 = this.fallbackUi.getChildByName( "separator1" ) as Sprite;
			this.separator2 = this.fallbackUi.getChildByName( "separator2" ) as Sprite;
			this.separator3 = this.fallbackUi.getChildByName( "separator3" ) as Sprite;
		}
		
		override public function set width( value:Number ) :void
		{
			if( !this.isFallback )
			{
				super.width = value;
			}
			else
			{
				this.currentWidth = value;
				
				this.bg.width = value;
				
				this.separator1.x = 50;
			}
		}
		
		public function setControlsSkin( imgUrl:String, colorBG:Number = 0, colorSeperators:Number = 0 ) :void
		{
			this.reset();
			
			if(imgUrl != "")
			{
				try
				{
					this.loader.load( new URLRequest( imgUrl ), new LoaderContext( true ) );
				}
				catch( e:Error )
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, e.getStacktrace() ) );
				}	
			}
			else if(colorBG != 0)
			{
				this.setColor(colorBG);
				
			}
			if(colorSeperators != 0) this.setSeperatorColor(colorSeperators);
		}
		
		protected function setSeperatorColor( color:Number ) :void
		{
			var gui:DisplayObject;
			var ct:ColorTransform;
			
			gui = this.separator1;
			
			if( gui != null )
			{
				ct = gui.transform.colorTransform;
				
				ct.color = color;
				this.separator1.transform.colorTransform = ct;
				this.separator2.transform.colorTransform = ct;
				this.separator3.transform.colorTransform = ct;
			}
		}
	}
}