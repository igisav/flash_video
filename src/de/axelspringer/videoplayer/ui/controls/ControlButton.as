/*
package de.axelspringer.videoplayer.ui.controls
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;

	public class ControlButton
	{
		public static const DEFAULT:String 		= "ControlButton.DEFAULT";
		public static const FULLSCREEN:String 	= "ControlButton.FULLSCREEN";
		public static const HD:String 			= "ControlButton.HD";
		public static const SUBTITLE:String 	= "ControlButton.SUBTITLE";
		
		public var type:String;
		public var event:String;
		
		protected var ui:Sprite;
		protected var skin:SkinBaseVO;
		protected var isActive:Boolean;
		protected var isEnabled:Boolean;
	
		protected var tooltipTimer:Timer;
		
		public function ControlButton( ui:Sprite, type:String = ControlButton.DEFAULT, event:String = ControlEvent.BUTTON_CLICK )
		{
			this.ui = ui;
			this.type = type;
			this.event = event;
			this.skin = new SkinBaseVO();
			
			this.enabled = true;
			this.active = false;
			
			this.ui.mouseChildren = false;
			this.ui.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		public function setSkin( skin:SkinBaseVO ) :void
		{
			this.skin = skin;
			if( true)//this.skin.skinStatus )
			{
				//this.tooltip.setColors(this.skin.colorText, this.skin.imgTooltipBackground);				
			}
			this.ui.dispatchEvent( new MouseEvent( MouseEvent.MOUSE_OUT ) );
		}
				
		protected function onClick( e:MouseEvent ) :void
		{
			this.ui.dispatchEvent( new ControlEvent( this.event, { button:this }, true, true ) );
		}
		
		public function get enabled() :Boolean
		{
			return this.isEnabled;
		}
		
		public function set enabled( value:Boolean ) :void
		{
			this.isEnabled = value;
			this.ui.mouseEnabled = value;
			this.ui.buttonMode = value;
			
			if( !value )
			{
				this.active = false;
			}
		}
		
		public function set x( value:Number ) :void
		{
			this.ui.x = value;
		}
		
		public function get active() :Boolean
		{
			return this.isActive;
		}
		
		public function set active( value:Boolean ) :void
		{
			this.isActive = value;
			
			if( value )
			{
				//this.setColor( this.skin.colorActiveIcon );
			}
			else
			{
				//this.setColor( this.skin.colorDefaultIcon );
			}
		}
		
		public function get visible() :Boolean
		{
			return this.ui.visible;
		}
		
		public function set visible( value:Boolean ) :void
		{
			this.ui.visible = value;
		}
		
		protected function setColor( color:Number ) :void
		{
			var ui:DisplayObject = this.ui.getChildByName( "highlight" );
			if( ui != null )
			{
				var ct:ColorTransform = ui.transform.colorTransform;
				ct.color = color;
				ui.transform.colorTransform = ct; 
				
			}
		}
	}
}*/
