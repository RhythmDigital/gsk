package com.wehaverhythm.gsk.oncology
{
	import flash.filesystem.File;

	public class Constants
	{
		//public static var DEV_MODE:Boolean = true;
		public static var DEBUG:Boolean = false;
		public static var CONTENT_DIR:File;
		
		public static const PATH_SLIDESHOW:String = "/images/slideshows/";
		public static const PATH_CAPTION_IMAGES:String = "/images/";
		public static const PATH_VIDEO_BG:String = "/videos/bg/";
		public static const PATH_VIDEO_CONTENT:String = "/videos/content/";
		
		public static const IDLE_TIMEOUT_MS:int = 30000;
		public static const FONT_GILL_SANS:String = "Gill Sans";
		public static const WIDTH:Number = 1080;
		public static const HEIGHT:Number = 1920;
		public static const CONTENT_LOCATION_FILENAME:String = "GSKContentLocation.txt";
		public static const SHOW_SLIDESHOW_LINKS:Boolean = true;
		public static const SCRIPT_PATH:String = "http://www.gsk-downloads.com/scripts/";
		
		public function Constants()
		{
		}
	}
}