package com.wehaverhythm.gsk.oncology.cart
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.gsk.oncology.EmailFormController;
	import com.wehaverhythm.utils.Validate;
	import com.wehaverhythm.utils.keyboard.OnScreenKeyboard;
	import com.wehaverhythm.utils.keyboard.input.ComboBox;
	import com.wehaverhythm.utils.keyboard.input.InputCopyBox;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CartEmailForm extends CartEmailFormDisplay
	{
		private var keyboard:OnScreenKeyboard;
		private var nameBox:InputCopyBox;
		private var emailBox:InputCopyBox;
		private var settings:XML;
		private var emailer:EmailFormController;
		
		public function CartEmailForm()
		{
			super();
			
			emailer = new EmailFormController();
			emailer.addEventListener(EmailFormController.SUCCESS, onSuccess);
			emailer.addEventListener(EmailFormController.FAILED, onFailed);
			
			keyboard = new OnScreenKeyboard();
			keyboard.addEventListener(OnScreenKeyboard.TF_HAS_FOCUS, onTFHasFocus);
			keyboard.y = 238;
			addChild(keyboard);
			
			nameBox = new InputCopyBox("NAME", keyboard);
			nameBox.x = 24;
			addChild(nameBox);
			
			emailBox = new InputCopyBox("EMAIL", keyboard);
			emailBox.x = 547;
			nameBox.y = emailBox.y = 129;
			addChild(emailBox);
			
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onCloseClicked);
			btnSend.addEventListener(MouseEvent.MOUSE_DOWN, onSendClicked);
			
			setChildIndex(validName, numChildren-1);
			setChildIndex(validEmail, numChildren-1);
		}
		
		protected function onTFHasFocus(e:Event):void
		{
			hideErrorBoxes();
		}
		
		private function hideErrorBoxes():void
		{
			validName.visible = false;
			validEmail.visible = false;
		}
		
		protected function onSuccess(event:Event):void
		{
			dispatchEvent(new Event(EmailFormController.SUCCESS, true));
		}
		
		protected function onFailed(event:Event):void
		{
			showSpinner = false;
			dispatchEvent(new Event(EmailFormController.FAILED, true));
		}
		
		protected function onCloseClicked(event:MouseEvent):void
		{
			showSpinner = false;
			emailer.cancel();
			dispatchEvent(new Event(CartView.CLOSE, true));
		}
		
		public function reset():void
		{
			hideErrorBoxes();
			nameBox.reset(true);
			emailBox.reset();
			showSpinner = false;
		}
		
		protected function onSendClicked(e:MouseEvent):void
		{
			keyboard.unbindTF(keyboard.currentCopyBox);
			
			emailBox.txtMain.text = emailBox.txtMain.text.toLowerCase();
			
			if(validateForm()) {
				trace("Email validation success!");
				showSpinner = true;
				sendEmail();
			} else {
				trace("Email validation FAILED!!");
				showSpinner = false;
			}
		}
		
		private function validateForm():Boolean
		{
			var valid:Boolean = true;
			var name:String = nameBox.textfield.text;
			var email:String = emailBox.textfield.text;
			
			validName.visible = false;
			validName.y = 194;
			
			validEmail.visible = false;
			validEmail.y = 194;
			
			if(name == "" || name == " ") {
				valid = false;
				animateBoxIn(validName);
			}
			
			if(!Validate.isValidEmail(email)) {
				valid = false;
				animateBoxIn(validEmail);
			}
			
			return valid;
		}
		
		private function sendEmail():void
		{
			emailer.emailCart(nameBox.textfield.text, emailBox.textfield.text);
		}
		
		
		private function emailSent():void
		{
			showSpinner = false;
		}
		
		private function emailFailed():void
		{
			showSpinner = false;
		}
		
		private function set showSpinner(show:Boolean):void
		{
			btnSend.visible = !show;
			spinner.visible = show;
		}
		
		private function animateBoxIn(box:*):void
		{
			box.visible = false;
			box.alpha = 0;
			box.y = 194;
			TweenMax.to(box, .2, {autoAlpha:1, y:184});
		}
	}
}