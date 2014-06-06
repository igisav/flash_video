package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.LinkUtil;
	
	public class VideoVO extends BaseVO
	{
		public var videoUrl:String 		= "";
		public var videoUrl2:String 	= "";
		public var imageUrl:String 		= "";
		public var headline:String 		= "";
		public var roofline:String 		= "";
		public var text:String 			= "";
		
		/**
		 * duration in seconds
		 */
		public var duration:Number			= 0;
		public var mute:Boolean 		= false;
		public var autoplay:Boolean 		= false;
		public var autorepeat:Boolean 		= false;
		public var startHDQuality:Boolean 	= false;
		public var hdAdaptive:Boolean 		= false;
		public var geoRestriction:String	= "";
		public var geoImage:String			= "";
		public var ageRestriction:String	= "";
		
		// gets set in ConfigVO
		public var bumperPrerollXml:String	= "";
		public var bumperPostrollXml:String	= "";
		
		// used for bumpers, set in ConfigVO because it's another node
		public var link:String 			= "";
		public var linkTarget:String	= "";
		
		public function VideoVO()
		{
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( hasAttribute( xml, "srcHDS" ) && xml.@srcHDS != "" )
			{
				this.videoUrl =  xml.@srcHDS;		
			}
			else
			{
				this.videoUrl = hasAttribute( xml, "src" ) ? xml.@src : this.videoUrl;		
			}
			
			this.videoUrl2 = hasAttribute( xml, "src" ) ? xml.@src : this.videoUrl2;
			this.imageUrl = hasAttribute( xml, "img" ) ? LinkUtil.absoluteLink( xml.@img ) : this.imageUrl;
			this.headline = hasAttribute( xml, "ueberschrift" ) ? xml.@ueberschrift : this.headline;
			this.roofline = hasAttribute( xml, "dachzeile" ) ? xml.@dachzeile : this.roofline;
			this.text = xml.text[0];
			
			if( this.videoUrl.indexOf( ".xml" ) != -1 )
			{
				trace("search for this one to get VAST player back");
				//BildTvDefines.isSingleVastPlayer = true;
			}
			
			BildTvDefines.isLivePlayer = hasAttribute( xml, "live" ) ? ( xml.@live.toLowerCase() == "true" ) : false;
			
			// XML value is in ms
			if( hasAttribute( xml, "duration" ) )
			{
				/* for livestreams duration is 1, check also for -1 for backward compatibility */
				if( xml.@duration == "1" || xml.@duration == "1000" || xml.@duration == "-1" )
				{
					this.duration = -1;
					BildTvDefines.isLivePlayer = true;
				}
				else
				{
					this.duration = parseInt( xml.@duration ) / 1000;
					if( isNaN( this.duration ) )
					{
						this.duration = 0;
					}
					else if( this.duration != 0 && this.duration < 1 )		// 18.3.2011: duration of 1 in CMS will be 1000 in XML - all values below 1000 (below 1 sec) mean Livestream
					{
						/*this.duration = -1;
						BildTvDefines.isLivePlayer = true;*/
					}
				}
			}
			else	// 18.3.2011: no duration in XML means Livestream
			{
				/*this.duration = -1;
				BildTvDefines.isLivePlayer = true;*/
			}
			
			this.mute = hasAttribute( xml, "mute" ) ? ( xml.@mute.toLowerCase() == "true" ) : this.mute;
			this.autoplay = hasAttribute( xml, "autoplay" ) ? ( xml.@autoplay.toLowerCase() == "true" ) : this.autoplay;
			this.autorepeat = hasAttribute( xml, "autorepeat" ) ? ( xml.@autorepeat.toLowerCase() == "true" ) : this.autorepeat;
			this.startHDQuality = hasAttribute( xml, "hddefault" ) ? ( xml.@hddefault.toLowerCase() == "true" ) : this.startHDQuality;
			this.hdAdaptive = hasAttribute( xml, "hdadaptive" ) ? ( xml.@hdadaptive.toLowerCase() == "true" ) : this.hdAdaptive;
			//fallback
			this.startHDQuality = hasAttribute( xml, "hdDefault" ) ? ( xml.@hdDefault.toLowerCase() == "true" ) : this.startHDQuality;
			this.hdAdaptive = hasAttribute( xml, "hdAdaptive" ) ? ( xml.@hdAdaptive.toLowerCase() == "true" ) : this.hdAdaptive;
		}
	}
}