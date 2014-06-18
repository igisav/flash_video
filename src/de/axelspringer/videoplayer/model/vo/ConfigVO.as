package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.util.LinkUtil;
	
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	public class ConfigVO extends BaseVO
	{

		public var playerWidth:Number	= -1;
		public var playerHeight:Number	= -1;
		
		// Id (welt player only)
		public var id:String = "";
		
		// VideoInfo
		public var videoVO:VideoVO;

		// related clips
		public var endScreenEnabled:Boolean = true;
		public var relatedXml:String = "";
		public var relatedVideos:Array;

		// in case we get a film.bild.de XML, use this to hydrate the data
		public var filmVO:FilmVO;
		
		// for paid content live streams use this VO
		public var streamingVO:StreamingVO;
		
		public function ConfigVO()
		{
			this.videoVO = new VideoVO();
			this.relatedVideos = new Array();
		}
	}
}