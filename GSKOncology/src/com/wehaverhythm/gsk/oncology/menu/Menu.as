package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Sine;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.Stats;
	import com.wehaverhythm.gsk.oncology.ask.AskView;
	import com.wehaverhythm.gsk.oncology.cart.Cart;
	import com.wehaverhythm.gsk.oncology.content.ContentBox;
	import com.wehaverhythm.gsk.oncology.content.ContentEvent;
	import com.wehaverhythm.gsk.oncology.content.ContentManager;
	import com.wehaverhythm.utils.IdleTimeout;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class Menu extends Sprite
	{
		public static var SELECTED_BUTTON_COPY:String = "";
		public static var ASSETS_LOADED:String = "ASSETS_LOADED";
		public static const CLOSE_CURRENT_CONTENT:String = "CLOSE_CURRENT_CONTENT";
		
		public static var PAGE_HOME:String = "home";
		public static var PAGE_ASK:String = "ask";
		public static var PAGE_CART:String = "cart";
		
		private const BUTTON_MARGIN:int = 9;
		private const START_Y_LOGO_BUTTONS:int = 1206;
		private const START_Y_NORMAL_BUTTONS_TITLED:int = 1241;
		private const START_Y_NORMAL_BUTTONS:int = 1141;
		
		private var menuXML:LoaderMax;
		private var buttons:Array;
		private var menuLookup:Array;
		private var imageLoader:LoaderMax;
		private var pickOne:PickOne;
		private var logoHolder:*;
		
		private var currentMenu:int = -1;
		private var currentXML:XMLList;
		private var currentSubMenu:int = -1;
		private var prevSubMenu:int = -1;
		private var brandColour:uint;
		public var type:String = "";
		private var isSubMenu:Boolean
		
		public var overlay:MenuOverlay;
		public var currentButton:MenuButton;
		public var currentID:String = null;
		public static var menus:Array;
		
		private var menuLevel:int;
		private var breadcrumb:Array;
	//	public var contentOpen:Boolean;
		private var prevItem:Object;
		
		public function Menu()
		{
			super();
			
			overlay = new MenuOverlay();
			overlay.y = 964;
			addChild(overlay);
			
			pickOne = overlay.display.pickOne;
			
			logoHolder = overlay.display.logoHolder;
			overlay.display.removeChild(logoHolder);
			
			alpha = 0;
			visible = false;
		}
		
		public function init(settingsXML:XML):void
		{
			menuXML = new LoaderMax({onComplete:onMenuXMLLoaded});
			menus = [];
			menuLookup = [];
			buttons = new Array();
			
			for(var i:int = 0; i < settingsXML.mainMenus.menu.length(); ++i) {
				var xmlPath:String = Constants.CONTENT_DIR.url+"/"+settingsXML.mainMenus.menu[i].@file;
				var nextXML:XMLLoader = new XMLLoader(xmlPath);
				menuXML.insert(nextXML);
				menus.push(nextXML);
			}
			menuXML.load();
		}
		
		private function addMainMenu(menu:XML):void
		{
			var nextMenu:Array = [];
			for(var i:int = 0; i < menu.menu.item.length(); ++i)
			{
				var nextBtn:XML = menu.menu.item[i];
				var location:String = String(nextBtn.@id);
				var locationParent:String = location.substr(0, location.lastIndexOf("."));
				var locationRoot:String = location.split(".")[0];
				
				if(locationParent == "") locationParent = locationRoot = null;
				//trace("id: " + location + " / parent: " + locationParent + " / root: " + locationRoot);
				nextMenu.push({btn:nextBtn, id:nextBtn.@id, parent:locationParent, root:locationRoot, menuID:menuLookup.length});
			}
			
			menuLookup.push(nextMenu);
		}
		
		public function showRootMenu():void
		{
			resetBreadcrumb();
			
			//trace("render buttons for main menu");
			var newButtons:Array = new Array();
			
			prevSubMenu = currentSubMenu;
			currentSubMenu = -1;
			
			for(var i:int = 0; i < menus.length; ++i) {
				//trace("Menu " + i);
				//trace(menus[i].content);
				addButton(newButtons, i, null, i, menus[i].content.title, null, true, START_Y_LOGO_BUTTONS);
			}
			
			if(!newButtons.length) {
				trace("There are no buttons for this item!");
				mouseEnabled = mouseChildren = true;
			} else {
				currentID = null;
				currentMenu = -1;
				destroyButtons();
				buttons = newButtons;
				animateButtons();
			}
			
			pickOne.visible = true;
			overlay.showButtons(MenuOverlay.TYPE_ROOTNAV);
			type = "root-menu";
			isSubMenu = false;
		//	contentOpen = false;
			dispatchEvent(new ContentEvent(ContentEvent.CONTENT_TRIGGER, {type:type, brandsXML:menus}));
		}
		
		public function showRootCaption(id:int):void
		{
			// if not on root menu, but root playlist still in bg, don't try and show/hide root captions.
			if(currentSubMenu != -1) return; 
			
			MenuButtonLogo(buttons[id]).showCaption();
		}
		
		public function hideRootCaptions():void
		{
			if(currentSubMenu != -1) return;
			
			for(var i:int = 0; i < buttons.length; ++i) {
				MenuButtonLogo(buttons[i]).hideCaption();
			}
		}
		
		private function renderButtonsFor(m:int, mid:int, id:String = null, menuSelection:Boolean = false):void
		{			
			trace("%%%% RENDER FOR : " + id);
		//	contentOpen = false;
			var newButtons:Array = new Array();
			type = "";
			
			prevSubMenu = currentSubMenu;
			currentSubMenu = mid;
			
		//	trace("PREVIOUS ITEM: " , prevItem ? prevItem.id : null);
			
			if(id != null){
				var idLen:int = id.split(".").length;
			}

			for(var i:int = 0; i < menuLookup[mid].length; ++i) {
				
				var startY:int = START_Y_NORMAL_BUTTONS;
				var valid:Boolean;
				var itemIdLen:int = menuLookup[mid][i].id.split(".").length;
				
				if(id == null && itemIdLen == 1) {
					// root item.
					valid = true;
				} else {
					valid = (String(menuLookup[mid][i].id).indexOf(id) == 0) && itemIdLen == idLen+1;
				}
				
				if(valid) {
					var xml:XMLList = XMLList(menus[mid].content.menu.item.(@id==id));
					addButton(newButtons, i, menuLookup[mid][i].id, mid, menus[mid].content.menu.item[i], xml, false, startY);
				}
			}
			
			if(!newButtons.length) {
				// There are no buttons for this item!
				currentID = id;
				currentMenu = mid;
				isSubMenu = false;
				mouseEnabled = mouseChildren = true;
			} else {
				currentID = id;
				currentMenu = mid;
				isSubMenu = true;
				destroyButtons();
				buttons = newButtons;
				if(menuSelection) breadcrumbLevelUp();
				positionMenuElements();
				animateButtons(breadcrumb.length ? true : false, menuSelection);
			}
			
			if(currentID == null && isSubMenu) {
				// BRAND MENU
				Stats.track(GSKOncology.sessionID, Menu.getBrandXML(mid).name, Stats.ACTION_NAVIGATE);
			} else {
				Stats.track(GSKOncology.sessionID, Menu.getBrandXML(mid).menu.item.(@id == currentID), Stats.ACTION_NAVIGATE);
			}
			
			if(currentID == null || isSubMenu) {
				type = "sub-menu";
				dispatchEvent(new ContentEvent(ContentEvent.CONTENT_TRIGGER, {type:type, mid:currentMenu, xml: currentXML}));//xml: menus[mid].content}));
			} else {
				type = "sub-menu-button";
				dispatchEvent(new ContentEvent(ContentEvent.CONTENT_TRIGGER, {type:type, mid:currentMenu, xml: currentXML}));
			}
			
			brandColour = uint("0x"+String(menus[currentMenu].content.colour).substr(1));
			
			logoHolder.logoHolder.logo.addChild(LoaderMax.getContent("logo"+mid));
			overlay.display.addChild(logoHolder);
			TweenMax.to(logoHolder.leftBar, 0, {tint:brandColour, immediateRender:true});
			TweenMax.to(logoHolder, .3, {autoAlpha:1, ease:Quad.easeOut});
			
			overlay.showButtons(MenuOverlay.TYPE_SUBNAV);
			
			// trace(" >>> BUTTON TYPE : " + type);
			prevItem = getButtonData(menuLookup[mid], id);
		}
		
		private function animateButtons(showTitles:Boolean = false, menuSelection:Boolean = false):void
		{
			var startProps:Object = {x:-100, autoAlpha:0};
			var endProps:Object = {autoAlpha:1, x:0, ease:Quad.easeOut};
			var delay:Number = 0;//.1;
			var time:Number = 0.35;
			
			if(currentID==null && prevSubMenu == -1) {
				delay += .07;
				//logoHolder.visible = false;
				TweenMax.fromTo(logoHolder, time, startProps,{delay:delay, x:endProps.x, autoAlpha:endProps.autoAlpha});
			}
			
			if(showTitles && (breadcrumb.length > 1 || menuSelection)) {
				//for(var i:int = 0; i < breadcrumb.length; ++i) {
					delay += .07;
					TweenMax.fromTo(breadcrumb[breadcrumb.length-1], time, startProps,{delay:delay, x:endProps.x, autoAlpha:endProps.autoAlpha});
				//}
			}
			
			endProps.delay = delay;
			endProps.onComplete = onMenuTransitionComplete;
			TweenMax.staggerFromTo(buttons, time, startProps, endProps, .07);
		}
		
		private function onMenuTransitionComplete():void
		{
			mouseEnabled = mouseChildren = true;
		}
		
		private function addButton(btns:Array, buttonID:int, xmlID:String, menuID:int, label:String, xml:XMLList = null, logo:Boolean = false, startY:int = 0):void
		{	
			var c:Class = logo ? MenuButtonLogo : MenuButton;
			
			var b:MenuButton = new c(buttonID, xmlID, menuID, label, xml, menus[menuID].content);
			b.y = startY+int(btns.length*(b.height+BUTTON_MARGIN));
			addChild(b);
			btns.push(b);
		}
		
		private function destroyButtons():void
		{
			pickOne.visible = false;
						
			if(overlay.display.contains(logoHolder)) {
				overlay.display.removeChild(logoHolder);
				if(logoHolder.logoHolder.logo.numChildren > 0)
					logoHolder.logoHolder.logo.removeChildAt(0);
			}
			
			while(buttons.length) {
				buttons[0].destroy();
				removeChild(buttons[0]);
				buttons.shift();
			}
		}
		
		private function onMenuXMLLoaded(e:LoaderEvent):void
		{
			for each(var menu:XMLLoader in menus)
				addMainMenu(XML(menu.content));
			
			loadAssets();			
		}
		
		private function loadAssets():void
		{
			imageLoader = new LoaderMax({onComplete:onAssetsLoaded});
			
			for(var i:int = 0; i < menus.length; ++i)
				imageLoader.insert(
					new ImageLoader(
						Constants.CONTENT_DIR.url+"/"+menus[i].content.name+"/images/logo.png", {name:"logo"+i}
					)
				);
			
			imageLoader.load();
		}
		
		private function onAssetsLoaded(e:LoaderEvent):void
		{
			dispatchEvent(new Event(Menu.ASSETS_LOADED, true));
			showRootMenu();
			addEventListener(MenuEvent.SELECT_ITEM, onMenuItemSelected);
			addEventListener(MenuEvent.NAV_BUTTON_CLICKED, onNavButtonClicked);
			TweenMax.to(this, .3, {autoAlpha:1, ease:Sine.easeOut, overwrite:2});
		}
		
		protected function onNavButtonClicked(e:MenuEvent):void
		{
			
			//trace(e.target.id + " clicked at id: " + currentID + " / menu: " + currentMenu);
			processNavEvent(e.target.id, getButtonData(menuLookup[currentMenu], currentID));
		}
		
		private function processNavEvent(id:String, itm:Object):void
		{
			var renderButtons:Boolean;
			var renderContentID:String;
			
			//trace("contentOpen: " + ContentManager.boxOpen);
			if(id == "back" && !ContentManager.boxOpen) {
				breadcrumbLevelDown();
			}
			
			if(id == "back" && type == "sub-menu-button" && !itm.parent) {
				if(itm.parent == null) {
					showRootMenu();
				} else {
					renderButtons = true;
					renderContentID = null;
				}
			} else {
				
				IdleTimeout.startListening();
				
				switch(id) {
					case "back":					
						if(currentMenu == -1) {
							//trace("don't go anywhere, i'm already root.");
						} else {
							if(currentID == null) {
								showRootMenu();
							} else {
								if(itm.parent == "") {
									renderButtons = true;
									renderContentID = null;
								} else {
									if(ContentManager.boxOpen) {
										renderButtons = true;
										renderContentID = prevItem.parent;
									} else {
										renderButtons = true;
										renderContentID = itm.parent;
									}
								}
							}
						}
						
						break;
					case Menu.PAGE_HOME:
						showRootMenu();
						break;
					case Menu.PAGE_CART:
						Cart.showCart();
						break;
					case Menu.PAGE_ASK:
						dispatchEvent(new Event(AskView.SHOW, true));
						break;
				}
				
			}
			
			
			if(renderButtons) {
				renderButtonsFor(currentMenu, currentMenu, renderContentID);
			}
		}
		
		private function getButtonData(menu:Array, buttonID:String):Object {
			for each(var button:Object in menu) {
				if(buttonID == String(button.id)) {
					return button;
				}
			}
			return null;
		}
		
		public static function getBrandXML(num:int):XML {
			return menus[num].content;
		}
		
		protected function onMenuItemSelected(e:MenuEvent):void
		{
			mouseEnabled = mouseChildren = false;
			currentButton = MenuButton(e.target);
			
			if(e.target.textField) Menu.SELECTED_BUTTON_COPY = e.target.textField.text;
			/*
			if(e.target.textField) {
				Menu.SELECTED_BUTTON_COPY = e.target.textField.text;
				trace("Item selected: " + e.target.menu + " / " + e.target.xmlID + " / " + Menu.SELECTED_BUTTON_COPY);
			} else {
				trace("Item selected: " + e.target.menu + " / " + e.target.xmlID);
			}
			*/
			// deselect old buttons
			for(var i:int = 0; i < buttons.length; ++i) {
				if(buttons[i] !== e.target) buttons[i].deselect();
			}
			
			// set current xml if exists.
			if(e.target.hasOwnProperty("menu") && e.target.hasOwnProperty("xmlID") && e.target.xmlID !== null)
				currentXML = menus[e.target.menu].content.menu.item.(@id == e.target.xmlID);
			
			renderButtonsFor(menuLookup[e.target.menu], e.target.menu, e.target.xmlID, true);
		}
		
		/**
		 * BREADCRUMB
		 */
		
		private function positionMenuElements():void
		{
			var nextY:int = START_Y_NORMAL_BUTTONS;
			var i:int;
			
			for(i = 0; i < breadcrumb.length; ++i) {
				breadcrumb[i].y = nextY;
				nextY += breadcrumb[i].height + BUTTON_MARGIN;
			}
			
			for(i = 0; i < buttons.length; ++i) {
				buttons[i].y = nextY;// + BUTTON_MARGIN;
				nextY += buttons[i].height + BUTTON_MARGIN;
			}
		}
		
		[Inline]
		private function addBreadcrumbItem():void
		{
			var titleText:String;
			
			if(currentID == null) {
				titleText = String(menus[currentMenu].content.title);
			} else {
				titleText = String(currentXML);
			}
			
			var title:SubMenuTitle = new SubMenuTitle(currentID, getButtonData(menuLookup[currentMenu], currentID).parent, titleText, brandColour);
			title.addEventListener(MouseEvent.MOUSE_DOWN, onTitleClicked, false, 0, true);
			breadcrumb.push(title);
			addChild(title);
		}
		
		protected function onTitleClicked(e:MouseEvent):void
		{
			var moveUpChain:int;
			var breadcrumbDepth:int;
			var i:int = 0;
			
			for(i; i < breadcrumb.length; ++i)
				if(breadcrumb[i] == e.target) break;
			
			breadcrumbDepth = i;
			moveUpChain = (breadcrumb.length-breadcrumbDepth)-1;
			
			if(breadcrumbDepth == breadcrumb.length-1) {
				dispatchEvent(new Event(Menu.CLOSE_CURRENT_CONTENT, true));
			} else {
				for(i = 0; i < moveUpChain; i++) breadcrumbLevelDown();
				renderButtonsFor(currentMenu, currentMenu, e.target.id, false);
			}
		}
		
		[Inline]
		private function removeBreadcrumbItem():void
		{
			removeChild(breadcrumb[breadcrumb.length-1]);
			breadcrumb.pop();
		}
		
		public function breadcrumbLevelUp():void
		{
			menuLevel++;
			if(menuLevel > 1) addBreadcrumbItem();
			trace("\n\nLEEEEVELING UUUP!!! >>> menuLevel: " + menuLevel + " / array: " + breadcrumb.length+"\n\n");
		}
		
		public function breadcrumbLevelDown():void
		{
			if(menuLevel > 1) removeBreadcrumbItem();
			menuLevel--;
			trace("\n\nLEEEEVELING DOWWN!!! >>> menuLevel: " + menuLevel + " / array: " + breadcrumb.length+"\n\n");
		}
		
		private function resetBreadcrumb():void
		{
			menuLevel = 0;
			
			if(!breadcrumb) {
				breadcrumb = new Array();
			} else {
				while(breadcrumb.length) {
					removeChild(breadcrumb[0]);
					breadcrumb.shift();
				}
			}
			
			trace("*** -> ", "Reset breadcrumb :: " + menuLevel);
		}
	}
}