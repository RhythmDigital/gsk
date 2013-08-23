package com.wehaverhythm.gsk.oncology.content
{
	import flash.events.Event;
	
	public class ContentEvent extends Event
	{
		public static var CONTENT_TRIGGER:String = "CONTENT_TRIGGER";
		
		public var params:Object;
		
		public function ContentEvent(type:String, params:Object = null)
		{
			this.params = params;
			super(type, true, false);
		}
	}
}