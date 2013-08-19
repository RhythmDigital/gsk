package com.wehaverhythm.gsk.oncology
{
	import com.cuepointvideo.CuePoint;
	import com.cuepointvideo.CuePointEvent;
	import com.cuepointvideo.CuePointVideoPlayer;
	
	import flash.display.Sprite;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	
	public class OncologyMain extends Sprite
	{
		private var settings:XML;
		private var video:CuePointVideoPlayer;
		private var menu:Menu;
		
		public function OncologyMain()
		{
			super();
		}
		
		public function init(settingsXML:XML, contentXML:XML):void {
			
			video = new CuePointVideoPlayer(GlobalSettings.STAGE_WIDTH, GlobalSettings.STAGE_HEIGHT);
			video.addEventListener(CuePointEvent.CUE_POINT_TRIGGER, onCuePointTriggered);
			addChild(video);
			
			menu = new Menu();
			addChild(menu);
			menu.init(settingsXML);
			
			initSection(0, contentXML);
		}
		
		private function initSection(section:int, content:XML):Vector.<CuePoint>
		{
			var cuePoints:Vector.<CuePoint> = new Vector.<CuePoint>();
			var sectionXML:XML = content.sections.section[section];
			
			for(var i:int = 0; i < sectionXML.cuePoints.cuePoint.length(); ++i) {
				var next:XML = sectionXML.cuePoints.cuePoint[i];
				var inTime:String = next.@inTime;
				var outTime:String = next.attribute("outTime") ? next.@outTime : null;
				
				cuePoints.push(new CuePoint(next.@id, next.@inTime, next.@outTime));
			}
			
			video.initWithCuePoints(cuePoints);
			
			return cuePoints;
		}
		
		protected function onCuePointTriggered(e:CuePointEvent):void
		{
			trace("Cue point: " + e.id + " / " + e.cueType);
		}
	}
}