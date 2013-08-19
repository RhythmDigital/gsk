package com.wehaverhythm.gsk.oncology.menu
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MenuButton extends Sprite
	{
		public static const BTN_TYPE_MAIN:String = "BTN_TYPE_MAIN";
		public static const BTN_TYPE_NORMAL:String = "BTN_TYPE_NORMAL";
		public var xmlID:String;
		public var buttonID:int;
		public var menu:int;
		public var xml:XMLList;
		
		private var tf:TextField;
		
		public function MenuButton(buttonID:int, xmlID:String, menu:int, label:String, xml:XMLList)
		{
			super();
			
			this.buttonID = buttonID;
			this.xmlID = xmlID;
			this.menu = menu;
			
			var w:int = 500;
			var h:int = 100;
			
			buttonMode = true;
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			drawDummy(new Rectangle(0, 0, w, h));
			
			tf = new TextField();
			tf.defaultTextFormat = new TextFormat("Arial", 40);
			tf.multiline = true;
			tf.text = "Label";
			tf.width = w;
			tf.height = h;
			addChild(tf);
			tf.text = label;//.toUpperCase(); NO!
		}
		
		private function drawDummy(sizePos:Rectangle, col:uint = 0xf4f400):void
		{
			this.graphics.beginFill(col, .7);
			this.graphics.drawRect(0, 0, sizePos.width, sizePos.height);
			this.graphics.endFill();
		}
		
		protected function onMouseUp(event:Event):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.SELECT_ITEM, true));
		}
		
		public function destroy():void
		{
			xmlID = null;
			xml = null;
			removeChild(tf);
		}
	}
}