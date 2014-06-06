package de.axelspringer.videoplayer.vpaid.model
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class VPaidWrapper extends EventDispatcher implements IVPAID
	{
		public static const VIEWMODE_NORMAL:String 		= "normal";
		public static const VIEWMODE_FULLSCREEN:String 	= "fullscreen";
		public static const VIEWMODE_THUMBNAIL:String 	= "thumbnail";
		
		private static const VPAID_VERSION:String = "1.1.0";
		
		// the loaded swf must implement IVPAID, but we cannot type it because it comes from another application domain
		// this class implements IVPAID explicitly and wraps the untyped ad
		private var _ad:*;
		
		// the graphic element
		private var _swf:DisplayObject;
		
		public function VPaidWrapper()
		{
			super( this );
		}
		
		public function setSwf( adSwf:Object ) :Boolean
		{
			var foundVPaidAd:Boolean;
			
			_swf = adSwf as DisplayObject;
			
			try
			{
				// doku says call this method, but many ads do not support it
				_ad = adSwf.getVPAID();
			}
			catch( error:Error )
			{
				Log.error( this + " Error getting VPAID interface: " + error.message );
				//foundVPaidAd = false;
				_ad = adSwf;
			}
			
			foundVPaidAd = ( _ad != null && this.isCompatibleVPaidVersion() );
			
			return foundVPaidAd;
		}
		
		protected function isCompatibleVPaidVersion() :Boolean
		{
			var result:Boolean = true;
			
			try
			{
				var adVersion:String = this.handshakeVersion( VPAID_VERSION );
				var adVersionParts:Array = adVersion.split( "." );
				var playerVersionParts:Array = VPAID_VERSION.split( "." );
				var a:int;
				var b:int;
				
				for( var i:uint = 0; i < 3; i++ )
				{
					if( adVersionParts.length > i )
					{
						a = parseInt( adVersionParts[i], 10 );
						b = parseInt( playerVersionParts[i], 10 );
						if( a > b )
						{
							result = false;
							break;
						}
					}
				}
			}
			catch( error:Error )
			{
				result = false;
			}
			
			return result;
		}
		
		public function reset() :void
		{
			_ad = null;
			_swf = null;
		}
		
		public function isInitialized() :Boolean
		{
			return ( _ad != null );
		}
		
		public function getSwf() :DisplayObject
		{
			return _swf;
		}
		
		// Properties
		
		public function get adLinear() :Boolean
		{
			var result:Boolean;
			
			try
			{
				result = ( this.isInitialized() && _ad.adLinear );
			}
			catch( error:Error )
			{
				result = false;
			}
			
			return result;
		}
		
		public function get adExpanded() :Boolean
		{
			var result:Boolean;
			
			try
			{
				result = ( this.isInitialized() && _ad.adExpanded );
			}
			catch( error:Error )
			{
				result = false;
			}
			
			return result;
		}
		public function get adRemainingTime() :Number
		{
			var result:Number;
			
			try
			{
				result = ( this.isInitialized() ? _ad.adRemainingTime : 0 );
			}
			catch( error:Error )
			{
				result = 0;
			}
			
			return result;
		}
		public function get adVolume() :Number
		{
			var result:Number;
			
			try
			{
				result = ( this.isInitialized() ? _ad.adVolume : 0 );
			}
			catch( error:Error )
			{
				result = 0;
			}
			
			return result;
		}
		public function set adVolume( value:Number ) :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.adVolume = value;
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		// Methods
		
		public function handshakeVersion( playerVPAIDVersion:String ) :String
		{
			var result:String;
			
			try
			{
				result = ( this.isInitialized() ? _ad.handshakeVersion( playerVPAIDVersion ) : "" );
			}
			catch( error:Error )
			{
				result = "";
			}
			
			return result;
		}
		
		public function initAd( width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String, environmentVars:String ) :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.initAd( width, height, viewMode, desiredBitrate, creativeData, environmentVars );
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		public function resizeAd( width:Number, height:Number, viewMode:String ) :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.resizeAd( width, height, viewMode );
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		public function startAd() :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.startAd();
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		public function stopAd():void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.stopAd();
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		public function pauseAd() :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.pauseAd();
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		public function resumeAd() :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.resumeAd();
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		public function expandAd() :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.expandAd();
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		public function collapseAd() :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.collapseAd();
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		// EventDispatcher overrides
		
		override public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false ) :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.addEventListener( type, listener, useCapture, priority, useWeakReference );
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		override public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ) :void
		{
			if( this.isInitialized() )
			{
				try
				{
					_ad.removeEventListener( type, listener, useCapture );
				}
				catch( error:Error )
				{
					// nix
				}
			}
		}
		
		override public function dispatchEvent( event:Event ) :Boolean
		{
			var result:Boolean;
			
			try
			{
				result = ( this.isInitialized() ? _ad.dispatchEvent( event ) : false );
			}
			catch( error:Error )
			{
				result = false;
			}
			
			return result;
		}
		
		override public function hasEventListener( type:String ) :Boolean
		{
			var result:Boolean;
			
			try
			{
				result = ( this.isInitialized() ? _ad.hasEventListener( type ) : false );
			}
			catch( error:Error )
			{
				result = false;
			}
			
			return result;
		}
		
		override public function willTrigger( type:String ) :Boolean
		{
			var result:Boolean;
			
			try
			{
				result = ( this.isInitialized() ? _ad.willTrigger( type ) : false );
			}
			catch( error:Error )
			{
				result = false;
			}
			
			return result;
		}
	}
}