package de.axelspringer.videoplayer.ui
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class ChapterListItemUi extends Sprite
	{
		private static const IMAGEWIDTH:uint 	= 64;
		private static const IMAGEHEIGHT:uint 	= 48;
		
		private static const COLOR_DEFAULT:uint		= 0x666666;
		private static const COLOR_SELECTED:uint 	= 0xFFFFFF;
		private static const COLOR_OVER:uint 		= 0xd30303;
		
		public static const WIDTH:uint 	= 66;
		public static const HEIGHT:uint = 50;
		
		protected var background:Sprite;
		protected var imageContainer:Sprite;
		protected var imageMask:Sprite;
		
		protected var isSelected:Boolean = false;
		
		public var timestamp:Number;
		public var index:uint;
		
		public function ChapterListItemUi()
		{
			super();
			
			this.init();
		}
		
		protected function init() :void
		{
			this.background = new Sprite();
			this.background.graphics.beginFill( COLOR_DEFAULT, 1 );
			this.background.graphics.drawRect( 0, 0, WIDTH, HEIGHT );
			this.background.graphics.endFill();
			this.addChild( this.background );
			
			this.imageContainer = new Sprite();
			this.imageContainer.x = Math.round( ( WIDTH - IMAGEWIDTH ) / 2 );
			this.imageContainer.y = Math.round( ( HEIGHT - IMAGEHEIGHT ) / 2 );
			this.addChild( this.imageContainer );
			
			this.imageMask = new Sprite();
			this.imageMask.graphics.beginFill( 0, 1 );
			this.imageMask.graphics.drawRect( 0, 0, IMAGEWIDTH, IMAGEHEIGHT );
			this.imageMask.graphics.endFill();
			this.imageMask.x = this.imageContainer.x;
			this.imageMask.y = this.imageContainer.y;
			this.addChild( this.imageMask );
			
			this.imageContainer.mask = this.imageMask;
			
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener( MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true );
			this.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true );
		}
		
		public function set imageUrl( value:String ) :void
		{
			this.loadImage( value );
		}
		
		public function set selected( value:Boolean ) :void
		{
			var color:uint = value ? COLOR_SELECTED : COLOR_DEFAULT;
			this.setBackgroundColor( color );
			this.isSelected = value;
		}
		
		protected function loadImage( url:String ) :void
		{
			while( this.imageContainer.numChildren > 0 )
			{
				this.imageContainer.removeChildAt( 0 );
			}
			
			var loader:Loader = new Loader();
			this.addListeners( loader.contentLoaderInfo );
			try
			{
				loader.load( new URLRequest( url ), new LoaderContext( true ) );
			}
			catch( error:Error )
			{
				this.onImageError( null );
			}
			
			this.imageContainer.addChild( loader );
		}
		
		protected function onImageError( e:ErrorEvent ) :void
		{
			this.removeListeners( e.target as LoaderInfo );
		}
		
		protected function onImageLoaded( e:Event ) :void
		{
			this.removeListeners( e.target as LoaderInfo );
		}
		
		protected function addListeners( loaderInfo:LoaderInfo ) :void
		{
			if( loaderInfo != null )
			{
				loaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onImageError );
				loaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onImageError );
				loaderInfo.addEventListener( Event.COMPLETE, onImageLoaded );
			}
		}
		
		protected function removeListeners( loaderInfo:LoaderInfo ) :void
		{
			if( loaderInfo != null )
			{
				loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onImageError );
				loaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onImageError );
				loaderInfo.removeEventListener( Event.COMPLETE, onImageLoaded );
			}
		}
		
		protected function onMouseOver( event:MouseEvent ) :void
		{
			if( !this.isSelected )
			{
				this.setBackgroundColor( COLOR_OVER );
			}
		}
		
		protected function onMouseOut( event:MouseEvent ) :void
		{
			if( !this.isSelected )
			{
				this.setBackgroundColor( COLOR_DEFAULT );
			}
		}
		
		protected function setBackgroundColor( color:uint ) :void
		{
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = color; 
			this.background.transform.colorTransform = colorTransform;
		}
	}
}