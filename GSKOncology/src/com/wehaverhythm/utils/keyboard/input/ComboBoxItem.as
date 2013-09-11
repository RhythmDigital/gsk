package com.wehaverhythm.utils.keyboard.input
{
	public class ComboBoxItem extends ComboItemDisplay
	{
		public var id:int;
		
		public function ComboBoxItem(label:String, id:int)
		{
			super();
			
			mouseChildren = false;
			txtLabel.text = label;
			this.id = id;
		}
	}
}