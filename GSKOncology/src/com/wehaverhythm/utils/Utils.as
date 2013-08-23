package com.wehaverhythm.utils
{
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
	}
}