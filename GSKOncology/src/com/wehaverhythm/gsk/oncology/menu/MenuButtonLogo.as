package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.LoaderMax;
	import com.wehaverhythm.gsk.oncology.Constants;
	
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class MenuButtonLogo extends MenuButton
	{
		private var d:MenuButtonLogoDisplay;
		private var caption:RootMenuCaptionDisplay;
		private var logo:*;
		
		public function MenuButtonLogo(buttonID:int, xmlID:String, menu:int, label:String, xml:XMLList, menuXML:XML)
		{
			super(buttonID, xmlID, menu, label, xml, menuXML);
			
			d = MenuButtonLogoDisplay(display);
			logo = LoaderMax.getContent(menuXML.logo);
			logo.x = int(-(logo.width>>1));
			logo.y = int(-(logo.height>>1));
			d.bg.logo.addChild(logo);
			
			setupCaption(menuXML);
		}
		
		private function setupCaption(menuXML:XML):void
		{
			var margin:Number = 12;
			
			caption = new RootMenuCaptionDisplay();
			caption.x = width + 10;
			caption.alpha = 0;
			caption.visible = false;
			caption.txtFooter.visible = false;
			caption.bg.height = height;
			
			// tint bg
			TweenMax.to(caption.bg, 0, {tint:uint("0x"+String(menuXML.colour).substr(1)), immediateRender:true});
			
			// set copy
			if(menuXML.rootCaption.hasOwnProperty("footer")) {
				caption.txtFooter.text = menuXML.rootCaption.footer;
				caption.txtFooter.visible = true;
			}
			
			var totalHeight:Number = 0;
			caption.txtCopy.text = String(menuXML.rootCaption.copy);
			caption.txtCopy.autoSize = TextFieldAutoSize.LEFT;
			caption.txtCopy.wordWrap = true; // prevent width-resize!
			
			totalHeight += caption.txtCopy.textHeight;
			if (caption.txtFooter.visible)
			{	
				totalHeight += caption.txtFooter.textHeight;
				totalHeight += margin;
			}
			
			caption.txtCopy.y = ((caption.bg.height >> 1) - (totalHeight>>1)) - 3;
			caption.txtFooter.y = (caption.txtCopy.y+totalHeight) - caption.txtFooter.textHeight;
			addChild(caption);
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
		
		public function showCaption():void
		{
			TweenMax.to(caption, .4, {delay:.1, autoAlpha:1, ease:Quad.easeOut});
		}
		
		public function hideCaption():void
		{
			if(caption.alpha > 0) TweenMax.to(caption, .4, {delay:.1, autoAlpha:0, ease:Quad.easeOut});
		}
		
		override public function destroy():void
		{
			d.bg.logo.removeChild(logo);
			logo = null;
			
			TweenMax.killTweensOf(caption);
			if(contains(caption)) removeChild(caption);
			caption = null;
			
			super.destroy();
		}
	}
}