package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	/* <tracking title="trackingTitle" groupLayout="trackingGroupLayout" groupUrl="trackingGroupUrl" /> */
	
	public class TrackingVO extends BaseVO
	{
		// set in configVo, because value is inside the <video> node
		public var trackingEnabled:Boolean 	= false;
		public var ivw:String 				= "";
		public var trackFunction:String 	= "";
		public var trackEmbedFunction:String= "";
		
		// webtrekk values
		public var trackTitle:String 		= "";
		public var groupLayout:String 		= "";
		public var groupUrl:String 			= "";
		
		public function TrackingVO()
		{
			super();
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				this.trackTitle = hasAttribute( xml, "title" ) ? xml.@title : this.trackTitle;
				this.groupLayout = hasAttribute( xml, "groupLayout" ) ? xml.@groupLayout : this.groupLayout;
				this.groupUrl = hasAttribute( xml, "groupUrl" ) ? xml.@groupUrl : this.groupUrl;
			}
		}
	}
}