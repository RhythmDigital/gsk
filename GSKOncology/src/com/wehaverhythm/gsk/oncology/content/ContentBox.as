package com.wehaverhythm.gsk.oncology.content
{
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.Stats;
	import com.wehaverhythm.gsk.oncology.cart.Cart;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	import com.wehaverhythm.utils.IdleTimeout;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ContentBox extends Sprite
	{
		public static var TYPE_VIDEO:String = "video";
		public static var TYPE_SLIDESHOW:String = "slideshow";
		
		public static var CLOSE:String = "CLOSE_CONTENT";
		public static var ADD_TO_CART:String = "ADD_TO_CART";
		
		private var d:ContentBoxDisplay;
		private var contentSettings:Object;
		private var brandXML:XML;
		private var area:Rectangle;
		private var video:ContentBoxVideo;
		private var slideshow:ContentBoxSlideshow;
		private var brandID:int;
		public var type:String;

		private var vidName:String;
	//	public static var showing:Boolean;
		
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
			IdleTimeout.startListening();
			stopVideo();
			slideshow.destroy();
			//showing = false;
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
					type = ContentBox.TYPE_VIDEO;
					break;
				case "slideshow-box":
					type = ContentBox.TYPE_SLIDESHOW;
					initSlideshow();
					d.slideshow.visible = true;
					break;
			}
			//showing = true;
			checkItemInCart();
		}
		
		private function initVideo():void
		{
			vidName = brandXML.videos.video.(@id == contentSettings["videoID"]).@filename;
			var url:String = Constants.CONTENT_DIR.url + "/"+brandXML.name+Constants.PATH_VIDEO_CONTENT+vidName;
			video = new ContentBoxVideo(d, url, {width:area.width, height:area.height, autoPlay:true, scaleMode:"proportionalInside"});
			addChild(video.content);
		}
		
		private function initSlideshow():void
		{
			slideshow.init(brandXML.name+Constants.PATH_SLIDESHOW+contentSettings["slideshowFolderID"]);
		}
		
		public function checkItemInCart():Boolean
		{
			if(!contentSettings) return false;
			
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
			switch(type) {
				case TYPE_VIDEO:
					var vidPercent:String = String(Math.ceil(video.playProgress*100))+"%";
					Stats.track(GSKOncology.sessionID, "video: " + vidName, vidPercent + " complete");
					break;
				case TYPE_SLIDESHOW:
					
					break;
			}
			//type = "";
			
			IdleTimeout.startListening();
		//	showing = false;
			dispatchEvent(new Event(ContentBox.CLOSE, true));
		}
		
		protected function onAddToCartClicked(e:MouseEvent):void
		{
			if(checkItemInCart()) {
				Cart.remove(contentSettings["id"], String(brandID));
			} else {
				var title:String = Menu.SELECTED_BUTTON_COPY;
				var contentNode:XML = XML(Menu.getBrandXML(brandID).content.content.(@id == contentSettings["id"]));
				
				if(contentNode.hasOwnProperty("@cartTitleAlt")) {
					var altTitle:String = String(contentNode.@cartTitleAlt);
					if(altTitle.length) {
						trace(">> Using alternate title. Was: " + title + ". Now: " + altTitle);
						title = altTitle;
					}
				}
				
				var result:Boolean = Cart.add(contentSettings["id"], String(brandID), title);
			}
			
			checkItemInCart();
			Cart.traceCart();
			//dispatchEvent(new CustomEvent(ContentBox.ADD_TO_CART, true, false, {contentID:contentSettings["id"], brandID:brandID}));
		}
		
		public function close():void
		{
			onCloseClicked(null);
		}
	}
}