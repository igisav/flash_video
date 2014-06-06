package de.axelspringer.videoplayer.controller
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.view.ControlsView;
	import de.axelspringer.videoplayer.view.PlayerView;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class JinglePlayerController extends EventDispatcher
	{
		// gui
		protected var playerView:PlayerView;
		protected var controlsView:ControlsView;
		
		// stream
		protected var streamServer:String;
		protected var streamName:String;
		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var soundTransform:SoundTransform;
		
		protected var videoBufferEmptyStatus:Boolean;
		protected var videoBufferFlushStatus:Boolean;
		protected var videoStopped:Boolean;
		
		public function JinglePlayerController( playerView:PlayerView, controlsView:ControlsView )
		{
			super( this );
			
			this.playerView = playerView;
			this.controlsView = controlsView;
		}
		
		public function playJingle( streamServer:String, streamName:String, soundTransform:SoundTransform ) :void
		{
			trace( this + " playJingle - server: " + streamServer + ", stream: " + streamName );
			
			this.streamServer = streamServer;
			this.streamName = streamName;
			this.soundTransform = soundTransform;
			
			this.playerView.setDisplayButtonVisible( false );
			this.controlsView.enable( false );
			
			this.resetStatus();
			
			this.initStream();

			this.nc.connect( streamServer );
		}
		
		public function pause() :void
		{
			if( this.ns != null )
			{
				this.ns.pause();
			}
		}
		
		public function resume() :void
		{
			if( this.ns != null )
			{
				// set lower buffer here to enable fast video start after pause
				this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
				
				trace( this + " set buffertime to " + this.ns.bufferTime );
				
				this.ns.resume();
			}
		}
		
		protected function initStream() :void
		{
			this.nc = new NetConnection();
			this.nc.addEventListener( NetStatusEvent.NET_STATUS, onNetConnectionStatus );
			this.nc.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
			this.nc.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onError );
			this.nc.addEventListener( IOErrorEvent.IO_ERROR, onError );
			
			//checkEndOfVideoTimer init
//			this.checkEndOfVideoTimer = new Timer(TIMER_DELAY);
//			this.checkEndOfVideoTimer.addEventListener(TimerEvent.TIMER, checkEndOfVideo);
		
			var client:Object = new Object();
			client.onBWCheck = this.emptyCallback;
			client.onBWDone = this.emptyCallback;
			this.nc.client = client;
		}
		
		protected function onNetConnectionStatus( e:NetStatusEvent ):void
		{
			trace( this + " onNetConnectionStatus: " + e.info.code );
			
			switch( e.info.code )
			{
				case "NetConnection.Connect.Success":
				{
					this.onNetConnectionConnect();
					
					break;
				}
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Refused":
				case "NetConnection.Connect.Failed":
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, e.info.code ) );
					
					break;
				}
			}	
        }
        
        protected function onNetConnectionConnect() :void
		{
			trace( this + " onNetConnectionConnect" );
			
			this.ns = new NetStream( this.nc );
			this.ns.soundTransform = this.soundTransform;
			this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
			
			trace( this + " set buffertime to " + this.ns.bufferTime );
			
			var metaHandler:Object = new Object();
			metaHandler.onMetaData = this.onMetaData;
			this.ns.client = metaHandler;
			
			this.ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus, false, 0, true );
			
			this.playerView.display.attachNetStream( null );
			this.playerView.display.attachNetStream( this.ns );
			this.playerView.setImageVisible( false );
			this.playerView.chapterList.visible = false;
			
			// play!
			this.ns.play( this.streamName );
		}
        
        protected function onMetaData( data:Object ):void
		{
			trace( this + " onMetaData" );
			trace( data );
			
			// check ratio
			var ratio:Number = 16 / 9;
			
			if( data.width != null && data.height != null )
			{
				ratio = parseFloat( data.width ) / parseFloat( data.height );
			}
			
			this.playerView.setVideoRatio( ratio );
		}
		
		protected function emptyCallback( ...args ) :void
		{
			// nix drin
		}
		
		protected function onNetStreamStatus( e:NetStatusEvent ):void
		{
			trace( this + " onNetStreamStatus: " + e.info.code );
			
			switch( e.info.code )
			{
				case "NetStream.Buffer.Flush":
				{
					this.videoBufferFlushStatus = true;
					break;
				}
				case "NetStream.Seek.Notify":
				{
					this.videoBufferEmptyStatus = false;
					
					// set lower buffer here to enable fast video start after pause
					this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
					
					trace( this + " set buffertime to " + this.ns.bufferTime );
											
					break;
				}
				case "NetStream.Buffer.Full":
				{
					this.videoBufferEmptyStatus = false;
					
					this.dispatchEvent( new ControlEvent( ControlEvent.LOADERANI_CHANGE, { visible:false } ) );
					
					// set higher buffer now to enable constant playback
					this.ns.bufferTime = BildTvDefines.buffertimeMaximum;
					
					trace( this + " set buffertime to " + this.ns.bufferTime );
					
					break;
				}
				case "NetStream.Buffer.Empty":
				{
					this.videoBufferEmptyStatus = true;
					if( !this.videoBufferFlushStatus )
					{
						this.dispatchEvent( new ControlEvent( ControlEvent.LOADERANI_CHANGE, { visible:true, stream:this.ns } ) );
						
						// set lower buffer here to enable fast video start
						this.ns.bufferTime = BildTvDefines.buffertimeMinimum;
						
						trace( this + " set buffertime to " + this.ns.bufferTime );
					}
					
					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
					this.onError( new ErrorEvent( ErrorEvent.ERROR, false, false, "NetStream.Play.StreamNotFound" ) );
					
					break;
				}
				case "NetStream.Play.Start":
				{
					this.resetStatus();
					
					this.controlsView.showJingleControls( true );
					
					break;
				}
				case "NetStream.Play.Stop":
				{
					this.videoStopped = true;
					
					break;
				}
			}
			
			// check for clip end
//			trace(this + " this.videoStopped == " + this.videoStopped + " || this.videoBufferEmptyStatus == " + this.videoBufferEmptyStatus  + " || this.videoBufferFlushStatus == " + this.videoBufferFlushStatus);
			if (this.videoStopped == true && this.videoBufferEmptyStatus == true && this.videoBufferFlushStatus == true)
			{
				this.onStreamFinished();
			}
		}
		
		protected function onStreamFinished() :void
		{
			this.playerView.setDisplayButtonVisible( true );
			this.controlsView.showJingleControls( false );
			this.controlsView.enable( true );
			
			this.dispatchEvent( new ControlEvent( ControlEvent.JINGLE_FINISHED ) );
		}
		
		protected function resetStatus() :void
		{
			this.videoBufferEmptyStatus = false;
			this.videoBufferFlushStatus = false;
			this.videoStopped = false;
		}
		
        protected function onError( e:ErrorEvent ):void
		{
			trace( this + " onError: " + e.type + ", " + e.text );
			
			//this.dispatchEvent( new ControlEvent( ControlEvent.ERROR ) );
			this.onStreamFinished();
		}
	}
}