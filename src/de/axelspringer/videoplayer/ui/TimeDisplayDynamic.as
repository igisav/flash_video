package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	[Embed(source="/embed/assets.swf", symbol="TimeDisplayDynamic")]
	public class TimeDisplayDynamic extends Sprite
	{
		public var txtTimeVideo:TextField;
		public var timeBg:Sprite;
		public var arrow:Sprite;
		
		public function TimeDisplayDynamic()
		{
			super();
			
			this.txtTimeVideo.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function set text( value:String ) :void
		{
			this.txtTimeVideo.text = value;
			this.txtTimeVideo.x = -this.txtTimeVideo.width/2;
			this.timeBg.x = this.txtTimeVideo.x - 5;
			this.timeBg.width = this.txtTimeVideo.width + 10;
		}
		
		public function setSkin(styleObj:SkinBaseVO):void
		{
		}
	}
}