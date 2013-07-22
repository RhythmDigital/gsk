package com.cuepointvideo
{
	public class CuePoint
	{
		public static const CUE_IN:String = "in";
		public static const CUE_OUT:String = "out";
		
		public var id:String;
		public var inTimeMS:int;
		public var outTimeMS:int;
		private var clock:Date;
		private var timecodeRegExp:RegExp;
		
		public function CuePoint(id:String, inTime:String, outTime:String = null)
		{
			this.id = id;
			clock = new Date();
			clock.time = 0;
			timecodeRegExp = new RegExp ( "[:\.]" , "gi" );
			
			this.inTimeMS = timecodeToMilliseconds(inTime);
			
			if(outTime != null)
				this.outTimeMS = timecodeToMilliseconds(outTime);
		}
		
		/**
		 * Convert hh:mm:ss.SSS to Milliseconds.
		 */
		public function timecodeToMilliseconds(timecode:String):int
		{
			var split:Array = timecode.split(timecodeRegExp);
			clock.time = 0;
			clock.hoursUTC = int(split[0]);
			clock.minutesUTC = int(split[1]);
			clock.secondsUTC = int(split[2]);
			clock.millisecondsUTC = int(split[3]);
			
			return clock.time;
		}
	}
}