package de.axelspringer.videoplayer.event
{
	import flash.events.Event;

	public class AdEvent extends Event
	{
		public static const LOADED:String				= "AdEvent.LOADED";
		public static const ERROR:String				= "AdEvent.ERROR";
		public static const LINEAR_START:String			= "AdEvent.LINEAR_START";
		public static const LINEAR_STOP:String			= "AdEvent.LINEAR_STOP";
		public static const NONLINEAR_START:String		= "AdEvent.NONLINEAR_START";
		public static const FINISH:String				= "AdEvent.FINISH";
		public static const CLICK:String				= "AdEvent.CLICK";
		public static const TRACK:String				= "AdEvent.TRACK";
		public static const TRACK_CUSTOM:String			= "AdEvent.TRACK_CUSTOM";
		public static const PROGRESS:String				= "AdEvent.PROGRESS";
		
		public var data:Object;
		public var adPlacement:String;
		
		public function AdEvent( type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false, adPlacement:String = "" )
		{
			super( type, bubbles, cancelable );
			
			this.data = ( data == null ) ? {} : data;
			this.adPlacement = ( adPlacement == "" ) ? "" : adPlacement;
		}
		
		public override function clone() :Event
		{
			return new AdEvent( this.type, this.data, this.bubbles, this.cancelable, this.adPlacement );
		}
	}
}