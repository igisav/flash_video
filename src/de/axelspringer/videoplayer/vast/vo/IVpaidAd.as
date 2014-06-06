package de.axelspringer.videoplayer.vast.vo
{
	public interface IVpaidAd
	{
		function set swfUrl( value:String ) :void;
		function get swfUrl() :String;
		
		function set adParameters( value:String ) :void;
		function get adParameters() :String;
	}
}