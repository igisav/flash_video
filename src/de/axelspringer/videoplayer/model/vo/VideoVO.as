package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;

	public class VideoVO extends BaseVO
	{
		public var videoUrl:String 		= "";

		/**
		 * duration in seconds
		 */
		public var duration:Number			= 0;
		public var mute:Boolean 		= false;
		public var autoplay:Boolean 		= false;
		public var autorepeat:Boolean 		= false;
		public var startHDQuality:Boolean 	= false;
		public var hdAdaptive:Boolean 		= true;
	}
}