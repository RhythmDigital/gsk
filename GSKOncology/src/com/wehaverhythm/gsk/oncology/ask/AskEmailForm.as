package com.wehaverhythm.gsk.oncology.ask
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.gsk.oncology.EmailFormController;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	import com.wehaverhythm.utils.Validate;
	import com.wehaverhythm.utils.keyboard.OnScreenKeyboard;
	import com.wehaverhythm.utils.keyboard.input.ComboBox;
	import com.wehaverhythm.utils.keyboard.input.InputCopyBox;
	import com.wehaverhythm.utils.keyboard.input.MultilineCopyBox;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class AskEmailForm extends AskEmailFormDisplay
	{
		private var nameBox:InputCopyBox;
		private var emailBox:InputCopyBox;
		private var keyboard:OnScreenKeyboard;
		private var emailer:EmailFormController;
		private var messageText:MultilineCopyBox;
		private var productsBox:ComboBox;
		
		public function AskEmailForm()
		{
			super();
			
			keyboard = new OnScreenKeyboard();
			keyboard.addEventListener(OnScreenKeyboard.TF_HAS_FOCUS, onTFHasFocus);
			keyboard.y = 579;
			addChild(keyboard);
			
			emailer = new EmailFormController();
			emailer.addEventListener(EmailFormController.SUCCESS, onSuccess);
			emailer.addEventListener(EmailFormController.FAILED, onFailed);
		
			nameBox = new InputCopyBox("NAME", keyboard);
			nameBox.x = 25;
			nameBox.y = 129;
			addChild(nameBox);
			
			emailBox = new InputCopyBox("EMAIL", keyboard);
			emailBox.x = 25;
			emailBox.y = 209;
			addChild(emailBox);
			
			messageText = new MultilineCopyBox("MESSAGE", keyboard);
			messageText.x = 25;
			messageText.y = 290;
			addChild(messageText);
			
			productsBox = new ComboBox("PRODUCT", keyboard);
			productsBox.addEventListener(ComboBox.HAS_FOCUS, onProductsBoxFocus);
			productsBox.x = 547;
			productsBox.y = 129;
			addChild(productsBox);
			
			
			for(var i:int = 0; i < Menu.menus.length; ++i) {
				productsBox.addComboItem(Menu.getBrandXML(i).title, i);
			}
			
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onCloseClicked);
			btnSend.addEventListener(MouseEvent.MOUSE_DOWN, onSendClicked);
			
			setChildIndex(validName, numChildren-1);
			setChildIndex(validEmail, numChildren-1);
			setChildIndex(validMessage, numChildren-1);
			setChildIndex(validProduct, numChildren-1);
		}
		
		protected function onProductsBoxFocus(e:Event):void
		{
			hideErrorBoxes();
		}
		
		protected function onTFHasFocus(e:Event):void
		{
			productsBox.lostFocus();
			hideErrorBoxes();
		}
		
		public function reset():void
		{
			hideErrorBoxes();
			nameBox.reset(true);
			emailBox.reset();
			messageText.reset();
			productsBox.reset();
			showSpinner = false;
		}
		
		private function hideErrorBoxes():void
		{
			validName.visible = false;
			validEmail.visible = false;
			validMessage.visible = false;
			validProduct.visible = false;
		}
		
		protected function onSendClicked(e:MouseEvent):void
		{
			productsBox.lostFocus();
			keyboard.unbindTF(keyboard.currentCopyBox);
			
			emailBox.txtMain.text = emailBox.txtMain.text.toLowerCase();
			
			if(validateForm()) {
				trace("Email validation success!");
				showSpinner = true;
				//sendEmail();
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
			var msg:String = messageText.textfield.text;
			
			validName.visible = false;
			validEmail.visible = false;
			validMessage.visible = false;
			validProduct.visible = false;
			
			if(name == "" || name == " ") {
				valid = false;
				animateBoxIn(validName, 194, 184);
			}
			
			if(msg == "" || msg == " ") {
				valid = false;
				animateBoxIn(validMessage, 539, 529);
			}

			if(productsBox.text == "" || productsBox.text == " ") {
				valid = false;
				animateBoxIn(validProduct, 194, 184);
			}
			
			if(!Validate.isValidEmail(email)) {
				valid = false;
				animateBoxIn(validEmail, 274, 264);
			}
			
			return valid;
		}
		
		private function animateBoxIn(box:*, fromY:Number, targY:Number):void
		{
			box.visible = false;
			box.alpha = 0;
			box.y = fromY;
			TweenMax.to(box, .2, {autoAlpha:1, y:targY});
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
			dispatchEvent(new Event(AskView.CLOSE, true));
		}
		
		private function set showSpinner(show:Boolean):void
		{
			btnSend.visible = !show;
			spinner.visible = show;
		}
	}
}