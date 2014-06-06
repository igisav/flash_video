package
{
	import de.axelspringer.videoplayer.controller.MainController;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	[SWF(backgroundColor="0xEEEEEE")]
	public class BildTvMain extends Sprite
	{
		protected var mainController:MainController;
		
		public function BildTvMain()
		{
			Log.setCustomPrefix("[BildTv]");
			//Log.logLevelFilter = Log.LEVEL_DEBUG;
			Log.logLevelFilter = Log.LEVEL_NONE;
			
			BildTvDefines.releaseNumber = "r3304";
			
			//BildTvDefines.develMode = BildTvDefines.DEVELMODE_STAGE;
			//BildTvDefines.develMode = BildTvDefines.DEVELMODE_EMBED;
			
			// set to true for GMX adcalls, otherwise false
			
			Security.allowDomain( "*" );
			
			BildTvDefines.isGmxPlayer = false;
			
			if( this.stage == null )
			{
				this.addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			}
			else
			{
				this.init();
			}
		}
		
		protected function init() :void
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;	
			
			this.checkDebugSetting();
						
			
			try
			{
				var refString:String = ExternalInterface.call("com.xoz.videoplayer.getVersion");
				
				if( refString != null && refString != "" && refString.indexOf("%") == -1 )
				{
					BildTvDefines.releaseNumber = refString;
				}
				
				BildTvDefines.url = ExternalInterface.call( "function(){ return window.location.href.toString() }" );
				BildTvDefines.urlLong = BildTvDefines.url;
				BildTvDefines.isScriptAccessAllowed = true;
				
				if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('ausgeführt auf: " + BildTvDefines.url+"');}");
				if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('swf geladen von: " + this.loaderInfo.url+"');}");
			}
			catch(e:Error)
			{
				//catch( err:SecurityError )
				BildTvDefines.isScriptAccessAllowed = false;
				Log.debug("ExternalInterface error, url von " + this.loaderInfo.url);
			}
			
			if( BildTvDefines.url == null )
			{
				BildTvDefines.url = "";
				BildTvDefines.urlLong = "";
			}
			
			if( BildTvDefines.url != "" )
			{
				if( BildTvDefines.url.indexOf("http://") != 0 )
				{
					BildTvDefines.url = "http://" + BildTvDefines.url;
				}
				
				BildTvDefines.url = BildTvDefines.url.substr( 0, BildTvDefines.url.indexOf( "/", 7 ) );
			}
			
			if( this.loaderInfo.parameters.type != null && this.loaderInfo.parameters.type != "" && this.loaderInfo.parameters.type != undefined )
			{
				BildTvDefines.playerType = this.loaderInfo.parameters.type;		
			}
			
			Log.debug( "BildTvDefines.url = " + BildTvDefines.url + " js URL:" + this.loaderInfo.parameters.jsurl );
			
			
			if( this.loaderInfo.parameters.id )
			{
				BildTvDefines.isEmbedPlayer = false;
				//this.checkEmbeddedStatus();			
				BildTvDefines.playerId = this.loaderInfo.parameters.id;
				
			}
			else
			{
				BildTvDefines.isEmbedPlayer = true;
			}
			
			trace("BildTvDefines.isEmbedPlayer: " + BildTvDefines.isEmbedPlayer);
			
			
			if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('isEmbedPlayer: " + BildTvDefines.isEmbedPlayer+"');}");
			
			this.mainController = new MainController( this );
			this.mainController.init( this.loaderInfo.parameters.xmlurl, this.loaderInfo.parameters.cssurl, this.loaderInfo.parameters.jsurl, this.loaderInfo.parameters.adtype, this.loaderInfo.parameters.autoplay, this.loaderInfo.parameters.time);
					
			var playerName:String = "";
			//Log.debug("............try to get long URL: " +  BildTvDefines.urlLong);
			try
			{
				if( BildTvDefines.urlLong.indexOf("computerbild") != -1 )
				{
					playerName = "Computer Bild Player";
				}
				else if( BildTvDefines.urlLong.indexOf("autobild") != -1 )
				{
					playerName = "Auto Bild Player";
				}
				else if( BildTvDefines.urlLong.indexOf("bild") != -1 )
				{
					playerName = "Bild Player";
				}
				else if( BildTvDefines.urlLong.indexOf("welt") != -1 )
				{
					playerName = "Welt Player";
					//Log.debug("setWelt = true");
					BildTvDefines.isWeltPlayer = true;
				}
				else if( BildTvDefines.urlLong.indexOf("morgenpost") != -1 )
				{
					BildTvDefines.isWeltPlayer = true;
					playerName = "Morgenpost Player";
				}
				else if( BildTvDefines.urlLong.indexOf("abendblatt") != -1 )
				{
					BildTvDefines.isWeltPlayer = true;
					playerName = "Abendblatt Player";
				}
				
				Log.debug("check " + BildTvDefines.urlLong + " for player version");			
			}
			catch(e:Error)
			{
				Log.debug(this+"Kein Scriptaccess!");
			}
			
			
			// add release number to context menu
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			menu.customItems.push( new ContextMenuItem( playerName + " " +  BildTvDefines.releaseNumber, true, false ) );
			this.contextMenu = menu;
		}
		
		private function checkEmbeddedStatus():void
		{
			/* we now use a whitelist to determine embedded players
			domains that are never embedded:
				"morgenpost.de"
				"computerbild.de"
				"autobild.de"
				"welt.de"
				"bild.de"
			all other domains are embedded
			*/
			
			// this regex searches a "://" or "." followed by one of the whitelist domain-names followed by ".de" and no more letters after that
			// it's important that the url was manipulated before so that it only contains the domain and no document path
			// match: http://bild.de
			// match: www.bild.de
			// no match: http://bild.de/
			// no match: http://dingsbild.de
			var regEx:RegExp = new RegExp( "(://|\.)(bild|welt|autobild|computerbild|morgenpost|abendblatt|xoz|exozet)\.de$" );
			// if the test is true, we are on a whitelist domain, if it's false, we have an embedded player
			BildTvDefines.isEmbedPlayer = !regEx.test( BildTvDefines.url );
		}
		
		protected function addedToStage( e:Event ) :void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
			this.init();
		}
		
		protected function checkDebugSetting() :void
		{
			BildTvDefines.debugFlag = (this.loaderInfo.parameters.debug == "true") ? true : false;  //set false again!!
			try
			{
				var url:String = ExternalInterface.call( "function(){ return window.location.href.toString() }" );
				if( url.indexOf( "debug=true" ) > -1 )
				{
					Log.logLevelFilter = Log.LEVEL_DEBUG;
					Log.debug( this + " set logLevelFilter because of url parameter" );
				}
				else
				{
					if( this.loaderInfo.parameters.debug == "1" || this.loaderInfo.parameters.debug == "true" )
					{
						Log.logLevelFilter = Log.LEVEL_DEBUG;
						Log.debug( this + " set logLevelFilter because of flashvar" );
					}
				}
			}
			catch( error:Error )
			{
				// nada
			}
		}
	}
}