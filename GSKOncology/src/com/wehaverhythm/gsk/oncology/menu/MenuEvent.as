package com.wehaverhythm.gsk.oncology.menu
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
		public static var SELECT_ITEM:String = "SELECT_ITEM";
		
		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}