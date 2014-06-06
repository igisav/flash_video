package de.axelspringer.videoplayer.controller
{
	import de.axelspringer.videoplayer.event.*;
	import de.axelspringer.videoplayer.model.vo.*;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	import de.axelspringer.videoplayer.ui.LoaderAni;
	import de.axelspringer.videoplayer.ui.controls.ControlButton;
	import de.axelspringer.videoplayer.util.*;
	import de.axelspringer.videoplayer.view.PlayerView;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.text.StyleSheet;
	import flash.utils.Timer;
	import flash.utils.getQualifiedSuperclassName;
	
	public class MainController
	{
		protected var xmlInitialized:Boolean;
		protected var jsInitialized:Boolean;
		protected var cssInitialized:Boolean;
		protected var cssUrl:String = "";
		protected var root:Sprite;
		protected var stage:Sprite;
		protected var loaderAni:LoaderAni;
//		protected var errorUi:ErrorUi;
		protected var config:ConfigVO;
		
		protected var relatedXmlsLoaded:uint;
		
		private static const CALLBACK_SUBTITLE_ON:String		= "SUBTITLE_ON";
		private static const CALLBACK_SUBTITLE_OFF:String		= "SUBTITLE_OFF";
		private static const CALLBACK_SET_XML:String			= "SET_XML";
		
		
		// controller
		protected var playerController:PlayerController;
		protected var viewController:ViewController;
			
		public function MainController( root:Sprite )
		{
			this.root = root;
			this.stage = new Sprite();
			this.stage.addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			
			this.root.addChild( this.stage );			
		}
		
		protected function addedToStage( e:Event ) :void
		{
			this.stage.removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
			
			this.setSize();
			
			this.loaderAni = new LoaderAni();
			this.root.addChild( this.loaderAni );
			
			this.root.stage.addEventListener( Event.RESIZE, onStageResize );
		}
		
		protected function forwardControlEvent( e:ControlEvent ) :void
		{
			this.viewController.dispatchEvent( new ControlEvent( e.type, e.data ) );
		}
		
		
		protected function registerExternalCallbacks(event:Event = null):void 
		{
			trace("ExternalInterface:" + ExternalInterface.available);
    		if (ExternalInterface.available) 
			{
	    		try
				{
					
					ExternalInterface.addCallback("apiCall", apiCall);
					ExternalInterface.addCallback("askForPlayingStatus", externalGetPlayingStatus);
					
					ExternalInterface.call("com.xoz.flash_logger.logTrace","SETTED CALLBACKS");
					
					ExternalInterface.call("com.xoz.flash_logger.logTrace","---------SEND READY SIGNAL------------------External is Available=" + ExternalInterface.available);
//					var xml:String = ExternalInterface.call("com.xoz.videoplayer.getXMLString", BildTvDefines.playerId) as String;								
			
					var xml2:String= ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","videoplayer/flashplayer/ready", {'id': BildTvDefines.playerId});							
//					this.setXMLByJSCall(xml);
					
				}
				catch(e:Error)				
				{
					trace("Error by adding callback");
					ExternalInterface.call("com.xoz.flash_logger.logTrace","ERROR SET CALLBACKS");
				}
			}
			else
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","TRY SET CALLBACKS");
			}
		}
				
		public function init( startXmlURL:String ="", cssURL:String="", jsURL:String="", adType:String="", autoplay:String="", time:Number = 0 ) :void
		{
			this.xmlInitialized = false;
			this.cssInitialized = false;
			this.jsInitialized = false;
				
			this.config = new ConfigVO();
			
			try
			{
				this.registerExternalCallbacks();
			}
			catch (error:Error)
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","ERROR BY SETTING CALLBACKS");
			}
			
			// to load relative linked stuff in the embed-player, we need absolute urls
			// bild.de wants us to use the url of the xml to generate absolute links
			// as this url may also be relative, let LinkUtil decide what to use
			trace(this + " XML: " + startXmlURL);
			
			//set type of Ad, playing first,
			BildTvDefines.adType = adType;
			
			if(!isNaN(time))
			{
				BildTvDefines.startTime = time;			
			}
			
			//Prio1: get Autoplay from Flashvars, Prio2: get Autoplay from video.xml if autoplaySet is false
			if(autoplay != null)
			{
				BildTvDefines.autoplay = (autoplay == "true") ? true : false;	
				BildTvDefines.autoplaySet= true;	
			}			
			
			if(startXmlURL!= null && startXmlURL != "")
			{
				//trace("video xml load: " + startXmlURL);
				LinkUtil.setServerFromUrl( startXmlURL );
				this.loadXml( startXmlURL );
			}
			else
			{
//				this.xmlInitialized = true;
			}
			//trace(" css load: " + cssURL);
			if(cssURL!= null && cssURL != "")
			{
				this.cssUrl = cssURL.substring(0,cssURL.lastIndexOf("/") + 1);
				this.loadCSS(cssURL);
			}
			else
			{
				this.cssLoaded();
				//this.cssInitialized = true;
			}
			//trace(" js load: " + jsURL);
			
			if(jsURL!= null && jsURL != "" && cssURL!= null && cssURL != "")
			{
				this.loadJS(jsURL, cssURL);	
				//BildTvDefines.isEmbedPlayer = true;
			}
			else
			{
//???				if( BildTvDefines.isEmbedPlayer != true )BildTvDefines.isEmbedPlayer = false; //zuvor durch ScriptaccessAbfrage geklärt bei FB
				this.jsInitialized = true;
				this.start();
			}			
		}

