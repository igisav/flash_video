package de.axelspringer.videoplayer.model.vo
{
	public class FullscreenData
	{
		public var isFullscreen:Boolean;
		public var wasFullscreen:Boolean;
		
		public function FullscreenData( isFullscreen:Boolean, wasFullscreen:Boolean )
		{
			this.isFullscreen = isFullscreen;
			this.wasFullscreen = wasFullscreen;
		}
	}
}