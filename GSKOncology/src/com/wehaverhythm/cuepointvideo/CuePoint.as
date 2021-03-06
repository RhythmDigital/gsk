package com.wehaverhythm.cuepointvideo
{
	import com.greensock.TweenMax;

	public class CuePoint
	{
		public static const CUE_IN:String = "in";
		public static const CUE_OUT:String = "out";
		
		public var id:String;
		public var inTimeSeconds:Number;
		public var outTimeSeconds:Number;
		public var inFrame:int;
		public var outFrame:int;
		public var pauseTimeMS:int;
		public var flagged:Boolean;
		public var visible:Boolean;
		public var enabled:Boolean;
		public var playedThisLoop:Boolean;
		
		public function CuePoint(id:String, inFrame:int, outFrame:int = -1, pauseTimeMS:int = -1)
		{
			this.id = id;
			this.inFrame = inFrame;
			this.outFrame = pauseTimeMS == -1 ? outFrame : inFrame+30;
			this.pauseTimeMS = pauseTimeMS;	
			this.enabled = true;
			/*clock = new Date();
			clock.time = 0;
			timecodeRegExp = new RegExp ( "[:\.]" , "gi" );*/
			
			//this.inTimeMS = timecodeToMilliseconds(inTime);
			
			//if(outTime != null)
			//	this.outTimeMS = timecodeToMilliseconds(outTime);
		}
		
		/**
		 * Convert hh:mm:ss.SSS to Milliseconds.
		 */
		/*
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
		*/
		public function setFrameRate(frameRate:int):void
		{
			inTimeSeconds = inFrame / frameRate;
			outTimeSeconds = outFrame / frameRate;
		}
		
		public function disableFor(numFrames:int):void
		{
			enabled = false;
			TweenMax.killDelayedCallsTo(enableMe);
			TweenMax.delayedCall(numFrames, enableMe, null, true);
		}
		
		private function enableMe():void
		{
			enabled = true;
		}
	}
}