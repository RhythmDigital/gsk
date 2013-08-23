package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	
	public class MenuOverlay extends Sprite
	{
		public static const TYPE_ROOTNAV:String = "TYPE_ROOTNAV";
		public static const TYPE_SUBNAV:String = "TYPE_SUBNAV";
		
		public var display:NavElementsDisplay;
		private var buttons:Array;
		
		public function MenuOverlay()
		{
			super();
			
			display = new NavElementsDisplay();
			
			initButtons([
				{id:"back", s:display.backBtn, l:"BACK", arrow:true}, 
				{id:"home", s:display.homeBtn, l:"HOME", arrow:true}, 
				{id:"cart", s:display.cartBtn, l:"VIEW CART"}, 
				{id:"ask", s:display.askBtn, l:"ASK GSK"}
			]);
			
			addChild(display);
		}
		
		private function initButtons(sprites:Array):void
		{
			buttons = [];
			
			for each(var params:Object in sprites) {
				buttons.push(new NavButton(params));
			}
			
			hide(false, [0,1,2,3]);
		}
		
		public function hide(animate:Boolean, buttonIDList:Array):void
		{
			for each(var btnID:int in buttonIDList) 
			{
				var p:Object = {autoAlpha:0, overwrite:2};
				p.immediateRender = animate ? false : true;
				TweenMax.to(buttons[btnID], animate ? .1 : 0, p);
			}
		}
		
		public function showButtons(type:String):void
		{
		//	trace("show buttons: " + type);
			switch(type) {
				case TYPE_ROOTNAV:
					hide(true, [0,1]);
					show([2,3]);
					break;
				
				case TYPE_SUBNAV:
					show([0,1,2,3]);
					break;
			}
		}
		
		private function show(buttonIDList:Array):void
		{
			for each(var btnID:int in buttonIDList) {
				TweenMax.to(buttons[btnID], .1, {autoAlpha:1, overwrite:2});
			}
		}
	}
}