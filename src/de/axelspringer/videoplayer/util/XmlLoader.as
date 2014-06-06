package de.axelspringer.videoplayer.util
{
	import de.axelspringer.videoplayer.event.XmlEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author Hendrik Apel <hendrik.apel@web.de>
	 */
	public class XmlLoader extends EventDispatcher
	{
		private var loaders:Array;
		
		public function XmlLoader() 
		{
			super( this );
			this.loaders = new Array();
		}
		
		public function loadXml( url:String ) :void
		{
//			trace( this + " load xml: " + url );
			
			var loader:URLLoader = new URLLoader();
			this.addListeners( loader );
			
			this.loaders.push( { loader:loader, url:url } );
           	
			try
			{
				loader.load( new URLRequest( url ) );
			}
			catch( e:Error )
			{
				this.removeListeners( loader );
				
				this.loaders.pop();
				
				this.onError( url, e.getStackTrace() );
			}
		}
		
		public function cancelXml( url:String ) :void
		{
			var loader:URLLoader;
			var i:uint = this.loaders.length;
			
			while( i-- )
			{
				if( this.loaders[i].url == url )
				{
					loader = this.loaders[i].loader;
					this.removeListeners( loader );
					this.loaders.splice( i, 1 );
					
					try
					{
						loader.close();
						
					}
					catch( error:Error )
					{
						// nix
					}
				}
			}
		}
		
		private function onLoaderComplete( e:Event ) :void
		{
//			trace( this + " onLoaderComplete" );
			
			var loader:URLLoader = e.target as URLLoader;
			this.removeListeners( loader );
            
            var url:String = "";
			
			for( var i:uint = 0; i < this.loaders.length; i++ )
			{
				if( this.loaders[i].loader == loader )
				{
					url = this.loaders[i].url;
					this.loaders.splice( i, 1 );
					break;
				}
			}
			
			var xml:XML;
			
			try
			{
				xml = new XML( loader.data );
			}
			catch( err:Error )
			{
				this.onError( url, err.getStackTrace() );
				return;
			}
			
			//trace( "xml: " + xml );
			
			this.dispatchEvent( new XmlEvent( XmlEvent.XML_LOADED, url, xml ) );
		}
		
		private function onLoaderError( e:ErrorEvent ) :void
		{
			trace( this + " onLoaderError: " + e.text );
			
			var loader:URLLoader = e.target as URLLoader;
			this.removeListeners( loader );
			
			var url:String = "";
			
			for( var i:uint = 0; i < this.loaders.length; i++ )
			{
				if( this.loaders[i].loader == loader )
				{
					url = this.loaders[i].url;
					this.loaders.splice( i, 1 );
					break;
				}
			}
			
			this.onError( url, e.text );
		}
		
		private function onError( url:String, text:String ) :void
		{
			this.dispatchEvent( new XmlEvent( XmlEvent.XML_ERROR, url, null, text ) );
		}
		
		private function addListeners( loader:URLLoader ) :void
		{
			if( loader != null )
			{
				loader.addEventListener(Event.COMPLETE, onLoaderComplete);
	            loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
	            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
	  		}
		}
		
		private function removeListeners( loader:URLLoader ) :void
		{
			if( loader != null )
			{
				loader.removeEventListener(Event.COMPLETE, onLoaderComplete);
	            loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
	            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
	  		}
		}
		
		public override function toString() :String
		{
			return "[XmlLoader]";
		}
	}
}