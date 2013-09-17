package com.wehaverhythm.gsk.oncology.content
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.Stats;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	public class ContentBoxSlideshow extends Sprite
	{
		private var d:ContentBoxDisplay;
		private var folder:File;
		private var loader:LoaderMax;
		private var images:Array;
		private var imageNames:Array;
		private var current:int;
		private var numSlides:int;
		private var slideWidth:int;
		
		private var speed:Number = .2;
		private var spring:Number = .4;
		private var velX:Number = 0;
		private var targetX:Number = 0;
		private var slideshowLinkSet:XMLList;
		private var links:Vector.<SlideshowLink>;
		
		public function ContentBoxSlideshow(display:ContentBoxDisplay)
		{
			super();
			
			d = display;
			slideWidth = d.slideshow.slideHolder.width;
			d.slideshow.scrollRect = new Rectangle(0, 0, d.slideshow.width, d.slideshow.height);
			d.slideshow.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, onNextClicked);
			d.slideshow.btnPrev.addEventListener(MouseEvent.MOUSE_DOWN, onPrevClicked);
			d.slideshow.btnNext.buttonMode = d.slideshow.btnPrev.buttonMode = true;
		}
		
		public function init(path:String, slideshowLinkSet:XMLList = null):void
		{
			this.slideshowLinkSet = slideshowLinkSet;
			folder = Constants.CONTENT_DIR.resolvePath(path);
			loader = new LoaderMax({onComplete:onLoadComplete});
			images = new Array();
			imageNames = new Array();
			
			x=0;
			current = 0;
			targetX = 0;
			alpha = 0;
			
			var files:Array;
			try {
				files = folder.getDirectoryListing();
			} catch(e:Error) {
				files = [];
			}
			
			var props:Object = new Object();
			props.width = d.slideshow.slideHolder.width;
			props.height = d.slideshow.slideHolder.height;
			props.scaleMode = "proportionalInside";
			
			var i:int = 0;
			for each(var f:File in files) {
				if(f.extension.toLowerCase() == "jpg" || f.extension.toLowerCase() == "png") {
					props.name = String(i);
					images.push(props.name);
					imageNames.push(f.name);
					loader.append(new ImageLoader(f.url, props));
					i++;
				}
			}
			
			loader.load(true);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			prevVisible = nextVisible = true;
			checkButtonStates();
			trackSlide();
		}
		
		protected function onEnterFrame(e:Event):void
		{
			velX = velX*spring;
			var diffX:Number = targetX - x;
			velX = velX+(diffX*speed);
			x = x+velX;
		}
		
		private function onNextClicked(e:MouseEvent):void
		{
			if(targetX <= 0) {
				current ++;
				targetX -= slideWidth;
				checkButtonStates();
				trackSlide();
			}
		}
		
		private function onPrevClicked(e:MouseEvent):void
		{
			if(targetX < 0) {
				current --;
				targetX += slideWidth;
				checkButtonStates();
				trackSlide();
			}
		}
		
		private function trackSlide():void
		{
			Stats.track(GSKOncology.sessionID, "slideshow: " + folder.name, "slide " + String(current));
		}
		
		private function checkButtonStates():void
		{
			if(current == 0) {
				prevVisible = false;
			} else if(numSlides > 0) {
				prevVisible = true;
			}
			
			if(current == (numSlides-1)) {
				nextVisible =false;
			} else if(numSlides > 0) {
				nextVisible = true;
			}
			
			if(slideshowLinkSet) drawLinks();//trace(imageNames[current]);
		}
		
		private function drawLinks():void
		{	
			destroyLinks();
			links = new Vector.<SlideshowLink>();
			
			for each(var item:XML in slideshowLinkSet.slide) {
				if(item.(@fileFrom == imageNames[current]).length()) {
					links.push(makeLink(item, loader.getContent(String(current))));
				}
			}
		}
		
		private function makeLink(item:XML, targ:*):Sprite
		{
			var link:Sprite = new SlideshowLink(current, item);
			link.addEventListener(MouseEvent.MOUSE_DOWN, onLinkClicked, false, 0, true);
			targ.addChild(link);
			return link;
		}
		
		private function destroyLinks():void
		{
			if(!links) return;
			while(links.length) {
				links[0].destroy();
				links[0].removeEventListener(MouseEvent.MOUSE_DOWN, onLinkClicked);
				links[0].parent.removeChild(links[0]);
				links[0] = null;
				links.shift();
			}
			links = null;
		}
		
		protected function onLinkClicked(e:MouseEvent):void
		{
			var gotoID:int = 0;
			for(var i:int = 0; i < imageNames.length; ++i) {
				if(imageNames[i] == e.target.targ) {
					gotoID = i;
					break;
				}
			}
			
			trace("Slideshow link clicked: " + current + " : > goto: " + gotoID);
			
			var diff:int = current-gotoID;
			targetX += (diff*slideWidth);
			current = gotoID;
			checkButtonStates();
			trackSlide();
			
			trace("diff: " + diff, " / targetX: " +targetX);
		}
		
		private function set prevVisible(visible:Boolean):void
		{
			d.slideshow.btnPrev.visible = visible;
			d.slideshow.prev.alpha = visible ? 1 : .5;
		}
		
		private function set nextVisible(visible:Boolean):void
		{
			d.slideshow.btnNext.visible = visible;
			d.slideshow.next.alpha = visible ? 1 : .5;
		}
		
		private function onLoadComplete(e:LoaderEvent):void
		{
			current = 0;
			numSlides = images.length;
			
			for(var i:int = 0; i < numSlides; ++i) {
				var img:ImageLoader = loader.getLoader(String(i));
				img.content.x = slideWidth*i;
				addChild(img.content);
			}
			
			TweenMax.to(this, .4, {autoAlpha:1, ease:Quad.easeOut});
		}
		
		public function destroy():void
		{
			destroyLinks();
			
			TweenMax.killTweensOf(this);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			while(numChildren) removeChildAt(0);
			
			if(images)
				while(images.length) images.shift();
			images = null;
			
			if(imageNames)
				while(imageNames.length) imageNames.shift();
			imageNames = null;
			
			if(loader) {
				loader.dispose(true);
				loader = null;
			}
		}
	}
}