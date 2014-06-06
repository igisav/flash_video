package de.axelspringer.videoplayer.event
{
	import flash.events.Event;

	public class ControlEvent extends Event
	{
		public static const PLAYPAUSE_CHANGE:String 	= "ControlEvent.PLAYPAUSE_CHANGE";
		public static const VIDEO_FINISH:String 		= "ControlEvent.VIDEO_FINISH";
		public static const PLAY:String 				= "ControlEvent.PLAY";
		public static const PAUSE:String 				= "ControlEvent.PAUSE";
		public static const RESUME:String 				= "ControlEvent.RESUME";
		public static const REPLAY:String 				= "ControlEvent.REPLAY";
		public static const PROGRESS_CHANGE:String 		= "ControlEvent.PROGRESS_CHANGE";
		public static const VOLUME_CHANGE:String 		= "ControlEvent.VOLUME_CHANGE";
		public static const FULLSCREEN_CHANGE:String 	= "ControlEvent.FULLSCREEN_CHANGE";
		public static const CONTENT_START:String 		= "ControlEvent.CONTENT_START";
		public static const BUTTON_OVER:String 			= "ControlEvent.BUTTON_OVER";
		public static const BUTTON_OUT:String 			= "ControlEvent.BUTTON_OUT";
		public static const BUTTON_CLICK:String 		= "ControlEvent.BUTTON_CLICK";
		public static const DISPLAY_CLICK:String 		= "ControlEvent.DISPLAY_CLICK";
		public static const DOUBLE_CLICK:String 		= "ControlEvent.DOUBLE_CLICK";
		public static const TEASER_CLICK:String 		= "ControlEvent.TEASER_CLICK";
		public static const CLOSE_UI:String 			= "ControlEvent.CLOSE_UI";
		public static const RESIZE:String 				= "ControlEvent.RESIZE";
		public static const AGE_RESTRICTION:String 		= "ControlEvent.AGE_RESTRICTION";
		public static const ERROR:String 				= "ControlEvent.ERROR";
		public static const ERROR_GEO:String 			= "ControlEvent.ERROR_GEO";
		public static const ERROR_SESSION:String 		= "ControlEvent.ERROR_SESSION";
		public static const ERROR_AVAILABLE:String 		= "ControlEvent.ERROR_AVAILABLE";
		public static const ERROR_CLICK:String 			= "ControlEvent.ERROR_CLICK";
		public static const LOADERANI_CHANGE:String 	= "ControlEvent.LOADERANI_CHANGE";
		public static const AD_LOAD_START:String 		= "ControlEvent.AD_LOAD_START";
		public static const JINGLE_FINISHED:String 		= "ControlEvent.JINGLE_FINISHED";
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