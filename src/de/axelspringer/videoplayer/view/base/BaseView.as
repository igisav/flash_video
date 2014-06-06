package de.axelspringer.videoplayer.view.base
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	public class BaseView extends EventDispatcher
	{
		public static const NAME:String = "BaseView";
		
		protected var stage:Sprite;
		
		public function BaseView( stage:Sprite )
		{
			super( this );
			
			this.stage = stage;
		}

		public function show() :void
		{
			this.stage.visible = true;
		}
		
		public function hide() :void
		{
			this.stage.visible = false;
		}
		
		public function resize() :void
		{
			// overwrite 
		}
		
		public function set x( value:int ) :void
		{
			this.stage.x = value;
		}
		
		public function get x() :int
		{
			return this.stage.x;
		}
		
		public function set y( value:int ) :void
		{
			this.stage.y = value;
		}
		
		public function get y() :int
		{
			return this.stage.y;
		}
	}
}