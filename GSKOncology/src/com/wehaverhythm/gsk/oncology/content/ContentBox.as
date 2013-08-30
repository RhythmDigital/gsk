package com.wehaverhythm.gsk.oncology.content
{
	import flash.display.Sprite;
	
	public class ContentBox extends Sprite
	{
		private var d:ContentBoxDisplay;
		private var contentSettings:Object;
		private var brandXML:XML;
		
		public function ContentBox()
		{
			super();
			d = new ContentBoxDisplay();
			addChild(d);
		}
		
		public function setup(contentSettings:Object, brandXML:XML):void
		{
			this.contentSettings = contentSettings;
			this.brandXML = brandXML;
			
			switch(contentSettings["action"]) {
				case "video-box":
					initVideo();
					break;
				case "slideshow-box":
					initSlideshow();
					break;
			}
		}
		
		private function initVideo():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function initSlideshow():void
		{
			// TODO Auto Generated method stub
			
		}
	}
}