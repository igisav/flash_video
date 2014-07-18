package de.axelspringer.videoplayer.model.vo
{	
	public class Const
	{
		/*
		 * constant values
		 */

        // type of errors
        public static const ERROR_TYPE_NETWORK:String   = "Network Error";
        public static const ERROR_TYPE_RUNTIME:String   = "Runtime Error";
        public static const ERROR_TYPE_SOURCE:String    = "Source Unsupported";
        public static const ERROR_TYPE_OTHER:String     = "Other Error";
        // errors messages
		public static const ERROR_NO_URL_FOUND:String	    = "Bei der Initialisierung ist keine Videoquelle vorhanden.";
		public static const ERROR_RUNTIME_UNKNOWN:String	= "Runtime unknown error.";
		public static const ERROR_EMPTY_VIDEOCLIP:String	= "Trying to set empty video clip.";
		public static const ERROR_HD_BITRATE:String	        = "Setting HD bitrate failed.";
		public static const ERROR_HD_CORE:String	        = "403: HD Core. Kein nächstes Segment in der bitrate gefunden";
		public static const ERROR_REDIRECT:String           = "Redirect error: ";

		/*
		 * dynamic values
		 */
		 
		public static var playerName:String = "Axel Springer Videoplayer";
		public static var isLivePlayer:Boolean = false;			// is a tokenized Akamai Stream - live
		public static var versionNumber:String;
		public static var buffertimeMinimum:Number = 0.5;
		public static var buffertimeMaximum:Number = 10;
	}
}