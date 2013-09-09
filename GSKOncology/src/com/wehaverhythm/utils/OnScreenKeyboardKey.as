package com.wehaverhythm.utils
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	public class OnScreenKeyboardKey extends Sprite
	{
		private static const specialKeys:Array = [
				"del"
			,	"shift"
			,	"com"
			,	"at"
			,	"space"
			,	"underscore"
			,	"hyphen"
			,	"dot"
		];
		
		private static const specialKeyChars:Array = [
				null//"del"
			,	null//"shift"
			,	".com"//"com"
			,	"@"//"at"
			,	" "//"space"
			,	"_"//"underscore"
			,	"-"//"hyphen"
			,	"."//"dot"
		];
				
		public var char:String;
		public var shiftChar:String;
		public var specialIndex:int;
		private var keySprite:*;
		private var shift:Boolean;
		private var bg:Sprite;
		
		public function OnScreenKeyboardKey(keySprite:*)
		{
			super();
			
			this.mouseChildren = false;
			this.buttonMode = true;
			this.keySprite = keySprite;
			
			x = keySprite.x;
			y = keySprite.y;
			keySprite.x = keySprite.y = 0;
			keySprite.parent.addChild(this);
			keySprite.parent.removeChild(keySprite);
			addChild(keySprite);
			
			bg = new Sprite();
			bg.addChild(keySprite.getChildAt(0));
			keySprite.addChildAt(bg, 0);
			
			char = keySprite.name.substr(keySprite.name.lastIndexOf("_")+1);
			
			specialIndex = specialKeys.indexOf(char);
			
			if(specialIndex == -1) {
				shiftChar = char.toUpperCase();
			}
			
			setText();
		}
		
		public function flash():void
		{
			TweenMax.to(bg, 0, {tint:0xff0000, immediateRender:true});
			TweenMax.to(bg, .5, {tint:0xff0000, removeTint:true, immediateRender:true});
		}
		
		public function set lit(on:Boolean):void
		{
			if(on) {
				TweenMax.to(bg, 0, {tint:0xff0000, immediateRender:true});
			} else {
				TweenMax.to(bg, 0, {removeTint:true, immediateRender:true});
			}
		}
		
		public function set upperCase(isUpperCase:Boolean):void
		{
			if( specialIndex != -1 || !keySprite.hasOwnProperty("txtChar") ) return;
			
			shift = isUpperCase;
			
			setText();
		}
		
		public function setText():void
		{
			if(specialIndex != -1) return;
			
			if(shift) {
				keySprite.txtChar.text = shiftChar;
			} else {
				keySprite.txtChar.text = char;
			}
		}
		
		public function getChar():String
		{
			if(specialIndex == -1) {
				return shift ? shiftChar : char;
			} else {
				return specialKeyChars[specialIndex] == null ? char : specialKeyChars[specialIndex];
			}
		}
	}
}