package com.wehaverhythm.gsk.oncology.cart
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class CartList extends CartListDisplay
	{
		public function CartList()
		{
			super();
			
			topSection.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onClose);
		}
		
		protected function onClose(e:MouseEvent):void
		{
			dispatchEvent(new Event(CartView.CLOSE, true));
		}
	}
}