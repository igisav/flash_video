package de.axelspringer.videoplayer.vast.vo
{
	public class VastMedium implements IVpaidAd
	{
		public var url:String = "";
		public var id:String = "";
		public var deliveryType:String = "";
		public var mimeType:String = "";
		public var bitrate:Number = -1;
		public var width:Number = -1;
		public var height:Number = -1;
		
		// vast 2.0 only
		public var scalable:Boolean = true;
		public var maintainAspectRatio:Boolean = true;
		public var apiFramework:String = "";
		
		protected var parameters:String = "";
		
		public function VastMedium()
		{
		}
		
		public function set swfUrl( value:String ) :void
		{
			this.url = value;
		}
		
		public function get swfUrl() :String
		{
			return this.url;
		}
		
		public function set adParameters( value:String ) :void
		{
			this.parameters = value;
		}
		
		public function get adParameters() :String
		{
			return this.parameters;
		}
	}
}