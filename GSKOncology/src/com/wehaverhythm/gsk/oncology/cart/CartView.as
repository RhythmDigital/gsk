package com.wehaverhythm.gsk.oncology.cart
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class CartView extends CartViewDisplay
	{
		public static var CLOSE:String = "close";
		public static var SHOW_LIST:String = "show_list";
		
		public var boxBoundary:Rectangle = new Rectangle(0,960,1080, 960);
		
		public var current:*;
		public var list:CartList;
		public var add:CartAddItem;
		
		public function CartView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			alpha = 0;
			visible = false;
		}
		
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			Cart.events.addEventListener(Cart.ADD_ITEM, onCartAddItem);
			list = new CartList();
			add = new CartAddItem();
			
			addEventListener(CartView.CLOSE, onCloseCartView);
			addEventListener(CartView.SHOW_LIST, onShowListView);
		}
		
		protected function onShowListView(e:Event):void
		{
			show(list);
		}
		
		protected function onCloseCartView(e:Event):void
		{
			hide();
		}
		
		protected function onCartAddItem(e:Event):void
		{
			show(add);
		}
		
		public function show(screen:*):void
		{
			if(this.visible && current) {
				hideCurrent(screen);
			} else {
				current = screen;
				current.visible = true;
				current.alpha = 1;
				positionView(current);
				addChild(current);
				TweenMax.to(this, .3, {autoAlpha:1, ease:Quad.easeOut});
			}
		}
		
		private function positionView(current:*):void
		{
			current.x = ((boxBoundary.x+boxBoundary.width)>>1)-(current.width>>1);
			current.y = boxBoundary.y;
		}
		
		public function hideCurrent(thenShow:*):void
		{
			TweenMax.to(current, .4, {autoAlpha:0, ease:Quad.easeOut, onComplete:onCurrentHidden, onCompleteParams:[thenShow]});
		}
		
		public function hide():void
		{
			TweenMax.to(this, .3, {autoAlpha:0, ease:Quad.easeOut, onComplete:onHidden});
		}
		
		private function onHidden():void
		{
			if(current) removeChild(current);
		}
			
		private function onCurrentHidden(showScreen:*):void
		{
		//	onHidden();
			if(showScreen) {
				current = showScreen;
				addChild(current);
				TweenMax.to(current, .4, {autoAlpha:1, ease:Quad.easeOut});
			}
		}
	}
}