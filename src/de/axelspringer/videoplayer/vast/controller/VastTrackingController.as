package de.axelspringer.videoplayer.vast.controller
{
	import de.axelspringer.videoplayer.event.AdEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.FullscreenData;
	import de.axelspringer.videoplayer.model.vo.VolumeData;
	import de.axelspringer.videoplayer.vast.VastController;
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEvent;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEventType;
	import de.axelspringer.videoplayer.vast.model.VASTUrl;
	import de.axelspringer.videoplayer.vast.vo.VastAd;
	import de.axelspringer.videoplayer.vast.vo.VastNonLinear;
	import de.axelspringer.videoplayer.vast.vo.VastTrackingExtension;
	import de.axelspringer.videoplayer.vast.vo.VastVideo;
	import de.axelspringer.videoplayer.vpaid.controller.VPaidController;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.sendToURL;
		
	public class VastTrackingController
	{
		protected var playerController:VastPlayerController;
		protected var vpaidController:VPaidController;
		
		protected var currentAd:VastAd;
		protected var currentAdPlacement:String;
		
		protected var trackedImpression:Boolean;
		protected var trackedStart:Boolean;
		protected var trackedFirstQuartile:Boolean;
		protected var trackedMidpoint:Boolean;
		protected var trackedThirdQuartile:Boolean;
		protected var trackedComplete:Boolean;
		
		//protected var eventType:VASTTrackingEventType;
		
		public function VastTrackingController( playerController:VastPlayerController, vpaidController:VPaidController )
		{
			this.playerController = playerController;
			this.vpaidController = vpaidController;
			
			this.init();
		}
		
		protected function init() :void
		{
			this.playerController.addEventListener( AdEvent.TRACK, trackEvent );
			this.playerController.addEventListener( AdEvent.PROGRESS, onAdProgress );
			this.playerController.addEventListener( AdEvent.ERROR, onAdPlayError );
			
			this.vpaidController.addEventListener( AdEvent.TRACK, trackEvent );
			this.vpaidController.addEventListener( AdEvent.TRACK_CUSTOM, trackCustom );
			this.vpaidController.addEventListener( AdEvent.ERROR, onAdPlayError );
			
			this.reset();
		}
		
		public function reset():void
		{
			this.trackedImpression = false;
			this.trackedStart = false;
			this.trackedFirstQuartile = false;
			this.trackedMidpoint = false;
			this.trackedThirdQuartile = false;
			this.trackedComplete = false;
		}
		
		public function setAd( ad:VastAd, placement:String ) :void
		{
			this.currentAd = ad;
			this.currentAdPlacement = placement;
			this.reset();
		}
		
		public function trackUrls( urls:Array ) :void
		{
//			trace( this + " trackUrls: " + urls.length );
			
			for each( var url:VASTUrl in urls )
			{
				this.trackUrl( url );
			}
		}
		
		public function trackFullscreen( fullscreenData:FullscreenData ) :void
		{
			if( fullscreenData.isFullscreen && !fullscreenData.wasFullscreen )
			{
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.FULLSCREEN ) );
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.EXPAND ) );
			}
			
			if( !fullscreenData.isFullscreen && fullscreenData.wasFullscreen )
			{
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.COLLAPSE ) );
			}
		}
		
		public function trackVolumeChange( volumeData:VolumeData ) :void
		{
			if( volumeData.oldVolume > 0 && volumeData.newVolume == 0 )
			{
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.MUTE ) );
			}
			if( volumeData.oldVolume == 0 && volumeData.newVolume > 0 )
			{
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.UNMUTE ) );
			}
		}
		
		protected function onAdProgress( event:AdEvent ) :void
		{
			var progress:Number = event.data as Number;
			if( progress > 0.25 && !this.trackedFirstQuartile )
			{
				this.trackedFirstQuartile = true;
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.FIRST_QUARTILE ) );
			}
			if( progress > 0.5 && !this.trackedMidpoint )
			{
				this.trackedMidpoint = true;
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.MIDPOINT ) );
			}
			if( progress > 0.75 && !this.trackedThirdQuartile )
			{
				this.trackedThirdQuartile = true;
				this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.THIRD_QUARTILE ) );
			}
		}
		
		protected function onAdPlayError( event:AdEvent ) :void
		{
			this.trackUrls( this.currentAd.errors );
		}
		
		protected function trackEvent( event:AdEvent ) :void
		{
			var eventType:VASTTrackingEventType = event.data as VASTTrackingEventType;
			
			switch( eventType )
			{
				case VASTTrackingEventType.START:
				{
					if( this.trackedStart )
					{
						return;
					}
					else
					{
						this.trackedStart = true;
						// also track creativeView here (VAST 2 only)
						this.trackEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.CREATIVE_VIEW ) );
						// and track impression if it's the first creative of the ad
						if( !this.trackedImpression )
						{
							this.trackedImpression = true;
							this.trackUrls( this.currentAd.impressions );
							
							// time to track the survey node
							this.trackUrls( this.currentAd.survey );
						}
					}
					
					trace("this.currentAdPlacement: " + this.currentAdPlacement);
					switch(this.currentAdPlacement)
					{
						case VastDefines.ADTYPE_PREROLL:this.trackPlayerEvent("PREROLL_START");break;
						case VastDefines.ADTYPE_MIDROLL:this.trackPlayerEvent("MIDROLL_START");break;
						case VastDefines.ADTYPE_POSTROLL:this.trackPlayerEvent("POSTROLL_START");break;
					}				
				
					break;
				}
				case VASTTrackingEventType.COMPLETE:
				{
					if( this.trackedComplete )
					{
						return;
					}
					else
					{
						this.trackedComplete = true;
					}
					
					switch(this.currentAdPlacement)
					{
						case VastDefines.ADTYPE_PREROLL:this.trackPlayerEvent("PREROLL_END");break;
						case VastDefines.ADTYPE_MIDROLL:this.trackPlayerEvent("MIDROLL_END");break;
						case VastDefines.ADTYPE_POSTROLL:this.trackPlayerEvent("POSTROLL_END");break;
					}
					
					break;
				}
				
				default:break;
			}
			
			//trace( this + " trackEvent: " + eventType );
			VastController.traceToHtml( "trackEvent: " + eventType );
			
			var trackingEvents:Array;
			
			switch( this.currentAdPlacement )
			{
				case VastDefines.ADTYPE_PREROLL:
				case VastDefines.ADTYPE_MIDROLL:
				case VastDefines.ADTYPE_POSTROLL:
				{
					trackingEvents = VastVideo( this.currentAd.videos[0] ).trackingEvents;
					
					break;
				}
				case VastDefines.ADTYPE_OVERLAY:
				{
					trackingEvents = VastNonLinear( this.currentAd.nonLinears[0] ).trackingEvents;
					
					break;
				}
			}
			
			for each( var trackingEvent:VASTTrackingEvent in trackingEvents )
			{
				//trace(this + " track type:" + trackingEvent.type + "::::" + eventType);
				if( trackingEvent.type == eventType )
				{
					this.trackUrls( trackingEvent.urls );
					
					// stop loop
					break;
				}
			}
		}
		
		protected function trackCustom( event:AdEvent ) :void
		{
			var id:String = event.data as String;
			
//			trace( this + " trackCustom: id = " + id );
			
			if( id != null )
			{
				for each( var extension:VastTrackingExtension in this.currentAd.extensions )
				{
					if( extension.id == id )
					{
						this.trackUrl( extension.url );
					}
				}
			}
		}
		
		protected function trackUrl( url:VASTUrl ) :void
		{
			var finalUrl:String = url.url;
			if( finalUrl != null && finalUrl.split( " " ).join("") != "" )
			{
				var cachebuster:String = new Date().time.toString();
				
				// replace placeholders
				finalUrl = finalUrl.split( "%5BTIMESTAMP%5D" ).join( cachebuster );
				finalUrl = finalUrl.split( "%5Btimestamp%5D" ).join( cachebuster );
				finalUrl = finalUrl.split( "[TIMESTAMP]" ).join( cachebuster );
				finalUrl = finalUrl.split( "[timestamp]" ).join( cachebuster );
				
				// only replace simple "timestamp" string if it's not a parameter name -> check if it's followed by a "="
				if( finalUrl.indexOf( "timestamp=" ) == -1 && finalUrl.indexOf( "timestamp%3D" ) == -1 )
				{
					finalUrl = finalUrl.split( "timestamp" ).join( cachebuster );
				}
				if( finalUrl.indexOf( "TIMESTAMP=" ) == -1 && finalUrl.indexOf( "TIMESTAMP%3D" ) == -1 )
				{
					finalUrl = finalUrl.split( "TIMESTAMP" ).join( cachebuster );
				}
				
				trace( this + " trackUrl: " + finalUrl );
				VastController.traceToHtml( "trackUrl: " + finalUrl );
				
				try
				{
					/*var request:URLRequest = new URLRequest(finalUrl);	
					var loader:URLLoader = new URLLoader();	
					request.method = URLRequestMethod.POST;
					loader.addEventListener(Event.COMPLETE, onURLCalled);
					loader.load(request);*/
					if(finalUrl.indexOf("extscripturl") != -1)
					{
						trace("catch -extsripturl- @ VAST Tracking");
						return;
					}
					sendToURL( new URLRequest( finalUrl ) );
				}
				catch( error:Error )
				{
					Log.error( this + " trackUrl - Error tracking url: " + finalUrl );
				}
			}
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////
// tracking for Selenium tests
//////////////////////////////////////////////////////////////////////////////////////////////////
		public function trackPlayerEvent(type:String) :void
		{
			ExternalInterface.call("project_objects.StateManger.triggerNotifyMessagee", BildTvDefines.playerId,type);
			
		}
	}
}