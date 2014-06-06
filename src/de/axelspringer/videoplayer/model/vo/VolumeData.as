package de.axelspringer.videoplayer.model.vo
{
	public class VolumeData
	{
		public var newVolume:Number;
		public var oldVolume:Number;
		
		public function VolumeData( newVolume:Number, oldVolume:Number )
		{
			this.newVolume = newVolume;
			this.oldVolume = oldVolume;
		}
	}
}