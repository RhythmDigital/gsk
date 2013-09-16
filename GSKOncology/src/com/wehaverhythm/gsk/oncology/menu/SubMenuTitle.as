package com.wehaverhythm.gsk.oncology.menu
{
	import com.greensock.TweenMax;
	
	import flash.text.TextField;

	public class SubMenuTitle extends SubMenuTitleDisplay
	{
		public var id:String;
		public var menuParent:String;
		
		public function SubMenuTitle(id:String, menuParent:String, copy:String, brandColour:uint)
		{
			super();
			
			this.id = id;
			this.menuParent = menuParent;
			this.mouseChildren = false;
			this.buttonMode = true;
			
			var tf:TextField = title.txtLabel;
			tf.autoSize = "left";
			tf.text = copy;
			tf.width = 630;
			tf.height = tf.textHeight;
			
			title.y = (bg.height >> 1) - (title.height >> 1);
			
			TweenMax.to(bg, 0, {immediateRender:true, tint:brandColour});
		}
	}
}