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
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class OncologyMain extends Sprite
	{
		private var settings:XML;
		private var menu:Menu;
		private var contentMan:ContentManager;
		private var askView:AskView
		private var footer:MenuFooter;
		
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
			
			//if(Constants.DEBUG) stage.addEventListener(KeyboardEvent.KEY_DOWN, onDebugKeyDown);
			
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
			
			IdleTimeout.init(stage, Constants.IDLE_TIMEOUT_MS, onIdleTimeout);
			waitForUser();
		}
		
		private function onIdleTimeout():void
		{
			trace("SESSION ENDED!");
			mouseEnabled = mouseChildren = false;
			Cart.view.hide();
			askView.hide(true);
			Cart.reset();
			if(menu.type != "root-menu") menu.showRootMenu();
			TweenMax.delayedCall(1, timeoutTransitionComplete);
			
			Stats.track(GSKOncology.sessionID, Menu.PAGE_HOME, Stats.ACTION_SESSION_END);
			waitForUser();
		}
		
		private function waitForUser():void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSessionStartTrigger);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSessionStartTrigger);
		}
		
		protected function onSessionStartTrigger(e:MouseEvent):void
		{
			GSKOncology.sessionID = new Date().time;
			trace("SESSION STARTED >> " + GSKOncology.sessionID);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSessionStartTrigger);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSessionStartTrigger);
			Stats.track(GSKOncology.sessionID, Menu.PAGE_HOME, Stats.ACTION_SESSION_START);
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
		/*
		private var contentID:int = 0;
		protected function onDebugKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.SPACE) Cart.forceAdd(String(contentID), "99999", "A title " + contentID);
			contentID++;
		}
		*/
		protected function onCloseContent(e:Event):void
		{
			if(menu.currentButton) menu.currentButton.deselect();
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
						// fall back to product menu content id
						contentID = String(Menu.menus[e.params.mid].content.menu.attribute("contentID"));
						trace("sub-menu -> fall back to product menu content id : ", contentID);
					} else {
						trace("sub-menu -> using content id : ", contentID);
					}
					
				break;
				
				case "sub-menu-button":
					trace(e.params.xml.toXMLString());
					contentID = String(e.params.xml.attribute("contentID"));
				break;
			}
			
			if(contentID != null && contentID.length) {
				contentMan.showContent(contentID, e.params.mid, Menu.getBrandXML(e.params.mid));
			} else {
				trace("No content for this node");
			}
		}
	}
}