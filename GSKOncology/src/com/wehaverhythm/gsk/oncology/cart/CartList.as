package com.wehaverhythm.gsk.oncology.cart
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.gsk.oncology.Constants;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class CartList extends CartListDisplay
	{
		private var itemList:Vector.<CartListItem>;
		private var cartListCopy:Object = {empty:"Your cart is empty.", hasContent:"Your cart: "};
		private var itemHalfwayLimit:int = 7;
		private var defaultY:int = 0;
		
		public function CartList()
		{
			super();
			
			topSection.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onClose);
			addEventListener(CartListItem.REMOVE, onRemoveItem);
			bottomSection.btnRemoveAll.addEventListener(MouseEvent.MOUSE_DOWN, onRemoveAll);
			bottomSection.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onClose);
			bottomSection.btnClose.visible = false;
		}
		
		protected function onRemoveAll(e:MouseEvent):void
		{
			for each(var item:CartListItem in itemList) {
				Cart.remove(item.contentID, item.brandID);
				TweenMax.killTweensOf(item);
			}
			
			TweenMax.to(bottomSection, .3, {autoAlpha:0, y:topSection.y, ease:Sine.easeOut, overwrite:2});
			
			clearList();
			itemList = null;
			
			showEmpty();
			positionListY();
		}
		
		protected function onRemoveItem(e:Event):void
		{
			//trace("Remove me from cart: " + e.target.id);
			Cart.remove(e.target.contentID, e.target.brandID);
			var item:CartListItem = CartListItem(e.target);
			
			var i:int;
			
			for(i = 0; i < itemList.length; ++i)
			{
				if(itemList[i].id >= item.id) {
					itemList[i].targY-=itemList[i].height;
					TweenMax.to(itemList[i], .2, {y:itemList[i].targY, ease:Sine.easeOut, overwrite:2});
				}
			}
			var lastItem:CartListItem = itemList[itemList.length-1];
			TweenMax.to(bottomSection, .2, {y:lastItem.targY+lastItem.height, ease:Sine.easeOut, overwrite:2});
			
			
			itemList.splice(item.id, 1);
			TweenMax.killTweensOf(item);
			removeChild(item);
			
			for(i = 0; i < itemList.length; ++i) {
				itemList[i].id = i;
			}
			
			if(!itemList.length) {
				onRemoveAll(null);
			}
			
			positionListY();
		}
		
		public function positionListY(animate:Boolean = true):void
		{
			var newY:int = int(defaultY);
			
			if(itemList && itemList.length >= itemHalfwayLimit) {
				newY = int(Constants.HEIGHT - height - 50);
				bottomSection.btnClose.visible = true;
			} else {
				bottomSection.btnClose.visible = false;
			}
			
			if(animate) TweenMax.to(this, .2, {y:newY, ease:Sine.easeOut});
			else this.y = newY;
		}
		
		public function populateList():void
		{
			defaultY = y;
			
			clearList();
			
			//trace("Populating list view.");
			var items:Dictionary = Cart.cart;
			itemList = new Vector.<CartListItem>();
			
			bottomSection.y = topSection.y;
			bottomSection.alpha = 1;
			bottomSection.visible = true;
			
			topSection.txtCopy.text = cartListCopy.hasContent;
			
			var nextY:int = topSection.y + topSection.height;
			
			for(var brand:String in items) {
				for each(var item:Object in items[brand]) {
					var nextItem:CartListItem = addItem(item.title, brand, item.contentID);
					nextItem.y = nextItem.targY = nextY;
					addChild(nextItem);
					nextY += nextItem.height;
					
					bottomSection.y = nextY;
				}
			}
			
			if(!itemList.length) {
				showEmpty();
			}
			
//			if(itemList.length > itemHalfwayLimit) {
//				y -= itemList[0].height*(itemList.length-itemHalfwayLimit);
//			}
			
			positionListY(false);
		}
		
		private function showEmpty():void
		{
			topSection.txtCopy.text = cartListCopy.empty;
		}
		
		private function clearList():void
		{
			// clear list items
			//trace("CLEAR ALL");
			if(itemList) {
				while(itemList.length) {
					if(contains(itemList[0])) removeChild(itemList[0]);
					itemList[0].destroy();
					itemList.shift();
					
					//trace("removing .. " + itemList.length);
				}
			}
			
		}
		
		public function addItem(title:String, brandID:String, contentID:String):CartListItem
		{
			var item:CartListItem = new CartListItem(itemList.length, title, brandID, contentID);
			itemList.push(item);
			//trace("NEW ITEM > " + item);
			return item;
		}
		
		protected function onClose(e:MouseEvent):void
		{
			dispatchEvent(new Event(CartView.CLOSE, true));
		}
	}
}