package com.wehaverhythm.gsk.oncology.ask
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class AskThanks extends AskThanksDisplay
	{
		public function AskThanks()
		{
			super();
			
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			dispatchEvent(new Event(AskView.CLOSE, true));
		}
	}
}