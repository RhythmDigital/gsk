package com.wehaverhythm.gsk.oncology.content
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.layout.ScaleMode;
	import com.greensock.loading.VideoLoader;
	import com.wehaverhythm.gsk.oncology.cart.Cart;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	
	public class ContentBox extends Sprite
	{
		public static var CLOSE:String = "CLOSE_CONTENT";
		public static var ADD_TO_CART:String = "ADD_TO_CART";
		
		private var d:ContentBoxDisplay;
		private var contentSettings:Object;
		private var brandXML:XML;
		private var area:Rectangle;
		private var video:ContentBoxVideo;
		private var slideshow:ContentBoxSlideshow;
		private var brandID:int;
		
		public function ContentBox()
		{
			super();
			d = new ContentBoxDisplay();
			addChild(d);
			
			area = d.area.getBounds(this);
			
			d.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onCloseClicked);
			d.btnAddCart.addEventListener(MouseEvent.MOUSE_DOWN, onAddToCartClicked);
			d.btnClose.buttonMode = d.btnAddCart.buttonMode = true;
			
			slideshow = new ContentBoxSlideshow(d);
			d.slideshow.addChild(slideshow);
		}
		
		private function stopVideo():void
		{
			if(video) {
				if(contains(video.content)) removeChild(video.content);
				video.dispose(true);
				video = null;
			}
		}
		
		public function reset():void
		{
			stopVideo();
			slideshow.destroy();
		}
		
		public function setup(contentSettings:Object, brandXML:XML, brandID:int):void
		{
			this.contentSettings = contentSettings;
			this.brandXML = brandXML;
			this.brandID = brandID;
			
			d.vidPlayer.visible = d.slideshow.visible = false;
			d.vidPlayer.progress.scaleX = 0;
			
			switch(contentSettings["action"]) {
				case "video-box":
					initVideo();
					d.vidPlayer.visible = true;
					break;
				case "slideshow-box":
					initSlideshow();
					d.slideshow.visible = true;
					break;
			}
			
			checkItemInCart();
		}
		
		private function initVideo():void
		{
			var filename:String = brandXML.videos.video.(@id == contentSettings["videoID"]).@filename;
			video = new ContentBoxVideo(d, File.applicationDirectory.url + "assets/video/"+filename, {width:area.width, height:area.height, autoPlay:true, scaleMode:"proportionalInside"});
			addChild(video.content);
		}
		
		private function initSlideshow():void
		{
			slideshow.init("assets/images/slideshows/"+contentSettings["slideshowFolderID"]);
		}
		
		public function checkItemInCart():Boolean
		{
			var exists:Boolean = Cart.exists(contentSettings["id"], String(brandID));
			trace("Item already in cart ? " + exists);
			if(exists) {
				d.addRemove.gotoAndStop("remove");
			} else {
				d.addRemove.gotoAndStop("add");
			}
			
			return exists;
		}
		
		/**
		 * CONTENT BOX EVENTS
		 */
		protected function onCloseClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(ContentBox.CLOSE, true));
		}
		
		protected function onAddToCartClicked(e:MouseEvent):void
		{
			if(checkItemInCart()) {
				Cart.remove(contentSettings["id"], String(brandID));
			} else {
				Cart.add(contentSettings["id"], String(brandID), Menu.SELECTED_BUTTON_COPY);
			}
			
			checkItemInCart();
			Cart.traceCart();
			//dispatchEvent(new CustomEvent(ContentBox.ADD_TO_CART, true, false, {contentID:contentSettings["id"], brandID:brandID}));
		}
		
		
		/**
		 * SLIDESHOW EVENTS
		 */
		
		protected function onNextClicked(e:MouseEvent):void
		{
			// TODO Auto-generated method stub
		}
		
		protected function onPrevClicked(e:MouseEvent):void
		{
			
		}
	}
}