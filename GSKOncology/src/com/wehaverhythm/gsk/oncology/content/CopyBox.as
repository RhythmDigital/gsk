package com.wehaverhythm.gsk.oncology.content
{
	import com.wehaverhythm.gsk.oncology.Constants;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CopyBox extends Sprite
	{
		private var d:CopyBoxDisplay;
		public function CopyBox(text:String, size:Number = 30, w:Number = 250)
		{
			super();
			
			d = new CopyBoxDisplay();
			d.txtCopy.htmlText = text;
			d.txtCopy.setTextFormat(new TextFormat(Constants.FONT_GILL_SANS, size));
			d.txtCopy.autoSize = TextFieldAutoSize.LEFT;
			d.txtCopy.wordWrap = true;    // prevent width-resize!

			//tf.height = tf.textHeight+5;
			addChild(d);
		}
		
		public function destroy():void
		{
			if(d) {
				removeChild(d);
				d = null;
			}
		}
		
		public function get tf():TextField
		{
			return d.txtCopy;
		}
	}
}