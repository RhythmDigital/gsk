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
		
		public function CuePointVideoPlayer(width:int, height:int)
		{
			clock = new Date();
			vidWidth = width;
			vidHeight = height;
			cuePoints = new Vector.<CuePoint>();
			
			super();	
		}
		
		public function initWithCuePoints(cues:Vector.<CuePoint>):void
		{
			
			for each(var cue:CuePoint in cues) {
				this.cuePoints.push(cue);
			}
			
			init();
		}
		
		public function init():void {
			with(graphics) {
				beginFill(0xffffff, 1);
				drawRect(0,0,stage.stageWidth, stage.stageHeight);
				endFill();
			}
			
			connection = new NetConnection();
			connection.connect(null);
			
			stream = new NetStream(connection);
			var vid:Video = new Video();
			var vidContainer:Sprite = new Sprite();
			var customClient:Object = new Object();
			stream.client = customClient;
			
			customClient["onMetaData"] = function(infoObject):void {
			/*	for (var propName:String in infoObject) {
					trace(propName + " = " + infoObject[propName]);
				}
			*/
				vid.rotation = 90;
				var bounds:Rectangle = vid.getBounds(stage);
				vid.x = -bounds.x;
				vid.y = 0;
			}
			
			
			vid.attachNetStream(stream);
			vidContainer.addChild(vid);
			addChild(vidContainer);
			
			vid.width = vidHeight;
			vid.height = vidWidth;
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, onStatusUpdate);
			
			play();
		}
		
		public function play():void
		{
			stream.play("/IMG_0888.MOV");
		}
		
		protected function onStatusUpdate(e:NetStatusEvent):void
		{
			switch(e.info.code) {
				case "NetStream.Play.Start":
					listenForCuePoints = true;
					break;
				case "NetStream.Play.Stop":
					listenForCuePoints = false;
					break;
			}
			
			for(var s:String in e.info) {
				trace(s+": " + e.info[s]);
			}
		}
		
		private function set listenForCuePoints(listen:Boolean):void
		{
			listeningForCuePoints = listen;
			
			if(listen && !this.hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, onCuePointCheck);
			} else if(!listen) {
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
			trace("CUE  " + cuePoint.id + " >> " + type);	
			dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT_TRIGGER, type, cuePoint.id, {}));
		}
		
		private function get listenForCuePoints():Boolean
		{
			return listeningForCuePoints;
		}
	}
}
