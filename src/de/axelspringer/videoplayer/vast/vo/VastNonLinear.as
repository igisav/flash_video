package de.axelspringer.videoplayer.vast.vo
{
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEvent;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEventType;
	import de.axelspringer.videoplayer.vast.model.VASTUrl;
	
	public class VastNonLinear implements IVpaidAd
	{
		public var id:String = "";
		public var duration:Number = 0;
		public var width:Number = -1;
		public var height:Number = -1;
		public var expandedWidth:Number = -1;
		public var expandedHeight:Number = -1;
		public var scalable:Boolean = true;
		public var maintainAspectRatio:Boolean = true;
		public var minSuggestedDuration:Number = -1;
		public var apiFramework:String = "";
		public var resourceType:String = "";
		public var staticResource:String = "";
		public var iFrameResource:String = "";
		public var htmlResource:String = "";
		public var clickThru:VASTUrl = new VASTUrl( "" );
		public var clickTrackings:Array = new Array();
		public var trackingEvents:Array = new Array();
		
		protected var parameters:String = "";
		
		public function VastNonLinear()
		{
		}
		
		public function set swfUrl( value:String ) :void
		{
			this.staticResource = value;
		}
		
		public function get swfUrl() :String
		{
			return this.staticResource;
		}
		
		public function set adParameters( value:String ) :void
		{
			this.parameters = value;
		}
		
		public function get adParameters() :String
		{
			return this.parameters;
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