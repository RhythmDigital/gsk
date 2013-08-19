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
			trace("initialising menu with : " + settingsXML);
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
			trace("Adding menu: " + menu);
			var nextMenu:Array = [];

			for(var i:int = 0; i < menu.buttons.button.length(); ++i)
			{
				var nextBtn:XML = menu.buttons.button[i];
				var location:String = String(nextBtn.@id);
				var locationParent:String = location.substr(0, location.lastIndexOf("."));
				var locationRoot:String = location.split(".")[0];
				
				trace("id: " + location + " / parent: " + locationParent + " / root: " + locationRoot);
				
				nextMenu.push({btn:nextBtn, id:nextBtn.@id, parent:locationParent, root:locationRoot, menuID:menuLookup.length});
			}
			
			menuLookup.push(nextMenu);
			
		}
		
		private function renderButtonsFor(m:int, id:String):void
		{
			trace("render buttons for: " + id);
			
			var newButtons:Vector.<MenuButton> = new Vector.<MenuButton>();
			var idLen:int = id.split(".").length;
			
			for(var i:int = 0; i < menuLookup[m].length; ++i) {
				var itemIdLen:int = menuLookup[m][i].id.split(".").length;
				var valid:Boolean = (String(menuLookup[m][i].id).indexOf(id) == 0) && itemIdLen == idLen+1;
				if(valid) {
					trace(menuLookup[m][i].id + ": " + valid);
					addButton(newButtons, menuLookup[m][i].id, m);
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
		
		private function addButton(vec:Vector.<MenuButton>, id:String, menuID:int):void
		{
			var b:MenuButton = new MenuButton(id, menuID, 400, 150);
			b.y = vec.length*(b.height+4);
			addChild(b);
			vec.push(b);
		}
		
		private function destroyButtons():void
		{
			trace("Killing current buttons");
			while(buttons.length) {
				removeChild(buttons[0]);
				buttons.shift();
			}
		}
		
		private function onMenuXMLLoaded(e:LoaderEvent):void
		{
			trace("Menu xml loaded.");
			
			// init menus
			for each(var menu:XMLLoader in menus) {
				addMainMenu(XML(menu.content));
			}
			
			addEventListener(MenuEvent.SELECT_ITEM, onMenuItemSelected);
			renderButtonsFor(0, "0");
		}
		
		protected function onMenuItemSelected(e:MenuEvent):void
		{
			trace("Item selected");
			renderButtonsFor(menuLookup[e.target.menu], e.target.id);
		}
	}
}