package com.wehaverhythm.utils
{
	import flash.events.Event;
	
	public class CustomEvent extends Event
	{
		public var params:Object;
		
		public function CustomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, params:Object = null)
		{
			this.params = params;
			super(type, bubbles, cancelable);
		}
	}
}