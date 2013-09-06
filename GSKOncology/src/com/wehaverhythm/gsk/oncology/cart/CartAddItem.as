package com.wehaverhythm.gsk.oncology.cart
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CartAddItem extends CartAddItemDisplay
	{
		public function CartAddItem()
		{
			super();
			
			Cart.addCounterTF(btnViewCart.txtLabel);
			
			btnViewCart.addEventListener(MouseEvent.MOUSE_DOWN, onViewCart);
			btnOK.addEventListener(MouseEvent.MOUSE_DOWN, onOK);
		}
		
		protected function onOK(e:MouseEvent):void
		{
			dispatchEvent(new Event(CartView.CLOSE, true));
		}
		
		protected function onViewCart(event:MouseEvent):void
		{
			dispatchEvent(new Event(CartView.SHOW_LIST, true));
		}
	}
}