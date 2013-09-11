package com.wehaverhythm.gsk.oncology.ask
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class AskPrivacy extends AskPrivacyDisplay
	{
		public function AskPrivacy()
		{
			super();
			
			btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, onContinue);
			btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, onCancel);
		}
		
		protected function onContinue(e:MouseEvent):void
		{
			dispatchEvent(new Event(AskView.SHOW_EMAIL_FORM, true));
		}
		
		protected function onCancel(e:MouseEvent):void
		{
			dispatchEvent(new Event(AskView.CLOSE, true));
		}
	}
}