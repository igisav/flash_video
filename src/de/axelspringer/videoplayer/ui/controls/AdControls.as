package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.model.vo.AdTimerTextVO;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	import de.axelspringer.videoplayer.vast.VastDefines;
	
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class AdControls extends Sprite
	{
		public var txtLabel:TextField;
		
		protected var skin:SkinBaseVO;
		protected var adTimerTextVo:AdTimerTextVO;
		protected var adType:String;
		
		public var visibility:Boolean = false;
		
		public var lastAdTime:Number = 0;
		
		public function AdControls()
		{
			super();
			
			this.adTimerTextVo = new AdTimerTextVO();
			this.txtLabel = new TextField;
			this.txtLabel.autoSize = "left";
			this.txtLabel.antiAliasType = AntiAliasType.ADVANCED;
			this.txtLabel.gridFitType = "pixel";
			this.txtLabel.selectable = false;
			
			this.addChild( this.txtLabel );
			
			this.txtLabel.x= this.txtLabel.y = 0;
		}
		
		public function setAdType( adType:String ) :void
		{
			this.adType = adType;
		}
		
		public function setSkin( skin:SkinBaseVO ) :void
		{
			this.skin = skin;
			if( true)//this.skin.skinStatus)
			{
				var tf:TextFormat = this.txtLabel.defaultTextFormat;
				tf.bold = true;
				tf.size = 10;
				tf.font = "Arial";
				tf.color = skin.color;
				this.txtLabel.defaultTextFormat = tf;
				//this.label.textColor = this.skin.colorDefault;
			}
		}
		
		public function setAdTimerText( adTimerText:AdTimerTextVO ) :void
		{
			this.adTimerTextVo = adTimerText;
		}
		
		public function setRemainingTime( seconds:int ) :void
		{
			var text:String = "";
			
			switch( this.adType )
			{
				case VastDefines.ADTYPE_PREROLL:
				{
					if( BildTvDefines.size == BildTvDefines.SIZE_MICRO )
					{
						text = this.adTimerTextVo.adTimerMicroplayerText;
					}
					else
					{
						text = this.adTimerTextVo.adTimerPrerollText;
					}	
					break;
				}
				case VastDefines.ADTYPE_MIDROLL:
				case VastDefines.ADTYPE_POSTROLL:
				{
					if( BildTvDefines.size == BildTvDefines.SIZE_MICRO )
					{
						text = this.adTimerTextVo.adTimerMicroplayerText;
					}
					else
					{
						text = this.adTimerTextVo.adTimerPostrollText;
					}
					break;
				}
			}
			
			if( isNaN( seconds ) || seconds < 0 )
			{
				text = this.adTimerTextVo.adTimerUnknownTimeText;
			}
			
			this.txtLabel.text = text.replace( "%TIME%", seconds.toString() );
			this.txtLabel.antiAliasType = AntiAliasType.ADVANCED;
			
			this.lastAdTime = seconds;
					
		}
	}
}