package de.axelspringer.videoplayer.vast.view
{
	import de.axelspringer.videoplayer.event.AdEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.FullscreenData;
	import de.axelspringer.videoplayer.vast.model.VASTTrackingEventType;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.utils.Timer;
	
	[Event(name="click", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="track", type="de.axelspringer.videoplayer.event.AdEvent")]
	[Event(name="nonlinearStart", type="de.axelspringer.videoplayer.event.AdEvent")]
	
	public class VastPlayerView extends EventDispatcher
	{
		static protected const OVERLAY_WIDTH_OPTIMUM:Number = 450; 
		
		// ui
		protected var stage:Sprite;
		protected var background:Sprite;
		protected var displayButton:Sprite;
		
		public var display:Video;
		public var overlay:Sprite;
		
		// properties
		protected var width:Number;
		protected var height:Number;
		protected var isFullscreen:Boolean;
		protected var ratio:Number = 16 / 9;
		protected var overlayWidth:Number;
		protected var overlayHeight:Number;
		protected var overlayDuration:Number;
		protected var scaleOverlay:Boolean;
		protected var isVpaid:Boolean;
		
		// stuff
		protected var showTimer:Timer;
		protected var hideTimer:Timer;
		
		public function VastPlayerView( stage:Sprite )
		{
			super( this );
			
			this.stage = stage;
			this.init();
		}
		
		public function init() :void
		{
			this.background = new Sprite();
			this.background.graphics.beginFill( 0, 1 );
			this.background.graphics.drawRect( 0, 0, 10, 10 );
			this.background.visible = false;
			this.stage.addChild( this.background );
			
			this.addDisplay();
			
			this.overlay = new Sprite();
			
			this.stage.parent.parent.stage.addChild( this.overlay );
			
			
			this.displayButton = new Sprite();
			this.displayButton.graphics.beginFill( 0, 0 );
			this.displayButton.graphics.drawRect( 0, 0, 10, 10 );
			this.displayButton.graphics.endFill();			
			this.displayButton.buttonMode = true;
			this.displayButton.addEventListener( MouseEvent.CLICK, onAdClick );
			this.enableDisplayButton( false );
			this.stage.addChild( this.displayButton );
			
			this.showTimer = new Timer( 0, 1 );		// was VastDefines.OVERLAY_DELAY, now we delay in PlayerController
			this.showTimer.addEventListener( TimerEvent.TIMER, onShowTimer );
			this.hideTimer = new Timer( 30000, 1 );	// real delay will be set later
			this.hideTimer.addEventListener( TimerEvent.TIMER, onHideTimer );
		}
		
		public function clear() :void
		{
			this.addDisplay();
		}
		
		public function setSize( rect:Rectangle, fullscreenData:FullscreenData ) :void
		{
			this.width = rect.width;
			this.height = rect.height;
			this.isFullscreen = ( fullscreenData != null && fullscreenData.isFullscreen );
			
			this.updateDisplaySize();
		}
		
		public function setVideoRatio( ratio:Number ) :void
		{
			this.ratio = ratio;
			
			this.updateDisplaySize();
		}
		
		public function enableDisplayButton( enable:Boolean ) :void
		{
			this.displayButton.visible = enable;
		}
		
		public function setNonLinear( graphic:DisplayObject, width:Number, height:Number, duration:Number, scalable:Boolean, minDuration:Number, hasClickThru:Boolean ) :void
		{
//			trace( this + " setNonLinear - " + width + " x " + height + ", scalable: " + scalable + ", minDuration: " + minDuration + ", hasClickThru: " + hasClickThru );
			
			this.removeOverlay();
			
			this.isVpaid = false;
			
			this.scaleOverlay = scalable;
//			this.scaleOverlay = false;
			
			this.overlayWidth = width;
			this.overlayHeight = height;
			
			this.overlay.addChild( graphic );
			trace("maße:" + graphic.width);
//			this.setNonLinearSize();
			
			if( hasClickThru )
			{
				this.overlay.addEventListener( MouseEvent.CLICK, onAdClick );
				this.overlay.buttonMode = true;
				this.overlay.mouseChildren = false;
			}
			
			// if it has a duration, start timer to hide it
			// it can have a duration (VAST 1 or VAST 2, sevenOne custom functionality) or minDuration (VAST 2 standard)
			if( minDuration > 0 && ( isNaN( duration ) || duration <= 0 ) )
			{
				duration = minDuration;
			} 
			 
			if( duration > 0 )
			{
				this.hideTimer.stop();
				this.hideTimer.delay = duration * 1000 + this.showTimer.delay; // add the delay before overlay is shown
				this.hideTimer.start();
			}
			
			// start delay
			this.showTimer.start();
		}
		
		public function setVPaid( graphic:DisplayObject, delayShow:Boolean ) :void
		{
//			trace( this + " setVPaid -  delaying: " + delayShow );
			
			this.removeOverlay();
			
			this.isVpaid = true;
			//this.scaleOverlay = false;
			
			this.overlay.addChild( graphic );
			
			// start delay or trigger showing event
			if( delayShow )
			{
				this.showTimer.start();
			}
			else
			{
				this.overlay.visible = true;
				this.dispatchEvent( new AdEvent( AdEvent.NONLINEAR_START ) );
			}
		}
		
		public function showDisplay( show:Boolean ) :void
		{
			this.display.visible = show;
			this.background.visible = show;
		}
		
		public function showBackground( show:Boolean ) :void
		{
			this.background.visible = show;
		}
		
		public function removeOverlay() :void
		{
//			trace( this + " ~~~~~~~~~~~~~~~~~~~~ removeOverlay ~~~~~~~~~~~~~~~~~~~~~~~" );
			
			this.hideTimer.stop();
			
			while( this.overlay.numChildren > 0 )
			{
				this.overlay.removeChildAt( 0 );
			}
			
			this.overlay.removeEventListener( MouseEvent.CLICK, onAdClick );
			this.overlay.buttonMode = false;
			//this.overlayCloseButton.visible = false;
			
			this.overlay.scaleX = this.overlay.scaleY = 1;
			this.overlay.x = this.overlay.y = 0;
			
			this.overlay.visible = false;
		}
		
		public function getSize() :Rectangle
		{
			return new Rectangle( 0, 0, this.width, this.height );
		}
		
		protected function onOverlayCloseButtonClick( event:MouseEvent ) :void
		{
			// track
			this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.CLOSE ) );
			
			this.removeOverlay();
		}
		
		protected function onShowTimer( event:TimerEvent ) :void
		{
			this.showTimer.stop();
			
			this.overlay.visible = true;
			//this.overlayCloseButton.visible = !this.isVpaid;
			
			// track
			this.dispatchEvent( new AdEvent( AdEvent.TRACK, VASTTrackingEventType.START ) );
			
			// VPAID only: signal start
			if( this.isVpaid )
			{
				this.dispatchEvent( new AdEvent( AdEvent.NONLINEAR_START ) );
			}
		}
		
		protected function onHideTimer( event:TimerEvent ) :void
		{
			this.hideTimer.stop();
			this.removeOverlay();
		}
		
		protected function addDisplay() :void
		{
			if( this.display != null && this.stage.contains( this.display ) )
			{
				this.stage.removeChild( this.display );
			}
			
			this.display = new Video();
			this.display.smoothing = true;
			this.stage.addChildAt( this.display, 1 );
		}
		
		protected function onAdClick( event:MouseEvent ) :void
		{
//			trace( this + " onAdClick" );
			
			this.dispatchEvent( new AdEvent( AdEvent.CLICK ) );
		}
		
		protected function updateDisplaySize() :void
		{
//			trace( this + " updateDisplaySize" );
			
			this.background.width = this.width;
			this.background.height = this.height;
			
			this.displayButton.width = this.width;
			this.displayButton.height = this.height;
			
			this.display.height = this.height;
			this.display.width = this.height * this.ratio;
			if( this.display.width > this.width )
			{
				this.display.width = this.width;
				this.display.height = this.width / this.ratio;
			}
			
			this.display.x = Math.round( ( this.width - this.display.width ) / 2 );
			this.display.y = Math.round( ( this.height - this.display.height ) / 2 );
			
			this.setNonLinearSize();
		}
		
		public function setNonLinearSize() :void
		{
//			trace( this + "setNonLinearSize - isVpaid: " + this.isVpaid );
			
			var scalor:Number = 1;
			
			this.overlay.width = this.overlayWidth;
			this.overlay.height = this.overlayHeight;
			
			if( this.scaleOverlay )
			{
				// scale to use all available width
				scalor = this.width / this.overlayWidth;
			}
			else
			{
				if( this.width >= this.overlayWidth )
				{
					// scale to original size
					scalor = this.overlayWidth / this.overlayWidth;
				}
				else
				{
					// scale to optimum size
					scalor = OVERLAY_WIDTH_OPTIMUM / this.overlayWidth;
				}
			}
			
			if( this.isVpaid )
			{
				this.overlay.x = 0;
				this.overlay.y = 0;
			}
			else
			{
				if(scalor < 1)
				{
					this.overlay.scaleX *= scalor;
					this.overlay.scaleY *= scalor;
					this.overlay.x = 0;
					this.overlay.y = Math.round( this.height - this.overlayHeight );
				}
				else
				{					
					this.overlay.x = Math.round( ( this.width - this.overlayWidth ) / 2 );
					this.overlay.y = Math.round( this.height - this.overlayHeight );
				}
				
				trace(scalor + "     " + this.overlay.width);
				
				if( this.isFullscreen )
				{
					//this.overlay.y -= BildTvDefines.HEIGHT_CONTROLS;
				}
			}
		}
	}
}