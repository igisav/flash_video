package de.axelspringer.videoplayer.event
{
	import flash.events.Event;

	public class ControlEvent extends Event
	{
		public static const PAUSE:String 				= "ControlEvent.PAUSE";
		public static const RESUME:String 				= "ControlEvent.RESUME";
		public static const PROGRESS_CHANGE:String 		= "ControlEvent.PROGRESS_CHANGE";
		public static const CONTENT_START:String 		= "ControlEvent.CONTENT_START";
		public static const RESIZE:String 				= "ControlEvent.RESIZE";
		public static const ERROR_SESSION:String 		= "ControlEvent.ERROR_SESSION";
		public static const LOAD_MIDROLL:String 		= "ControlEvent.LOAD_MIDROLL";
		public static const LOAD_POSTROLL:String 		= "ControlEvent.LOAD_POSTROLL";
		public static const SESSION_OK:String 			= "ControlEvent.SESSION_OK";
		
		public var data:Object;
		
		public function ControlEvent( type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			
			this.data = ( data == null ) ? {} : data;
		}
		
		public override function clone() :Event
		{
			return new ControlEvent( this.type, this.data, this.bubbles, this.cancelable );
		}
	}
}