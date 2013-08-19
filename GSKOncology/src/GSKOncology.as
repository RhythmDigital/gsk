package
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.wehaverhythm.gsk.oncology.OncologyMain;
	
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	
	[SWF (width="1080", height="1920", frameRate="60", backgroundColor="#000000"]
	public class GSKOncology extends Sprite
	{
		private var main:OncologyMain;
		
		public function GSKOncology()
		{
			addEventListener(Event.ADDED_TO_STAGE, launchApp);
		}
		
		protected function launchApp(e:Event):void
		{
			trace("Added.");
			removeEventListener(Event.ADDED_TO_STAGE, launchApp);
			
			// instantiate main app
			main = new OncologyMain();
			addChild(main);
			
			// position native window
			var nw:NativeWindow = stage.nativeWindow;
			var screen:Screen = Screen(Screen.screens[Screen.screens.length-1]);
			nw.x = screen.bounds.x;
			
			// enter fullscreen
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			// load xml.
			var lm:LoaderMax = new LoaderMax({onComplete:onXMLLoaded});
			lm.insert(new XMLLoader(File.applicationDirectory.url+"data/settings.xml", {name:"settings"}));
			lm.insert(new XMLLoader(File.applicationDirectory.url+"data/test.xml", {name:"content"}));
			lm.load();
		}
		
		private function onXMLLoaded(e:LoaderEvent):void
		{
			trace("initialised.");
			main.init(XML(LoaderMax.getContent("settings")), XML(LoaderMax.getContent("content")));
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
	}
}