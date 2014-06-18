package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

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
			
			//this.trackingVO = new TrackingVO();
			this.chapters = new Array();
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