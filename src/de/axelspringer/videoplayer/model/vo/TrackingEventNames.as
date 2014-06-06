/*
package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.controller.TrackingController;
	
	public class TrackingEventNames
	{
		private static var EVENT_PLAY_CLICK:String 		= "playClick";
		private static var EVENT_PLAY_START:String 		= "playStart";
		private static var EVENT_PLAY_COMPLETE:String	= "playComplete";
		private static var EVENT_PLAY_DENIED:String		= "playDenied";
		private static var EVENT_PAUSE:String 			= "pause";
		private static var EVENT_PROGRESS:String 		= "progress";
		private static var EVENT_UNPAUSE:String 		= "play";
		private static var EVENT_SEEK_FORWARD:String 	= "spulenVor";
		private static var EVENT_SEEK_BACK:String 		= "spulenZuruek";
		private static var EVENT_ABORT:String 			= "abbruch";
		private static var EVENT_POPUP:String 			= "popup";
		private static var EVENT_REPLAY:String 			= "wiederholen";
		private static var EVENT_START_PLAYER:String 	= "oeffnen";
		private static var EVENT_TEASER:String 			= "teaserClick";
		
		public static var EMPTY_TRACK:String 			= '""';
		
		public static function getEventName( eventType:String ) :String
		{
			var name:String = EMPTY_TRACK;
			
			switch( eventType )
			{
				case TrackingController.STATUS_INIT:
				{
					name = EVENT_PLAY_CLICK;
					break;
				}
				case TrackingController.STATUS_PAUSE:
				{
					name = EVENT_PAUSE;
					break;
				}
				case TrackingController.STATUS_PLAY:
				{
					name = EVENT_PLAY_START;
					break;
				}
				case TrackingController.STATUS_END:
				{
					name = EVENT_PLAY_COMPLETE;
					break;
				}
				case TrackingController.STATUS_POS:
				{
					name = EMPTY_TRACK;
					break;
				}
			}
			
			return name;
		}
	}
}*/
