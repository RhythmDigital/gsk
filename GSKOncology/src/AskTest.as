package
{
	import com.wehaverhythm.gsk.oncology.EmailFormController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class AskTest extends Sprite
	{
		private var emailer:EmailFormController;
		
		public function AskTest()
		{
			super();
			
			emailer = new EmailFormController();
			emailer.addEventListener(EmailFormController.SUCCESS, onSuccess);
			emailer.addEventListener(EmailFormController.FAILED, onFailed);
			
			emailer.emailAsk(
				"John Smith " + Math.random()*100, 
				"john.smith@example.com", 
				"Test Product 2", 
				"Can I have some information please?"
			);
			
		}
		
		protected function onFailed(e:Event):void
		{
			trace(e);
		}
		
		protected function onSuccess(e:Event):void
		{
			trace("Success: " + e);
		}
	}
}