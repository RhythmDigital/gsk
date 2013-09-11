package
{
	import com.wehaverhythm.utils.keyboard.OnScreenKeyboard;
	
	import flash.display.Sprite;
	
	[SWF (width="1020" height="370", frameRate="60", backgroundColor="#000000")]
	public class KeyboardTest extends Sprite
	{
		public function KeyboardTest()
		{
			super();
			
			var keys:OnScreenKeyboard = new OnScreenKeyboard();
			addChild(keys);
			
			//keys.addTextField(keys.te);
		}
	}
}

