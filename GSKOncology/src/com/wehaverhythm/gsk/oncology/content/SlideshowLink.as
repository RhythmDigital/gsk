package com.wehaverhythm.gsk.oncology.content
{
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.Settings;
	
	import flash.display.Sprite;
	
	public class SlideshowLink extends Sprite
	{
		public var id:int;
		public var targ:String;
		
		public function SlideshowLink(id:int, item:XML)
		{
			super();
			
			this.buttonMode = true;
			
			this.id = id;
			this.targ = String(item.@fileTo);
			
			var rect:Array = String(item.@linkRect).split(",");
			
			graphics.clear();
			graphics.beginFill(0xff0000, Settings.data.showSlideHotspots == "true" ? .3 : 0);
			graphics.drawRect(Number(rect[0]), Number(rect[1]), Number(rect[2]), Number(rect[3]));
			graphics.endFill();
		}
		
		public function destroy():void
		{
			targ = null;
			graphics.clear();
		}
	}
}