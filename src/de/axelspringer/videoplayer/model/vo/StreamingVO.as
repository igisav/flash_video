package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.event.XmlEvent;
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.XmlLoader;

	public class StreamingVO extends BaseVO
	{
		
		public var ns:Namespace = new Namespace("http://www.w3.org/2001/SMIL20/Language");
			
		public var streamUrl:String 	= "";
		public var streamUrl2:String 	= "";
		public var duration:Number		= -1;
		public var autoplay:Boolean 	= true;
		public var isLivestream:Boolean = false;
		
		public var functionNameStreamEnd:String 		= "onStreamEnd";
		public var functionNameConnectionClose:String 	= "location.reload";

		// session pinger
		public var pingUrl:String 		= "";
		public var pingSession:String	= "";
		public var pingInterval:uint	= 10 * 60 * 1000;	// in ms
		public var pingText:String		= "";
		public var pingDebug:Boolean	= false;
		
		public function StreamingVO()
		{
			super();
		}
		
		protected function loadSmil() :void
		{
			var xmlLoader:XmlLoader = new XmlLoader();
			xmlLoader.addEventListener( XmlEvent.XML_LOADED, onSmilLoaded, false, 0, true );
			xmlLoader.addEventListener( XmlEvent.XML_ERROR, onSmilError, false, 0, true );
			xmlLoader.loadXml( this.streamUrl );
		}
		
		protected function onSmilLoaded( e:XmlEvent ) :void
		{
			var loadedXml:XML = e.xml;
			this.hydrateSmil( loadedXml.ns::head, loadedXml.ns::body );
		}
		
		protected function onSmilError( e:XmlEvent ) :void
		{
			trace( "onXmlError: " + e.text );
		}
		
		public function hydrateSmil( smilHead:XMLList, smilBody:XMLList ) :void
		{
			if( smilHead != null )
			{
				var metaList:XMLList = smilHead.children();
				for each (var metaElement:* in metaList)
				{
					if( metaElement.@name == "rtmpPlaybackBase" )     
	              	{
	                 	trace("connectionUrl:" + metaElement.@content);
	                 	break;
	                } 
				}       
	  		} 
	  		 
			if( smilBody != null )
			{
				var videoList:XMLList = smilBody.children().children();
				for each (var videoElement:* in videoList)
				{
	               //	trace("connectionUrl:" + videoElement.@src + "        " + videoElement.@system-bitrate);
				}          
	  		}  			
		}
	}
}