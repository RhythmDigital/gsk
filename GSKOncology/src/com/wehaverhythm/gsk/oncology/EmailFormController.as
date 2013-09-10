package com.wehaverhythm.gsk.oncology
{
	import com.greensock.loading.LoaderMax;
	import com.wehaverhythm.gsk.oncology.cart.Cart;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;

	public class EmailFormController
	{
		public static const CART_MAIL_SCRIPT_LIVE:String = "http://www.gsk-downloads.com/scripts/cart_mail.php";
		public static const CART_MAIL_SCRIPT_LOCAL:String = "http://gsk.local/scripts/cart_mail.php";
		
		private var settings:XML;
		
		public function EmailFormController()
		{
			
		}
		
		public function emailCart(theirName:String, emailAddress:String):void
		{
			settings = XML(LoaderMax.getContent("settings"));
			var path:String = settings.downloadsURL;
			var cart:Dictionary = Cart.cart;
			var message:String = "Hello " + theirName + ", \nHere are your GSK Oncology items as requested:\n\n";
			var brands:Array = new Array();
			
			for(var b:String in Cart.cart) {
				var brand:Vector.<Object> = Cart.cart[b];
				var brandData:XML = Menu.getBrandXML(int(b));
				//trace(brandData.toXMLString());
				for(var i:int = 0; i < brand.length; ++i) {
					var node:XML = XML(brandData.content.content.(@id == brand[i].contentID));
					trace(node.toXMLString());
					
					message += brand[i].title+ ": " + path+"/"+node.@cartLink+"\n";
					
					//	trace(cart[b] + ": " + 
					//	trace("  brand : " + b + " > contentID : " + brand[i].contentID + " > title: " + brand[i].title); 
				}
			}
			
			var vars:URLVariables = new URLVariables();
			vars.theirName = encodeURIComponent(theirName);
			vars.theirEmail = encodeURIComponent(Constants.DEBUG ? "hello@jamie-white.com" : emailAddress);
			vars.theirMessage = encodeURIComponent(message);
			
			var request:URLRequest = new URLRequest(Constants.DEBUG ? CART_MAIL_SCRIPT_LOCAL : CART_MAIL_SCRIPT_LIVE);
			request.method = URLRequestMethod.POST;
			request.contentType = 'application/x-www-form-urlencoded';
			request.data = vars;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			loader.load(request);
			
			trace("Emailing cart: ", vars.toString());
		}
		
		protected function onIOError(e:IOErrorEvent):void
		{
			trace("Failed.");
		}
		
		protected function onComplete(e:Event):void
		{
			trace("Done.");
			//trace(URLLoader(e.target).data);
		}
	}
}