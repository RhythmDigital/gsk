package com.wehaverhythm.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;

	public class OnScreenKeyboard extends OnScreenKeyboardDisplay
	{ 
		private var allKeys:Vector.<OnScreenKeyboardKey>;
		private var shiftOn:Boolean;
		private var current:TextField;
		private var caratIdx:int;
		
		public function OnScreenKeyboard()
		{
			super();
			
			allKeys = new Vector.<OnScreenKeyboardKey>();
			
			var i:int = 0;
			for each(var d:DisplayObject in keys) {
				var key:OnScreenKeyboardKey = new OnScreenKeyboardKey(d);
				key.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				allKeys.push(key);
				++i;
			}
		}
		
		public function addTextField(tf:TextField):void
		{
			tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		}
		
		protected function onFocusOut(e:FocusEvent):void
		{
			unbindTF(current);
		}
		
		protected function onFocusIn(e:FocusEvent):void
		{
			bindTF(TextField(e.target));
		}
		
		private function bindTF(tf:TextField):void
		{
			if(tf == current) return;
			
			trace(current + " has focus");
			current = TextField(tf);
		}
		
		public function unbindTF(tf:TextField):void
		{
			trace(current + " lost focus");
			current = null;
		}
		
		protected function onMouseDown(e:Event):void
		{
			if(!current) return;
			//trace(e.target.char);
			caratIdx = current.caretIndex;
						
			var str:String = current.text;
			var firstBit:String;
			var lastBit:String;
			var newStr:String;
			var newChar:String;
			
			switch(e.target.char) {
				case "shift":
					shiftOn = !shiftOn;
					e.target.lit = shiftOn;
					for(var i:int = 0; i < allKeys.length; ++i) {
						allKeys[i].upperCase = shiftOn;
					}
					break;
				
				case "del":
					e.target.flash();
					
					if(caratIdx > 0) {
						if(current.selectedText.length) {
							firstBit = str.substr(0,current.selectionBeginIndex);
							lastBit = str.substr(current.selectionEndIndex, current.text.length);
							newStr = firstBit+lastBit;
							caratIdx = current.selectionBeginIndex;
						} else {
							firstBit = str.substr(0,caratIdx-1);
							lastBit = str.substr(caratIdx, current.text.length);
							newStr = firstBit+lastBit;
							caratIdx --;
						}
						current.text = newStr;
					}
					
					break;
				
				default:
					e.target.flash();
					newChar = e.target.getChar();
					
					if(current.selectedText.length) {
						firstBit = str.substr(0,current.selectionBeginIndex);
						lastBit = str.substr(current.selectionEndIndex, current.text.length);
						newStr = firstBit+newChar+lastBit;
						caratIdx = current.selectionBeginIndex+newChar.length;
					} else {
						firstBit = str.substr(0,caratIdx);
						lastBit = str.substr(caratIdx, current.text.length);
						newStr = firstBit+newChar+lastBit;
						caratIdx += newChar.length;
					}
					
					current.text = newStr;
			}
			
			stage.focus = current;
			if(caratIdx < 0) caratIdx = 0;
			current.setSelection(caratIdx, caratIdx);
		}
	}
}