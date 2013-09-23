package com.wehaverhythm.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class IdleTimeout
	{
		public static var stage:Stage;
		public static var timeout:int;
		public static var callback:Function;
		public static var delay:Timer;
		
		public static var resetCount:int;
		
		public static var newSession:Boolean = true;
		
		private static var listening:Boolean = false;
		
		public function IdleTimeout()
		{
		}
		
		public static function init(stage:Stage, timeout:int, callback:Function):void
		{
			IdleTimeout.stage = stage;
			IdleTimeout.timeout = timeout;
			IdleTimeout.callback = callback;
			//IdleTimeout.startListening();
		}
		
		protected static function onMouseMove(event:Event):void
		{
			IdleTimeout.resetTimeout();
		}
		
		public static function stopListening():void
		{
			if(!listening) return;
			listening = false;
			trace(IdleTimeout, "stop listening.");
			IdleTimeout.resetTimeout();
			IdleTimeout.delay.stop();
			IdleTimeout.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseMove);
		}
		
		public static function startListening():void
		{
			if(listening) return;
			listening = true;
			trace(IdleTimeout, "start listening.");
			IdleTimeout.resetTimeout();
			IdleTimeout.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseMove);
		}
		
		private static function resetTimeout():void
		{
			//trace(IdleTimeout, "reset.");
			if(!IdleTimeout.delay) {
				IdleTimeout.delay = new Timer(IdleTimeout.timeout, 1);
				IdleTimeout.delay.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
			}
			
			IdleTimeout.delay.reset();
			IdleTimeout.delay.start();
		}
		
		protected static function onTimeout(e:TimerEvent):void
		{
			trace(IdleTimeout, "timeout!");
			IdleTimeout.resetCount++;
			IdleTimeout.callback();
		}
		
		public function toString():String
		{
			return "IdleTimeout :: ";
		}
	}
}