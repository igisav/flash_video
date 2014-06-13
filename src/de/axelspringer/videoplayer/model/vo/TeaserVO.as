package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.LinkUtil;

	/* <video xml="XML-URL" img="THUMBNAIL-URL" title="CLIP-TITEL" text="CLIP-TEXT" duration="MILLISECONDS" date="DATUM" rating="RATINGWERT"/> */
	
	public class TeaserVO extends BaseVO
	{
		public var xml:String = "";
		public var thumb:String = "";
		public var title:String = "";
		public var text:String = "";
		public var date:String = "";
		public var duration:Number = 0;
		public var rating:Number = 0;
		
		// set in MainController.onRelatedVideoXmlLoaded - contains deeplink from video.xml
		public var deeplink:String = "";
		
		public function TeaserVO( xml:XML )
		{
			super();
			this.hydrate( xml );
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				this.xml = hasAttribute( xml, "xml" ) ?  xml.@xml : this.xml;
				this.thumb = hasAttribute( xml, "img" ) ? xml.@img : this.thumb;
				this.title = hasAttribute( xml, "title" ) ? xml.@title : this.title;
				this.text = hasAttribute( xml, "text" ) ? xml.@text : this.text;
				this.date = hasAttribute( xml, "date" ) ? xml.@date : this.date;
				this.duration = hasAttribute( xml, "duration" ) ? parseInt( xml.@duration, 10 ) / 1000 : this.duration;
				this.rating = hasAttribute( xml, "rating" ) ? parseInt( xml.@rating, 10 ) : this.rating;
			}
		}
	}
}