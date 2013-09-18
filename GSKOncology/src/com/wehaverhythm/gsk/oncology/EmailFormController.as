package com.wehaverhythm.gsk.oncology
{
	import com.greensock.loading.LoaderMax;
	import com.wehaverhythm.gsk.oncology.cart.Cart;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;

	public class EmailFormController extends EventDispatcher
	{
		public static var FAILED:String = "FAILED";
		public static var SUCCESS:String = "SUCCESS";
		
		private var settings:XML;
		private var loader:URLLoader;
		
		public function EmailFormController()
		{
		}
		
		public function emailCart(theirName:String, emailAddress:String):void
		{
			settings = XML(LoaderMax.getContent("settings"));
			var path:String = settings.downloadsURL;
			var cart:Dictionary = Cart.cart;
			//var message:String = "<h3>Hello " + theirName + ", \nHere are your GSK Oncology items as requested:\n\n</h3><br/><p>";
			var brands:Array = new Array();
			
			var cartJson:Object = new Object();
			cartJson['path'] = path;
			cartJson['cart'] = [];
			
			for(var b:String in Cart.cart) {
				var brand:Vector.<Object> = Cart.cart[b];
				var brandData:XML = Menu.getBrandXML(int(b));
				var items:Array = new Array();
				
				cartJson.cart.push({brand:String(brandData.name), items:items});
				
				for(var i:int = 0; i < brand.length; ++i) {
					var node:XML = XML(brandData.content.content.(@id == brand[i].contentID));
					items.push({
						file:String(node.@cartLink),
						title:String(brand[i].title)
					});
				}
			}
			
			//message += "</p>";
			
			var vars:URLVariables = new URLVariables();
			vars.theirName = encodeURIComponent(theirName);
			vars.theirEmail = encodeURIComponent(emailAddress); //Constants.DEBUG ? "hello@jamie-white.com" : emailAddress);
			vars.cart = encodeURIComponent(JSON.stringify(cartJson));
			vars.sessionID = GSKOncology.sessionID;
			//trace(vars.cart);
			
			Stats.track(GSKOncology.sessionID, "cart", "email");
			doSend(vars, Constants.SCRIPT_PATH+"cart.php");
			
			trace(this, "Emailing cart: ", vars.toString());
		}
		
		public function emailAsk(theirName:String, theirEmail:String, product:String, message:String):void
		{
			var vars:URLVariables = new URLVariables();
			vars.name = encodeURIComponent(theirName);
			vars.email = encodeURIComponent(theirEmail);
			vars.product = encodeURIComponent(product);
			vars.message = encodeURIComponent(message);
			vars.sessionID = GSKOncology.sessionID;
			
			trace(this, "ASKING GSK: ", vars.toString());
			
			Stats.track(GSKOncology.sessionID, "ask", "email");
			
			doSend(vars, Constants.SCRIPT_PATH+"ask.php");
		}
		
		public function doSend(vars:URLVariables, url:String):void
		{
			trace(this, "URL: " + url);
			//var request:URLRequest = new URLRequest(Constants.DEBUG ? CART_MAIL_SCRIPT_LOCAL : CART_MAIL_SCRIPT_LIVE);
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			request.contentType = 'application/x-www-form-urlencoded';
			request.data = vars;
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			loader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			
			loader.load(request);
		}
		
		protected function onIOError(e:IOErrorEvent):void
		{
			trace(this, "IO Error, email failed.");
			destroyLoader();
			dispatchEvent(new Event(EmailFormController.FAILED, true));
		}
		
		protected function onComplete(e:Event):void
		{
			trace(this, "Done: " + e.target.data.result);
			destroyLoader();
			dispatchEvent(new Event(EmailFormController.SUCCESS, true));
		}
		
		public function cancel():void
		{
			destroyLoader();
		}
		
		private function destroyLoader():void
		{
			if(loader) {
				loader.close();
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader = null;
			}
		}
		
		override public function toString():String
		{
			return "EmailFormController :: ";
		}
	}
}