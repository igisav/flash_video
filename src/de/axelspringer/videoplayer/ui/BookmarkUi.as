package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.BookmarkVO;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	[Embed(source="/embed/assets.swf", symbol="BookmarkUi")]
	public class BookmarkUi extends Sprite
	{
		public var mcMask:Sprite;
		public var bg:Sprite;
		public var txtTitle:TextField;
		
		protected var vo:BookmarkVO;
		protected var mcImage:Sprite;
		
		public function BookmarkUi( bookmarkVO:BookmarkVO )
		{
			super();
			
			this.vo = bookmarkVO;
			
			this.mcImage = new Sprite();
			this.addChild( this.mcImage );
			this.mcImage.mask = this.mcMask;
			
			this.txtTitle.autoSize = TextFieldAutoSize.LEFT;
			this.txtTitle.text = this.vo.title;
			this.txtTitle.x = Math.round( ( this.mcMask.width - this.txtTitle.width ) / 2 );
			this.txtTitle.visible = false;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIconError );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onIconError );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onIconLoaded );
			loader.load( new URLRequest( this.vo.icon ), new LoaderContext( true ) );
			
			this.mcImage.addChild( loader );
			
			this.mouseChildren = false;
			this.buttonMode = true;
			this.bg.width = Math.max( this.mcMask.width, this.txtTitle.width ) + 10;
			this.bg.height = this.txtTitle.y + this.txtTitle.height + 10;
			this.bg.x = Math.min( this.mcMask.x, this.txtTitle.x ) - 5;
			this.bg.y = -5;
			this.addEventListener( MouseEvent.CLICK, onClick, false, 0, true );
		}
		
		protected function onIconError( e:ErrorEvent ) :void
		{
			// nüschts
		}
		
		protected function onIconLoaded( e:Event ) :void
		{
			try
			{
				var bmp:Bitmap = e.target.content;
				bmp.smoothing = true;
			}
			catch( oops:Error )
			{
				// nix
			}
				
			this.mcImage.width = 33;
			this.mcImage.height = 33;
			this.txtTitle.x = Math.round( ( this.mcImage.width - this.txtTitle.width ) / 2 );
			this.txtTitle.y = 28;
				
			this.bg.width = Math.max( this.mcImage.width, this.txtTitle.width ) + 10;
			this.bg.height = this.txtTitle.y + this.txtTitle.height + 10;
			this.bg.x = Math.min( this.mcMask.x, this.txtTitle.x ) - 5;
			this.bg.y = -5;
				
			this.x += 7;	
		}
		
		protected function onClick( e:MouseEvent ) :void
		{
			this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK, { url:this.vo.url } ) );
		}
	}
}