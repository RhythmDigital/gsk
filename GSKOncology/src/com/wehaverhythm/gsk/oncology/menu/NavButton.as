package com.wehaverhythm.gsk.oncology.menu
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class NavButton extends Sprite
	{
		protected var sprite:*;
		protected var label:String;
		protected var params:Object;
		protected var num:int;
		
		public var id:String;

		public function NavButton(params:Object)
		{
			super();
			
			sprite = params.s;
			label = params.l;
			id = params.id;
			this.params = params;
			
			sprite.parent.addChild(this);
			this.x = sprite.x;
			this.y = sprite.y;
			sprite.x = sprite.y = 0;
			addChild(sprite);
			
			this.buttonMode = true;
			this.mouseChildren = false;
			
			this.sprite.txtLabel.text = label;
			
			if(!params.hasOwnProperty("arrow") || params.arrow == false)
			{
				this.sprite.arrow.visible = false;
			}
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.NAV_BUTTON_CLICKED, true));
		}
		
		public function appendNumber(num:int):void
		{
			if(num == 0) {
				sprite.txtLabel.text = label;
			} else {
				this.num = num;
				sprite.txtLabel.text = label + " ("+num+")";
			}
		}
		
		
	}
}