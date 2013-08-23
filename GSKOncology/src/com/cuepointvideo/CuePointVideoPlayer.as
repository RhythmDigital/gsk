package com.cuepointvideo
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.VideoEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	public class CuePointVideoPlayer extends Sprite
	{
		public static const MODE_SINGLE:String = "MODE_SINGLE";
		public static const MODE_PLAYLIST:String = "MODE_PLAYLIST";
		
		private var vidWidth:int;
		private var vidHeight:int;
		private var settings:XML;
		private var connection:NetConnection;
		private var stream:NetStream;
		private var cuePoints:Vector.<CuePoint>;
		private var currentPoint:CuePoint;
		private var listeningForCuePoints:Boolean;
		private var clock:Date;
		private var vidInfo:Object;
		private var video:Video;
		private var initialised:Boolean;
		private var useCuePoints:Boolean;
		private var mode:String; // single file or playlist? changes play complete behaviour.
		private var playlist:Array;
		private var currentVideo:int;
		private var frameFrozen:Boolean;
		private var frame:Bitmap;
		private var vidContainer:Sprite;
		private var canFade:Boolean;
		
		private var verbose:Boolean = false;
		
		public function CuePointVideoPlayer(width:int, height:int)
		{
			clock = new Date();
			vidWidth = width;
			vidHeight = height;
			cuePoints = new Vector.<CuePoint>();
			
			super();	
		}
		
		public function initWithCuePoints(file:String, cues:Vector.<CuePoint>):void
		{
			for each(var cue:CuePoint in cues) {
				this.cuePoints.push(cue);
			}
			
			init(file);
		}
		
		public function init(file:String=null):void {
			
			if(!initialised) {
				trace("Video player initialising...");
				with(graphics) {
					beginFill(0x000000, 1);
					drawRect(0,0,stage.stageWidth, stage.stageHeight);
					endFill();
				}
				
				connection = new NetConnection();
				connection.connect(null);
				
				stream = new NetStream(connection);
				video = new Video();
				vidContainer = new Sprite();
				var customClient:Object = new Object();
				stream.client = customClient;
				
				
				customClient["onMetaData"] = onMetaData;
				
				
				video.attachNetStream(stream);
				vidContainer.addChild(video);
				addChild(vidContainer);
				
				video.width = vidWidth;
				video.height = vidHeight;
				
				stream.addEventListener(NetStatusEvent.NET_STATUS, onStatusUpdate);
				
				initialised = true;
			} else {
				trace("Video player already initialised.");
			}
			
			if(file) play(file);
		}
		
		public function onMetaData(vidInfo):void {
			this.vidInfo = vidInfo;
			if(verbose) {
				for (var propName:String in vidInfo) {
					trace(propName + " = " + vidInfo[propName]);
				}
			}
			//vid.rotation = 90;
			var bounds:Rectangle = video.getBounds(stage);
			video.x = -bounds.x;
			video.y = 0;
		}
		
		public function play(file:String):void
		{
			trace("play " + file);
			mode = MODE_SINGLE;
		}
		
		public function playPlaylist(files:Array):void
		{
			mode = MODE_PLAYLIST;
			useCuePoints = false;
			playlist = files;
			currentVideo = 0;
			playNextVideo();
		}
		
		private function playNextVideo():void
		{
			var url:String = File.applicationDirectory.url+"assets/video/"+playlist[currentVideo];
			stream.play(url);
			dispatchEvent(new CuePointVideoEvent(CuePointVideoEvent.NEXT_VIDEO_PLAYING, true, false, {id:currentVideo}));
			
			TweenMax.killTweensOf(vidContainer);
			vidContainer.alpha = 0;
			
			currentVideo++;
			if(currentVideo == playlist.length) {
				currentVideo = 0;
			}
		}
		
		protected function onStatusUpdate(e:NetStatusEvent):void
		{
			switch(e.info.code) {
				case "NetStream.SeekStart.Notify":
					//
					break;
				case "NetStream.Play.Start":
					canFade = true;
					break;
				case "NetStream.Buffer.Full":
					trace("Buffer full.");
					
					//trace("START");
					listenForCuePoints = true;
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					
					if(vidContainer.alpha == 0 && canFade) {
						canFade = false;
						trace("FADE IN!");
						TweenMax.to(vidContainer, 1, {alpha:1, ease:Quad.easeOut, overwrite:2});
					}
					
					//stream.resume();
					break;
				case "NetStream.Buffer.Empty":
					//throw("SNAPSHOT HERE!");
					break;
				case "NetStream.Play.Stop":
					listenForCuePoints = false;
					if(mode == MODE_PLAYLIST) {
						freezeFrame();
					}
					break;
			}
			
			for(var s:String in e.info) {
				if(verbose) trace(s+": " + e.info[s]);
			}
		}
		
		private function freezeFrame():void
		{
			if(verbose) trace("FREEZE!!");
			frameFrozen = true;
			if(!frame) {
				frame = new Bitmap(new BitmapData(vidWidth, vidHeight, false, 0xff0000));
			}
			
			frame.bitmapData.draw(vidContainer);
			frame.alpha = 1;
			addChild(frame);
			if(contains(vidContainer)) removeChild(vidContainer);
			
			TweenMax.to(frame, 1, {alpha: 0, ease:Quad.easeOut, onComplete:unfreezeFrame});
		}
		
		public function reset():void
		{
			
		}
		
		private function unfreezeFrame():void
		{
			if(verbose) trace("UNFREEZE!!");
			
			vidContainer.alpha = 0;
			if(!contains(vidContainer)) addChild(vidContainer);
			
			if(frame && contains(frame)) {
				removeChild(frame);
			}
			
			playNextVideo();
			
			frameFrozen = false;
		}
		
		protected function onEnterFrame(e:Event):void
		{
			//if(verbose) trace(stream.time + " / " + vidInfo.duration);
			// loop code
			/*if(stream.time >= 14) {
				trace(stream.time + " / " + vidInfo.duration);
				listenForCuePoints = false;
				stream.pause();
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				stream.seek(5.23);
			}*/
		}
		
		private function set listenForCuePoints(listen:Boolean):void
		{
			listeningForCuePoints = listen;
			
			if(listen) {
				addEventListener(Event.ENTER_FRAME, onCuePointCheck);
			} else {
				removeEventListener(Event.ENTER_FRAME, onCuePointCheck);
			}
		}
		
		protected function onCuePointCheck(e:Event):void
		{
			clock.time = stream.time*1000;
		//	trace(clock.time);
			if(cuePoints && cuePoints.length) {
				if(clock.time >= cuePoints[0].inTimeMS) {
					if(cuePoints[0].outTimeMS !== null) currentPoint = cuePoints[0];
					processCuePoint(cuePoints.shift(), CuePoint.CUE_IN);
				}
			}
			
			if(currentPoint !== null) {
				if(clock.time >= currentPoint.outTimeMS) {
					processCuePoint(currentPoint, CuePoint.CUE_OUT);
					currentPoint = null;
				}
			}
		}
		
		private function processCuePoint(cuePoint:CuePoint, type:String):void
		{
			if(verbose) trace("CUE  " + cuePoint.id + " >> " + type);	
			dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT_TRIGGER, type, cuePoint.id, {}));
		}
		
		private function get listenForCuePoints():Boolean
		{
			return listeningForCuePoints;
		}
	}
}
