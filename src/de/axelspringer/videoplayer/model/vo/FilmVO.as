package de.axelspringer.videoplayer.model.vo
{
	public class FilmVO
	{

		private static const CP_CODE_TRAILER:String = "cp88082";

		public var streamUrl:String 	= "";
		public var duration:Number		= 0;
		public var chapters:Array		= null;

		public function FilmVO()
		{
			super();
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