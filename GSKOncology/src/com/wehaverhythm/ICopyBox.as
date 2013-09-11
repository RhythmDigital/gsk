package com.wehaverhythm
{
	import flash.text.TextField;

	public interface ICopyBox
	{
		function reset(focus:Boolean=false):void;
		function lostFocus():void;
		function keyPressed(str:String):void;
		function get textfield():TextField;
	}
	
}