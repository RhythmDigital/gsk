package com.wehaverhythm.gsk.oncology.content
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ContentBox extends Sprite
	{
		public static var CLOSE:String = "CLOSE_CONTENT";
		public static var ADD_TO_CART:String = "ADD_TO_CART";
		
		private var d:ContentBoxDisplay;
		private var contentSettings:Object;
		private var brandXML:XML;
		
		
		public function ContentBox()
		{
			super();
			d = new ContentBoxDisplay();
			addChild(d);
			
			d.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onCloseClicked);
			d.btnAddCart.addEventListener(MouseEvent.MOUSE_DOWN, onAddToCartClicked);
			d.slideshow.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, onNextClicked);
			d.slideshow.btnPrev.addEventListener(MouseEvent.MOUSE_DOWN, onPrevClicked);
			d.vidPlayer.btnPlayPause.addEventListener(MouseEvent.MOUSE_DOWN, onPlayPauseClicked);
			d.vidPlayer.btnSeekBack.addEventListener(MouseEvent.MOUSE_DOWN, onSeekBackClicked);
			d.vidPlayer.btnSeekForward.addEventListener(MouseEvent.MOUSE_DOWN, onSeekForwardClicked);
				
			d.btnClose.buttonMode = d.btnAddCart.buttonMode = true;
			d.slideshow.btnNext.buttonMode = d.slideshow.btnPrev.buttonMode = true;
			d.vidPlayer.btnPlayPause.buttonMode = d.vidPlayer.btnSeekBack.buttonMode = d.vidPlayer.btnSeekForward.buttonMode = true;
		}
		
		private function stopVideo():void
		{
			
		}
		
		public function reset():void
		{
			stopVideo();
			// cancel & dispose loaders & content.
		}
		
		public function setup(contentSettings:Object, brandXML:XML):void
		{
			this.contentSettings = contentSettings;
			this.brandXML = brandXML;
			
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
		}
		
		private function initVideo():void
		{
			// TODO Auto Generated method stub
		}
		
		private function initSlideshow():void
		{
			// TODO Auto Generated method stub
		}
		
		/**
		 * CONTENT BOX EVENTS
		 */
		protected function onCloseClicked(e:MouseEvent):void
		{
			stopVideo();
			dispatchEvent(new Event(ContentBox.CLOSE, true));
		}
		
		protected function onAddToCartClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(ContentBox.CLOSE, true));
		}
		
		/**
		 * VIDEO PLAYER EVENTS
		 */
		protected function onSeekForwardClicked(e:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onSeekBackClicked(e:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onPlayPauseClicked(e:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
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