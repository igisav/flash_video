package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	public class AdTimerTextVO extends BaseVO
	{
		private static const MICROPLAYER_TEXT_PREROLL:String = "NOCH %TIME% SEKUNDEN";
		private static const TEXT_PREROLL:String = "VIDEO BEGINNT IN %TIME% SEKUNDEN";
		private static const TEXT_POSTROLL:String = "WERBUNG ENDET IN %TIME% SEKUNDEN";
		private static const TEXT_UNKNOWN_DURATION:String = "GLEICH GEHT'S WEITER";
		
			 
		public var adTimerMicroplayerText:String 	= "";
		public var adTimerPrerollText:String 		= "";
		public var adTimerPostrollText:String 		= "";
		public var adTimerUnknownTimeText:String 	= "";
		
		
		public function AdTimerTextVO()
		{
			super();
			
			this.adTimerMicroplayerText 	=  MICROPLAYER_TEXT_PREROLL;
			this.adTimerPrerollText			=  TEXT_PREROLL;
			this.adTimerPostrollText 		=  TEXT_POSTROLL;		
			this.adTimerUnknownTimeText 	=  TEXT_UNKNOWN_DURATION;
		}
		
		public function hydrate( xml:XML ) :void
		{
			if( xml != null )
			{	
				this.adTimerMicroplayerText = hasAttribute( xml, "microPlayer" ) ? String( xml.@microPlayer ).toUpperCase() : MICROPLAYER_TEXT_PREROLL;
				this.adTimerMicroplayerText = hasAttribute( xml, "microplayer" ) ? String( xml.@microplayer ).toUpperCase() : this.adTimerMicroplayerText;//Fallback
				
				this.adTimerPrerollText		= hasAttribute( xml, "preroll" ) ?  String( xml.@preroll ).toUpperCase() : TEXT_PREROLL;
				this.adTimerPostrollText = hasAttribute( xml, "postroll" ) ? String( xml.@postroll ).toUpperCase() : TEXT_POSTROLL;		
				
				this.adTimerUnknownTimeText 	= hasAttribute( xml, "unknownTime" ) ?  String( xml.@unknownTime ).toUpperCase()  : TEXT_UNKNOWN_DURATION;
				this.adTimerUnknownTimeText 	= hasAttribute( xml, "unknowntime" ) ?  String( xml.@unknowntime ).toUpperCase()  : this.adTimerUnknownTimeText; //Fallback
				
				
				
				if(  this.adTimerMicroplayerText == "" ) this.adTimerMicroplayerText=  MICROPLAYER_TEXT_PREROLL;
				if(  this.adTimerPrerollText == "" )	 this.adTimerPrerollText	=  TEXT_PREROLL;
				if(  this.adTimerPostrollText == "" ) 	 this.adTimerPostrollText 	=  TEXT_POSTROLL;					
				if(  this.adTimerUnknownTimeText == "" ) this.adTimerUnknownTimeText=  TEXT_UNKNOWN_DURATION;
			}
		}
	}
}