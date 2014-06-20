package de.axelspringer.videoplayer.model.vo
{	
	public class Const
	{
		/*
		 * constant values
		 */
		public static const ERROR_NO_URL_FOUND:String	    = "Bei der Initialisierung ist keine Videoquelle vorhanden.";
		public static const ERROR_RUNTIME_UNKNOWN:String	= "Runtime unknown error.";
		public static const ERROR_EMPTY_VIDEOCLIP:String	= "Trying to set empty video clip.";

		public static const ERROR_SESSION_INFO:String	= "SIE SIND NICHT EINGELOGGT.";
		
		/*
		 * dynamic values
		 */
		 
		public static var playerName:String = "Axel Springer Videoplayer";
		public static var isMoviePlayer:Boolean = false;		// is a Nowtilus tokenized Akamai Stream - trailer or full movie
		public static var isTrailerPlayer:Boolean = false;		// is a Nowtilus tokenized Akamai Stream - trailer
		public static var isStreamPlayer:Boolean = false;		// is a tokenized Akamai Stream - VOD or live
		public static var isLivePlayer:Boolean = false;			// is a tokenized Akamai Stream - live
		public static var versionNumber:String;
		public static var isBumper:Boolean = false;
		public static var autoplay:Boolean;
		public static var autoplaySet:Boolean;
		public static var width:int;
		public static var height:int;
		public static var buffertimeMinimum:Number = 0.5;
		public static var buffertimeMaximum:Number = 10;
		public static var liveBuffertimeMinimum:Number = 3;
	}
}