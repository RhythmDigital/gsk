package com.wehaverhythm.gsk.oncology.ask
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.EmailFormController;
	import com.wehaverhythm.gsk.oncology.cart.CartView;
	
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class AskView extends AskViewDisplay
	{
		public static var SHOW:String = "SHOW";
		public static const CLOSE:String = "close";
		public static const SHOW_LIST:String = "show_list";
		public static const CLOSING:String = "CLOSING";
		
		public var boxBoundary:Rectangle = new Rectangle(0,960,1080, 960);
		
		public var current:*;
		public var email:AskEmailForm;
		
		public function AskView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			alpha = 0;
			visible = false;
		}
		
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			email = new AskEmailForm();
			email.addEventListener(EmailFormController.SUCCESS, onEmailSuccess);
			
			addEventListener(AskView.CLOSE, onCloseAskView);
		}
		
		protected function onCloseAskView(event:Event):void
		{
			hide();
		}
		
		protected function onEmailSuccess(e:Event):void
		{
			trace("EMAIL SUCCESS IN MAIN VIEW");
			//show(thanks);
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
			
			if(current.y+current.height > boxBoundary.y+boxBoundary.height) {
				current.y = (Constants.HEIGHT-50)-current.height;
			}
		}
		
		public function hideCurrent(thenShow:*, onComplete:Function = null):void
		{
			TweenMax.to(current, .4, {autoAlpha:0, ease:Quad.easeOut, onComplete:onCurrentHidden, onCompleteParams:[thenShow, onComplete]});
		}
		
		public function hide():void
		{
			TweenMax.to(this, .3, {autoAlpha:0, ease:Quad.easeOut, onComplete:onHidden});
			dispatchEvent(new Event(AskView.CLOSING, true)); 
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