/************************************************************************************************
 * APP CONTROL
 ************************************************************************************************/
		
		private var readySignalsended:Boolean = false;
		private var readytimer:Timer = new Timer(2000,5);
		
		protected function start() :void
		{
			var consolstring:String = "Starte den Player. Daten geladen? xml js css:"+ this.xmlInitialized +"..."+this.jsInitialized +"..."+this.cssInitialized + "  ready send? " + this.readySignalsended;
			
//			ExternalInterface.call("com.xoz.flash_logger.logTrace",consolstring);
           			
			if( false == this.readySignalsended && true == this.jsInitialized && true == this.cssInitialized)
			{
				this.readySignalsended = true;
				var userAgent:String = ExternalInterface.call("function(){return navigator.userAgent}")
//				ExternalInterface.call("com.xoz.flash_logger.logTrace","USE TIMER WHEN IE8 IS USED: " + userAgent);
					
				if(false)//userAgent == null)
				{
//					ExternalInterface.call("com.xoz.flash_logger.logTrace","START TIMER BECAUSE IE8");
					/*this.readytimer.addEventListener(TimerEvent.TIMER, onTimerTick);
					this.readytimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					this.readytimer.start();		*/	
				}
				else
				{
	/*				ExternalInterface.call("com.xoz.flash_logger.logTrace","---------SEND READY SIGNAL------------------External is Available=" + ExternalInterface.available);
					var xml:String = ExternalInterface.call("com.xoz.videoplayer.getXMLString", BildTvDefines.playerId) as String;								
					var xml2:String = ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","videoplayer/flashplayer/ready", {'id': BildTvDefines.playerId});								
					ExternalInterface.call("com.xoz.flash_logger.logTrace","GOT IT WITHOUT CALLBACK: " + xml)
					this.setXMLByJSCall(xml);*/
				
				}
			}	
			
			if( true == this.xmlInitialized && true == this.jsInitialized && true == this.cssInitialized)
			{
//				ExternalInterface.call("com.xoz.flash_logger.logTrace","Embed: " + BildTvDefines.isEmbedPlayer);
								
				if( true == BildTvDefines.isEmbedPlayer )
				{
					var id:String 		= BildTvDefines.playerId;
					try
					{
						ExternalInterface.call("project_objects.StateManger.setWidth", id, root.stage.stageWidth);		
					}
					catch(e:Error)
					{
					}
				}
			
				this.initMode();
				
				for (var i:int = 0; i < this.config.ads.length; i++) 
				{	
					if( this.config.ads[i].club == "default" )
					{
						this.config.adVO = this.config.ads[i];
						break;
					}
					else
					{
						var adPossible:Boolean = ExternalInterface.call("de.bild.user.userHasClub",this.config.ads[i].club);
						
						//ExternalInterface.call("function(){if (window.console) console.log('club is ok? : "+this.config.ads[i].club + ": " + adPossible+"');}");
						if( adPossible )
						{
							this.config.adVO = this.config.ads[i];
							break;
						}					
					}
				}
//				if( this.config.adVO ) ExternalInterface.call("com.xoz.flash_logger.logTrace","AD CALL CHOOSEN: id:" + this.config.adVO.club);
				
				this.initController();
				this.update();	
			}
			
		}
		
		protected function setXMLByJSCall(xml:String):void
		{
//			ExternalInterface.call("com.xoz.flash_logger.logTrace","GET XML FILE IN FLASH ");
			var videoXml:XML = XML(unescape(String(xml)));
			this.setLoaderAniVisibility( false );	
			this.config.xmlUrl = "";				
			this.config.hydrate( videoXml );
			ExternalInterface.call("com.xoz.flash_logger.logTrace","GET XML FILE IN FLASH ,SRC IS: " + this.config.videoVO.videoUrl);
			
//			if(this.config.videoVO.videoUrl != "")
			{
				this.xmlInitialized = true;
				
				this.start();			
			}
		}
				
		/********************************************************************************************************
		 * EXTERNAL CALLBACKS
		 *******************************************************************************************************/
						
		protected function apiCall(type:String, params:Object = null ):void
		{
			trace("Type:" + type + "    params: " + params);
//			ExternalInterface.call("com.xoz.flash_logger.logTrace","Type:" + type + "    params: " + params);
			
			switch(type)
			{			
				case CALLBACK_SET_XML:
				{
					var xml:String = params.xml;
					
					ExternalInterface.call("com.xoz.flash_logger.logTrace","GOT IT WITH CALLBACK: " + xml)
					this.setXMLByJSCall(xml);
					break;
				}
				/*case CALLBACK_SUBTITLE_OFF:
				{
					if( this.viewController.subtitleView ) this.viewController.subtitleView.ui.visible = false;
					break;
				}
				case CALLBACK_SUBTITLE_ON:
				{
					if( this.viewController.subtitleView ) this.viewController.subtitleView.ui.visible = true;
					break;
				}*/
				default:
				{
					if( this.playerController ) this.playerController.apiCall(type,params);
					break;
				}
			}
		}
		
		protected function externalGetPlayingStatus():Boolean
		{
			return this.playerController.externalGetPlayingStatus();
		}
		
		protected function setSize() :void
		{
			BildTvDefines.width = this.stage.stage.stageWidth;
			BildTvDefines.height = this.stage.stage.stageHeight;
			
			if( BildTvDefines.width < BildTvDefines.WIDTH_MINIMUM )
			{
				BildTvDefines.size = BildTvDefines.SIZE_MICRO;
			}
			else if( BildTvDefines.width < BildTvDefines.WIDTH_ARTICLE )
			{
				BildTvDefines.size = BildTvDefines.SIZE_MINI;
			}
			else if( BildTvDefines.width < BildTvDefines.WIDTH_BIG)
			{ 
				BildTvDefines.size = BildTvDefines.SIZE_MEDIUM;
			}
			else
			{
				BildTvDefines.size = BildTvDefines.SIZE_BIG;
			}
		}
		
		protected function initMode() :void
		{
			if( BildTvDefines.isEmbedPlayer )
			{
				BildTvDefines.mode = BildTvDefines.MODE_EMBED;
			}
			else
			{
				BildTvDefines.mode = BildTvDefines.MODE_STAGE;
			}
	
			trace( this + " mode => " + BildTvDefines.mode );
		}
		
		protected function initController() :void
		{
			this.viewController = new ViewController( this.stage );
			this.viewController.addEventListener( ControlEvent.TEASER_CLICK, onTeaserClick );
			this.viewController.addEventListener( ControlEvent.BUTTON_CLICK, onControlButtonClick );
			this.viewController.addEventListener( ControlEvent.BUTTON_OVER, onControlButtonClick );
			this.viewController.addEventListener( ControlEvent.BUTTON_OUT, onControlButtonClick );
			this.viewController.addEventListener( ControlEvent.REPLAY, onReplayClick );
			
			this.playerController = new PlayerController( this.viewController.playerView, this.viewController.controlsView); //, this.viewController.subtitleView
            this.playerController.addEventListener( ControlEvent.ERROR, onError );
			this.playerController.addEventListener( ControlEvent.ERROR_AVAILABLE, onErrorAvailable );
			this.playerController.addEventListener( ControlEvent.ERROR_GEO, onErrorGeo );
			this.playerController.addEventListener( ControlEvent.VIDEO_FINISH, onVideoFinish );
			this.playerController.addEventListener( ControlEvent.LOADERANI_CHANGE, onShowLoaderAni );
			this.playerController.setVolume( 0.5 );
			
			//this.subtitleController = new SubtitleController( this.viewController.playerView, this.viewController.controlsView );
		}
		
		protected function update() :void
		{ 
			if(BildTvDefines.size == BildTvDefines.SIZE_MICRO)
			{
				//this.config.endScreenEnabled = false;	
			}
			this.viewController.showView( PlayerView.NAME );
			this.viewController.setConfig( this.config );
			
			// set LoaderUi skinning
			var styleObjectLoader:SkinBaseVO = this.config.skinVO.styleLoader;
			if( styleObjectLoader != null )
			{
				this.loaderAni.setSkin( styleObjectLoader);
			}
			
			// different action depending on type of player - video player vs. movie player vs. live player
			if( this.config.filmVO != null )
			{
				BildTvDefines.isMoviePlayer = true;
				BildTvDefines.isTrailerPlayer = this.config.filmVO.isTrailer();
				// force STAGE mode to enable correct tracking
				BildTvDefines.mode = BildTvDefines.MODE_STAGE;
				this.playerController.setMovie( this.config.filmVO );
			}
			else if( this.config.streamingVO != null )
			{
				BildTvDefines.isStreamPlayer = true;
				BildTvDefines.isLivePlayer = this.config.streamingVO.isLivestream;
				// force STAGE mode to enable correct tracking
				BildTvDefines.mode = BildTvDefines.MODE_STAGE;
				//this.playerController.setStream( this.config.streamingVO );
				
				var videoVO:VideoVO=new VideoVO();
				videoVO.videoUrl=this.config.streamingVO.streamUrl;
				videoVO.videoUrl2=this.config.streamingVO.streamUrl2;
				videoVO.duration=this.config.streamingVO.duration;
				videoVO.autoplay=this.config.streamingVO.autoplay;
				
				this.playerController.setClip( videoVO, this.config.adVO );
				
				if( true == BildTvDefines.isEmbedPlayer ) this.loadRelatedXml();
			}
			else
			{
				/*
				*
				* To Do
				* check if videoURL Exception Handling is implemented. 
				* for example if the videoURl Param is not set but the videoULR2 Param is set. 
				* how does the script handle that issue
				*
				*/
				
				//Call Error when videoUrl and videoUrl2 is not set
				if(this.config.videoVO.videoUrl == "" && this.config.videoVO.videoUrl2 == "")
				{
					trace("NO SRC SET, BUT ONLY IN IE8?");
					ExternalInterface.call("com.xoz.flash_logger.logTrace","NO SRC SET, BUT ONLY IN IE8?");
					
//					if(this.config.xmlUrl != "")
					{
						this.showError( true, BildTvDefines.TEXT_ERROR_HEADER, BildTvDefines.TEXT_ERROR_INFO_INVALID, "INVALID" );				
					}
/*					else
					{
						ExternalInterface.call("com.xoz.flash_logger.logTrace","TRY AGAIN, BUT ONLY IN IE8?");
					}*/
					return;
				}
				
				//set videoURL2 for videoURL when videoURL2 is set and and videoURL not
				if(this.config.videoVO.videoUrl == "" && this.config.videoVO.videoUrl2 != "")
				{
					this.config.videoVO.videoUrl = this.config.videoVO.videoUrl2;
				}
				 
				
				
				this.playerController.setClip( this.config.videoVO, this.config.adVO );
						
				if( true == BildTvDefines.isEmbedPlayer ) this.loadRelatedXml();
			}
		}
				
