package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Sine;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.wehaverhythm.gsk.oncology.content.ContentEvent;
	
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	public class Menu extends Sprite
	{
		private const BUTTON_MARGIN:int = 10;
		private const START_Y_LOGO_BUTTONS:int = 1199;
		private const START_Y_NORMAL_BUTTONS_TITLED:int = 1245;
		private const START_Y_NORMAL_BUTTONS:int = 1134;
		
		private var menuXML:LoaderMax;
		private var buttons:Array;
		private var menuLookup:Array;
		private var imageLoader:LoaderMax;
		private var pickOne:PickOne;
		private var logoHolder:*;
		private var overlay:MenuOverlay;
		private var currentID:String = null;
		private var currentMenu:int = -1;
		private var currentXML:XMLList;
		private var currentSubMenu:int = -1;
		private var prevSubMenu:int = -1;
		
		public var menus:Array;
		
		public function Menu()
		{
			super();
			
			overlay = new MenuOverlay();
			overlay.y = 954;
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
				var nextXML:XMLLoader = new XMLLoader(File.applicationDirectory.url+settingsXML.mainMenus.menu[i].@file);
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
		
		private function showRootMenu():void
		{
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
				//trace("There are no buttons for this item!");
			} else {
				currentID = null;
				currentMenu = -1;
				destroyButtons();
				buttons = newButtons;
				animateButtons();
			}
			
			pickOne.visible = true;
			hideTitle();
			overlay.display.titleBar.visible = false;
			overlay.showButtons(MenuOverlay.TYPE_ROOTNAV);
			dispatchEvent(new ContentEvent(ContentEvent.CONTENT_TRIGGER, {type:"root-menu", brandsXML:menus}));
		}
		
		public function showRootCaption(id:int):void
		{
			// if not on root menu, but root playlist still in bg, don't try and show/hide root captions.
			if(currentSubMenu != -1) return; 
			
			trace("Show root caption for : " + id);
			for(var i:int = 0; i < buttons.length; ++i) {
				MenuButtonLogo(buttons[i]).hideCaption();
			}
			
			MenuButtonLogo(buttons[id]).showCaption();
		}
		
		private function renderButtonsFor(m:int, mid:int, id:String = null):void
		{			
			var newButtons:Array = new Array();
			
			prevSubMenu = currentSubMenu;
			currentSubMenu = mid;
			
			if(id != null){
				var idLen:int = id.split(".").length;
			}

			for(var i:int = 0; i < menuLookup[mid].length; ++i) {
				
				var startY:int;
				
				if(id == null) {
					startY = START_Y_NORMAL_BUTTONS;
					hideTitle();
				} else {
					startY = START_Y_NORMAL_BUTTONS_TITLED;
				}
				
				var valid:Boolean;
				var itemIdLen:int = menuLookup[mid][i].id.split(".").length;
				
				if(id == null || itemIdLen == 1) {
					startY = START_Y_NORMAL_BUTTONS;
				} else {
					startY = START_Y_NORMAL_BUTTONS_TITLED;
				}
				
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
				//trace("There are no buttons for this item!");
			} else {
				currentID = id;
				//trace("currentID: " + currentID);
				currentMenu = mid;
				destroyButtons();
				buttons = newButtons;
				if(currentID != null) { 
					setTitle();
					animateButtons(true);
				} else {
					animateButtons(false);
				}
				
			}
			
			if(currentID == null) {
				dispatchEvent(new ContentEvent(ContentEvent.CONTENT_TRIGGER, {type:"sub-menu", mid:currentMenu}));//xml: menus[mid].content}));
			} else {
				dispatchEvent(new ContentEvent(ContentEvent.CONTENT_TRIGGER, {type:"sub-menu-button", mid:currentMenu, xml: currentXML}));
			}
			
			logoHolder.logoHolder.logo.addChild(LoaderMax.getContent(String(menus[mid].content.logo)));
			overlay.display.addChild(logoHolder);
			TweenMax.to(logoHolder, .3, {autoAlpha:1, ease:Quad.easeOut});
			
			overlay.showButtons(MenuOverlay.TYPE_SUBNAV);
		}
		
		private function hideTitle():void
		{
			overlay.display.titleBar.alpha = 0;
			TweenMax.killTweensOf(overlay.display.titleBar);
		}
		
		private function setTitle():void
		{
			var title:String;
			
			if(currentID == null) {
				title = String(menus[currentMenu].content.title);
			} else {
				title = String(currentXML);
			}
			
			overlay.display.titleBar.txtLabel.text = title;
			TweenMax.to(overlay.display.titleBar.bg, 0, {immediateRender:true, tint:uint("0x"+String(menus[currentMenu].content.colour).substr(1))});
		}
		
		private function animateButtons(showTitle:Boolean = false):void
		{
			var startProps:Object = {x:-100, autoAlpha:0};
			var endProps:Object = {autoAlpha:1, x:0, ease:Quad.easeOut};
			var delay:Number = 0;
			
			if(currentID==null && prevSubMenu == -1) {
				delay = .07;
				TweenMax.fromTo(logoHolder, .27, startProps,{x:endProps.x, autoAlpha:endProps.autoAlpha});
			}
			
			if(showTitle) {
				delay += .07;
				TweenMax.fromTo(overlay.display.titleBar, .27, startProps,{delay:delay, x:endProps.x, autoAlpha:endProps.autoAlpha});
			}
			
			endProps.delay = delay;
			
			TweenMax.staggerFromTo(buttons, .27, startProps, endProps, .07);
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
			// init menus
			for each(var menu:XMLLoader in menus) {
				addMainMenu(XML(menu.content));
			}
			
			loadAssets();			
		}
		
		private function loadAssets():void
		{
			imageLoader = new LoaderMax({onComplete:onAssetsLoaded});
			
			for(var i:int = 0; i < menus.length; ++i) {
				imageLoader.insert(new ImageLoader(File.applicationDirectory.url+"assets/images/"+menus[i].content.logo, {name:menus[i].content.logo}));
			}
			imageLoader.load();
		}
		
		private function onAssetsLoaded(e:LoaderEvent):void
		{
			showRootMenu();
			addEventListener(MenuEvent.SELECT_ITEM, onMenuItemSelected);
			addEventListener(MenuEvent.NAV_BUTTON_CLICKED, onNavButtonClicked);
			
			TweenMax.to(this, .3, {autoAlpha:1, ease:Sine.easeOut, overwrite:2});
		}
		
		protected function onNavButtonClicked(e:MenuEvent):void
		{
			//trace(e.target.id + " clicked at id: " + currentID + " / menu: " + currentMenu);
			
			switch(e.target.id) {
				case "back":
					if(currentMenu == -1) {
						// home.
						//trace("don't go anywhere, i'm already root.");
					} else {
						if(currentID == null) {
							showRootMenu();
						} else {
							var itm:Object = getButtonData(menuLookup[currentMenu], currentID);
							if(itm.parent == "") {
								renderButtonsFor(currentMenu, currentMenu);
							} else {
								renderButtonsFor(currentMenu, currentMenu, itm.parent);
							}
						}
					}
				break;
				
				case "home":
					//trace("Showing root menu...");
					showRootMenu();
					break;
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
		
		public function getBrandXML(num:int):XML {
			return menus[num].content;
		}
		
		protected function onMenuItemSelected(e:MenuEvent):void
		{
			//trace("Item selected: " + e.target.menu + " / " + e.target.xmlID);
			
			// deselect old buttons
			for(var i:int = 0; i < buttons.length; ++i) {
				if(buttons[i] !== e.target) buttons[i].deselect();
			}
			
			// set current xml if exists.
			if(e.target.hasOwnProperty("menu") && e.target.hasOwnProperty("xmlID") && e.target.xmlID !== null)
				currentXML = menus[e.target.menu].content.menu.item.(@id == e.target.xmlID);
			
			renderButtonsFor(menuLookup[e.target.menu], e.target.menu, e.target.xmlID);
		}
	}
}