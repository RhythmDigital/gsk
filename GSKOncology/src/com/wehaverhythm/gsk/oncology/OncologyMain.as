package com.wehaverhythm.gsk.oncology
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.gsk.oncology.ask.AskView;
	import com.wehaverhythm.gsk.oncology.cart.Cart;
	import com.wehaverhythm.gsk.oncology.cart.CartView;
	import com.wehaverhythm.gsk.oncology.content.ContentBox;
	import com.wehaverhythm.gsk.oncology.content.ContentEvent;
	import com.wehaverhythm.gsk.oncology.content.ContentManager;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	import com.wehaverhythm.utils.IdleTimeout;
	import com.wehaverhythm.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	public class OncologyMain extends Sprite
	{
		private var settings:XML;
		private var menu:Menu;
		private var contentMan:ContentManager;
		private var askView:AskView
		private var footer:MenuFooter;
		private var startTime:int;
		private var endTime:int;
		
		public function OncologyMain()
		{
			super();
		}
		
		public function init(settingsXML:XML):void
		{
			menu = new Menu();
			menu.addEventListener(Menu.ASSETS_LOADED, onAssetsLoaded);
			menu.addEventListener(ContentEvent.CONTENT_TRIGGER, onContentTrigger);
			menu.addEventListener(Menu.CLOSE_CURRENT_CONTENT, onCloseCurrentContent);
			menu.x = 29;
			addChild(menu);
			menu.init(settingsXML);
		}
		
		protected function onCloseCurrentContent(e:Event):void
		{
			contentMan.content.close();
		}
		
		protected function onAssetsLoaded(event:Event):void
		{
			Cart.init(new CartView());
			Cart.addCounterTF(menu.overlay.buttons[2].getTextField(), "VIEW CART");
			
			contentMan = new ContentManager(menu);
			contentMan.addEventListener(ContentBox.CLOSE, onCloseContent);
			addChildAt(contentMan, 0);
			
			askView = new AskView();
			addEventListener(AskView.SHOW, onAskViewShow);
			addChild(askView);
			
			addChild(Cart.view);
			addEventListener(CartView.CLOSING, onCartClosing);
			
			var logo:Bitmap = new Bitmap(new GSKLogo(0,0));
			logo.smoothing = true;
			logo.x = 40;
			logo.y = 20;
			addChild(logo);
			
			footer = new MenuFooter();
			footer.y = Constants.HEIGHT - footer.height;
			addChild(footer);
			
			IdleTimeout.init(stage, Constants.DEBUG ? 10000 : int(Settings.data.idleTimeoutMS), onIdleTimeout);
			waitForUser();
		}
		
		private function onIdleTimeout():void
		{
			var endTime:int = getTimer();
			var duration:int = endTime - startTime - IdleTimeout.timeout;
			
			var hrs:int = (duration / (1000*60*60)) % 24;
			var mins:int = (duration / (1000*60)) % 60;
			var secs:int = (duration / 1000) % 60;
			
			var timeStr:String = 
				(hrs > 9 ? hrs : "0"+hrs) + ":" + 
				(mins > 9 ? mins : "0" + mins) + ":" + 
				(secs > 9 ? secs : "0"  + secs);
			
			trace("SESSION ENDED. Total duration: " + timeStr);
			// trace(totalTime.h, totalTime.m, totalTime.s, totalTime.ms);
			mouseEnabled = mouseChildren = false;
			Cart.view.hide();
			askView.hide(true);
			Cart.reset();
			if(menu.type != "root-menu") menu.showRootMenu();
			TweenMax.delayedCall(1, timeoutTransitionComplete);
			
			Stats.track(GSKOncology.sessionID, Menu.PAGE_HOME, Stats.ACTION_SESSION_END, timeStr);
			
			waitForUser();
		}
		
		private function waitForUser():void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onSessionStartTrigger);
		}
		
		protected function onSessionStartTrigger(e:MouseEvent):void
		{
			startTime = getTimer();
			GSKOncology.sessionID = new Date().time;
			trace("SESSION STARTED >> " + GSKOncology.sessionID);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onSessionStartTrigger);
			Stats.track(GSKOncology.sessionID, Menu.PAGE_HOME, Stats.ACTION_SESSION_START, null, Settings.data.screenID);
		}
		
		private function timeoutTransitionComplete():void
		{
			mouseEnabled = mouseChildren = true;
		}
		
		protected function onAskViewShow(e:Event):void
		{
			askView.show(askView.privacy);
		}
		
		protected function onCartClosing(e:Event):void
		{
			contentMan.content.checkItemInCart();
		}
		
		protected function onCloseContent(e:Event):void
		{
			trace("CLOSING CONTENT IN MAIN.");
			if(menu.currentButton) {
				menu.contentClose();
			}
		}
		
		protected function onContentTrigger(e:ContentEvent):void
		{
			contentMan.hideCurrentOverlays();
			
			var contentID:String = null;
			
			switch(e.params.type) {
				case "root-menu":
					contentMan.showRootPlaylist(e.params.brandsXML);
				break;
				
				case "sub-menu":
					
					contentID = String(Menu.menus[e.params.mid].content.menu.item.(@id == menu.currentID).attribute("contentID"));
					
					if(!contentID.length) {
						//	fall back to product menu content id
						contentID = String(Menu.menus[e.params.mid].content.menu.attribute("contentID"));
						//	trace("sub-menu -> fall back to product menu content id : ", contentID);
					}/* else {
						//	trace("sub-menu -> using content id : ", contentID);
					}*/
					
				break;
				
				case "sub-menu-button":
					contentID = String(e.params.xml.attribute("contentID"));
				break;
			}
			
			if(contentID != null && contentID.length) {
				contentMan.showContent(contentID, e.params.mid, Menu.getBrandXML(e.params.mid), e.params.type);
				if(ContentManager.boxOpen) {
				}
			}/* else {
				trace("No content for this node");
			}*/
		}
	}
}