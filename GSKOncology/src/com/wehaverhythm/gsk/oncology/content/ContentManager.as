package com.wehaverhythm.gsk.oncology.content
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.cuepointvideo.CuePoint;
	import com.wehaverhythm.cuepointvideo.CuePointEvent;
	import com.wehaverhythm.cuepointvideo.CuePointVideoEvent;
	import com.wehaverhythm.cuepointvideo.CuePointVideoPlayer;
	import com.wehaverhythm.gsk.oncology.Constants;
	import com.wehaverhythm.gsk.oncology.GlobalSettings;
	import com.wehaverhythm.gsk.oncology.menu.Menu;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class ContentManager extends Sprite
	{
		private var menu:Menu;
		private var video:CuePointVideoPlayer;
		private var rootVideos:Array;
		private var captions:Dictionary;
		private var cuePointSet:XML;
		private var currentBrandXML:XML;
		private var brandsXMLArray:Array;
		private var contentSettings:Object;
		private var contentNode:XML;
		private var brandID:int;
		private var verbose:Boolean = true;
		
		public var content:ContentBox;
		
		public function ContentManager(menu:Menu)
		{
			this.menu = menu;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			content = new ContentBox();
			content.alpha = 0;
			content.visible = false;
			content.x = 30;
			content.y = 180;
			content.addEventListener(ContentBox.CLOSE, onContentBoxClosed);
			
			video = new CuePointVideoPlayer(GlobalSettings.STAGE_WIDTH, GlobalSettings.STAGE_HEIGHT, Constants.CONTENT_DIR.url+"/assets/video/");
			video.addEventListener(CuePointEvent.CUE_POINT_TRIGGER, onCuePointTriggered);
			video.addEventListener(CuePointVideoEvent.NEXT_VIDEO_PLAYING, onNextVideoPlaying);
			video.addEventListener(CuePointVideoEvent.HIDE_CURRENT_CAPTION, onHideCurrentCaption);
			addChild(video);
			//video.init();
		}
		
		protected function onContentBoxClosed(e:Event):void
		{
			if(verbose) trace("CONTENT BOX CLOSED");
			hideContentBox();
		}
		
		public function hideCurrentOverlays():void
		{
			if(verbose) trace("hideCurrentOverlays");
			
		}
		
		private function clearOldAnnotations():void
		{
			if(captions)
			{
				for(var k:String in captions) {
					removeAnnotation(k, true);
				}
			}
			
			captions = new Dictionary();
		}
		
		public function showRootPlaylist(xmlFiles:Array):void
		{
			clearOldAnnotations();
			brandsXMLArray = xmlFiles;
			// Get video list first time.
			if(!rootVideos) {
				rootVideos = [];
				
				// get video files.
				for(var i:int = 0; i < xmlFiles.length; ++i) {
					rootVideos.push(String(xmlFiles[i].content.rootVideo));
				}
			}
			
			if(verbose) trace("Play Root Videos: " + rootVideos);
			video.playPlaylist(rootVideos, "root");
			
			hideContentBox();
		}
		
		public function showContent(contentID:String, brandID:int, brandXML:XML):void
		{
			if(verbose) {
				trace("---------------------");
				trace("process content id: " + contentID + " for brand " + brandID);
			}
			
			this.brandID = brandID;
			var xml:XML = currentBrandXML = brandXML;
			contentNode = XML(xml.content.content.(@id == contentID));
			var attributes:XMLList = contentNode.attributes();
			contentSettings = {};
			
			for each (var attr:XML in contentNode.attributes()) {
				contentSettings[String(attr.name())] = String(attr);
			}
			
			if(verbose) {
				for (var key:String in contentSettings) {
					trace(key+": "+contentSettings[key]);
				}
			}
			
			if(verbose) trace("---------------------");
			if(verbose) trace(contentSettings["action"]);
			switch(contentSettings["action"]) {
				case "video-bg":
					
					if(verbose) trace(contentSettings["action"]);
					// standard cuepoint video with annotations
					if(verbose) trace("play the video!");
					var videoXML:XML = XML(xml.videos.video.(@id == contentSettings["videoID"]));
					if(verbose) trace("video: " + videoXML.@filename);
					
					video.listenForCuePoints = false;
					clearOldAnnotations();
					var cuePoints:Vector.<CuePoint>;
					
					if(contentSettings.hasOwnProperty("cuePointSet")) {
						cuePointSet = XML(xml.cuePointSets.cuePointSet.(@id == contentSettings["cuePointSet"]));
						cuePoints = parseCuePointXML(cuePointSet);
					}
					
					
					video.play(videoXML.@filename, contentID);
					
					var looped:Boolean = (videoXML.hasOwnProperty("@loopInFrame") && videoXML.hasOwnProperty("@loopOutFrame"));
					if(looped) {
						video.setLoop(
							Number(videoXML.@loopInFrame),
							Number(videoXML.@loopOutFrame)
						);
					}
					
					if(cuePoints) {
						video.setCuePoints(cuePoints);
					}
					
					hideContentBox();
					
					break;
				case "slideshow-box":
					
					if(verbose) trace("Show slideshow box!");
					// new image loader , these will always have a content holder.
					// (can even scale within!!! see settings for contentHolder);
					showContentBox();
					break;
				
				case "video-box":
					if(verbose) trace("Show video box!");
					showContentBox();
					break;
			}
		}
		
		private function showContentBox():void
		{
			if(contains(content)) {
				hideContentBox(true);
			} else {
				addChild(content);
				content.setup(contentSettings, currentBrandXML, brandID);
				TweenMax.killTweensOf(content);
				content.alpha = 0;
				content.visible = false;
				TweenMax.to(content, .4, {autoAlpha:1});
			}
		}

		private function hideContentBox(showAgain:Boolean = false):void
		{
			TweenMax.to(content, .4, {autoAlpha:0, onComplete:hideContentComplete, onCompleteParams:[showAgain]});
		}
		
		private function hideContentComplete(showAgain:Boolean):void
		{
			if(contains(content)) {
				content.reset();
				removeChild(content);
			}
			if(showAgain) {
				showContentBox();
			}
		}
		
		private function addAnnotation(id:String):void
		{
			if(!captions[id]) {
				var a:Caption = new Caption();
				a.setup(XML(cuePointSet.cuePoint.(@id == id)), currentBrandXML.colour);
				captions[id] = a;
			}
			
			addChildAt(captions[id], contains(content) ? getChildIndex(content)-1 : numChildren-1);
			captions[id].showCaption();
		}
		
		private function removeAnnotation(id:String, destroy:Boolean = false):void
		{
			var a:Caption = captions[id];
			if(a && this.contains(a)) {
				a.hideCaption(true)
			}
			
			if(destroy) {
				a.destroy();
				captions[id] = null;
			}
			
		}
		
		private function parseCuePointXML(xml:XML):Vector.<CuePoint>
		{
			if(xml && xml.hasOwnProperty("cuePoint"))
			{
				var cuePoints:Vector.<CuePoint> = new Vector.<CuePoint>();
				for(var i:int = 0; i < xml.cuePoint.length(); ++i) {
					var next:XML = xml.cuePoint[i];
					var inTime:int = int(next.@inFrame);
					var outTime:int = int(next.@outFrame);
					if(verbose) trace("Add cue point " + inTime + "," +outTime);
					cuePoints.push(new CuePoint(next.@id, inTime, outTime));
				}
			
				return cuePoints;
				
			} else {
				return null;
			}
		}
		
		protected function onCuePointTriggered(e:CuePointEvent):void
		{
			if(verbose) trace("Cue point: " + e.id + " / " + e.cueType);
			
			// dont show cuepoint if content box is visible
			if(e.cueType == CuePoint.CUE_IN) {
				addAnnotation(e.id);
			} else {
				removeAnnotation(e.id);
			}
		}
		
		protected function onNextVideoPlaying(e:CuePointVideoEvent):void
		{
			currentBrandXML = brandsXMLArray[e.params.id].content;
			//trace(currentBrandXML.rootCaption);
			menu.showRootCaption(e.params.id);
		}
		
		
		protected function onHideCurrentCaption(e:Event):void
		{
			menu.hideRootCaptions();
		}
	}
}