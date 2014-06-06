package de.axelspringer.videoplayer.vast.vo
{
	import de.axelspringer.videoplayer.vast.model.VASTUrl;
	
	public class VastAd
	{
		public var videos:Array = new Array();
		public var nonLinears:Array = new Array();
		public var companions:Array = new Array();
		
		public var id:String = "";
		public var errors:Array = new Array();
		public var impressions:Array = new Array();
		public var extensions:Array = new Array();
		public var survey:Array = new Array();
		
		// custom functionality by sevenone: store duration of non-linear vast 1 ads in <video> node
		public var duration:Number = -1;
		
		public function VastAd()
		{
		}
	}
}