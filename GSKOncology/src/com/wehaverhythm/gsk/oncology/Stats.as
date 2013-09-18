package com.wehaverhythm.gsk.oncology
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Stats
	{
		public static var ACTION_NAVIGATE:String = "navigate";
		public static var ACTION_SESSION_START:String = "start";
		public static var ACTION_SESSION_END:String = "end";
		
		public function Stats()
		{
			
		}
		
		public static function track(session:int, page:String, action:String):void
		{
			var url:String = Constants.SCRIPT_PATH+"stats.php?session_id="+session+"&page="+page+"&action="+action;
			var l:URLLoader = new URLLoader(new URLRequest(url));
			l.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorEvent, false, 0, true);
			l.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
		}
		
		protected static function onComplete(e:Event):void
		{
			trace(URLLoader(e.target).data);
			removeEventListeners(e.target);
		}
		
		protected static function onIOErrorEvent(e:IOErrorEvent):void
		{
			trace(e);
			removeEventListeners(e.target);
		}
		
		private static function removeEventListeners(t:Object):void
		{
			t.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorEvent);
			t.removeEventListener(Event.COMPLETE, onComplete);
		}
	}
}