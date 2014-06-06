package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	public class AdVO extends BaseVO
	{
		protected static const URL_PREROLL_GMX:String 	= "http://ad.de.doubleclick.net/ad/bildde.einsundeins.smartclip/;sz=400x320;dcmt=text/xml;ord=[random]?";
		protected static const URL_OVERLAY_GMX:String 	= "http://ad.de.doubleclick.net/ad/bildde.einsundeins.smartclip/;sz=300x50;dcmt=text/xml;ord=[random]?";
		protected static const URL_MIDROLL_GMX:String 	= "";
		protected static const URL_POSTROLL_GMX:String 	= "http://ad.de.doubleclick.net/ad/bildde.einsundeins.smartclip/;sz=400x300;dcmt=text/xml;ord=[random]?";
					
		public var club:String 	= "";
		public var adText:String 	= "";
		public var preroll:String 	= "";
		public var overlay:String 	= "";
		public var midroll:String 	= "";
		public var postroll:String 	= "";
		
		public function AdVO()
		{
			super();
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				this.adText = hasAttribute( xml, "text" ) ? xml.@text : this.adText;
				this.club = hasAttribute( xml, "club" ) ? xml.@club : this.club;
			 	
			 	if( BildTvDefines.isGmxPlayer )
			 	{
			 		this.preroll = URL_PREROLL_GMX;
					this.midroll = URL_MIDROLL_GMX;
					this.overlay = URL_OVERLAY_GMX;
					this.postroll = URL_POSTROLL_GMX;
			 	}
			 	else
			 	{
			 		// new vast ads
			 		if( hasAttribute( xml, "adcall" ) )
			 		{
			 			this.preroll = xml.@adcall;
						this.overlay = xml.@adcall;
						this.midroll = xml.@adcall;
						this.postroll = xml.@adcall;
			 		}
			 		// "backward compatibility" - vast adcall in old adtech node
			 		else if( hasAttribute( xml, "xml" ) )
			 		{
			 			this.preroll = xml.@xml;
						this.overlay = xml.@xml;
						this.midroll = xml.@xml;
						this.postroll = xml.@xml;
			 		}
			 		else
			 		{
				 		// old eyewonder ads
						this.preroll = hasAttribute( xml, "preroll" ) ? xml.@preroll : this.preroll;
						this.overlay = hasAttribute( xml, "overlay" ) ?  xml.@overlay : this.overlay;
						this.midroll = hasAttribute( xml, "midroll" ) ?  xml.@midroll  : this.midroll;
						this.postroll = hasAttribute( xml, "postroll" ) ? xml.@postroll : this.postroll;
					}
			 	}	
			}
		}
	}
}