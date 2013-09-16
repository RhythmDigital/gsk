package com.wehaverhythm.gsk.oncology.content
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Caption extends Sprite
	{
		private const TYPE_TITLE:String = "title";
		private const TYPE_TEXT:String = "body";
		private const TYPE_IMAGE:String = "image";
		private const TYPE_FOOTER:String = "footer";
		
		private const PADDING:Point = new Point(20,20);
		
		private var colour:uint;
		private var bg:Sprite;
		private var elements:Array;
		private var boxWidth:int;
		private var canShowCaption:Boolean;
		private var loader:LoaderMax;
		
		public var ready:Boolean;
		private var verbose:Boolean = true;
		private var xml:XML;
		private var brandID:int;
		
		public function Caption()
		{
			super();
			alpha = 0;
		}
		
		public function setup(xml:XML, col:String, brandID:int):void
		{
			this.brandID = brandID;
			this.xml = xml;
			this.colour = uint("0x"+String(col).substr(1));
			this.boxWidth = int(xml.@boxWidth);
			
			loader = new LoaderMax({onComplete:onLoadComplete});
			
			// fill bg
			bg = new Sprite();
			with(bg.graphics) {
				beginFill(colour);
				drawRect(0,0,int(xml.@boxWidth),500);
				endFill();
			}
			addChild(bg);
			
			if(verbose) trace("-------------------------");
			if(verbose) trace("Add caption: ");
			elements = [];
			
			for(var i:int = 0; i < xml.children().length(); ++i) {
				var n:String = String(xml.children()[i].name());
				addElement(n, String(xml.children()[i]));
			}
			if(verbose) trace("-------------------------");
			
			var xySplit:Array = String(xml.@boxXY).split(",");
			x = int(xySplit[0]); // get x pos
			y = int(xySplit[1]); // get y pos
			
			visible = false;
			alpha = 0;
			
			
			
			if(loader.numChildren > 0) {
				if(verbose) trace("LOADER: " + loader);
				loader.load();
			} else {
				ready = true;
			}
		}
		
		public function addElement(type:String, data:String):void
		{
			if(verbose) trace("\tAdd element: " + type+": " + data);
			var el:*;
			
			switch(type) {
				case TYPE_TITLE:
					el = createTextField(data, 30, true);
					break;
				case TYPE_TEXT:
					el = createTextField(data, 28, true);
					break;
				case TYPE_IMAGE:
					var imgLoader:ImageLoader = addImage(data);
					loader.insert(imgLoader);
					el = imgLoader.content;
					break;
				case TYPE_FOOTER:
					el =  createTextField(data, 15, true);
					break;
			}
			
			addChild(el);
			elements.push(el);
		}
		
		private function onLoadComplete(e:LoaderEvent):void
		{
			ready = true;
			
			// fade in if alpha is still zero.
			if(canShowCaption && alpha == 0) {
				showCaption();
			}
		}
		
		private function addImage(data:String):ImageLoader
		{
			return new ImageLoader(Constants.CONTENT_DIR.url+"/"+Menu.getBrandXML(brandID).name+Constants.PATH_CAPTION_IMAGES+data);
		}
		
		private function createTextField(text:String, size:Number = 30, multiline:Boolean = false):CopyBox
		{
			var tf:CopyBox = new CopyBox(text, size, boxWidth-(PADDING.x*2), multiline);
			tf.x = 10;
			return tf;
		}
		
		private function positionElements():void
		{
			var pt:Point = new Point(PADDING.x, PADDING.y);
			var gap:int = PADDING.y;
			
			for(var i:int = 0; i < elements.length; ++i) {
				var el:* = elements[i];
				el.x = pt.x;
				el.y = pt.y;
				pt.y += el.height+gap;
			}
			
			bg.height = pt.y;
		}
		
		public function showCaption():void
		{
			canShowCaption = true;
			if(!ready) return;
			
			if(verbose) trace("SHOWING CAPTION.");
			
			positionElements();
			
			alpha = 0;
			
			visible = false;
			TweenMax.to(this, .4, {delay:.1, autoAlpha:1, ease:Quad.easeOut});
		}
		
		public function hideCaption(removeFromParent:Boolean):void
		{
			var p:Object = {delay:.1, autoAlpha:0, ease:Quad.easeOut};
			
			canShowCaption = false;
			
			if(parent && removeFromParent) {
				p.onComplete = parent.removeChild;
				p.onCompleteParams = [this];
			}
			
			if(alpha > 0) TweenMax.to(this, .4, p);
		}
		
		public function destroy():void
		{
			if(verbose) trace("destroy annotation");
			
			while(elements.length) {
				if(elements[0].hasOwnProperty("destroy")) elements[0].destroy();
				if(contains(elements[0])) removeChild(elements[0]);
				elements.shift();
			}
			elements = null;
			
			if(loader) {
				loader.cancel();
				loader.dispose(true);
				loader = null;
			}
			
			TweenMax.killTweensOf(this);
			
			removeChild(bg);
			bg = null;
			xml = null;
		}
	}
}