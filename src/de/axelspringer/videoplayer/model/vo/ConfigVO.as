package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.LinkUtil;
	
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	public class ConfigVO extends BaseVO
	{

		public var playerWidth:Number	= -1;
		public var playerHeight:Number	= -1;
		
		// Id (welt player only)
		public var id:String = "";
		
		// VideoInfo
		public var videoVO:VideoVO;
		// Popup
		public var popupUrl:String = "";
		public var popupStatus:Boolean = true;
		
		//SubtitleUrl
		public var srtUrl:String = "";
		
		// related clips
		public var endScreenEnabled:Boolean = true;
		public var relatedXml:String = "";
		public var relatedVideos:Array;
		
		// ads
		public var ads:Vector.<AdVO>;
		public var adVO:AdVO;
		
		//AdTexts
		public var adTextTextVO:AdTimerTextVO;
		
		// in case we get a film.bild.de XML, use this to hydrate the data
		public var filmVO:FilmVO;
		
		// for paid content live streams use this VO
		public var streamingVO:StreamingVO;
		
		public function ConfigVO()
		{
			this.videoVO = new VideoVO();
			this.ads = new Vector.<AdVO>;
			this.adTextTextVO = new AdTimerTextVO();
			this.relatedVideos = new Array();
		}
		
		public function hydrate( xml:XML ) :void
		{
			var rootName:String = xml.name();
			
			trace( this + " XML root: " + rootName );
			
			switch( rootName )
			{
				case "video":
				{
					this.hydrateConfigXml( xml );
					
					break;
				}
				case "rss":
				{
					this.filmVO = new FilmVO();
					this.filmVO.hydrate( xml.channel[0] );
					
					break;
				}
				case "live":
				{
					this.streamingVO = new StreamingVO();
					this.streamingVO.hydrate( xml );	
					this.streamingVO.isLivestream = true;
					
					break;
				}
				case "vod":
				{
					this.streamingVO = new StreamingVO();
					this.streamingVO.hydrate( xml );
					this.streamingVO.duration = 0.1;		// to start with 00:00 display
					// no ads - overwrite adVO
					this.streamingVO.adVO = new AdVO();
					
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		protected function hydrateConfigXml( xml:XML ) :void
		{
			// welt player only
			//this.id = hasAttribute( xml, "id" ) ? xml.@id : this.id;
			
			this.playerWidth = hasAttribute( xml.player[0], "width" ) ? parseInt( xml.player[0].@width ) : this.playerWidth;
			this.playerHeight = hasAttribute( xml.player[0], "height" ) ? parseInt( xml.player[0].@height ) : this.playerHeight;
			
			this.videoVO.hydrate( xml );
			this.videoVO.bumperPrerollXml = hasAttribute( xml.bumper[0], "preroll" ) ?  xml.bumper[0].@preroll  : this.videoVO.bumperPrerollXml;
			this.videoVO.bumperPostrollXml = hasAttribute( xml.bumper[0], "postroll" ) ? xml.bumper[0].@postroll : this.videoVO.bumperPostrollXml;
			this.videoVO.link = hasAttribute( xml.link[0], "link" ) ? xml.link[0].@link : this.videoVO.link;
			this.videoVO.linkTarget = hasAttribute( xml.link[0], "target" ) ? xml.link[0].@target : this.videoVO.linkTarget;
			
			//this.skinVO.hydrate( xml.skin[0] );

			/*this.trackingVO.hydrate( xml.tracking[0] );
			this.trackingVO.ivw = hasAttribute( xml, "ivw" ) ? xml.@ivw : this.trackingVO.ivw;
			this.trackingVO.trackFunction = hasAttribute( xml, "track" ) ? xml.@track : this.trackingVO.trackFunction;
			
			this.trackingVO.trackEmbedFunction = hasAttribute( xml, "embed_track" ) ? xml.@embed_track : BildTvDefines.embedTrackUrl;
			this.trackingVO.trackEmbedFunction = hasAttribute( xml, "embedtrack" ) ? xml.@embedtrack : this.trackingVO.trackEmbedFunction; // Fallback
			
			this.trackingVO.trackingEnabled = hasAttribute( xml, "tracking" ) ? ( xml.@tracking == "true" ? true : false ) : true;*/
			
			//if(BildTvDefines.isSingleVastPlayer == false)
			
			//map premium Ad
			if( xml.hasOwnProperty( "ads" ) )
			{
				var item:XML;
				for each( item in xml.ads.ad )
				{
					this.adVO = new AdVO();
					this.adVO.hydrate( item );
					this.adVO.adText = hasAttribute( xml.ads[0], "text" ) ? xml.ads[0].@text : "";
					this.ads.push(this.adVO);
				}
				
//				this.adVO = this.ads["default"];
			}
			//map dafault Ad
			if( xml.hasOwnProperty( "ad" ) )
			{
				this.adVO = new AdVO();
				this.adVO.hydrate( xml.ad[0] );
				this.adVO.adText = hasAttribute( xml.ad[0], "text" ) ? xml.ad[0].@text : "";
				this.adVO.club = "default";
				this.ads.push(this.adVO);
			}
			else if( xml.hasOwnProperty( "anzeige" ) )
			{
//				this.adVO.hydrate( xml.anzeige[0] );
			}
			else
			{
				this.adVO = new AdVO();
			}
			
			if( xml.hasOwnProperty( "adTimerText" ) )
			{
				this.adTextTextVO.hydrate( xml.adTimerText[0] );
			}	
			
			
			if( hasAttribute( xml.end[0], "status" ) )
			{
				if(xml.end[0].@status == "0" || xml.end[0].@status == "false") this.endScreenEnabled = false;
				else if(xml.end[0].@status == "1" || xml.end[0].@status == "true")this.endScreenEnabled =true;
			}
			else this.endScreenEnabled = true;
				
			if( hasAttribute( xml.subtitle[0], "status" ) )
			{	
				if(xml.subtitle[0].@status == "1" || xml.subtitle[0].@status == "true")
				{
					this.srtUrl = hasAttribute( xml.subtitle[0], "url" ) ? xml.subtitle[0].@url : this.srtUrl;
				}
			}
			BildTvDefines.buffertimeMaximum = hasAttribute( xml.buffer[0], "dynbuffer" ) ? xml.buffer[0].@dynbuffer : BildTvDefines.buffertimeMaximum;
			BildTvDefines.buffertimeMinimum = hasAttribute( xml.buffer[0], "startbuffer" ) ? xml.buffer[0].@startbuffer : BildTvDefines.buffertimeMinimum;
						
			if(this.endScreenEnabled && true == BildTvDefines.isEmbedPlayer )this.relatedXml = hasAttribute( xml.end[0], "xml" ) ? xml.end[0].@xml : this.relatedXml;
			if(this.endScreenEnabled && true == BildTvDefines.isEmbedPlayer && this.relatedXml == "" )this.relatedXml = hasAttribute( xml.channel[0], "xml" ) ? xml.channel[0].@xml : this.relatedXml;
																	
			if( hasAttribute( xml.popup[0], "status" ) )
			{
				if(xml.popup[0].@status == "1" || xml.popup[0].@status == "true")
				{
					this.popupStatus = true;
				}
				else
				{
					this.popupStatus = false;
				}
			}
			else
			{
				this.popupStatus = true;
			}	
			
			if(this.popupStatus)
			{
				this.popupUrl = hasAttribute( xml.popup[0], "link" ) ? xml.popup[0].@link : this.popupUrl;
			}
		}
		
	}
}