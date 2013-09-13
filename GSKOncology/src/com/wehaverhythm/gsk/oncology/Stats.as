package com.wehaverhythm.gsk.oncology
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Stats
	{
		public static var SCRIPT:String = "http://gsk.local/scripts/stats.php";
		public static var ACTION_NAVIGATE:String = "navigate";
		public static var ACTION_SESSION_START:String = "start";
		public static var ACTION_SESSION_END:String = "end";
		
		public function Stats()
		{
			
		}
		
		public static function track(session:int, page:String, action:String):void
		{
			var url:String = SCRIPT + "?session_id="+session+"&page="+page+"&action="+action;
			var l:URLLoader = new URLLoader(new URLRequest(url));
			
		}
	}
}