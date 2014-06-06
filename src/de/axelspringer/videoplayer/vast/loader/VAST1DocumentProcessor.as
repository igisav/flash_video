package de.axelspringer.videoplayer.vast.loader
{
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.vast.model.VASTDocument;
	import de.axelspringer.videoplayer.vast.parser.VAST1Parser;
	
	import flash.events.EventDispatcher;
	
	[Event("processed")]
	[Event("processingFailed")]
	
	public class VAST1DocumentProcessor extends EventDispatcher
	{
		public function VAST1DocumentProcessor()
		{
			super( this );
		}

		public function processVASTDocument( document:XML ) :void
		{
			var parser:VAST1Parser = new VAST1Parser();
			var vastDocument:VASTDocument = parser.parse( document, VastDefines.VAST_STRICT_MODE );
			if( vastDocument != null )
			{
				this.dispatchEvent( new VASTDocumentProcessedEvent( VASTDocumentProcessedEvent.PROCESSED, vastDocument ) );
			}
			else
			{
				trace( "[VAST] Processing failed for document with contents: " + document );
					
				this.dispatchEvent( new VASTDocumentProcessedEvent( VASTDocumentProcessedEvent.PROCESSING_FAILED ) );
			}
		}
	}
}
