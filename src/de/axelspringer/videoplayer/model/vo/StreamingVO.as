package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

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

	}
}