/************************************************************************************************
 * CSS HANDLING
 ************************************************************************************************/
 		
 		private function loadCSS(cssURL:String):void
		{
			var cssLoader:URLLoader = new URLLoader();
		   cssLoader.load(new URLRequest(cssURL));   
		   cssLoader.addEventListener(Event.COMPLETE, cssLoaded);
		   cssLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			
		}
		
		private function cssLoaded(e:Event = null):void
		{
			
			ExternalInterface.call("com.xoz.flash_logger.logTrace","CSS File geladen");
			var css:StyleSheet = new StyleSheet();
 			var rex:RegExp = /[\s]/gim;	
			var cssString:String = BildTvDefines.FALLBACK_CSS.replace(rex,"");;//String(e.target.data).replace(rex,"");
      		
			cssString = cssString.split("!important").join("");
         	
			css.parseCSS(cssString);
  		 	this.config.skinVO.cssStyles = css;
   			
			var urlPart:String = String(css.getStyle(".exozet-css.vjs-controls>div").backgroundImage);			
			var spriteUrl:String = urlPart.substring(urlPart.indexOf("url(") + 4,urlPart.indexOf(")"));
   			spriteUrl = spriteUrl.split("\"").join("");
   			
			if( spriteUrl.indexOf("http://") == -1 && spriteUrl.charAt(0) != "/" )//relative
   			{
   				spriteUrl = this.cssUrl + spriteUrl;			   
   			}
   			else if(spriteUrl.charAt(0) == "/")
   			{
   				if(BildTvDefines.url.indexOf("file:")!= -1 )
				{
	   				spriteUrl = this.cssUrl.substring(0,this.cssUrl.indexOf(".de/")+3) + spriteUrl;					
				}
				else
				{
					spriteUrl = BildTvDefines.url + spriteUrl;						
				}
   			}
			
   			this.loadSprite();//spriteUrl);		
   		}
		
		
		
		private function loadSprite(spriteUrl:String = ""):void
		{
			if( spriteUrl != "" )
			{
				var loader:Loader = new Loader();
				var context : LoaderContext = new LoaderContext();
	   			context.checkPolicyFile = true;
	   			
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				loader.load(new URLRequest(spriteUrl),context);	
			}
			else
			{
				onImageReady();
			}
		}

		
		[Embed(source="/embed/assets.swf", symbol="FallbackSpriteSheet")]
		private var FallbackSpritesheet:Class;
		
		private function onImageReady(event:Event = null):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","Spritesheet geladen");
           
			var IconsBD:*;
			if(event != null)
			{
				event.target.loader.contentLoaderInfo.removeEventListener(Event .COMPLETE, onImageReady);
				IconsBD = event.target.loader.contentLoaderInfo.content.bitmapData;
			}
			else
			{
				IconsBD = new FallbackSpritesheet().bitmapData;
			}
			
			this.config.skinVO.cssSprite = IconsBD;				
			this.cssInitialized = true;
			this.start();
		}
		
		
		private function onLoadError(ioError:IOErrorEvent):void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","Spritesheet nicht geladen:" +ioError.text);
		}
		
		
		
