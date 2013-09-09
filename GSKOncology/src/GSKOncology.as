package
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.OncologyMain;
	import com.wehaverhythm.utils.OnScreenKeyboard;
	
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	[SWF (width="1080", height="1920", frameRate="30", backgroundColor="#000000")]
	public class GSKOncology extends Sprite
	{
		private var startup:StartupDisplay;
		private var main:OncologyMain;
		
		public function GSKOncology()
		{
			Constants.DEBUG = Capabilities.isDebugger;
			
			if(Constants.DEBUG) {
				stage.nativeWindow.x = Screen.screens[Screen.screens.length-1].bounds.x;
				trace("********************************");
				trace("********************************");
				trace("         DEBUG ENABLED");
				trace("********************************");
				trace("********************************");
			}
			
			Font.registerFont(GillSans);
			this.scrollRect = new Rectangle(0,0,1080,1920);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
		}
		
		protected function onAddedToStage(e:Event):void
		{
			startup = new StartupDisplay();
			addChild(startup);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			if(!Constants.DEBUG) stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			else onFullScreen(null);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode) {
				case Keyboard.ENTER:
					stage.displayState = StageDisplayState.FULL_SCREEN;
				break;
				case Keyboard.ESCAPE:
					stage.displayState = StageDisplayState.NORMAL;
				break;
			}
		}
		
		protected function onFullScreen(e:FullScreenEvent):void
		{
			if(!Constants.DEBUG) Mouse.hide();
			removeChild(startup);
			launchApp(null);
		}
		
		protected function launchApp(e:Event):void
		{
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen); // don't want to re-initialised.
			
			// instantiate main app
			main = new OncologyMain();
			addChild(main);
			
			// load xml.
			var lm:LoaderMax = new LoaderMax({onComplete:onXMLLoaded});
			lm.insert(new XMLLoader(File.applicationDirectory.url+"data/settings.xml", {name:"settings"}));
			lm.load(); 
		}
		
		private function onXMLLoaded(e:LoaderEvent):void
		{
			main.init(XML(LoaderMax.getContent("settings")));
		}
	}
}