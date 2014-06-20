package de.axelspringer.videoplayer.model.vo
{
	public class ConfigVO
	{
		// VideoInfo
		public var videoVO:VideoVO;
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