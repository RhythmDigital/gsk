package com.wehaverhythm.gsk.oncology
{
	import com.cuepointvideo.CuePoint;
	import com.cuepointvideo.CuePointEvent;
	import com.cuepointvideo.CuePointVideoPlayer;
	import com.wehaverhythm.gsk.oncology.menu.ContentEvent;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	import com.wehaverhythm.gsk.oncology.menu.MenuEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class OncologyMain extends Sprite
	{
		private var settings:XML;
		private var video:CuePointVideoPlayer;
		private var menu:Menu;
		
		public function OncologyMain()
		{
			super();
		}
		
		public function init(settingsXML:XML):void {
			
			video = new CuePointVideoPlayer(GlobalSettings.STAGE_WIDTH, GlobalSettings.STAGE_HEIGHT);
			video.addEventListener(CuePointEvent.CUE_POINT_TRIGGER, onCuePointTriggered);
			addChild(video);
			
			menu = new Menu();
			menu.addEventListener(ContentEvent.CONTENT_TRIGGER, onContentTrigger);
			menu.x = 29;
			addChild(menu);
			menu.init(settingsXML);
			
			//initSection(0, contentXML);
		}
		
		private function initVideoFromXML(section:int, videoXML:XML):Vector.<CuePoint>
		{
			var cuePoints:Vector.<CuePoint> = new Vector.<CuePoint>();
			
			for(var i:int = 0; i < videoXML.cuePoints.cuePoint.length(); ++i) {
				var next:XML = videoXML.cuePoints.cuePoint[i];
				var inTime:String = next.@inTime;
				var outTime:String = next.attribute("outTime") ? next.@outTime : null;
				
				cuePoints.push(new CuePoint(next.@id, next.@inTime, next.@outTime));
			}
			
			//video.initWithCuePoints(File.applicationDirectory.url+"assets/video/"+sectionXML.video[0].@filename, cuePoints);
			
			return cuePoints;
		}
		
		protected function onContentTrigger(e:ContentEvent):void
		{
			//trace("Content Trigger: " + e);
			
			var contentID:String = null;
			
			switch(e.params.type) {
				case "root-menu":
					//trace("Playing sequence of videos for "+e.params.menuType+": " + e.params.brandsXML);
					trace(">> Root Menu Content");
				break;
				
				case "sub-menu":
					trace(">> Sub Menu Content");
					contentID = String(menu.menus[e.params.mid].content.menu.attribute("contentID"));
				break;
				
				case "sub-menu-button":
					trace(">> Sub Menu Button Content");
					contentID = String(e.params.xml.attribute("contentID"));
				break;
			}
			
			if(contentID != null && contentID.length) {
				parseContent(contentID, e.params.mid);
			} else {
				trace("No content for this node");
			}
		}
		
		private function parseContent(contentID:String, brandID:int):void
		{
			trace("---------------------");
			trace("process content id: " + contentID + " for brand " + brandID);
			
			var xml:XML = menu.getBrandXML(brandID);
			var contentNode:XMLList = xml.content.content.(@id == contentID);
			var attributes:XMLList = contentNode.attributes();
			var contentSettings:Object = {};
			
			for each (var attr:XML in contentNode.attributes()) {
				contentSettings[String(attr.name())] = String(attr);
			}
			
			for (var key:String in contentSettings) {
				trace(key+": "+contentSettings[key]);
			}
			trace("---------------------");
			trace(contentSettings["action"]);
			switch(contentSettings["action"]) {
				case "video":
					// standard cuepoint video with annotations
					trace("play the video!");
					var video:XMLList = xml.videos.video.(@id == contentSettings["videoID"]);
					trace("video: " + video.@id);
					break;
			}
		}
		
		protected function onCuePointTriggered(e:CuePointEvent):void
		{
			trace("Cue point: " + e.id + " / " + e.cueType);
		}
	}
}