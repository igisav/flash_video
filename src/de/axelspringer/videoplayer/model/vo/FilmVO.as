package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	
	import tv.tvnext.stdlib.utils.StringUtils;

	public class FilmVO extends BaseVO
	{
		private static const TRACKING_FUNCTION_NOWTILUS:String = "javascript:ReportingCallback(%EVENT%,%PARAM%);";
		
		private static const CP_CODE_TRAILER:String = "cp88082";
		private static const CP_CODE_MOVIE:String 	= "cp88016";
		
		public var title:String			= "";
		public var streamUrl:String 	= "";
		public var streamUrl2:String 	= "";
		public var thumbnailUrl:String 	= "";
		public var duration:Number		= 0;
		public var chapters:Array		= null;
		
		public var functionNameMail:String 	= "showEmbed";
		public var functionNameShare:String = "showShare";
		
		// ads
		public var adVO:AdVO;
		
		// tracking
		//public var trackingVO:TrackingVO;
		
		// jingels
		public var jingleServer:String				= "rtmp://cp82244.edgefcs.net/ondemand";
		public var jingleFilePrerollMovie:String 	= "mp4:nonsecure/jingle.mp4";
		public var jingleFilePrerollTrailer:String 	= "mp4:nonsecure/jingle-trailer.mp4";
		public var jingleFileMidroll:String 		= "mp4:nonsecure/before_film_midroll.mp4";
		public var jingleFilePostroll:String 		= "mp4:nonsecure/bild-videothek.mp4";
		
		public function FilmVO()
		{
			super();
			
			this.adVO = new AdVO();
			//this.trackingVO = new TrackingVO();
			this.chapters = new Array();
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null && xml.item.length() > 0 )
			{
				var contentItem:XML = xml.item[0];				
				var mediaNS:Namespace = xml.namespace( "media" );
				
				this.title = contentItem.mediaNS::title;
				this.streamUrl = contentItem.mediaNS::content.@url;
				this.streamUrl2 = contentItem.mediaNS::content.@url2;
				this.duration = parseInt( contentItem.mediaNS::content.@duration, 10 );
				this.thumbnailUrl = contentItem.mediaNS::thumbnail.@url;
				
				BildTvDefines.buffertimeMaximum = hasAttribute( xml.buffer[0], "dynbuffer" ) ? xml.buffer[0].@dynbuffer : BildTvDefines.buffertimeMaximum;
				BildTvDefines.buffertimeMinimum = hasAttribute( xml.buffer[0], "startbuffer" ) ? xml.buffer[0].@startbuffer : BildTvDefines.buffertimeMinimum;
			
				this.adVO.hydrate( contentItem.ad[0] );
				// no overlay in movies
				this.adVO.overlay = "";
				
				/*this.trackingVO.trackingEnabled = true;
				this.trackingVO.trackFunction = BildTvDefines.TRACKING_FUNCTION_BILD;
				this.trackingVO.trackFunction = hasAttribute( xml, "track" ) ? xml.@track : this.trackingVO.trackFunction;
				// replace DATE placeholder with XML value
				this.trackingVO.trackFunction = StringUtils.replace( this.trackingVO.trackFunction, "%DATE%", "'" + contentItem.pubDate[0] + "'" );
				// abuse "ivw" property for nowtilus tracking
				this.trackingVO.ivw = TRACKING_FUNCTION_NOWTILUS;*/
				
				this.chapters = new Array();
				var chapterVO:FilmChapterVO;
				
				// add first chapter manually as it has no time set
				chapterVO = new FilmChapterVO();
				chapterVO.hydrate( xml.item[0] );
				chapterVO.chapterTime = 0;
				this.chapters.push( chapterVO );
				
				// add the rest
				for( var i:uint = 1; i < xml.item.length(); i++ )
				{
					chapterVO = new FilmChapterVO();
					chapterVO.hydrate( xml.item[i] );
					this.chapters.push( chapterVO );
				}
			}
		}
		
		public function getCPCode() :String
		{
			var result:String = "";
			
			// get the cp code - the subdomain part of the stream url, eg: rtmp://cp1234.akamai.net
			var regEx:RegExp = new RegExp( '(://)([^.]*)' );
			var regExResult:Object;
			
			try
			{
				regExResult = regEx.exec( this.streamUrl );
				if( regExResult != null && regExResult.length > 2 )
				{
					result = regExResult[2];
				}
			}
			catch( oops:Error )
			{
				// ignore
			}
			
			return result;
		}
		
		public function isTrailer() :Boolean
		{
			return ( this.getCPCode() == CP_CODE_TRAILER );
		}
	}
}