package de.axelspringer.videoplayer.util
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	[Event(name="errorSession", type="de.axelspringer.videoplayer.event.ControlEvent")]
	[Event(name="sessionOk", type="de.axelspringer.videoplayer.event.ControlEvent")]
	
	public class SessionPinger extends EventDispatcher
	{
		protected var url:String = "";
		protected var session:String = "";
		protected var interval:Number = 0;
		
		protected var timer:Timer;
		protected var loader:URLLoader;
		protected var initialized:Boolean;
		protected var stopped:Boolean;
		
		protected var testing:Boolean = false;
		
		public function SessionPinger()
		{
			super( this );
		}
		
		public function init( url:String, session:String, interval:Number ) :void
		{
			trace( this + " init - url: " + url + ", session: " + session + ", interval: " + interval );
			
			this.stop();
			
			if( url != null && url.split( " " ).join( "" ) != "" && interval > 0 )
			{
				this.url = url;
				this.session = session;
				this.interval = interval;
				
				this.loader = new URLLoader();
				this.addLoaderListeners( this.loader );
				
				this.timer = new Timer( this.interval );
				this.timer.addEventListener( TimerEvent.TIMER, onTimer );
				
				this.initialized = true;
			}
		}
		
		public function start() :void
		{
			if( this.initialized )
			{
				trace( this + " start" );
				
				this.stopped = false;
				this.timer.start();
			}
		}
		
		public function stop() :void
		{
			trace( this + " stop" );
			
			this.stopped = true;
			this.initialized = false;
			
			if( this.loader != null )
			{
				this.removeLoaderListeners( this.loader );
				try
				{
					this.loader.close();
				}
				catch( error:Error )
				{
					// ignore
				}
			}
			
			if( this.timer != null )
			{
				this.timer.stop();
				this.timer.removeEventListener( TimerEvent.TIMER, onTimer );
			}
		}
		
		public function pingOnce() :void
		{
			if( this.initialized )
			{
				trace( this + " pingOnce" );
				
				// testing
				if( this.testing )
				{
					this.dispatchEvent( new ControlEvent( ControlEvent.SESSION_OK ) );
					return;
				}
				
				this.stopped = false;
				this.onTimer( null );
			}
		}
		
		public function get isInitialized() :Boolean
		{
			return this.initialized;
		}
		
		protected function onTimer( event:TimerEvent ) :void
		{
			trace( this + " onTimer - calling sessioncheck" );
			
			// testing
			if( this.testing )
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.SESSION_OK ) );
				return;
			}
			
			var variables:URLVariables = new URLVariables();
			variables.session = this.session;
			
			var request:URLRequest = new URLRequest();
			request.url = this.url;
			request.method = URLRequestMethod.GET;
			request.data = variables;
				
			try
			{
				this.loader.load( request );
			}
			catch( error:Error )
			{
				this.onLoadError( new ErrorEvent( ErrorEvent.ERROR, false, false, error.message ) );
			}
		}
		
		protected function onLoadComplete( event:Event ) :void
		{
			trace( this + " onLoadComplete - data: " + this.loader.data );
			
			if( this.loader.data == "true" )
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.SESSION_OK ) );
			}
			else
			{
				this.onLoadError( new ErrorEvent( ErrorEvent.ERROR, false, false, "Error in onLoadComplete: data != true" ) );
			}
		}
		
		protected function onLoadError( event:ErrorEvent ) :void
		{
			Log.error( this + " onLoadError: " + event.text );
			
			if( !this.stopped )
			{
				this.stop();
				this.dispatchEvent( new ControlEvent( ControlEvent.ERROR_SESSION ) );
			}
			
			// clean up
			this.removeLoaderListeners( this.loader );
		}
		
		protected function addLoaderListeners( loader:URLLoader ) :void
		{
			if( loader != null )
			{
				loader.addEventListener( Event.COMPLETE, onLoadComplete );
				loader.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoadError );
			}
		}
		
		protected function removeLoaderListeners( loader:URLLoader ) :void
		{
			if( loader != null )
			{
				loader.removeEventListener( Event.COMPLETE, onLoadComplete );
				loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoadError );
				loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoadError );
			}
		}
	}
}