package de.axelspringer.videoplayer.vast.vo
{
	public class VastCompanion
	{
		public static var RESOURCETYPE_IFRAME:String 	= "iframe";
		public static var RESOURCETYPE_SCRIPT:String 	= "script";
		public static var RESOURCETYPE_HTML:String 		= "html";
		public static var RESOURCETYPE_STATIC:String 	= "static";
		public static var RESOURCETYPE_OTHER:String 	= "other";
		
		public var id:String = "";
		public var width:Number = -1;
		public var height:Number = -1;
		public var expandedWidth:Number = -1;
		public var expandedHeight:Number = -1;
		public var apiFramework:String = "";		// vast 2.0 only
		public var resourceType:String = "";		// vast 1.0 only
		public var creativeType:String = "";
		public var staticResource:String = "";
		public var iFrameResource:String = "";
		public var htmlResource:String = "";
		public var clickThru:String = "";
		public var clickTrackings:Array = new Array();
		public var adParameters:String = "";
		public var altText:String = "";
		
		public function VastCompanion()
		{
		}
	}
}