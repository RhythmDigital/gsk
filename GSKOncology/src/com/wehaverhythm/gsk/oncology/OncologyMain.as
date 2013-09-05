package com.wehaverhythm.gsk.oncology
{
	import com.wehaverhythm.cuepointvideo.CuePointVideoEvent;
	import com.wehaverhythm.gsk.oncology.content.ContentBox;
	import com.wehaverhythm.gsk.oncology.content.ContentEvent;
	import com.wehaverhythm.gsk.oncology.content.ContentManager;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class OncologyMain extends Sprite
	{
		private var settings:XML;
		private var menu:Menu;
		private var contentMan:ContentManager;
		
		public function OncologyMain()
		{
			super();
		}
		
		public function init(settingsXML:XML):void
		{
			menu = new Menu();
			menu.addEventListener(ContentEvent.CONTENT_TRIGGER, onContentTrigger);
			menu.x = 29;
			addChild(menu);
			
			menu.init(settingsXML);

			Cart.init(menu.overlay.buttons[2]);
			
			contentMan = new ContentManager(menu);
			contentMan.addEventListener(ContentBox.CLOSE, onCloseContent);
			addChildAt(contentMan, 0);
			
			var logo:Bitmap = new Bitmap(new GSKLogo(0,0));
			logo.smoothing = true;
			logo.x = 40;
			logo.y = 20;
			addChild(logo);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMousedown);
		//	this.needsSoftKeyboard = true;
		}
		
		protected function onMousedown(e:MouseEvent):void
		{
		//	stage.focus = this;
		//	trace(this.requestSoftKeyboard());
		}
		
		protected function onCloseContent(e:Event):void
		{
			trace("Close in main.");
			menu.currentButton.deselect();
		}
		
		protected function onContentTrigger(e:ContentEvent):void
		{
			trace("Content Trigger: " + e);
			
			contentMan.hideCurrentOverlays();
			
			var contentID:String = null;
			
			switch(e.params.type) {
				case "root-menu":
					//trace("Playing sequence of videos for "+e.params.menuType+": " + e.params.brandsXML);
					trace(">> Root Menu Content");
					contentMan.showRootPlaylist(e.params.brandsXML);
				break;
				
				case "sub-menu":
					trace(">> Sub Menu Content");
					contentID = String(menu.menus[e.params.mid].content.menu.attribute("contentID"));
				break;
				
				case "sub-menu-button":
					trace(">> Sub Menu Button Content");
					contentID = String(e.params.xml.attribute("contentID"));
				break;
			}
			
			trace("CONTENT ID: " + contentID);
			
			if(contentID != null && contentID.length) {
				contentMan.showContent(contentID, e.params.mid, menu.getBrandXML(e.params.mid));
			} else {
				trace("No content for this node");
			}
		}
	}
}