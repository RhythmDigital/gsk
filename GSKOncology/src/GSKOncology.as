package
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.OncologyMain;
	import com.wehaverhythm.gsk.oncology.Settings;
	
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	[SWF (width="1080", height="1920", frameRate="30", backgroundColor="#000000")]
	public class GSKOncology extends Sprite
	{
		public static var sessionID:int;
		
		private var startup:StartupDisplay;
		private var main:OncologyMain;
		private var contentFolder:File;
		private var contentDefinitionFile:File;
		
		public function GSKOncology()
		{
			var appXML:XML =  NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			stage.nativeWindow.title = "GSK ESMO 2013 - Version " + appXML.ns::versionNumber;
			findContentDirectory();
		}
		
		private function findContentDirectory():void
		{
			contentDefinitionFile = File.desktopDirectory;
			var fs:FileStream = new FileStream();
			contentFolder = File.documentsDirectory;
			
			if(contentDefinitionFile.resolvePath(Constants.CONTENT_LOCATION_FILENAME).exists) {
				fs.open(contentDefinitionFile.resolvePath(Constants.CONTENT_LOCATION_FILENAME), FileMode.READ);
				var path:String = fs.readUTFBytes(fs.bytesAvailable);
				contentFolder = new File(path);
				fs.close();
				contentFolderFound();
			} else {
				contentFolder.browseForDirectory("Select the content folder...");
				contentFolder.addEventListener(Event.SELECT, onDirectorySelected);
			}
		}
		
		protected function onDirectorySelected(e:Event):void
		{
			var fs:FileStream = new FileStream();
			fs.open(contentDefinitionFile.resolvePath(Constants.CONTENT_LOCATION_FILENAME), FileMode.WRITE);
			fs.writeUTFBytes(contentFolder.nativePath);
			fs.close();
			
			contentFolderFound();
		}
		
		private function contentFolderFound():void
		{
			trace("Content folder found.");
			Constants.CONTENT_DIR = contentFolder;
			trace(Constants.CONTENT_DIR.nativePath);
			//return;
			Constants.DEBUG = Capabilities.isDebugger;
			
			if(Constants.DEBUG) {
				stage.nativeWindow.x = Screen.screens[Screen.screens.length-1].bounds.x;
				stage.nativeWindow.width = Screen.screens[Screen.screens.length-1].bounds.height*(1080/1920);
				trace("********************************");
				trace("********************************");
				trace("         DEBUG ENABLED");
				trace("********************************");
				trace("********************************");
			}
			
			Font.registerFont(GillSans);
			this.scrollRect = new Rectangle(0,0,1080,1920);
			
			if(stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);	
		}
		
		protected function onAddedToStage(e:Event):void
		{
			startup = new StartupDisplay();
			addChild(startup);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			//if(!Constants.DEBUG && Settings.data.startupScreenSelector == "true") stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			//else onFullScreen(null);
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
			lm.insert(new XMLLoader(Constants.CONTENT_DIR.url+"/settings.xml", {name:"settings"}));
			lm.load();
		}
		
		private function onXMLLoaded(e:LoaderEvent):void
		{
			Settings.data = XML(LoaderMax.getContent("settings"));
			Constants.SCREEN_NAME = Settings.data.screenName;
			if(Settings.data.showMouse == "false") Mouse.hide();
			main.init(Settings.data);
		}
	}
}