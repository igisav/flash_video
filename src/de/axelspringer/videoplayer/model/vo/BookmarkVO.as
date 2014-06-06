package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.LinkUtil;
	
	/* <bookmark url="SERVICE-URL" title="SERVICE-NAME" icon="ICON-URL" /> */
	
	public class BookmarkVO extends BaseVO
	{
		public var url:String = "";
		public var title:String = "";
		public var icon:String = "";
		
		public function BookmarkVO( xml:XML )
		{
			this.hydrate( xml );
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				this.url = hasAttribute( xml, "url" ) ? xml.@url : this.url;
				this.title = hasAttribute( xml, "title" ) ? xml.@title : this.title;
				this.icon = hasAttribute( xml, "icon" ) ? LinkUtil.absoluteLink( xml.@icon ) : this.icon;
			}
		}
	}
}