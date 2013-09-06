package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class MenuButton extends Sprite
	{
		public static const BTN_TYPE_MAIN:String = "BTN_TYPE_MAIN";
		public static const BTN_TYPE_NORMAL:String = "BTN_TYPE_NORMAL";
		public var xmlID:String;
		public var buttonID:int;
		public var menu:int;
		public var xml:XMLList;
		public var display:*;
		
		private var brandColour:uint = 0xffffff;
		
		public function MenuButton(buttonID:int, xmlID:String, menu:int, label:String, xml:XMLList, menuXML:XML)
		{
			super();
			
			this.buttonID = buttonID;
			this.xmlID = xmlID;
			this.menu = menu;
			this.brandColour = uint("0x"+String(menuXML.colour).substr(1));
			
			display = getButtonDisplay();
			buttonText = label;
			addChild(display);
			
			tint(display.arrow, brandColour, true);
			tint(display.leftBar, brandColour, false);
			
			buttonMode = true;
			mouseChildren = false;
			
		//	addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		protected function getButtonDisplay():*
		{
			return new MenuButtonDisplay;
		}
		
		protected function onMouseUp(e:Event):void
		{
			//onRollOut(null);
			//dispatchEvent(new MenuEvent(MenuEvent.SELECT_ITEM, true));
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			tint(display.copy, 0x000000, false);
			tint(display.bg, 0xffffff, false);
			tint(display.arrow, 0x000000, true);
			
			selectButton();
		}
		
		protected function selectButton():void
		{
			TweenMax.to(this, .2, {onComplete:dispatchSelectEvent, overwrite:2});
		}
		
		private function dispatchSelectEvent():void
		{
			dispatchEvent(new MenuEvent(MenuEvent.SELECT_ITEM, true));
		}
		
		public function deselect():void
		{
			tint(display.copy, 0xffffff, true);
			tint(display.bg, 0x000000, true);
			tint(display.arrow, brandColour, true);
		}
		
		protected function tint(el:*, col:uint = 0xffffff, remove:Boolean = true):void
		{
			TweenMax.to(el, 0, {immediateRender:true, tint:col});
		}
		
		protected function set buttonText(s:String):void
		{
			var tf:TextField = display.copy.txtLabel;
			tf.autoSize = "left";
			tf.text = s;
			tf.width = 570;
			tf.height = tf.textHeight;
			
			display.copy.y = (display.bg.height >> 1) - (display.copy.height >> 1);
		}
		
		public function get textField():TextField
		{
			if(display.copy && display.copy.txtLabel) return display.copy.txtLabel;
			else return null;
		}
		
		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeChild(display);
			display = null;
			xmlID = null;
			xml = null;
		}
	}
}