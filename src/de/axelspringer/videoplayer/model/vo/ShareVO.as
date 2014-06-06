package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	/*
	<share deeplink="DEEPLINK-URL" swf="SWF-URL" embed="true">
		<bookmark url="SERVICE-URL" title="SERVICE-NAME" icon="ICON-URL" />
		<bookmark url="SERVICE-URL" title="SERVICE-NAME" icon="ICON-URL" />
	</share>
	*/
	
	public class ShareVO extends BaseVO
	{
		
		public var xmlUrl:String = "";
		
		/*Sharing Parameter*/
		private var _shareStatus:Boolean = true;
		public var deeplinkUrl:String = "";
		public var bookmarks:Array;
		
		/*Embed Parameter*/
		public var swfUrl:String = "";
		public var trackUrl:String = "";
		public var embedTrackUrl:String = "";
		public var embedEnabled:Boolean = true;
		
		public function ShareVO()
		{
			super();
			
			this.bookmarks = new Array();
		}
		
		public function hydrate( xmlShare:XML, xmlEmbed:XML ) :void
		{
			if( xmlShare != null )
			{
				// new XML feature
				if( hasAttribute( xmlShare, "status" ) )
				{
					if( xmlShare.@status == "1" || xmlShare.@status == "true" )
					{
						this._shareStatus = true;
					}
					else
					{
						this._shareStatus = false;
					}
				}
				// fallback for old XML
				else
				{
					this._shareStatus = true;
				}
				
				if( this.shareStatus )
				{
					this.deeplinkUrl = hasAttribute( xmlShare, "deeplink" ) ? xmlShare.@deeplink : this.deeplinkUrl;
					this.bookmarks = new Array();
					var item:XML;
					for each( item in xmlShare.bookmark )
					{
						this.bookmarks.push( new BookmarkVO( item ) );
					}
				}
			}
			else
			{
				this._shareStatus = false;
			}
			
			// new XML feature
			if( xmlEmbed != null )
			{
				if( hasAttribute( xmlEmbed, "status" ) )
				{
					if( xmlEmbed.@status == "1" || xmlEmbed.@status == "true" )
					{
						this.embedEnabled = true;
					}
					else
					{
						this.embedEnabled = false;
					}
				}
				else
				{
					this.embedEnabled = true;
				}
				
				this.swfUrl = hasAttribute( xmlEmbed, "swf" ) ? xmlEmbed.@swf : this.swfUrl;
				this.trackUrl = hasAttribute( xmlEmbed, "track" ) ? xmlEmbed.@track : this.trackUrl;
			}
			// fallback for old XML
			else if( xmlShare != null && hasAttribute( xmlShare, "embed" ) )//Abwärtskompatibilität zur alten video.xml
			{	
				if( xmlShare.@embed == "0" || xmlShare.@embed == "false" )
				{
					this.embedEnabled = false;
				}
				else
				{
					this.embedEnabled = true;
				}
			}
			else
			{
				this.embedEnabled = true;
			}
			
			// finally set embed data
			if( this.embedEnabled )
			{
				if( this.swfUrl == "" && xmlShare != null )
				{
					this.swfUrl = hasAttribute( xmlShare, "swf" ) ? xmlShare.@swf : this.swfUrl; //Abwärtskompatibilität zur alten video.xml
				}
				if( this.swfUrl == "" )
				{
					this.swfUrl = BildTvDefines.URL_PLAYER;
				}
				
				if( this.trackUrl == "" ) 
				{
					this.trackUrl = BildTvDefines.EMBED_TRACKING_URL;
				}
				
				BildTvDefines.embedTrackUrl = this.trackUrl;
			}
		}
		
		public function get shareStatus():Boolean
		{
			return this._shareStatus;
		}
	}
}
					