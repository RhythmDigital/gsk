package com.wehaverhythm.utils
{
	import com.greensock.TweenMax;

	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function deepLogArray(array:Array, level:int = 0):void {
			var tabs:String = "";
			for ( var i : int = 0 ; i < level ; i++, tabs += "\t" );
			
			for(var j:int = 0; j < array.length; ++j) {
				trace( tabs + level +" > "+ array[j].button);
				if(array[j].menu is Array) {
					deepLogArray(array[j].menu, level+1);
				}
			}
		}
		
		public static function getTimeFromMilliseconds(ms:int):Date
		{
			var d:Date = new Date()
				d.time = ms;
				trace(d.hours, d.minutes, d.seconds);
			return d;
		}
		
		public static function frameToSeconds(frame:int, fps:int):Number
		{
			return frame/fps;
		}
	}
}