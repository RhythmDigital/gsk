package com.wehaverhythm.gsk.oncology
{
	import com.wehaverhythm.gsk.oncology.menu.NavButton;
	
	import flash.utils.Dictionary;

	public class Cart
	{
		public static var cart:Dictionary;
		public static var counter:int = 0;
		public static var cartButton:NavButton;
		
		public function Cart()
		{
		}
		
		public static function init(button:NavButton):void
		{
			Cart.cartButton = button;
			Cart.reset();
		}
		
		public static function add(contentID:String, brandID:String):Boolean
		{
			if(!Cart.cart[brandID]) {
				var brand:Vector.<int> = new Vector.<int>();
				Cart.cart[brandID] = brand;
			}
			
			if(!exists(contentID, brandID)) {
				counter ++;
				Cart.cartButton.appendNumber(counter);
				Cart.cart[brandID].push(contentID);
				trace("Adding "+contentID+" of brand " + brandID + " to cart.");
				return true;
			}
			
			return false;
		}
		
		public static function remove(contentID:String, brandID:String):void
		{
			if(Cart.cart[brandID]) {
				for(var i:int = 0; i < Cart.cart[brandID].length; ++i) {
					if(Cart.cart[brandID][i] == contentID) {
						counter --;
						Cart.cartButton.appendNumber(counter);
						Cart.cart[brandID].splice(i, 1);
						return;
					}
				}
			}
		}
		
		public static function exists(contentID:String, brandID:String):Boolean
		{
			if(Cart.cart[brandID]) {
				for(var i:int = 0; i < Cart.cart[brandID].length; ++i) {
					if(Cart.cart[brandID][i] == contentID) return true;
				}
			}
				
			return false;
		}
		
		public static function traceCart():void
		{
			trace("\n------ CART ------");
			for(var b:String in Cart.cart) {
				var brand:Vector.<int> = Cart.cart[b];
				for(var i:int = 0; i < brand.length; ++i) {
					trace("  brand : " + b + " > contentID : " + brand[i]); 
				}
			}
			trace("------------------\n");
		}
		
		public static function count():int
		{
			return counter;
		}
		
		public static function reset():void
		{
			if(Cart.cart)
			{
				for(var k:* in Cart.cart) {
					while(Cart.cart[k].length) {
						Cart.cart[k].shift();
					}
					Cart.cart[k] = null;
				}
			}
			Cart.cart = new Dictionary();
			counter = 0;
			Cart.cartButton.appendNumber(counter);
		}
	}
}