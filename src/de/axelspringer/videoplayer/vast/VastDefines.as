package de.axelspringer.videoplayer.vast
{
	public class VastDefines
	{
		// ad types
		public static const ADTYPE_PREROLL:String	= "9446";
		public static const ADTYPE_MIDROLL:String	= "9447";
		public static const ADTYPE_POSTROLL:String	= "9448";
		public static const ADTYPE_OVERLAY:String	= "9449";
		public static const ADTYPE_NONE:String		= "0";
		
		// ad resource types
		public static const RESOURCETYPE_IFRAME:String 	= "iframe";
		public static const RESOURCETYPE_SCRIPT:String 	= "script";
		public static const RESOURCETYPE_HTML:String 	= "html";
		public static const RESOURCETYPE_STATIC:String 	= "static";
		public static const RESOURCETYPE_OTHER:String 	= "other";
		
		// framework types
		public static const API_FRAMEWORK_VPAID:String 	= "VPAID";
		
		// delivery types
		public static const DELIVERYTYPE_STREAMING:String 	= "streaming";
		public static const DELIVERYTYPE_PROGRESSIVE:String = "progressive";
		
		// notifications
		public static const INFO_STARTUP_FINISHED:String    = "VastDefines::INFO_STARTUP_FINISHED";
		public static const INFO_AD_FINISHED:String    		= "VastDefines::INFO_AD_FINISHED";
		
		// commands
		public static const SET_VAST_AD_XML:String    		= "VastDefines::SET_VAST_AD_XML";
		public static const SET_VAST_AD:String    			= "VastDefines::SET_VAST_AD";
		
		public static const CMD_LOAD_XML:String    			= "VastDefines::CMD_LOAD_XML";
		public static const CMD_LOAD_PREROLL:String    		= "VastDefines::CMD_LOAD_PREROLL";
		public static const CMD_LOAD_POSTROLL:String    	= "VastDefines::CMD_LOAD_POSTROLL";
		public static const CMD_LOAD_OVERLAY:String    		= "VastDefines::CMD_LOAD_OVERLAY";
		
		// constants
		public static const MAX_REDIRECTS:int	 			= 2;
		public static const OVERLAY_DELAY:int	 			= 10000;		// ms
		public static const BITRATE_OPTIMUM:int				= 850;		// Kbps
		public static const LOADER_TIMEOUT:int				= 10000;		// ms
		
		// vast parsing
		public static const VAST_STRICT_MODE:Boolean		= false;
	}
}