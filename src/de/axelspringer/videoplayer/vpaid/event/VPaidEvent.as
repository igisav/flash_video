package de.axelspringer.videoplayer.vpaid.event
{
	import flash.events.Event;

	public class VPaidEvent extends Event
	{
		public static const LOADED:String 				= "AdLoaded";
		public static const STARTED:String 				= "AdStarted";
		public static const STOPPED:String 				= "AdStopped";
		public static const LINEARCHANGE:String 		= "AdLinearChange";
		public static const EXPANDEDCHANGE:String 		= "AdExpandedChange";
		public static const REMAININGTIMECHANGE:String	= "AdRemainingTimeChange";
		public static const VOLUMECHANGE:String 		= "AdVolumeChange";
		public static const IMPRESSION:String 			= "AdImpression";
		public static const VIDEOSTART:String 			= "AdVideoStart";
		public static const VIDEOFIRSTQUARTILE:String	= "AdVideoFirstQuartile";
		public static const VIDEOMIDPOINT:String 		= "AdVideoMidpoint";
		public static const VIDEOTHIRDQUARTILE:String	= "AdVideoThirdQuartile";
		public static const VIDEOCOMPLETE:String 		= "AdVideoComplete";
		public static const CLICKTHRU:String 			= "AdClickThru";
		public static const USERACCEPTINVITATION:String	= "AdUserAcceptInvitation";
		public static const USERMINIMIZE:String 		= "AdUserMinimize";
		public static const USERCLOSE:String 			= "AdUserClose";
		public static const PAUSED:String 				= "AdPaused";
		public static const PLAYING:String 				= "AdPlaying";
		public static const LOG:String 					= "AdLog";
		public static const ERROR:String 				= "AdError";
		public static const CREATIVEVIEW:String 		= "AdCreativeView";
		
		private var _data:Object;
		
		public function VPaidEvent( type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			_data = ( data == null ) ? {} : data;
		}
		
		public function get data() :Object
		{
			return _data;
		}
	}
}