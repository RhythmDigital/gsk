package com.wehaverhythm.gsk.oncology.cart
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.wehaverhythm.gsk.oncology.EmailFormController;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class CartView extends CartViewDisplay
	{
		public static const CLOSE:String = "close";
		public static const SHOW_LIST:String = "show_list";
		public static const CLOSING:String = "CLOSING";
		
		public var boxBoundary:Rectangle = new Rectangle(0,960,1080, 960);
		
		public var current:*;
		public var list:CartList;
		public var add:CartAddItem;
		public var full:CartFull;
		public var privacy:CartPrivacy;
		public var email:CartEmailForm;
		public var thanks:CartThanks;
		
		public function CartView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			alpha = 0;
			visible = false;
		}
		
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			Cart.events.addEventListener(Cart.ADD_ITEM, onCartAddItem);
			Cart.events.addEventListener(Cart.CART_FULL, onCartFull);
			
			list = new CartList();
			add = new CartAddItem();
			full = new CartFull();
			privacy = new CartPrivacy();
			email = new CartEmailForm();
			email.addEventListener(EmailFormController.SUCCESS, onEmailSuccess);
			thanks = new CartThanks();
			
			list.bottomSection.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, onSend);
			privacy.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, onPrivacyYesClicked);
			privacy.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, onPrivacyNoClicked);
			
			addEventListener(CartView.CLOSE, onCloseCartView);
			addEventListener(CartView.SHOW_LIST, onShowListView);
		}
		
		protected function onEmailSuccess(e:Event):void
		{
			trace("EMAIL SUCCESS IN MAIN VIEW");
			show(thanks);
		}
		
		protected function onPrivacyYesClicked(e:MouseEvent):void
		{
			show(email);
		}
		
		protected function onPrivacyNoClicked(e:MouseEvent):void
		{
			Cart.reset();
			hide();
		}
		
		protected function onSend(e:MouseEvent):void
		{
			show(privacy);
		}
		
		protected function onCartFull(e:Event):void
		{
			show(full);
		}
		
		protected function onShowListView(e:Event):void
		{
			showCart();
		}
		
		protected function onCloseCartView(e:Event):void
		{
			hide();
		}
		
		protected function onCartAddItem(e:CustomEvent):void
		{
			add.txtTitle.text = e.params.label;
			show(add);
		}
		
		public function showCart():void
		{
			show(list, list.populateList);
		}
		
		public function show(screen:*, onComplete:Function = null):void
		{
			if(this.visible && current) {
				hideCurrent(screen, onComplete);
			} else {
				current = screen;
				current.visible = true;
				current.alpha = 1;
				positionView(current);
				addChild(current);
				if(current.hasOwnProperty('reset')) current.reset();
				if(onComplete) onComplete();
				TweenMax.to(this, .3, {autoAlpha:1, ease:Quad.easeOut});
			}
		}
		
		private function positionView(current:*):void
		{
			current.x = int(((boxBoundary.x+boxBoundary.width)>>1)-(current.width>>1));
			current.y = int(boxBoundary.y);
		}
		
		public function hideCurrent(thenShow:*, onComplete:Function = null):void
		{
			TweenMax.to(current, .4, {autoAlpha:0, ease:Quad.easeOut, onComplete:onCurrentHidden, onCompleteParams:[thenShow, onComplete]});
		}
		
		public function hide():void
		{
			TweenMax.to(this, .3, {autoAlpha:0, ease:Quad.easeOut, onComplete:onHidden});
			dispatchEvent(new Event(CartView.CLOSING, true)); 
		}
		
		private function onHidden():void
		{
			if(current) removeChild(current);
		}
			
		private function onCurrentHidden(showScreen:*, onComplete:Function = null):void
		{
		//	onHidden();
			if(showScreen) {
				current = showScreen;
				addChild(current);
				positionView(current);
				TweenMax.to(current, .4, {autoAlpha:1, ease:Quad.easeOut});
				if(current.hasOwnProperty('reset')) current.reset();
				if(onComplete) onComplete();
			}
		}
	}
}