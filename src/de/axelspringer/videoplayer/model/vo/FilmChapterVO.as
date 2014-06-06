package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	public class FilmChapterVO extends BaseVO
	{
		public var title:String 		= "";
		public var thumbnailUrl:String 	= "";
		public var chapterTime:Number 	= 0;
		
		public function FilmChapterVO()
		{
			super();
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				var mediaNS:Namespace = xml.namespace( "media" );
				
				this.title = xml.title;
				this.thumbnailUrl = xml.mediaNS::thumbnail.@url;
				this.chapterTime = parseInt( xml.chapterTime, 10 );
			}
		}
	}
}