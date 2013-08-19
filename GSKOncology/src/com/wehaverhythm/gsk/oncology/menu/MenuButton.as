package com.wehaverhythm.gsk.oncology.menu
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class MenuButton extends Sprite
	{
		public static const BTN_TYPE_MAIN:String = "BTN_TYPE_MAIN";
		public static const BTN_TYPE_NORMAL:String = "BTN_TYPE_NORMAL";
		public var id:String;
		public var menu:int;
		
		public function MenuButton(id:String, menu:int, w:int = 350, h:int = 45)
		{
			super();
			
			this.id = id;
			this.menu = menu;
			
			buttonMode = true;
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			drawDummy(new Rectangle(0, 0, w, h));
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
	}
}