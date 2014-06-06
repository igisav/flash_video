package de.axelspringer.videoplayer.vast.loader
{
	import de.axelspringer.videoplayer.vast.model.VASTDataObject;
	
	import flash.events.Event;
	
	public class VASTDocumentProcessedEvent extends Event
	{
		public static const PROCESSED:String = "processed";
		public static const PROCESSING_FAILED:String = "processingFailed";
		
		public var vastDocument:VASTDataObject;
		
		public function VASTDocumentProcessedEvent( type:String, vastDocument:VASTDataObject=null, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			
			this.vastDocument = vastDocument;
		}
		
		override public function clone():Event
		{
			return new VASTDocumentProcessedEvent( this.type, this.vastDocument, this.bubbles, this.cancelable );
		}
	}
}