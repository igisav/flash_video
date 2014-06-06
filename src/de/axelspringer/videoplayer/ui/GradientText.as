package de.axelspringer.videoplayer.ui
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class GradientText
	{
		protected var root:Sprite;
		protected var textfield:TextField;
		protected var gradient:Sprite;
		
		public function GradientText( mc:Sprite )
		{
			this.root = mc;
			this.init();
		}
		
		protected function init() :void
		{
			var textMc:Sprite = this.root.getChildByName( "txtMc" ) as Sprite;
			this.textfield = textMc.getChildByName( "label" ) as TextField;
			this.textfield.autoSize = TextFieldAutoSize.LEFT;
			
			this.gradient = this.root.getChildByName( "gradient" ) as Sprite;
		}
		
		public function set text( value:String ) :void
		{
			if( value == null || value.replace( " ", "" ) == "" )
			{
				this.root.visible = false;
			}
			else
			{
				this.root.visible = true;
				this.textfield.text = value;
				this.gradient.x = this.textfield.x;
				this.gradient.width = this.textfield.width;
			}
		}
	}
}