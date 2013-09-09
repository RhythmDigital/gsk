package com.wehaverhythm.gsk.oncology.cart
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CartListItem extends CartListItemDisplay
	{
		public static const REMOVE:String = "REMOVE";
		
		public var id:int;
		public var title:String;
		public var brandID:String;
		public var contentID:String;
		
		public var targY:Number = 0;
		
		public function CartListItem(itemListID:int, title:String, brandID:String, contentID:String)
		{
			super();
			
			this.id = itemListID;
			this.title = title;
			this.brandID = brandID;
			this.contentID = contentID;
			
			txtItemName.text = title;
			
			btnRemove.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			dispatchEvent(new Event(CartListItem.REMOVE, true, false)); 
		}
		
		public function destroy():void
		{
			btnRemove.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		override public function toString():String
		{
			return title + " / brand: " + brandID + " / contentID: " + contentID;
		}
	}
}