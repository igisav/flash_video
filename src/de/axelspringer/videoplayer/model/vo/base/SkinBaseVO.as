package de.axelspringer.videoplayer.model.vo.base
{
	import flash.text.StyleSheet;
	
	public class SkinBaseVO
	{
		public var skinWidth:Number = 0;
		public var skinHeight:Number = 0;
		public var skinX:Number = 0;
		public var skinY:Number = 0;
		public var skinPhases:Number = 0;
		public var displayObjectX:Number = 0;
		public var displayObjectY:Number = 0;
		public var buttonAdjustHorizontal:String = "";
		public var buttonAdjustVertical:String = "";
		public var position:String = "";
		public var display:String = "";
		public var alpha:Number = 1;
		public var alpha2:Number = 1;
		public var alpha3:Number = 1;
		public var alpha4:Number = 1;
		public var borderRadius:Number = 0;
		public var borderRadiusTop:Number = 0;
		public var rotation:Boolean = false;
		public var hideable:Boolean = true;
		public var skinReady:Boolean;

		public var fontsize:Number = 10;
		public var fontHeight:Number = 10;
		public var fontAlign:String = "center";
		
		public var color:uint;
		public var backgroundColor:uint;
		public var loadColor:uint;
	}
}