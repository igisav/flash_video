package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.SkinVO;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	public class PlayPauseBtn
	{
		protected var ui:Sprite;
		protected var skin:SkinVO;
		protected var btnPlay:Sprite;
		protected var btnPause:Sprite;
		protected var btnMc:Sprite;
		
		public function PlayPauseBtn( ui:Sprite )
		{
			this.ui = ui;
			this.skin = new SkinVO();
			
			this.btnPlay = this.ui.getChildByName( "mcPlay" ) as Sprite;
			this.btnPause = this.ui.getChildByName( "mcPause" ) as Sprite;
			this.btnMc = this.ui.getChildByName( "mcBtn" ) as Sprite;
			
			this.btnMc.addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			this.btnMc.addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			this.btnMc.addEventListener( MouseEvent.CLICK, onClick );
			
			this.btnMc.buttonMode = true;
			this.btnMc.dispatchEvent( new MouseEvent( MouseEvent.ROLL_OUT ) );
			this.playing = false;
		}
		
		public function setSkin( skin:SkinVO ) :void
		{
			this.skin = skin;
			this.btnMc.dispatchEvent( new MouseEvent( MouseEvent.ROLL_OUT ) );
		}
		
		public function set playing( value:Boolean ) :void
		{
			this.btnPause.visible = value;
			this.btnPlay.visible = !value;
		}
		
		public function get playing() :Boolean
		{
			return this.btnPause.visible;
		}
		
		protected function onRollOver( e:MouseEvent ) :void
		{
			//this.setColor( this.skin.colorActive );
		}
		
		protected function onRollOut( e:MouseEvent ) :void
		{
			//this.setColor( this.skin.colorDefault );
		}
		
		protected function onClick( e:MouseEvent ) :void
		{
			this.ui.dispatchEvent( new ControlEvent( ControlEvent.PLAYPAUSE_CHANGE, null, true, true ) );
		}
		
		protected function setColor( color:Number ) :void
		{
			var gui:DisplayObject;
			var txt:TextField;
			var ct:ColorTransform;
			
			// pause btn
			gui = this.btnPause.getChildByName( "highlight" );
			
			if( gui != null )
			{
				ct = gui.transform.colorTransform;
				ct.color = color;
				gui.transform.colorTransform = ct;
			}
			
			txt = this.btnPause.getChildByName( "label" ) as TextField;
			if( txt != null )
			{
				txt.textColor = color;
			}
			
			// play btn
			gui = this.btnPlay.getChildByName( "highlight" );
			
			if( gui != null )
			{
				ct = gui.transform.colorTransform;
				ct.color = color;
				gui.transform.colorTransform = ct;
			}
			
			txt = this.btnPlay.getChildByName( "label" ) as TextField;
			if( txt != null )
			{
				txt.textColor = color;
			}
		}
	}
}