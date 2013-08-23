package com.cuepointvideo
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	public class CuePointVideoPlayer extends Sprite
	{
		private var vidWidth:int;
		private var vidHeight:int;
		private var settings:XML;
		private var connection:NetConnection;
		private var stream:NetStream;
		private var cuePoints:Vector.<CuePoint>;
		private var currentPoint:CuePoint;
		private var listeningForCuePoints:Boolean;
		private var clock:Date;
		private var verbose:Boolean = false;
		private var vidInfo:Object;
		private var video:Video;
		
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
		
		public function init(file:String):void {
			with(graphics) {
				beginFill(0xffffff, 1);
				drawRect(0,0,stage.stageWidth, stage.stageHeight);
				endFill();
			}
			
			connection = new NetConnection();
			connection.connect(null);
			
			stream = new NetStream(connection);
			video = new Video();
			var vidContainer:Sprite = new Sprite();
			var customClient:Object = new Object();
			stream.client = customClient;
			

			customClient["onMetaData"] = onMetaData;
				
			
			video.attachNetStream(stream);
			vidContainer.addChild(video);
			addChild(vidContainer);
			
			video.width = vidWidth;
			video.height = vidHeight;
			
			
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, onStatusUpdate);
			play(file);
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
			stream.play(file);
		}
		
		protected function onStatusUpdate(e:NetStatusEvent):void
		{
			switch(e.info.code) {
				case "NetStream.SeekStart.Notify":
					//
				case "NetStream.Play.Start":
					
					break;
				case "NetStream.Buffer.Full":
					trace("START");
					listenForCuePoints = true;
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					stream.resume();
					break;
				case "NetStream.Buffer.Empty":
					//throw("SNAPSHOT HERE!");
					break;
				case "NetStream.Play.Stop":
					listenForCuePoints = false;
					break;
			}
			
			for(var s:String in e.info) {
				if(verbose) trace(s+": " + e.info[s]);
			}
		}
		
		protected function onEnterFrame(e:Event):void
		{
			if(stream.time >= 14) {
				trace(stream.time + " / " + vidInfo.duration);
				listenForCuePoints = false;
				stream.pause();
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				stream.seek(5.23);
			}
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
