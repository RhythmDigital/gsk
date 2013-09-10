package com.wehaverhythm.gsk.oncology.cart
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CartThanks extends CartThanksDisplay
	{
		public function CartThanks()
		{
			super();
			
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onCloseClicked);
		}
		
		protected function onCloseClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(CartView.CLOSE, true));
		}
	}
}