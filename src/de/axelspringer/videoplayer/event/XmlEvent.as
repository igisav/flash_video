package de.axelspringer.videoplayer.event
{
	import flash.events.Event;

	public class XmlEvent extends Event
	{
		public static const XML_LOADED:String 	= "XmlEvent.XML_LOADED";
		public static const XML_ERROR:String 	= "XmlEvent.XML_ERROR";
		
		public var xml:XML;
		public var text:String;
		public var url:String;
		
		public function XmlEvent( type:String, url:String, xml:XML = null, text:String = null, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{
			super( type, bubbles, cancelable );
			this.url = url;
			this.xml = xml;
			this.text = text;
		}
	}
}