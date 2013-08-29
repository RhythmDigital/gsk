package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class StageVideoDesktop extends Sprite
	{
		private var v:*;
		
		public function StageVideoDesktop()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideo);
		}
		
		protected function onStageVideo(e:StageVideoAvailabilityEvent):void
		{
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			var ns:NetStream = new NetStream(nc);
			ns.client = this;
			
			var file:File = File.applicationDirectory.resolvePath("assets/video/kt_tunstall.mp4");
			if(file.exists) {
				
				 if(e.availability == StageVideoAvailability.AVAILABLE) {
					trace("ININTIALISING: " + e.availability);
					v = stage.stageVideos[0];
					v.addEventListener(StageVideoEvent.RENDER_STATE, onRender);
					v.attachNetStream(ns);
					//v.viewPort = new Rectangle(0,0,1920,1080);
					//v.viewPort = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
					
					
				} else {
					v = new Video(1920,1080);
					v.attachNetStream(ns);
					addChild(v);
				}
				
				ns.play(file.url);//"assets/video/brain_move_stgvid_0.mp4");
			} else {
				trace("FILE DOES NOT EXIST");
			}
			
			
		}
		
		public function onXMPData(o:Object):void
		{
			
		}
		
		public function onMetaData(m:Object):void
		{
			
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
			trace("IO ERROR!");
		}
		
		protected function onRender(event:StageVideoEvent):void
		{
			v.viewPort = new Rectangle(0,0,1920,1080);
			trace("RENDER!");
		}
	}
}