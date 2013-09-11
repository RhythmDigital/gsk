package com.wehaverhythm.utils.keyboard.input
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.wehaverhythm.utils.keyboard.OnScreenKeyboard;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ComboBox extends ComboDisplay
	{
		public static var HAS_FOCUS:String = "HAS_FOCUS";
		
		private var nextY:int = 0;
		private var items:Vector.<ComboBoxItem>;
		private var itemsContainer:Sprite;
		private var _hasFocus:Boolean;
		private var keyboard:OnScreenKeyboard;
		private var dropMask:Sprite;
		
		public var selectedID:int;
		
		public function ComboBox(defaultText:String, keyboard:OnScreenKeyboard)
		{
			super();
			
			this.keyboard = keyboard;
			
			txtDefault.text = defaultText;
			txtMain.visible = false;
			
			items = new Vector.<ComboBoxItem>();
			itemsContainer = new Sprite();
			itemsContainer.y = 58;
			addChild(itemsContainer);
			
			
			dropMask = new Sprite();
			dropMask.y = itemsContainer.y;
			addChild(dropMask);
			itemsContainer.mask = dropMask;
			reset();
			
			btnDrop.stop();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onClickFocus);
		}
		
		protected function onClickFocus(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onClickFocus);
			addEventListener(MouseEvent.MOUSE_DOWN, onClickLoseFocus);
			if(!_hasFocus) hasFocus();
		}
		
		protected function onClickLoseFocus(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onClickLoseFocus);
			addEventListener(MouseEvent.MOUSE_DOWN, onClickFocus);
			lostFocus();
		}
		
		public function addComboItem(label:String, id:int):void
		{
			var next:ComboBoxItem = new ComboBoxItem(label, id);
			next.addEventListener(MouseEvent.MOUSE_DOWN, onItemSelected, false, 0, true);
			next.y = nextY;
			nextY+=next.height-1;
			items.push(next);
			itemsContainer.addChild(next);
			
			with(dropMask.graphics)
			{
				clear();
				beginFill(0xff0000, 1);
				drawRect(-3,-3,itemsContainer.width+6, itemsContainer.height+6);
				endFill();
			}
		}
		
		public function hasFocus():void
		{
			keyboard.unbindTF(keyboard.currentCopyBox);
			focusState = true;
			TweenMax.to(dropMask, .2, {scaleY:1, ease:Quad.easeOut});
			dispatchEvent(new Event(ComboBox.HAS_FOCUS, true));
		}
		
		protected function onItemSelected(e:MouseEvent):void
		{
			trace("item " + e.target.id + " selected.");
			txtMain.text = e.target.txtLabel.text;
			selectedID = int(e.target.id);
			txtDefault.visible = false;
			txtMain.visible = true;
			focusState = false;
			dropMask.scaleY = 0;
		}
		
		public function lostFocus():void
		{
			if(!_hasFocus) return;
			focusState = false;
			resetMouseEvents();
			TweenMax.to(dropMask, .2, {scaleY:0, ease:Quad.easeOut});
		}
		
		public function get text():String
		{
			return txtMain.text;
		}
		
		public function reset():void
		{
			TweenMax.killTweensOf(this);
			txtDefault.visible = true;
			txtMain.visible = false;
			txtMain.text = "";
			dropMask.scaleY = 0;
			focusState = false;
			resetMouseEvents();
		}

		private function set focusState(focus:Boolean):void
		{
			if(focus) {
				_hasFocus = true;
				selectedBox.visible = true;
				btnDrop.gotoAndStop("on");
			} else {
				_hasFocus = false;
				selectedBox.visible = false;
				btnDrop.gotoAndStop("off");
				
			}
		}
		
		private function resetMouseEvents():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onClickLoseFocus);
			addEventListener(MouseEvent.MOUSE_DOWN, onClickFocus);
		}
	}
}