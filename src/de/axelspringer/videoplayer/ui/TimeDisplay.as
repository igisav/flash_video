package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	[Embed(source="/embed/assets.swf", symbol="TimeDisplay")]
	public class TimeDisplay extends Sprite
	{
		public var txtTimeVideo:TextField;
		public var txtTimeTotal:TextField;
		public var separatorMc:Sprite;
		public var slashMc:Sprite;
		
		public function TimeDisplay()
		{
			super();
			
			this.slashMc.visible = false;
			this.separatorMc.visible = false;
			this.txtTimeTotal.autoSize = TextFieldAutoSize.LEFT;
			this.txtTimeVideo.autoSize = TextFieldAutoSize.RIGHT;
			
			//this.txtTimeTotal.wordWrap = true;
			//this.txtTimeVideo.wordWrap = true;
		}
		
		public function set text( value:String ) :void
		{
			//this.txtTimeVideo.text = value;
			//this.txtTimeTotal.text = value;
		}
		
		public function setSkin(styleObj:SkinBaseVO):void
		{
		}
	}
}