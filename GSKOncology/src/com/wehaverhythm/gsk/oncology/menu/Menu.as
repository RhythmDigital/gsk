package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	public class Menu extends Sprite
	{
		private var menuXML:LoaderMax;
		private var menus:Array;
		private var buttons:Vector.<MenuButton>;
		private var menuLookup:Array;
		
		public function Menu()
		{
			super();
		}
		
		public function init(settingsXML:XML):void
		{
		//	trace("initialising menu with : " + settingsXML);
			menuXML = new LoaderMax({onComplete:onMenuXMLLoaded});
			menus = [];
			menuLookup = [];
			buttons = new Vector.<MenuButton>();
			
			for(var i:int = 0; i < settingsXML.mainMenus.menu.length(); ++i) {
				var nextXML:XMLLoader = new XMLLoader(File.applicationDirectory.url+settingsXML.mainMenus.menu[i].@file);
				menuXML.insert(nextXML);
				menus.push(nextXML);
			}
			menuXML.load();
		}
		
		private function addMainMenu(menu:XML):void
		{
			//("Adding menu: " + menu);
			var nextMenu:Array = [];
			
			for(var i:int = 0; i < menu.menu.item.length(); ++i)
			{
				var nextBtn:XML = menu.menu.item[i];
				var location:String = String(nextBtn.@id);
				var locationParent:String = location.substr(0, location.lastIndexOf("."));
				var locationRoot:String = location.split(".")[0];
				
				//trace("id: " + location + " / parent: " + locationParent + " / root: " + locationRoot);
				
				nextMenu.push({btn:nextBtn, id:nextBtn.@id, parent:locationParent, root:locationRoot, menuID:menuLookup.length});
			}
			
			menuLookup.push(nextMenu);
			
		}
		
		private function showRootMenu():void
		{
			trace("render buttons for main menu");
			var newButtons:Vector.<MenuButton> = new Vector.<MenuButton>();
			
			
			for(var i:int = 0; i < menus.length; ++i) {
				//trace("Menu " + i);
				//trace(menus[i].content);
				addButton(newButtons, i, null, i, menus[i].content.title);
			}
			
			
			if(!newButtons.length) {
				trace("There are no buttons for this item!");
			} else {
				destroyButtons();
				buttons = newButtons;
			}
		}
		
		private function renderButtonsFor(m:int, mid:int, id:String = null):void
		{			
			var newButtons:Vector.<MenuButton> = new Vector.<MenuButton>();
		
			if(id != null){
				var idLen:int = id.split(".").length;
			}

			for(var i:int = 0; i < menuLookup[mid].length; ++i) {
				
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
					addButton(newButtons, i, menuLookup[mid][i].id, mid, menus[mid].content.menu.item[i], xml);
				}
				
			}
			
			if(!newButtons.length) {
				trace("There are no buttons for this item!");
			} else {
				destroyButtons();
				buttons = newButtons;
			}
		}
		
		public function deepLogArray(array:Array, level:int = 0):void {
			var tabs:String = "";
			for ( var i : int = 0 ; i < level ; i++, tabs += "\t" );
			
			for(var j:int = 0; j < array.length; ++j) {
				trace( tabs + level +" > "+ array[j].button);
				if(array[j].menu is Array) {
					deepLogArray(array[j].menu, level+1);
				}
			}
		}
		
		private function addButton(vec:Vector.<MenuButton>, buttonID:int, xmlID:String, menuID:int, label:String, xml:XMLList = null):void
		{	
			var b:MenuButton = new MenuButton(buttonID, xmlID, menuID, label, xml);
			b.y = vec.length*(b.height+4);
			addChild(b);
			vec.push(b);
		}
		
		private function destroyButtons():void
		{
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
			
			addEventListener(MenuEvent.SELECT_ITEM, onMenuItemSelected);
			showRootMenu();
		}
		
		protected function onMenuItemSelected(e:MenuEvent):void
		{
			trace("Item selected: " + e.target.menu + " / " + e.target.xmlID);
			renderButtonsFor(menuLookup[e.target.menu], e.target.menu, e.target.xmlID);
			
			if(e.target.hasOwnProperty("menu") && e.target.hasOwnProperty("id") && e.target.id !== null)
			{
				trace("button xml: " + menus[e.target.menu][e.target.buttonID]);
			}
			
		}
	}
}