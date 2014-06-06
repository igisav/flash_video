package de.axelspringer.videoplayer.ui
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.NetStream;
	import flash.text.TextField;
	
	public class BufferDisplay
	{
		protected static const LOADED_BAR_WIDTH:Number = 150;
		
		public var netstream:NetStream;
		
		protected var mc:MovieClip;
		protected var txtPercent:TextField;
		
		public function BufferDisplay( mc:MovieClip )
		{
			this.mc = mc;
			this.txtPercent = mc.getChildByName( "txtPercent" ) as TextField;
		}
		
		public function set active( value:Boolean ) :void
		{
			this.mc.removeEventListener( Event.ENTER_FRAME, update );
			
			if( value )
			{
				this.mc.addEventListener( Event.ENTER_FRAME, update );
			}
		}
		
		public function set visible( value:Boolean ) :void
		{
			this.active = value;
			this.mc.visible = value;
		}
		
		public function set x( value:Number ) :void
		{
			this.mc.x = value;
		}
		
		public function get x() :Number
		{
			return this.mc.x;
		}
		
		public function set y( value:Number ) :void
		{
			this.mc.y = value;
		}
		
		public function get y() :Number
		{
			return this.mc.y;
		}
		
		protected function update( event:Event = null ) :void
		{
			var loaded:Number = 0;
			
			if( this.netstream != null )
			{
				loaded = this.netstream.bufferLength / this.netstream.bufferTime;
				loaded = Math.min( 1, Math.max( 0, loaded ) );
				if( isNaN( loaded ) )
				{
					loaded = 0;
				}
			}
			
			this.txtPercent.text = Math.round( loaded * 100 ).toString();
		}
	}
}