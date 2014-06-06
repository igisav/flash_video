package de.axelspringer.videoplayer.ui
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	[Embed(source="/embed/assets.swf", symbol="AdLabel")]
	public class AdLabel extends Sprite
	{
		public var label:TextField;
		public var shadow:TextField;
		
		public function AdLabel()
		{
			super();
			
			this.label.autoSize = TextFieldAutoSize.LEFT;
			this.shadow.autoSize = TextFieldAutoSize.LEFT;
			
			this.text = "";
		}
		
		public function set text( value:String ) :void
		{
			this.label.text = value;
			this.shadow.text = value;
		}
		
		override public function get width() :Number
		{
			return this.shadow.textWidth;
		}
	}
}