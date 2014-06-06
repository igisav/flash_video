package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	/*
	<mail 	status="1" 
			link="http://www.bild.de/BILD/video/clip/leute/2010/03/22/burkhardt,templateId=recommendVideo.xml?" 
			privacy="http://www.bild.de/BILD/corporate-site/datenschutz/artikel-datenschutz.html" />
	*/
	
	public class MailVO extends BaseVO
	{
		public var sendLink:String = "";
		public var agbLink:String = "";
	
		private var _mailStatus:Boolean;
		
		public function MailVO()
		{
			super();
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{
				if(hasAttribute( xml, "status" ))
				{
					if(xml.@status == "0" || xml.@status == "false") this._mailStatus = false;
					else if(xml.@status == "1" || xml.@status == "true") this._mailStatus = true;
				}
				else this._mailStatus = true;
				
				
				if(this.mailStatus)
				{
					this.sendLink = hasAttribute( xml, "link" ) ? xml.@link : this.sendLink;
					this.agbLink = hasAttribute( xml, "privacy" ) && xml.@privacy.split(" ").join("") != "" ? xml.@privacy : BildTvDefines.URL_AGB;
				}
			}
			else this._mailStatus = false;
		}
		
		public function get mailStatus():Boolean
		{
			return this._mailStatus;
		}
	}
}