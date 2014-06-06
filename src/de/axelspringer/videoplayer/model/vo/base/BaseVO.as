package de.axelspringer.videoplayer.model.vo.base
{
	public class BaseVO
	{
		public function BaseVO()
		{
		}
		
		protected function hasAttribute( xml:XML, attribute:String ) :Boolean
		{
			var result:Boolean = false;
			
			if( xml != null && xml.attribute(attribute).length() > 0 )
			{
				result = true;
			}
			
			return result;
		}
	}
}