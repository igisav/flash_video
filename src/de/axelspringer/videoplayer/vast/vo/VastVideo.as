package de.axelspringer.videoplayer.vast.vo
{
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEvent;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEventType;
	
	public class VastVideo
	{
		public var duration:Number = 0;
		public var videoClicks:VastVideoClicks = new VastVideoClicks();
		public var mediaFiles:Array = new Array();
		public var trackingEvents:Array = new Array();
		public var adParameters:String = "";
		
		public function VastVideo()
		{
		}
		
		public function addTrackingEvents( newEvents:Array ) :void
		{
			var existingTrackingEvent:VASTTrackingEvent;
			
			for each( var trackingEvent:VASTTrackingEvent in newEvents )
			{
				existingTrackingEvent = this.getTrackingEventByType( trackingEvent.type );
				if( existingTrackingEvent != null )
				{
					existingTrackingEvent.urls = existingTrackingEvent.urls.concat( trackingEvent.urls );
				}
				else
				{
					this.trackingEvents.push( trackingEvent );
				}
			}
		}
		
		protected function getTrackingEventByType( eventType:VASTTrackingEventType ) :VASTTrackingEvent
		{
			var result:VASTTrackingEvent;
			
			for each( var trackingEvent:VASTTrackingEvent in this.trackingEvents )
			{
				if( trackingEvent.type == eventType )
				{
					result = trackingEvent;
					break;
				}
			}
			
			return result;
		}
	}
}