/************************************************************************************************
 * JS HANDLING
 ************************************************************************************************/
		
		private function loadJS(jsURL:String, cssURL:String):void
		{
			/* var jsLoader:URLLoader = new URLLoader();
			jsLoader.load(new URLRequest(jsURL));   
		   	jsLoader.addEventListener(Event.COMPLETE, jSLoaded);
		   	jsLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError); */	
		   	try
			{
			   	ExternalInterface.call("function(){var head= document.getElementsByTagName('head')[0]; var script=document.createElement('script'); script.type='text/javascript'; script.src='"+ jsURL +"'; head.appendChild(script);}");
			   	ExternalInterface.call("function(){var head= document.getElementsByTagName('head')[0]; var link=document.createElement('link'); link.type='text/css'; link.rel='stylesheet'; link.href='"+ cssURL +"'; head.appendChild(link);}");
				var jsInitTimer:Timer = new Timer(1000,1);	
				jsInitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onInitJS);
				jsInitTimer.start();
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
				this.jsInitialized = true;
			}	 
			//trace("start timer..");
		}
       
 		private function onInitJS(e:TimerEvent):void
		{
			try
			{
				ExternalInterface.call("function(){project_objects.StateManger = new project.StateManager();}");
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			this.jsInitialized = true;
			this.start();
		}
 
 
 
/************************************************************************************************
 * XML HANDLING
 ************************************************************************************************/
 
 		protected function loadXml( url:String ) :void
		{
			//trace( this + " loadXml: " + url );
			
			this.setLoaderAniVisibility( true );

			var xmlLoader:XmlLoader = new XmlLoader();
			xmlLoader.addEventListener( XmlEvent.XML_LOADED, onXmlLoaded, false, 0, true );
			xmlLoader.addEventListener( XmlEvent.XML_ERROR, onXmlError, false, 0, true );
			xmlLoader.loadXml( url );
		}
		
		protected function onXmlLoaded( e:XmlEvent ) :void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","XML geladen");
			
			this.setLoaderAniVisibility( false );
			
			
			this.config.xmlUrl = LinkUtil.absoluteLink( e.url );
			
			this.config.hydrate( e.xml );
			
			this.xmlInitialized = true;
				
			this.start();
		}
		
		protected function onXmlError( e:XmlEvent ) :void
		{
			trace( "onXmlError: " + e.text );
			
			this.setLoaderAniVisibility( false );
			
			this.showError( true, BildTvDefines.TEXT_ERROR_HEADER, BildTvDefines.TEXT_ERROR_INFO_DEFAULT );		
		}
		
		protected function loadRelatedXml() :void
		{
			//trace( this + " loadRelatedXml: " + this.config.relatedXml );
			
			var xmlLoader:XmlLoader = new XmlLoader();
			xmlLoader.addEventListener( XmlEvent.XML_LOADED, onRelatedXmlLoaded, false, 0, true );
			xmlLoader.addEventListener( XmlEvent.XML_ERROR, onRelatedXmlError, false, 0, true );
			xmlLoader.loadXml( this.config.relatedXml );
		}
		
		protected function onRelatedXmlLoaded( e:XmlEvent ) :void
		{
			//trace( "onRelatedXmlLoaded" );
			this.config.hydrateTeaserXml( e.xml );
			this.relatedXmlsLoaded = 0;
			
			if( this.config.relatedVideos != null && this.config.relatedVideos.length != 0 )
			{
				for( var i:uint = 0; i < this.config.relatedVideos.length; i++ )
				{
					this.loadRelatedVideoXml( TeaserVO( this.config.relatedVideos[i] ).xml );
				}
			}
			else
			{
				this.checkRelatedVideosComplete( true );
			}
		}
		
		protected function onRelatedXmlError( e:XmlEvent ) :void
		{
			trace( "onRelatedXmlError: " + e.text );
		}
		
		protected function loadRelatedVideoXml( url:String ) :void
		{
			var xmlLoader:XmlLoader = new XmlLoader();
			xmlLoader.addEventListener( XmlEvent.XML_LOADED, onRelatedVideoXmlLoaded, false, 0, true );
			xmlLoader.addEventListener( XmlEvent.XML_ERROR, onRelatedVideoXmlError, false, 0, true );
			xmlLoader.loadXml( url );
		}
		
		protected function onRelatedVideoXmlLoaded( e:XmlEvent ) :void
		{
			//trace( this + " onRelatedVideoXmlLoaded: " + e.url );
			
			var shareVO:ShareVO = new ShareVO();
			shareVO.hydrate( e.xml.share[0], null );
			
			var teaser:TeaserVO;
			for( var i:uint = 0; i < this.config.relatedVideos.length; i++ )
			{
				teaser = this.config.relatedVideos[i] as TeaserVO;
				if( teaser.xml == e.url )
				{
					teaser.deeplink = shareVO.deeplinkUrl;
					break;
				}
			}
			
			this.relatedXmlsLoaded++;
			this.checkRelatedVideosComplete();
		}
		
		protected function onRelatedVideoXmlError( e:XmlEvent ) :void
		{
			//trace( this + " onRelatedVideoXmlError: " + e.url );
			
			this.relatedXmlsLoaded++;
			this.checkRelatedVideosComplete();
		}
		
		protected function checkRelatedVideosComplete(ready:Boolean = false) :void
		{
			if( this.relatedXmlsLoaded == this.config.relatedVideos.length || ready )
			{
				if( true == BildTvDefines.isEmbedPlayer )
				{
					var id:String 		= BildTvDefines.playerId;
					var relatedArray:Array = this.config.relatedVideos;	
					ExternalInterface.call("com.xoz.flash_logger.logTrace","Set endscreen informations!"+relatedArray);
					
					try
					{
						//ExternalInterface.call("project_objects.StateManger.setEndscreenInformation", id , relatedArray );		
					}
					catch(e:Error)
					{
						trace("Kein Scriptaccess!");
					}
				}	
			}
		}
		
