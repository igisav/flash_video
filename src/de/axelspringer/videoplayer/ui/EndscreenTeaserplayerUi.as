package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	//[Embed(source="/embed/assets.swf", symbol="EndscreenTeaserplayerUi")]
	public class EndscreenTeaserplayerUi extends SimpleButton
	{
		protected var url:String;
		
		public function EndscreenTeaserplayerUi()
		{
			super();
			
			if( this.stage == null )
			{
				this.addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			}
			else
			{
				this.init();
			}
		}
		
		protected function addedToStage( event:Event ) :void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
			this.init();
		}
		
		protected function init() :void
		{
			this.addEventListener( MouseEvent.CLICK, onClick );
			
			// create link
			
			// get url from swf location
			var url:String = root.loaderInfo.url;
            var baseUrl:String = url.substring( 0, url.indexOf( "/swf/" ) );
            
            // get movie id from current site
            var index:Number = BildTvDefines.urlLong.indexOf( "&m=" ) + 3;
            var movieId:String = BildTvDefines.urlLong.substring( index, BildTvDefines.urlLong.indexOf( "&", index ) );
            
            this.url = baseUrl + "/detail.aspx?s=detail&m=" + movieId + "&pl=m";
			
			this.resize();
		}
		
		protected function onClick( event:MouseEvent ) :void
		{
			try
            {
            	navigateToURL( new URLRequest( this.url ), "_blank" );
            }
            catch( error:Error )
            {
            	trace( this + " error opening movie: " + error.message );
            }
		}
		
		public function resize() :void
		{
			this.x = Math.round( ( BildTvDefines.width - this.width ) / 2 );
			this.y = Math.round( ( BildTvDefines.height - this.height ) / 2 );
		}
	}
}