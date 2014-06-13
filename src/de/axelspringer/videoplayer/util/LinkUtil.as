package de.axelspringer.videoplayer.util
{
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	
	import flash.external.ExternalInterface;
	
	public class LinkUtil
	{
		static public var defaultServerUrl:String 	= "http://www.bild.de";
		static public var serverUrl:String 			= defaultServerUrl;
		
		/*static public function setServerFromUrl( url:String ) :void
		{
			//if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('get Serverstring from: " + url+"');}");
			// if it's a relative url, use the url of the website
			if( url != null && ( url.search( "https://" ) == -1 && url.search( "http://" ) == -1 ) )
			{
				url = BildTvDefines.url;
				if( url == null )
				{
					url = defaultServerUrl;
				}
			}
			//if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('now cut some stuff from: " + url+"');}");
			// now get the server part 
			var endIndex:int = url.indexOf( "/", 7 );
			if( endIndex == -1 )
			{
				endIndex = url.length;
			}
			
			serverUrl = url.substring( 0, endIndex );
			//if( BildTvDefines.debugFlag ) ExternalInterface.call("function(){if (window.console) console.log('Serverstring is: " + serverUrl+"');}");
		}

		static public function absoluteLink( url:String ) :String
		{
			var result:String = url;
			if( url.search( "https://" ) != 0 &&
				url.search( "http://" ) != 0 &&
				url.search( "www." ) != 0 &&
				url.search( "javascript:" ) != 0 )
			{
				var prefix:String = serverUrl;
				if( url.search( "/" ) != 0 )
				{
					prefix += "/";
				}
			}
			return result;
		}*/
				
		static public function forceAbsoluteLink( url:String ) :String
		{
			var result:String = url;			
			
			if( url.search( "https://" ) == -1 && url.search( "http://" ) == -1 )
			{
				var prefix:String = serverUrl;
				if( url.search( "/" ) != 0 )
				{
					prefix += "/";
				}
				
				result = prefix + url;
			}

			return result;
		}
	}
}