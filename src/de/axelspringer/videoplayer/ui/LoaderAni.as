package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	[Embed(source="/embed/assets.swf", symbol="Loader")]
	public class LoaderAni extends Sprite
	{
		public var loader:Sprite;
		public var loaderBg:Sprite;
		public var loaderMask:Sprite;
		public var background:Sprite;
		
		// buffer display
		public var bufferDisplayMc:MovieClip;
		public var bufferDisplay:BufferDisplay;
		
		public function LoaderAni()
		{
			super();
			
			this.bufferDisplay = new BufferDisplay( this.bufferDisplayMc );
			
			this.resize();
		}
		
		public function resize() :void
		{
			this.background.width = BildTvDefines.width;
			this.background.height = BildTvDefines.height;
			
			if(!BildTvDefines.isWidgetPlayer)
			{
				this.background.height -= BildTvDefines.HEIGHT_CONTROLS;
			}
			var yOffset:Number = 0;
			
			if( BildTvDefines.playerType != "normal" )
			{
				yOffset = 70;
			}
			
			this.loader.x = Math.round( BildTvDefines.width / 2 );
			this.loader.y = Math.round( (this.background.height) / 2 ) + yOffset;
			this.loaderBg.x = Math.round( BildTvDefines.width / 2 );
			this.loaderBg.y = Math.round(( this.background.height ) / 2 ) + yOffset;
			this.loaderMask.x = Math.round( BildTvDefines.width / 2 );
			this.loaderMask.y = Math.round(( this.background.height ) / 2 ) + yOffset;
			
			this.bufferDisplay.x = this.loader.x - 130;
			this.bufferDisplay.y = this.loader.y - 9;
		}
		
		public function setSkin(styleObj:SkinBaseVO):void
		{
			var color:ColorTransform = new ColorTransform();
				
			 if( styleObj.color != 0 )
			{
				color.color = styleObj.color;
				this.loader.transform.colorTransform = color;			
			}
			
			if(styleObj.backgroundColor != 0 )
			{
				color.color = styleObj.backgroundColor;
				this.loaderBg.transform.colorTransform = color;							
			} 
		}
		
		public override function set visible( value:Boolean ) :void
		{
			this.resize();
			//trace( "------- loaderani visible = " + value );
			// if bufferDisplay's netstream is defined, show also bufferDisplay
			this.loader.visible = value;
			this.bufferDisplay.visible = ( value && this.bufferDisplay.netstream != null );
			
			super.visible = value;
		}
	}
}