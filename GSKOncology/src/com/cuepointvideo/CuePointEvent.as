package com.cuepointvideo
{
	import flash.events.Event;
	
	public class CuePointEvent extends Event
	{
		public static var CUE_POINT_TRIGGER:String = "CUE_POINT_TRIGGER";
		
		public var cueType:String;
		public var id:String;
		public var data:Object
		
		public function CuePointEvent(type:String, cueType:String, id:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.cueType = cueType;
			this.id = id;
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
	}
}