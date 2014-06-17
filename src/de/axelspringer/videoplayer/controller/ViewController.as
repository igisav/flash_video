package de.axelspringer.videoplayer.controller
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.ConfigVO;
//	import de.axelspringer.videoplayer.model.vo.SkinVO;
//	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	import de.axelspringer.videoplayer.view.ControlsView;
	import de.axelspringer.videoplayer.view.PlayerView;
//	import de.axelspringer.videoplayer.view.SubtitleView;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class ViewController extends EventDispatcher
	{
		public static const STATE_START:String 	= "ViewController.STATE_START";
		public static const STATE_PLAY:String	= "ViewController.STATE_PLAY";
		public static const STATE_OVERLAY:String= "ViewController.STATE_OVERLAY";
		public static const STATE_END:String 	= "ViewController.STATE_END";
		
		protected var stage:Sprite;
		protected var config:ConfigVO;
		protected var views:Object;
		public var isFullscreen:Boolean = false;
		protected var state:String = STATE_START;
		
		// views
		public var playerView:PlayerView;
		//public var controlsView:ControlsView;
		//public var subtitleView:SubtitleView;
		/* protected var shareView:ShareView;
		protected var mailView:MailView;
		protected var endView:EndView; */
		
		public var currentView:String;
		
		public function ViewController( stage:Sprite )
		{
			super( this );
			
			this.stage = stage;
			this.views = new Object();
			
			this.init();
			
			this.resize();
			
			this.showView( PlayerView.NAME );
		}
		
		protected function init() :void
		{
			var s:Sprite;
			
			s = new Sprite();
			this.stage.addChild( s );
			this.playerView = new PlayerView( s );
			this.playerView.addEventListener( ControlEvent.PLAY, onPlay );
			this.playerView.addEventListener( ControlEvent.ERROR_CLICK, onErrorClick );
			
			if(BildTvDefines.size == BildTvDefines.SIZE_BIG || BildTvDefines.size == BildTvDefines.SIZE_MEDIUM)
			{
				s = new Sprite();
				this.stage.addChild( s );
				//this.subtitleView = new SubtitleView(s);
			}
			
			s = new Sprite();
			this.stage.addChild( s );
			/*this.controlsView = new ControlsView( s );
			this.controlsView.addEventListener( ControlEvent.PLAYPAUSE_CHANGE, forwardControlEvent );
			this.controlsView.addEventListener( ControlEvent.PROGRESS_CHANGE, forwardControlEvent );
			this.controlsView.addEventListener( ControlEvent.VOLUME_CHANGE, forwardControlEvent );
			this.controlsView.addEventListener( ControlEvent.BUTTON_CLICK, forwardControlEvent );
			this.controlsView.addEventListener( ControlEvent.BUTTON_OUT, forwardControlEvent );
			this.controlsView.addEventListener( ControlEvent.BUTTON_OVER, forwardControlEvent );*/
			
			// add views under their NAME property to hashmap - skip ControlsView because it's always visible
			this.views[ PlayerView.NAME ] = this.playerView;
			//this.views[ ShareView.NAME ] = this.shareView;
			//this.views[ MailView.NAME ] = this.mailView;
			//this.views[ EndView.NAME ] = this.endView;
		}
		
		public function setConfig( config:ConfigVO ) :void
		{
			this.config = config;
			
			if( this.config.srtUrl == "" || BildTvDefines.isEmbedPlayer )
			{
				this.config.skinVO.styleSubtitleBtn = null;	
				this.config.skinVO.styleSubtitleBox = null;	
			} 
			else if( this.config.skinVO.styleSubtitleBtn == null )
			{
				this.config.skinVO.styleSubtitleBtn = this.config.skinVO.styleFullscreenBtn;
			}
			
			if( this.config.videoVO.videoUrl.indexOf(".f4m") == -1 || this.config.videoVO.hdAdaptive == true)
			{
				this.config.skinVO.styleHDBtn = null;	
			} 
		
			// check if it's a movie player - if so, disable feature buttons			
			/*if( this.config.filmVO != null )
			{				
				this.controlsView.setSkin( this.config.skinVO, this.config.adTextTextVO, true );
			}
			else if( this.config.streamingVO != null )
			{				
				this.controlsView.setSkin( this.config.skinVO, this.config.adTextTextVO, false );
			}
			else if( BildTvDefines.size == BildTvDefines.SIZE_MICRO )
			{				
				this.controlsView.setSkin( this.config.skinVO, this.config.adTextTextVO, false );
			}
			else
			{ 
				if( true)//this.config.skinVO.skinStatus )
				{
					//this.playerView.setSkin( this.config.skinVO );
				
					//this.shareView.setSkin( this.config.skinVO );
					//this.mailView.setSkin( this.config.skinVO );
					//this.endView.setSkin( this.config.skinVO );	
				}
				
				this.controlsView.setSkin( this.config.skinVO, this.config.adTextTextVO, (!BildTvDefines.isWeltPlayer && this.config.shareVO.shareStatus) );
			}*/
			
			/*if(BildTvDefines.size == BildTvDefines.SIZE_BIG || BildTvDefines.size == BildTvDefines.SIZE_MEDIUM)
			{
			 	if( this.subtitleView ) 
			 	{
				 	this.subtitleView.init( this.config.srtUrl, this.config.skinVO.styleSubtitleBox );
				 	this.subtitleView.ui.visible = false;	 		
			 	}
			}*/
            	
			this.state = STATE_START;
			
			this.playerView.setSkin( this.config.skinVO );
			
			this.resize();
		}



        /*public function externFullscreenChange( state:Boolean) :void
		{
			if( this.state != STATE_PLAY )
			{
				this.controlsView.dispatchEvent( new ControlEvent( ControlEvent.PLAYPAUSE_CHANGE ) );
			}
			
			this.showView( PlayerView.NAME );
			
			this.setFullscreen(state);
		}

        public function fullscreenChange( e:Event = null ) :void
		{
			if( this.state != STATE_PLAY )
			{
				this.controlsView.dispatchEvent( new ControlEvent( ControlEvent.PLAYPAUSE_CHANGE ) );
			}
			
			this.showView( PlayerView.NAME );
			
			this.setFullscreen( !this.isFullscreen );
		}*/
		
		public function showView( name:String ) :void
		{
			this.currentView = name;
			
			for( var id:String in this.views )
			{
				if( id == name )
				{
					//BaseView( this.views[ id ] ).show();
					
				}
				else
				{
					//BaseView( this.views[ id ] ).hide();
					
				}
			}
			
			switch( name )
			{
				case PlayerView.NAME:
				{
					this.state = STATE_PLAY;
					break;
				}
			}
		}
		
		public function resize() :void
		{
			// this.controlsView.resizeControls( this.stage.stage.displayState );
			this.playerView.resize();
			//this.shareView.resize();
			//this.mailView.resize();
			//this.endView.resize();
			
			// this.controlsView.y = BildTvDefines.height - BildTvDefines.HEIGHT_CONTROLS;
		}
		
		protected function onFullscreenExit( e:Event ) :void
		{
			this.setFullscreen( false );
		}
		
		protected function setFullscreen( fullscreen:Boolean ) :void
		{
			if( this.isFullscreen == fullscreen )
			{
				return;
			}
			
			this.isFullscreen = fullscreen;
			
			if( fullscreen )
			{
				this.stage.stage.displayState = StageDisplayState.FULL_SCREEN;
				this.stage.stage.addEventListener( Event.RESIZE, onFullscreenExit );
				
				//this.controlsView.hide();
				this.playerView.setDisplaySizeFullscreen();
			}
			else
			{
				this.stage.stage.displayState = StageDisplayState.NORMAL;
				this.stage.stage.removeEventListener( Event.RESIZE, onFullscreenExit );
				
				// this.controlsView.show();
				this.playerView.setDisplaySizeDefault();
			}
		}
		
		protected function onViewClose( e:ControlEvent ) :void
		{
			switch( this.state )
			{
				default:
				{
					this.showView( PlayerView.NAME );
					break;
				}
			}
		}
		
		protected function onPlay( e:ControlEvent ) :void
		{
			this.state = STATE_PLAY;
			this.showView( PlayerView.NAME );
		}
		
		protected function onErrorClick( e:ControlEvent ) :void
		{
			var js:String = "javascript:location.reload();";
			try
			{
				navigateToURL( new URLRequest( js ), "_self" );
			}
			catch( oops:Error )
			{
				// nix
			}
		}
	}
}