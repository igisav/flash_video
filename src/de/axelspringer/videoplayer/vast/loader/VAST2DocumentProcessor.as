package de.axelspringer.videoplayer.vast.loader
{
	import de.axelspringer.videoplayer.vast.model.VAST2Translator;
	import de.axelspringer.videoplayer.vast.parser.VAST2Parser;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2TrackingData;
	import de.axelspringer.videoplayer.vast.parser.base.events.ParserErrorEvent;
	import de.axelspringer.videoplayer.vast.parser.base.events.ParserEvent;
	
	import flash.events.EventDispatcher;
	
	[Event("processed")]
	[Event("processingFailed")]
	
	public class VAST2DocumentProcessor extends EventDispatcher
	{
		private var parser:VAST2Parser;
		
		public function VAST2DocumentProcessor()
		{
			super( this );
		}
		
		public function processVASTDocument( document:XML, trackingData:VAST2TrackingData = null ) :void
		{
			parser = new VAST2Parser( trackingData );
			parser.addEventListener( ParserEvent.XML_PARSED, onXMLParsed );
			parser.addEventListener( ParserErrorEvent.XML_ERROR, onXMLParseError );
			parser.parse( document );
		}
		
		private function onXMLParsed(event:ParserEvent):void
		{
			parser.removeEventListener(ParserEvent.XML_PARSED, onXMLParsed);
			parser.removeEventListener(ParserErrorEvent.XML_ERROR, onXMLParseError);
			
			var translator:VAST2Translator = new VAST2Translator(parser);
			this.dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSED, translator));
		}
		
		private function onXMLParseError(event:ParserErrorEvent):void
		{
			parser.removeEventListener(ParserEvent.XML_PARSED, onXMLParsed);
			parser.removeEventListener(ParserErrorEvent.XML_ERROR, onXMLParseError);
			
			trace("[VAST] Error Parsing Tag: " + event.description);
			
			dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));			
		}
	}
}
