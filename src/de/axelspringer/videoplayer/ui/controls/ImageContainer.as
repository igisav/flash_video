package de.axelspringer.videoplayer.ui.controls
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class ImageContainer extends EventDispatcher
	{
		protected var containerUi:Sprite;
		protected var loadedUi:Sprite;
		protected var fallbackUi:Sprite;
		protected var loader:Loader;
		
		protected var currentWidth:Number = -1;
		protected var currentHeight:Number = -1;
		
		protected var isLoaded:Boolean = false;
		protected var isFallback:Boolean = true;
		protected var isVisible:Boolean = true;
		
		public function ImageContainer( containerUi:Sprite )
		{
			super( this );
			
			this.containerUi = containerUi;
			this.fallbackUi = this.containerUi.getChildByName( "fallback" ) as Sprite;
			
			this.loadedUi = new Sprite();
			this.loadedUi.visible = false;
			this.containerUi.addChild( this.loadedUi );
			
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onError, false, 0, true );
			this.loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true );
			this.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete, false, 0, true );
		}
		
		public function get stage():Sprite
		{
			return this.containerUi;
		}
		
		public function get x() :Number
		{
			return this.containerUi.x;
		}
		
		public function set x( value:Number ) :void
		{
			this.containerUi.x = value;
		}
		
		public function get y() :Number
		{
			return this.containerUi.y;
		}
		
		public function set y( value:Number ) :void
		{
			this.containerUi.y = value;
		}
		
		public function get width() :Number
		{
			var result:Number = this.loadedUi.width;
			
			if( this.isFallback )
			{
				result = this.fallbackUi.width;
			}
			
			return result;
		}
		
		public function set width( value:Number ) :void
		{
			this.currentWidth = value;
			this.loadedUi.width = value;
			this.fallbackUi.width = value;
		}
		
		public function get height() :Number
		{
			var result:Number = this.loadedUi.height;
			
			if( this.isFallback )
			{
				result = this.fallbackUi.height;
			}
			
			return result;
		}
		
		public function set height( value:Number ) :void
		{
			this.currentHeight = value;
			this.loadedUi.height = value;
			this.fallbackUi.height = value;
		}
		
		public function get visible() :Boolean
		{
			return this.isVisible;
		}
		
		public function set visible( value:Boolean ) :void
		{
			this.isVisible = value;
			this.update();
		}
		
		public function setSkin( imgUrl:String, color:Number = 0 ) :void
		{
			this.reset();
			if(imgUrl != "")
			{
				try
				{
					this.loader.load( new URLRequest( imgUrl ), new LoaderContext( true ) );
				}
				catch( e:Error )
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, e.getStackTrace() ) );
				}	
			}
			else if(color != 0)
			{
				this.setColor(color);
			}
		}
		
		protected function setColor( color:Number ) :void
		{
			var gui:DisplayObject;
			var ct:ColorTransform;
			
			// pause btn
			gui = this.fallbackUi.getChildByName("bg");
			
			if( gui != null )
			{
				ct = gui.transform.colorTransform;
				ct.color = color;
				gui.transform.colorTransform = ct;
			}
		}
		
		protected function onError( e:ErrorEvent ) :void
		{
			this.isFallback = true;	
			this.finalizeInit();
		}
		
		protected function onComplete( e:Event ) :void
		{
			this.isFallback = false;
			this.loadedUi.addChild( this.loader );
			
			this.finalizeInit();
		}
		
		protected function finalizeInit() :void
		{
			this.isLoaded = true;
			this.dispatchEvent( new Event( Event.COMPLETE ) );
			this.update();
		}
		
		protected function update() :void
		{
			if( this.isLoaded )
			{
				if( this.isFallback )
				{
					this.fallbackUi.visible = this.isVisible;
					this.loadedUi.visible = false;
				}
				else
				{
					this.fallbackUi.visible = false;
					this.loadedUi.visible = this.isVisible;
				}
				
				if( this.currentWidth > 0 )
				{
					this.width = this.currentWidth;
				}
				if( this.currentHeight > 0 )
				{
					this.height = this.currentHeight;
				}
			}
		}
		
		protected function reset() :void
		{
			this.isLoaded = false;
			this.isFallback = true;
			this.loadedUi.visible = false;
			this.fallbackUi.visible = this.isVisible;
			if( this.loadedUi.contains( this.loader ) )
			{
				this.loadedUi.removeChild( this.loader );
			}
		}
	}
}