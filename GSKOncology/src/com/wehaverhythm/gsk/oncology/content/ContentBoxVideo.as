package com.wehaverhythm.gsk.oncology.content
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.VideoLoader;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	
	public class ContentBoxVideo extends VideoLoader
	{
		private var onCompleteCallback:Function;
		private var d:ContentBoxDisplay;
		private var seekAmount:Number = 3;
		private var playing:Boolean = false;
		
		public function ContentBoxVideo(display:ContentBoxDisplay, urlOrRequest:*, vars:Object=null)
		{
			super(urlOrRequest, vars);
			
			d = display;
			d.vidPlayer.btnPlayPause.addEventListener(MouseEvent.MOUSE_DOWN, onPlayPauseClicked, false, 0, true);
			d.vidPlayer.btnSeekBack.addEventListener(MouseEvent.MOUSE_DOWN, onSeekBackClicked, false, 0, true);
			d.vidPlayer.btnSeekForward.addEventListener(MouseEvent.MOUSE_DOWN, onSeekForwardClicked, false, 0, true);
			d.vidPlayer.btnPlayPause.buttonMode = d.vidPlayer.btnSeekBack.buttonMode = d.vidPlayer.btnSeekForward.buttonMode = true;
			
			load();
			content.alpha = 0;
			bindVideoControls();
		}
		
		override public function dispose(flushContent:Boolean=false):void
		{
			isPlaying = false;
			d.vidPlayer.btnPlayPause.removeEventListener(MouseEvent.MOUSE_DOWN, onPlayPauseClicked);
			d.vidPlayer.btnSeekBack.removeEventListener(MouseEvent.MOUSE_DOWN, onSeekBackClicked);
			d.vidPlayer.btnSeekForward.removeEventListener(MouseEvent.MOUSE_DOWN, onSeekForwardClicked);
			content.removeEventListener(Event.ENTER_FRAME, onVideoRender);
			netStream.removeEventListener(NetStatusEvent.NET_STATUS, onVideoStatus);
			super.dispose(flushContent);
			d = null;
		}
		
		private function bindVideoControls():void
		{
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onVideoStatus, false, 0, true);
		}
		
		protected function onVideoStatus(e:NetStatusEvent):void
		{
			//trace(e.info.code);
			
			switch(e.info.code) {
				case "NetStream.Unpause.Notify":
				case "NetStream.Buffer.Full":
					TweenMax.to(content, .4, {autoAlpha:1, ease:Quad.easeOut});
					content.addEventListener(Event.ENTER_FRAME, onVideoRender, false, 0, true);
					isPlaying = true;
					break;
				case "NetStream.Pause.Notify":
					content.removeEventListener(Event.ENTER_FRAME, onVideoRender);
					isPlaying = false;
					break;
				case "NetStream.Play.Stop":
					content.removeEventListener(Event.ENTER_FRAME, onVideoRender);
					netStream.pause();
					netStream.seek(0);
					isPlaying = false;
					break;
				case "NetStream.Seek.Complete":
					isPlaying = false;
					break;
			}
		}
		
		public function set isPlaying(state:Boolean):void
		{
			playing = state;
			d.vidPlayer.playPause.gotoAndStop(state ? "playing" : "paused");
		}
		
		protected function onVideoRender(e:Event):void
		{
			d.vidPlayer.progress.scaleX = netStream.time / metaData.duration;
		}
		
		/**
		 * VIDEO PLAYER EVENTS
		 */
		protected function onSeekForwardClicked(e:MouseEvent):void
		{
			netStream.seek(netStream.time+seekAmount);
		}
		
		protected function onSeekBackClicked(e:MouseEvent):void
		{
			netStream.seek(netStream.time-seekAmount);
		}
		
		protected function onPlayPauseClicked(e:MouseEvent):void
		{
			netStream.togglePause();
		}
	}
}