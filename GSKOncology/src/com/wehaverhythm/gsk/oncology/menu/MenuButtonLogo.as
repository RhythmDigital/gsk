package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.loading.LoaderMax;
	
	import flash.events.MouseEvent;
	
	public class MenuButtonLogo extends MenuButton
	{
		private var d:MenuButtonLogoDisplay;
		private var logo:*;
		
		public function MenuButtonLogo(buttonID:int, xmlID:String, menu:int, label:String, xml:XMLList, menuXML:XML)
		{
			super(buttonID, xmlID, menu, label, xml, menuXML);
			
			d = MenuButtonLogoDisplay(display);
			logo = LoaderMax.getContent(menuXML.logo);
			logo.x = int(-(logo.width>>1));
			logo.y = int(-(logo.height>>1));
			d.bg.logo.addChild(logo);
		}
		
		override protected function getButtonDisplay():*
		{
			return new MenuButtonLogoDisplay;
		}
		
		override protected function onMouseDown(e:MouseEvent):void
		{
			selectButton();
		}
		
		override public function deselect():void
		{
		}
		
		override protected function set buttonText(s:String):void
		{
			// no copy!
		}
		
		override public function destroy():void
		{
			d.bg.logo.removeChild(logo);
			logo = null;
			super.destroy();
		}
	}
}