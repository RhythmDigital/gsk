package com.cuepointvideo
{
	import flash.events.Event;
	
	public class CuePointVideoEvent extends Event
	{
		public static const NEXT_VIDEO_PLAYING:String = "NEXT_VIDEO_PLAYING";
		
		public var params:Object;
		
		public function CuePointVideoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, params:Object = null)
		{
			this.params = params;
			super(type, bubbles, cancelable);
		}
	}
}