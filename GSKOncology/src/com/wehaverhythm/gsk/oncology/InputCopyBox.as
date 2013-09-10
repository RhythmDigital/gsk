package com.wehaverhythm.gsk.oncology
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.utils.OnScreenKeyboard;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class InputCopyBox extends InputCopyBoxDisplay
	{
		public var overlay:Sprite;
		public var keyboard:OnScreenKeyboard;
		
		public function InputCopyBox(defaultText:String, keyboard:OnScreenKeyboard)
		{
			super();
			
			this.keyboard = keyboard;
			
			overlay = new Sprite();
			overlay.graphics.beginFill(0xff00ff,0);
			overlay.graphics.drawRect(0,0,width,height);
			addChild(overlay);
			
			this.mouseChildren = true;
			this.buttonMode = true;
			selectedBox.visible = false;
			txtDefault.text = defaultText;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			overlay.addEventListener(MouseEvent.MOUSE_DOWN, hasFocus);
			txtDefault.visible = true;
			txtMain.visible = false;
		}
		
		public function keyPressed(str:String):void
		{
			txtDefault.visible = txtMain.text.length ? false : true;			
		}
		
		public function reset(focus:Boolean=false):void
		{
			txtDefault.visible = true;
			txtMain.visible = false;
			txtMain.text = "";
			
			if(focus) {
				hasFocus(null);
				txtDefault.visible = true;
			}
		}
		
		public function lostFocus():void
		{
			if(txtMain.text.length == 0) {
				txtDefault.visible = true;
				txtMain.visible = false;
			}
			
			overlay.visible = true;
			selectedBox.visible = false;
		}
		
		protected function hasFocus(e:MouseEvent):void
		{
			keyboard.bindTF(this);
			TweenMax.killDelayedCallsTo(lostFocus);
			overlay.visible = false;
			txtDefault.visible = txtMain.text.length ? false : true;	
			txtMain.visible = true;
			stage.focus = txtMain;
			selectedBox.visible = true;
			// remove old selection state and place carat at end.
			txtMain.setSelection(txtMain.text.length,txtMain.text.length);
		}
		
		public function get textfield():TextField
		{
			return txtMain;
		}
	}
}