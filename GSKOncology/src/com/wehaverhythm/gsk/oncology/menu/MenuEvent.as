package com.wehaverhythm.gsk.oncology.menu
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
		public static var SELECT_ITEM:String = "SELECT_ITEM";
		public static var NAV_BUTTON_CLICKED:String = "NAV_BUTTON_CLICKED";
		public var params:Object;		
		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, params:Object = null)
		{
			this.params = params;
			super(type, bubbles, cancelable);
		}
	}
}