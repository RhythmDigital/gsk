package com.wehaverhythm.gsk.oncology.content
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
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
		private var current:int;
		private var numSlides:int;
		private var slideWidth:int;
		
		private var speed:Number = .2;
		private var spring:Number = .4;
		private var velX:Number = 0;
		private var targetX:Number = 0;
		
		
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
		
		public function init(path:String):void
		{
			folder = File.applicationDirectory.resolvePath(path);
			loader = new LoaderMax({onComplete:onLoadComplete});
			images = new Array();
			
			x=0;
			current = 0;
			targetX = 0;
			alpha = 0;
			
			var files:Array = folder.getDirectoryListing();
			var props:Object = new Object();
			props.width = d.slideshow.slideHolder.width;
			props.height = d.slideshow.slideHolder.height;
			props.scaleMode = "proportionalInside";
			
			var i:int = 0;
			for each(var f:File in files) {
				props.name = String(i);
				images.push(props.name);
				loader.append(new ImageLoader(f.url, props));
				i++;
			}
			
			loader.load(true);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			prevVisible = nextVisible = true;
			checkButtonStates();
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
			}
		}
		
		private function onPrevClicked(e:MouseEvent):void
		{
			if(targetX < 0) {
				current --;
				targetX += slideWidth;
				checkButtonStates();
			}
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
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			while(numChildren) removeChildAt(0);
			if(images)
				while(images.length) images.shift();
			if(loader) {
				loader.dispose(true);
				loader = null;
			}
		}
	}
}