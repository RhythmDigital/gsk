package com.wehaverhythm.gsk.oncology.cart
{
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	public class Cart
	{
		public static const SHOW:String = "SHOW";
		public static const HIDE:String = "HIDE";
		public static const ADD_ITEM:String = "ADD_ITEM";
		public static const CART_FULL:String = "CART_FULL";
		
		public static const MAX_CART_ITEMS:int = 21;
		
		public static var events:EventDispatcher;
		public static var view:CartView;
		public static var cart:Dictionary;
		public static var counter:int = 0;
		public static var textfields:Array;
		
		
		
		public function Cart()
		{
		}
		
		public static function init(cartView:CartView):void
		{
			Cart.events = new EventDispatcher(null);
			Cart.view = cartView;
			Cart.reset();
		}
		
		public static function addCounterTF(tf:TextField, prefix:String = "VIEW CART"):void
		{
			if(!Cart.textfields) Cart.textfields = [];
			Cart.textfields.push({tf:tf, prefix:prefix});
		}
		
		public static function add(contentID:String, brandID:String, title:String, cancelEvent:Boolean = false):Boolean
		{
			if(!Cart.cart[brandID]) {
				var brand:Vector.<Object> = new Vector.<Object>();
				Cart.cart[brandID] = brand;
			}
			
			if(!exists(contentID, brandID) && Cart.hasRoom()) {
				counter ++;
				Cart.appendNumberToTextfields();
				Cart.cart[brandID].push({contentID:contentID, title:title});
				//trace("Adding "+contentID+" of brand " + brandID + " to cart.");
				if(!cancelEvent) Cart.events.dispatchEvent(new CustomEvent(Cart.ADD_ITEM, true, false, {label:title}));
				return true;
			} else if (!Cart.hasRoom()) {
				if(!cancelEvent) Cart.events.dispatchEvent(new CustomEvent(Cart.CART_FULL, true, false));
				return false;
			}
			
			return false;
		}
		
		public static function showCart():void
		{
			Cart.view.showCart();
		}
		
		private static function appendNumberToTextfields():void
		{
			if(!Cart.textfields) return;
			
			var tfs:Array = Cart.textfields;
			var t:TextField;
			var pfx:String;
			
			for(var i:int = 0; i < tfs.length; ++i) {
				
				t = tfs[i].tf;
				pfx = tfs[i].prefix;
				
				if(counter == 0) {
					t.text = pfx;
				} else {
					t.text = pfx + " ("+counter+")";
				}
			}
		}
		
		public static function remove(contentID:String, brandID:String):void
		{
			if(Cart.cart[brandID]) {
				for(var i:int = 0; i < Cart.cart[brandID].length; ++i) {
					if(Cart.cart[brandID][i].contentID == contentID) {
						counter --;
						Cart.appendNumberToTextfields();
						Cart.cart[brandID].splice(i, 1);
						return;
					}
				}
			}
		}
		
		public static function hasRoom():Boolean
		{
			trace("HAS ROOM ? " + !(Cart.counter >= Cart.MAX_CART_ITEMS));
			return !(Cart.counter >= Cart.MAX_CART_ITEMS);
		}
		
		public static function exists(contentID:String, brandID:String):Boolean
		{
			if(Cart.cart[brandID]) {
				for(var i:int = 0; i < Cart.cart[brandID].length; ++i) {
					if(Cart.cart[brandID][i].contentID == contentID) return true;
				}
			}
				
			return false;
		}
		
		public static function traceCart():void
		{
			trace("\n------ CART ------");
			for(var b:String in Cart.cart) {
				var brand:Vector.<Object> = Cart.cart[b];
				for(var i:int = 0; i < brand.length; ++i) {
					trace("  brand : " + b + " > contentID : " + brand[i].contentID + " > title: " + brand[i].title); 
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
			Cart.appendNumberToTextfields();
		}
		
		public static function forceAdd(contentID:String, brandID:String, title:String):void
		{
			trace("Adding "+contentID+" of brand " + brandID + " to cart.");
			Cart.add(contentID, brandID, title, true);
			
		}
	}
}