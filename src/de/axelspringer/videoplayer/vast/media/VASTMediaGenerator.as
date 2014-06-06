package de.axelspringer.videoplayer.vast.media
{
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.vast.model.VAST2MediaFile;
	import de.axelspringer.videoplayer.vast.model.VAST2Translator;
	import de.axelspringer.videoplayer.vast.model.VASTAd;
	import de.axelspringer.videoplayer.vast.model.VASTCompanionAd;
	import de.axelspringer.videoplayer.vast.model.VASTDataObject;
	import de.axelspringer.videoplayer.vast.model.VASTDocument;
	import de.axelspringer.videoplayer.vast.model.VASTMediaFile;
	import de.axelspringer.videoplayer.vast.model.VASTNonLinearAd;
	import de.axelspringer.videoplayer.vast.model.VASTUrl;
	import de.axelspringer.videoplayer.vast.model.VASTVideo;
	import de.axelspringer.videoplayer.vast.parser.VAST2Parser;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2CompanionElement;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2CreativeElement;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2LinearElement;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2NonLinearElement;
	import de.axelspringer.videoplayer.vast.parser.base.VAST2WrapperElement;
	import de.axelspringer.videoplayer.vast.vo.VastAd;
	import de.axelspringer.videoplayer.vast.vo.VastCompanion;
	import de.axelspringer.videoplayer.vast.vo.VastMedium;
	import de.axelspringer.videoplayer.vast.vo.VastNonLinear;
	import de.axelspringer.videoplayer.vast.vo.VastTrackingExtension;
	import de.axelspringer.videoplayer.vast.vo.VastVideo;
	
	public class VASTMediaGenerator
	{
		public function VASTMediaGenerator()
		{
		}
		
		/**
		 * returns an Array of VastAd instances
		 */
		static public function getAds( vastData:VASTDataObject ) :Array
		{
			var result:Array = new Array();
			
			var ad:VastAd;
			
			switch( vastData.vastVersion )
			{
				case VASTDataObject.VERSION_1_0:
				{
					var vast1Document:VASTDocument = vastData as VASTDocument;
					
					for each( var vastAd:VASTAd in vast1Document.ads )
					{
						if( vastAd.inlineAd != null )
						{
							ad = new VastAd();
							ad.id = vastAd.id;
							ad.duration = getDurationFromTimeString( vastAd.inlineAd.duration );
							ad.companions = getCompanionsFromVast1( vastAd.inlineAd.companionAds );
							ad.impressions = vastAd.inlineAd.impressions;
							ad.errors = vastAd.inlineAd.errors;
							ad.extensions = getExtensions( vastAd.inlineAd.extensions );
							ad.survey = [ new VASTUrl( vastAd.inlineAd.surveyURL ) ];
							ad.nonLinears = getNonLinearsFromVast1( vastAd.inlineAd.nonLinearAds, 0 );
							ad.videos = getVideosFromVast1( vastAd.inlineAd.video, vastAd.inlineAd.trackingEvents );
							
							result.push( ad );
						}
					}
					
					break;
				}
				case VASTDataObject.VERSION_2_0:
				{
					var vast2Document:VAST2Translator = vastData as VAST2Translator;
					
					ad = new VastAd();
					ad.id = vast2Document.adTagID;
					ad.companions = getCompanionsFromVast2( vast2Document.companionArray );
					ad.impressions = vast2Document.impressionArray;
					ad.errors = vast2Document.errorArray;
					ad.extensions = getExtensions( vast2Document.extensionsArray );
					ad.survey = vast2Document.surveyArray;
					ad.nonLinears = getNonLinearsFromVast2( vast2Document.nonlinearArray, vast2Document.trackingEventsNonLinear );
					ad.videos = getVideosFromVast2( vast2Document );
					
					result.push( ad );
					
					break;
				}
				default:
				{
					trace( "[VASTMediaGenerator] getAds - unbnown VAST version: " + vastData.vastVersion );
					break;
				}
			}
			
			return result;
		}
		
		/**
		 * returns a VastAd from Wrapper
		 */
		static public function getWrapper( vastData:VASTDataObject ) :VastAd
		{
			var ad:VastAd;
			
			switch( vastData.vastVersion )
			{
				case VASTDataObject.VERSION_1_0:
				{
					var vast1Document:VASTDocument = vastData as VASTDocument;
					
					// only use first ad
					var vastAd:VASTAd = vast1Document.ads[0];
					
					if( vastAd.wrapperAd != null )
					{
						ad = new VastAd();
						ad.id = vastAd.id;
//						ad.companions = getCompanionsFromVast1( vastAd.wrapperAd.companionAdTag );
						ad.impressions = vastAd.wrapperAd.impressions;
						ad.errors = vastAd.wrapperAd.errors;
						ad.extensions = getExtensions( vastAd.wrapperAd.extensions );
//						ad.survey = new VASTUrl( vastAd.inlineAd.surveyURL );
//						ad.nonLinears = getNonLinearsFromVast1( vastAd.wrapperAd.nonLinearAdTag );
						var video:VASTVideo = new VASTVideo();
						video.videoClick = vastAd.wrapperAd.videoClick;
						ad.videos = getVideosFromVast1( video, vastAd.wrapperAd.trackingEvents );
						ad.duration = getDurationFromTimeString( vastAd.wrapperAd.duration );
						if( vastAd.wrapperAd.nonLinearClickTrackings.length > 0 )
						{
							var nonLinear:VastNonLinear = new VastNonLinear();
							nonLinear.clickTrackings = vastAd.wrapperAd.nonLinearClickTrackings;
							ad.nonLinears.push( nonLinear );
						}
					}
					
					break;
				}
				case VASTDataObject.VERSION_2_0:
				{
					var vast2Document:VAST2Translator = vastData as VAST2Translator;
					var parser:VAST2Parser = vast2Document.vastParser;
					if( parser.isVASTXMLWRAPPER )
					{
						var wrapper:VAST2WrapperElement = parser._Wrapper;
						
						ad = new VastAd();
						ad.id = vast2Document.adTagID;
						ad.impressions = vast2Document.impressionArray;
						ad.errors = vast2Document.errorArray;
						ad.extensions = getExtensions( vast2Document.extensionsArray );
						ad.survey = vast2Document.surveyArray;
						
						// tracking infos
						vast2Document.adPlacement = VAST2Translator.PLACEMENT_LINEAR;
						var vastVideoFile:VastVideo = new VastVideo();
						vastVideoFile.videoClicks.clickTrackings = vast2Document.trkClickThruEvent;
						vastVideoFile.trackingEvents = vast2Document.trackingEventsLinear;
						
						var creative:VAST2CreativeElement = wrapper.Creatives[0];
						if( creative != null )
						{
							var vastVideo:VAST2LinearElement = creative.Linear;
							
							ad.companions = getCompanionsFromVast2( creative.CompanionAds );
							ad.nonLinears = getNonLinearsFromVast2( creative.NonLinearAds, vast2Document.trackingEventsNonLinear );
							
							vastVideoFile.videoClicks.clickThru = new VASTUrl( vastVideo.ClickThrough );
							vastVideoFile.mediaFiles = getMediaFilesFromVast2( vastVideo.MediaFiles );
							vastVideoFile.duration = vastVideo.videoDuration.totalSeconds;
						}
						
						ad.videos = [vastVideoFile];
					}
					
					break;
				}
				default:
				{
					trace( "[VASTMediaGenerator] getWrapper - unbnown VAST version: " + vastData.vastVersion );
					break;
				}
			}
			
			return ad;
		}
		
		static protected function getVideosFromVast1( video:VASTVideo, trackingEvents:Array ) :Array
		{
			var result:Array = new Array();
			
			if( video != null )
			{
				var vastVideoFile:VastVideo = new VastVideo();
				vastVideoFile.videoClicks.clickThru = video.videoClick.clickThrough;
				vastVideoFile.videoClicks.clickTrackings = video.videoClick.clickTrackings.concat( video.videoClick.customClicks );
				vastVideoFile.trackingEvents = trackingEvents;
				vastVideoFile.duration = getDurationFromTimeString( video.duration );
				vastVideoFile.mediaFiles = getMediaFilesFromVast1( video.mediaFiles );
				
				result.push( vastVideoFile );
			}
			
			return result;
		}
		
		static protected function getVideosFromVast2( vastDocument:VAST2Translator ) :Array
		{
			var result:Array = new Array();
			
			// set placement so the tracking getters will return the correct trackings
			vastDocument.adPlacement = VAST2Translator.PLACEMENT_LINEAR;
			
			var vastVideoFile:VastVideo = new VastVideo();
			vastVideoFile.videoClicks.clickThru = new VASTUrl( vastDocument.clickThruUrl );
			vastVideoFile.videoClicks.clickTrackings = vastDocument.trkClickThruEvent;
			vastVideoFile.trackingEvents = vastDocument.trackingEventsLinear;
			vastVideoFile.mediaFiles = getMediaFilesFromVast2( vastDocument.mediafileArray );
			vastVideoFile.duration = vastDocument.adTagVASTDuration;
			vastVideoFile.adParameters = vastDocument.adParameters;
			
			result.push( vastVideoFile );
			
			return result;
		}
		
		static protected function getNonLinearsFromVast1( nonLinearAds:Array, duration:Number ) :Array
		{
			var result:Array = new Array();
			
			for each( var nonLinearAd:VASTNonLinearAd in nonLinearAds )
			{
				var vastNonLinear:VastNonLinear = new VastNonLinear();
				
				vastNonLinear.trackingEvents = new Array();
				
				vastNonLinear.id = nonLinearAd.id;
				vastNonLinear.duration = getDurationFromTimeString( nonLinearAd.duration );
				vastNonLinear.width = nonLinearAd.width;
				vastNonLinear.height = nonLinearAd.height;
				vastNonLinear.expandedWidth = nonLinearAd.expandedWidth;
				vastNonLinear.expandedHeight = nonLinearAd.expandedHeight;
				vastNonLinear.scalable = nonLinearAd.scalable;
				vastNonLinear.maintainAspectRatio = nonLinearAd.maintainAspectRatio;
				vastNonLinear.minSuggestedDuration = duration;
				
				vastNonLinear.apiFramework = nonLinearAd.apiFramework;
				vastNonLinear.resourceType = nonLinearAd.resourceType.name;
				switch( vastNonLinear.resourceType )
				{
					case VastDefines.RESOURCETYPE_HTML:
					case VastDefines.RESOURCETYPE_SCRIPT:
					{
						vastNonLinear.htmlResource = nonLinearAd.code;
						break;
					}
					case VastDefines.RESOURCETYPE_IFRAME:
					{
						vastNonLinear.iFrameResource = nonLinearAd.code;
						break;
					}
					case VastDefines.RESOURCETYPE_STATIC:
					{
						vastNonLinear.staticResource = nonLinearAd.url;
						break;
					}
				}
				vastNonLinear.clickThru = new VASTUrl( nonLinearAd.clickThroughURL );
				vastNonLinear.clickTrackings = nonLinearAd.clickTrackings;
				vastNonLinear.adParameters = nonLinearAd.adParameters;
				
				result.push( vastNonLinear );
			}
			
			return result;
		}
		
		static protected function getNonLinearsFromVast2( nonlinearArray:Array, trackingEvents:Array ) :Array
		{
			var result:Array = new Array();
			
			for each( var nonLinearAd:VAST2NonLinearElement in nonlinearArray )
			{
				var vastNonLinear:VastNonLinear = new VastNonLinear();
				
				vastNonLinear.trackingEvents = trackingEvents;
				
				vastNonLinear.adParameters = nonLinearAd.adParameters;
				vastNonLinear.apiFramework = nonLinearAd.apiFramework;
				vastNonLinear.clickThru = new VASTUrl( nonLinearAd.nonLinearClickThrough );
				vastNonLinear.clickTrackings = nonLinearAd.clickTrackings;
				vastNonLinear.expandedHeight = nonLinearAd.expandedHeight;
				vastNonLinear.expandedWidth = nonLinearAd.expandedWidth;
				vastNonLinear.height = nonLinearAd.height;
				vastNonLinear.width = nonLinearAd.width;
				vastNonLinear.htmlResource = nonLinearAd.htmlResource;
				vastNonLinear.iFrameResource = nonLinearAd.iframeResource;
				vastNonLinear.staticResource = nonLinearAd.staticResource;
				vastNonLinear.id = nonLinearAd.id;
				vastNonLinear.duration = getDurationFromTimeString( nonLinearAd.duration );
				vastNonLinear.maintainAspectRatio = nonLinearAd.maintainAspectRatio;
				vastNonLinear.minSuggestedDuration = getDurationFromTimeString(nonLinearAd.minSuggestedDuration );//-1;
				vastNonLinear.resourceType = nonLinearAd.resourceType;
				vastNonLinear.scalable = nonLinearAd.scalable;
				
				result.push( vastNonLinear );
			} 
			
			return result;
		}
		
		static protected function getCompanionsFromVast1( companionArray:Array ) :Array
		{
			var result:Array = new Array();
			
			var companion:VastCompanion;
			
			for each( var companionData:VASTCompanionAd in companionArray )
			{
				companion = new VastCompanion();
				companion.adParameters = companionData.adParameters;
				companion.altText = companionData.altText;
				companion.clickThru = companionData.clickThroughURL;
				companion.clickTrackings = companionData.clickTrackings;
				companion.expandedHeight = companionData.expandedHeight;
				companion.expandedWidth = companionData.expandedWidth;
				companion.height = companionData.height;
				companion.width = companionData.width;
				companion.id = companionData.id;
				companion.resourceType = companionData.resourceType.name;
				
				switch( companion.resourceType )
				{
					case VastCompanion.RESOURCETYPE_HTML:
					case VastCompanion.RESOURCETYPE_SCRIPT:
					{
						companion.htmlResource = companionData.code;
						break;
					}
					case VastCompanion.RESOURCETYPE_IFRAME:
					{
						companion.iFrameResource = companionData.code;
						break;
					}
					case VastCompanion.RESOURCETYPE_STATIC:
					{
						companion.staticResource = companionData.url;
						break;
					}
				}				
				
				result.push( companion );
			}
			
			return result;
		}
		
		static protected function getCompanionsFromVast2( companionArray:Array ) :Array
		{
			var result:Array = new Array();
			
			var companion:VastCompanion;
			
			for each( var companionData:VAST2CompanionElement in companionArray )
			{
				companion = new VastCompanion();
				companion.adParameters = companionData.adParameters;
				companion.altText = companionData.AltText;
				companion.clickThru = companionData.companionClickThrough;
				companion.expandedHeight = companionData.expandedHeight;
				companion.expandedWidth = companionData.expandedWidth;
				companion.height = companionData.height;
				companion.width = companionData.width;
				companion.id = companionData.id;
				companion.resourceType = companionData.resourceType;
				companion.htmlResource = companionData.htmlResource;
				companion.iFrameResource = companionData.iframeResource;
				companion.staticResource = companionData.staticResource;
				
				result.push( companion );
			}
			
			return result;
		}
		
		static protected function getMediaFilesFromVast1( mediaArray:Array ) :Array
		{
			var result:Array = new Array();
			
			var media:VastMedium;
			
			for each( var mediaData:VASTMediaFile in mediaArray )
			{
				media = new VastMedium();
				media.bitrate = mediaData.bitrate;
				media.deliveryType = mediaData.delivery;
				media.height = mediaData.height;
				media.width = mediaData.width;
				media.id = mediaData.id;
				media.mimeType = mediaData.type;
				media.url = mediaData.url;
				
				result.push( media );
			}
			
			return result;
		}
		
		static protected function getMediaFilesFromVast2( mediaArray:Array ) :Array
		{
			var result:Array = new Array();
			
			var media:VastMedium;
			
			for each( var mediaData:VAST2MediaFile in mediaArray )
			{
				media = new VastMedium();
				media.bitrate = mediaData.bitrate;
				media.deliveryType = mediaData.delivery;
				media.height = mediaData.height;
				media.width = mediaData.width;
				media.id = mediaData.id;
				media.mimeType = mediaData.type;
				media.url = mediaData.url;
				media.apiFramework = mediaData.apiFramework;
				
				result.push( media );
			}
			
			return result;
		}
		
		static public function getExtensions( extensionsArray:Array ) :Array
		{
			var result:Array = new Array();
			
			for each( var xmlEntry:XML in extensionsArray )
			{
				if( xmlEntry.@type == "CustomTracking" )
				{
					var extension:VastTrackingExtension;
					
					for each( var interaction:XML in xmlEntry.Interaction )
					{
						extension = new VastTrackingExtension();
						extension.id = interaction.@id;
						extension.url = new VASTUrl( interaction.text() );
						
						result.push( extension );
					}
				}
			}
			
			return result;
		}
		
///////////////////////////////////////////////////////////////////////////////////////////////////
		
		static protected function getDurationFromTimeString( timeString:String ) :Number
		{
			var result:Number = 0;
			
			if( timeString != null )
			{
				var timeParts:Array = timeString.split( ":" );
				
				// vast 1 may contain plain seconds
				if( timeParts.length == 1 )
				{
					result = parseInt( timeString );
				}
				else if( timeParts.length == 3 )
				{
					result = ( parseInt( timeParts[0], 10 ) * 3600 ) + ( parseInt( timeParts[1], 10 ) * 60 ) + ( parseInt( timeParts[2], 10 ) );
				}
			}
			
			return result;
		}
	}
}