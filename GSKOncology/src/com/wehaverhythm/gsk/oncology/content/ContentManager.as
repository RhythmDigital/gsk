package com.wehaverhythm.gsk.oncology.content
{
	import com.cuepointvideo.CuePoint;
	import com.cuepointvideo.CuePointEvent;
	import com.cuepointvideo.CuePointVideoEvent;
	import com.cuepointvideo.CuePointVideoPlayer;
	import com.wehaverhythm.gsk.oncology.GlobalSettings;
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class ContentManager extends Sprite
	{
		private var video:CuePointVideoPlayer;
		private var rootVideos:Array;
		
		public function ContentManager()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			video = new CuePointVideoPlayer(GlobalSettings.STAGE_WIDTH, GlobalSettings.STAGE_HEIGHT);
			video.addEventListener(CuePointEvent.CUE_POINT_TRIGGER, onCuePointTriggered);
			video.addEventListener(CuePointVideoEvent.NEXT_VIDEO_PLAYING, onNextVideoPlaying);
			addChild(video);
			video.init();
		}
		
		protected function onNextVideoPlaying(e:CuePointVideoEvent):void
		{
			trace("Show root caption for menu: " + e.params.id);
		}
		
		public function hideCurrentOverlays():void
		{
			trace("hideCurrentOverlays");
		}
		
		public function showRootPlaylist(xmlFiles:Array):void
		{
			// Get video list first time.
			if(!rootVideos) {
				rootVideos = [];
				
				// get video files.
				for(var i:int = 0; i < xmlFiles.length; ++i) {
					rootVideos.push(String(xmlFiles[i].content.rootVideo));
				}
			}
			
			trace("Play Root Videos: " + rootVideos);
			video.playPlaylist(rootVideos);
		}
		
		public function showContent(contentID:String, brandID:int, brandXML:XML):void
		{
			trace("---------------------");
			trace("process content id: " + contentID + " for brand " + brandID);
			
			var xml:XML = brandXML;
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
		
		protected function onCuePointTriggered(e:CuePointEvent):void
		{
			trace("Cue point: " + e.id + " / " + e.cueType);
		}
	}
}