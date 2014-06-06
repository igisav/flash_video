package de.axelspringer.videoplayer.vast.loader
{
	import de.axelspringer.videoplayer.vast.model.VASTDataObject;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2TrackingData;
	
	import flash.events.EventDispatcher;
	
	[Event("processed")]
	[Event("processingFailed")]
	
	public class VASTDocumentProcessor extends EventDispatcher
	{
		private static const VAST_1_ROOT:String = "VideoAdServingTemplate";
		private static const VAST_2_ROOT:String = "VAST";
		
		private var maxNumWrapperRedirects:Number;
		
		public function VASTDocumentProcessor()
		{
			super( this );
		}
		
		public function processVASTDocument( document:XML, trackingData:VAST2TrackingData = null ) :void
		{
			var vastVersion:Number;
			if( document.localName() == VAST_1_ROOT )
			{
				vastVersion = VASTDataObject.VERSION_1_0;
			}
			else if( document.localName() == VAST_2_ROOT )
			{
				vastVersion = document.@version;
			}
			
			switch( vastVersion )
			{
				case VASTDataObject.VERSION_1_0:
				{
					var vast1DocumentProcessor:VAST1DocumentProcessor = new VAST1DocumentProcessor();
					vast1DocumentProcessor.addEventListener( VASTDocumentProcessedEvent.PROCESSED, cloneDocumentProcessorEvent );
					vast1DocumentProcessor.addEventListener( VASTDocumentProcessedEvent.PROCESSING_FAILED, cloneDocumentProcessorEvent );						
					vast1DocumentProcessor.processVASTDocument( document );
					
					break;
				}					
				case VASTDataObject.VERSION_2_0:
				{
					var vast2DocumentProcessor:VAST2DocumentProcessor = new VAST2DocumentProcessor();
					vast2DocumentProcessor.addEventListener( VASTDocumentProcessedEvent.PROCESSED, cloneDocumentProcessorEvent );
					vast2DocumentProcessor.addEventListener( VASTDocumentProcessedEvent.PROCESSING_FAILED, cloneDocumentProcessorEvent ); 					
					vast2DocumentProcessor.processVASTDocument( document, trackingData );
					
					break;
				}
				default:
				{
					trace( "[VAST] Processing failed for document with contents: " + document );
			
					this.dispatchEvent( new VASTDocumentProcessedEvent( VASTDocumentProcessedEvent.PROCESSING_FAILED ) );
					
					break;
				}
			}			
		}
		
		private function cloneDocumentProcessorEvent( event:VASTDocumentProcessedEvent ) :void
		{
			var processor:EventDispatcher = event.target as EventDispatcher;
			processor.removeEventListener( VASTDocumentProcessedEvent.PROCESSED, cloneDocumentProcessorEvent );
			processor.removeEventListener( VASTDocumentProcessedEvent.PROCESSING_FAILED, cloneDocumentProcessorEvent ); 
			this.dispatchEvent( event.clone() );
		}
	}
}