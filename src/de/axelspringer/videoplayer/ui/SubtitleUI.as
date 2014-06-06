package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
		
	public class SubtitleUI extends Sprite
	{		
		private var skin:SkinBaseVO;
		public var subtitleBackground:Sprite = new Sprite();
		public var subtitleText:TextField = new TextField();;
		
		private var tF:TextFormat;
		
		public function SubtitleUI()
		{
			super();	
		}
		
		public function buildUi( skin:SkinBaseVO ):void
		{
			this.skin = skin;
			if( this.skin == null ) return;
			
			this.addChild( this.subtitleBackground );
			this.addChild( this.subtitleText );
			
			this.tF = new TextFormat();
			this.tF.color = this.skin.color;
			this.tF.size = this.skin.fontsize;
			this.tF.leading = this.skin.skinHeight;
			this.tF.align = this.skin.fontAlign;
			
			this.subtitleText.autoSize = TextFieldAutoSize.LEFT;
			this.subtitleText.wordWrap = true;
			this.subtitleText.defaultTextFormat = this.tF;
		}
		
		private function drawBackground():void
		{
			this.subtitleBackground.graphics.clear();
			this.subtitleBackground.graphics.beginFill(this.skin.backgroundColor,this.skin.alpha);
			this.subtitleBackground.graphics.drawRoundRect(BildTvDefines.width *(1 - this.skin.skinWidth)/2,0,BildTvDefines.width * this.skin.skinWidth ,this.skin.fontHeight * this.subtitleText.numLines + 10 ,this.skin.borderRadiusTop*3,this.skin.borderRadiusTop*3);
			this.subtitleBackground.graphics.endFill();
		}
		
		public function setText(text:String):void
		{
			if( text == "" )
			{
				this.subtitleText.text = "";
				this.subtitleBackground.graphics.clear();
				this.subtitleBackground.visible = false;
			}
			else
			{			
				this.subtitleText.text = text;
				this.subtitleBackground.visible = true;			
				this.update();	
			}
		}
		
		public function update():void
		{
			if(!this.skin) return;
			//trace(this.skin.skinWidth);
			this.subtitleText.x = Math.floor(BildTvDefines.width *(1 - this.skin.skinWidth)/2);
			this.subtitleText.width = BildTvDefines.width * this.skin.skinWidth;
			this.subtitleBackground.y = this.subtitleText.y = Math.floor(-(this.skin.fontHeight * this.subtitleText.numLines) - this.skin.displayObjectY);
			this.drawBackground();
		}
	}
}