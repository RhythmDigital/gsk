package com.wehaverhythm.cuepointvideo
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	
	public class CuePointVideoPlayer extends SimpleStageVideo
	{
		public static const MODE_SINGLE:String = "MODE_SINGLE";
		public static const MODE_PLAYLIST:String = "MODE_PLAYLIST";
		private const verbose:Boolean = false;
		
		private var settings:XML;
		private var cuePoints:Vector.<CuePoint>;
		private var currentPoint:CuePoint;
		private var listeningForCuePoints:Boolean;
		private var clock:Date;
		private var vidInfo:Object;
		private var initialised:Boolean;
		private var useCuePoints:Boolean;
		private var playMode:String; // single file or playlist? changes play complete behaviour.
		private var playlist:Array;
		private var currentVideo:int;
		private var vidContainer:Sprite;
		private var canFade:Boolean;
		private var videoPath:String;
		private var contentID:String;
		private var useLooping:Boolean;
		private var listenForLooping:Boolean;
		private var loopIn:Number;
		private var loopOut:Number;
		private var loopInFrame:Number;
		private var loopOutFrame:Number;
		private var videoFrameRate:Number;
		private var numCuePoints:int;
		private var playing:Boolean;
		
		public function CuePointVideoPlayer(width:int, height:int, path:String)
		{
			this.videoPath = path;
			contentID = "";
			clock = new Date();
			
			super();
		}
		
		override protected function init():void {
			
			if(!initialised) {
				if(verbose) trace("Video player initialising...");

				vidContainer = new Sprite();
				with(vidContainer.graphics) {
					beginFill(0x000000, 1);
					drawRect(0,0,stage.stageWidth*1.1, stage.stageHeight*1.1); // overlap to hide dirty edge
					endFill();
				}
				
				addChild(vidContainer);
				
				initialised = true;
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			} else {
				if(verbose) trace("Video player already initialised.");
			}
		}
		
		override public function onMetaData(vidInfo:Object):void {
			super.onMetaData(vidInfo);
			
			this.vidInfo = vidInfo;
			if(verbose) {
				for (var propName:String in vidInfo) {
					trace(propName + " = " + vidInfo[propName]);
				}
			}
			
			videoFrameRate = vidInfo.videoframerate;
			vidContainer.width = vidInfo.width*1.3;
			vidContainer.height = vidInfo.height*1.3;
			
			if(useLooping) {
				setLoopTime();
				calculateCuePointSeconds();
			}
		}
		
		public function play(file:String, contentID:String):void
		{			
			if(this.contentID != contentID || !playing) {
				if(verbose) trace("play " + file + " / contentID: " + contentID);
				resetPlayer();
				var videoFile:String = videoPath+file;
				ns.close();
				ns.play(videoFile);
			}
			
			playMode = MODE_SINGLE;
			useCuePoints = true;
			this.contentID = contentID;
		}
		
		public function playPlaylist(files:Array, contentID:String = null):void
		{
			if(this.contentID == contentID) return;
			this.contentID = contentID;
			
			resetPlayer();
			
			playMode = MODE_PLAYLIST;
			useCuePoints = false;
			useLooping = listenForLooping = false;
			
			playlist = files;
			currentVideo = 0;
			playNextVideo();
		}
		
		private function resetPlayer():void
		{
			if(verbose) trace("RESET PLAYER");
			TweenMax.killTweensOf(vidContainer);
			vidContainer.alpha = 1;
			vidContainer.visible = true;
			
			useCuePoints = false;
			useLooping = listenForLooping = false;
			
			destroyCuePoints();
		}
		
		private function playNextVideo():void
		{
			var url:String = videoPath+playlist[currentVideo];
			if(verbose) trace(url);
			ns.play(url);
			dispatchEvent(new CuePointVideoEvent(CuePointVideoEvent.NEXT_VIDEO_PLAYING, true, false, {id:currentVideo}));
			
			TweenMax.killTweensOf(vidContainer);
			vidContainer.alpha = 1;
			
			currentVideo++;
			if(currentVideo == playlist.length) {
				currentVideo = 0;
			}
		}
		
		override protected function onNetStatus(e:NetStatusEvent):void
		{
			super.onNetStatus(e);
			
			switch(e.info.code) {
				case "NetStream.Play.Start":
					canFade = true;
					break;
				case "NetStream.Buffer.Full":
					if(verbose) trace("Buffer full. Can fade: " + canFade);
					
					if(useCuePoints) listenForCuePoints = true;
					if(useLooping) {
						setLoopTime();
						listenForLooping = true;
						ns.resume();
					}
					
					playing = true;
					
					if(vidContainer.alpha > 0 && canFade) {
						canFade = false;
						if(verbose) trace("FADE IN!");
						TweenMax.delayedCall(2, fadeVideoIn, null, true);
					}
					
					break;
				case "NetStream.Play.Stop":
					listenForCuePoints = false;
					if(playMode == MODE_PLAYLIST) {
						freezeFrame();
					}
					break;
			}
			
			for(var s:String in e.info) {
				if(verbose) trace(s+": " + e.info[s]);
			}
		}
		
		private function fadeVideoIn():void
		{
			TweenMax.to(vidContainer, 1, {alpha:0, ease:Quad.easeOut, overwrite:2});
		}
		
		private function setLoopTime():void
		{
			loopIn = loopInFrame / videoFrameRate;
			loopOut = loopOutFrame / videoFrameRate;
		}
		
		private function freezeFrame():void
		{
			dispatchEvent(new CuePointVideoEvent(CuePointVideoEvent.HIDE_CURRENT_CAPTION, true, false, {id:currentVideo}));
			TweenMax.to(vidContainer, 1, {alpha: 1, ease:Quad.easeOut, onComplete:playNextVideo});
		}
		
		public function reset():void
		{
			
		}
		
		protected function onEnterFrame(e:Event):void
		{
			if(listenForLooping && useLooping) {
				if(ns.time >= loopOut) {
					listenForLooping = false;
					listenForCuePoints = false;
					ns.pause();
					ns.seek(loopIn);
				}
			}
			
			if(listenForCuePoints && useCuePoints) {
				var i:int = 0;
				
				for(i; i < numCuePoints; ++i)
				{
					if(ns.time >= cuePoints[i].inTimeSeconds && ns.time < cuePoints[i].outTimeSeconds) {
						if(!cuePoints[i].visible) {
							cuePoints[i].visible = true;
							processCuePoint(cuePoints[i], CuePoint.CUE_IN);
						}
					} else if(cuePoints[i].visible) {
						cuePoints[i].visible = false;
						processCuePoint(cuePoints[i], CuePoint.CUE_OUT);
					}
				}
			}
		}
		
		public function set listenForCuePoints(listen:Boolean):void
		{
			listeningForCuePoints = listen;
		}
		
		public function destroyCuePoints():void
		{
			listenForCuePoints = useCuePoints = false;
			
			// die cuepoints!
			if(cuePoints) {
				while(cuePoints.length) {
					cuePoints[0] = null;
					cuePoints.shift();
				}
			}
			numCuePoints = 0;
		}
		
		private function processCuePoint(cuePoint:CuePoint, type:String):void
		{		
			dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT_TRIGGER, type, cuePoint.id, {}));
		}
		
		public function get listenForCuePoints():Boolean
		{
			return listeningForCuePoints;
		}
		
		public function setLoop(loopIn:Number, loopOut:Number):void
		{
			this.loopInFrame = loopIn;
			this.loopOutFrame = loopOut;
			this.useLooping = true;
			
			if(verbose) trace("Loop set: " + loopIn + "s -> "+loopOut+"s");
		}
		
		public function setCuePoints(cuePoints:Vector.<CuePoint>):void
		{
			useCuePoints = true;
			this.cuePoints = cuePoints;
			numCuePoints = this.cuePoints.length;
		}
		
		private function calculateCuePointSeconds():void
		{
			var i:int = 0;
			if(verbose) trace("Setting up cuepoints: " + cuePoints);
			for(i; i < numCuePoints; ++i)
			{
				cuePoints[i].setFrameRate(videoFrameRate);
			}
		}
	}
}
