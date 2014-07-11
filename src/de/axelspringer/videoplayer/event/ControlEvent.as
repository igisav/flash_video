package de.axelspringer.videoplayer.event
{
	import flash.events.Event;

	public class ControlEvent extends Event
	{
		public static const RESIZE:String 				= "ControlEvent.RESIZE";

		public var data:Object;
		
		public function ControlEvent( name:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( name, bubbles, cancelable );
			
			this.data = ( data == null ) ? {} : data;
		}
		
		public override function clone() :Event
		{
			return new ControlEvent( this.type, this.data, this.bubbles, this.cancelable );
		}
	}
}