/************************************************************************************************
 * EVENTS
 ************************************************************************************************/
 
		protected function onTeaserClick( e:ControlEvent ) :void
		{
			trace( this + " onTeaserClick: " + e.data.deeplink );
			//this.loadXml( e.data.xml );
			
			try
			{
				navigateToURL( new URLRequest( e.data.deeplink ), "_self" );
			}
			catch( oops:Error )
			{
				// dumm gelaufen
			}
		}
		
		protected function onControlButtonClick( e:ControlEvent ) :void
		{
			//trace( this + " onControlButtonClick: " + e.data.type + "   " + e.type );
			
			switch( e.data.type )
			{
				case ControlButton.SUBTITLE:
				{	
					/*if( this.viewController.subtitleView.ui.visible )
					{
						this.playerController.trackingController.trackPlayerEvent("SUBTITLE_ON");		
					}
					else
					{
						this.playerController.trackingController.trackPlayerEvent("SUBTITLE_OFF");				
					}*/
					break;
				}
				case ControlButton.FULLSCREEN:
				{
					this.viewController.fullscreenChange();
					
					/*if( this.viewController.isFullscreen )
					{
						this.playerController.trackingController.trackPlayerEvent("FULLSCREEN_ON");		
					}
					else
					{
						this.playerController.trackingController.trackPlayerEvent("FULLSCREEN_OFF");				
					}*/
					
					break;
				}
				case ControlButton.HD:
				{
					var phase:Number = e.data.phase;
					this.playerController.setHDBitrate(phase);
					break;
				}
				case ControlButton.SHARE:
				{
										
					// movieplayer calls javascript, other players toggle the share overlay
					 if( BildTvDefines.isMoviePlayer )
					{
						if( e.type == ControlEvent.BUTTON_OVER )
						{
							try
							{
								ExternalInterface.call( this.config.filmVO.functionNameShare );
							}
							catch( error:Error )
							{								
								trace("Kein Scriptaccess!");
							}	
						}
					}
					else
					{
						try
						{
							if( e.type == ControlEvent.BUTTON_OUT )
							{
								//trace(ExternalInterface.call("project_objects.StateManger.hideLikeOverlay",BildTvDefines.playerId));
								ExternalInterface.call("project_objects.StateManger.hideLikeOverlay",BildTvDefines.playerId);		
							}
							if( e.type == ControlEvent.BUTTON_OVER )
							{	
								//ExternalInterface.call("Dojo.testCall","hide");
								//ExternalInterface.call("Dojo.myFunction", "Hide jetzt mal nicht den Player..");
							
								var url:String = BookmarkVO(this.config.shareVO.bookmarks[0]).url;
								ExternalInterface.call("project_objects.StateManger.showLikeOverlay",BildTvDefines.playerId, url);
							}
						}
						catch(e:Error)
						{
							trace("Kein Scriptaccess!");
						}
					}
					
					break;
				}
			}
		}

		protected function onVideoFinish( e:ControlEvent ) :void
		{
			ExternalInterface.call("com.xoz.flash_logger.logTrace","try to hide likeOverlay and show endscreen with id:"+BildTvDefines.playerId);
			
			try
			{
				//wait till all trackings are done
//				ExternalInterface.call("project_objects.StateManger.hideLikeOverlay",BildTvDefines.playerId);
//				ExternalInterface.call("project_objects.StateManger.showEndscreen",BildTvDefines.playerId);
				
				//this.playerController.trackingController.trackPlayerEvent("ENDSCREEN");
			}
			catch(e:Error)
			{
			}
		}
		
		protected function onReplayClick( e:ControlEvent ) :void
		{
			this.playerController.replay();
		}
		
		protected function onShowLoaderAni( e:ControlEvent ) :void
		{
			// data: { visible:true, stream:this.ns }
			this.setLoaderAniVisibility( e.data.visible, e.data.stream );
		}
		
		public function setLoaderAniVisibility( visible:Boolean, stream:NetStream = null ):void
		{
			this.loaderAni.bufferDisplay.netstream = stream;
			if (!this.config.videoVO.autorepeat)
			{
				this.loaderAni.visible = visible;			
			}
			else
			{
				//trace("playtype: " + this.playerController.clipType + "     adType:" + BildTvDefines.adType);
				this.loaderAni.visible = false;
			}

		}
		
		protected function openPopup() :void
		{
			//trace( this + " openPopup" );
			
			if( this.config.popupUrl != "" )
			{
				var target:String = "_blank";
				var url:String = this.config.popupUrl;
				
				if( url.toLowerCase().substr( 0, 11 ) == "javascript:" )
				{
					target = "_self";
					url += "void(0);";
				}
				
				//trace( "url: " + url + ", target: " + target );
				
				try
				{
					// open link
					navigateToURL( new URLRequest( url ), target );
					// stop clip
					this.playerController.pause();
				}
				catch( e:Error )
				{
					trace( this + " Error opening popup: " + e.getStackTrace() );
				}
			}
		}
		
		protected function onError( e:ControlEvent ):void
		{
			
			var header:String = ( e.data.header == null ) ? BildTvDefines.TEXT_ERROR_HEADER : e.data.header;
			var info:String = ( e.data.info == null ) ? BildTvDefines.TEXT_ERROR_INFO_DEFAULT : e.data.info;
			var button:Boolean = ( e.data.button == null ) ? true : e.data.button;
			
			this.showError( true, header, info );
		}
		
		protected function onErrorAvailable( e:ControlEvent ):void
		{
			
			var header:String = ( e.data.header == null ) ? BildTvDefines.TEXT_ERROR_HEADER : e.data.header;
			var info:String = ( e.data.info == null ) ? BildTvDefines.TEXT_ERROR_INFO_DEFAULT : e.data.info;
			var button:Boolean = ( e.data.button == null ) ? true : e.data.button;
			
			this.showError( true, header, info );
		}
		
		protected function onErrorGeo( e:ControlEvent) :void
		{ 
			var header:String = BildTvDefines.TEXT_ERROR_HEADER;
			var info:String = BildTvDefines.TEXT_ERROR_INFO_GEO;
			this.showError( true, header, info, "GEO" );
		}
		
		protected function showError( show:Boolean = true, headerText:String = "", infoText:String = "", errorType:String = "") :void
		{
			try
			{
				ExternalInterface.call("com.xoz.flash_logger.logTrace","Show Errorscreen :: Error String :: show Boolean = " + show.toString() + " ::  headerText = " + headerText + " :: infoText = " + infoText + " :: errorType = " + errorType);
				ExternalInterface.call("com.xoz.events.publish","videoplayer/video/error", {'id': BildTvDefines.playerId, 'message': infoText, 'type':errorType});				
				//this.playerController.trackingController.trackPlayerEvent("ERRORSCREEN");
			}
			catch(e:Error)
			{
				trace("Kein Scriptaccess!");
			}
			
			/* if(BildTvDefines.size == BildTvDefines.SIZE_MICRO)
			{
				this.errorUi.setText( headerText, infoText, false);	
			}
			else
			{
				this.errorUi.setText( headerText, infoText, relatedClips);
			}  */
			
		
			//this.errorUi.btnReplay.visible = showButton;
			//this.errorUi.visible = show;
		}
		
		protected function onErrorClick( e:MouseEvent ) :void
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
		
		protected function onStageResize( e:Event ) :void
		{
			this.setSize();
			
			//this.errorUi.resize();
			if( this.viewController != null )
			{
				this.viewController.resize();
			}
			this.loaderAni.resize();
		}
	}
}