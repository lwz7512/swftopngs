package com.ybcx.animdiy.common{
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	/**
	 * 如果指定autosize，则border边框不随width/height大小设置变化
	 * 
	 * 2013/03/21
	 */ 
	public class SimpleText extends TextField{
		
		protected var _normalFormat:TextFormat;
		protected var _txt:String;
		
		public function SimpleText(text:String, color:uint=0, fontSize:int=12, bold:Boolean=false, wrap:Boolean=true, selectable:Boolean=false, autosize:Boolean=true){
			if(autosize) this.autoSize = "left";	
			
			this.wordWrap = wrap;
			this.multiline = true;			
			this.selectable = selectable;
			
			_txt = text;
			
			_normalFormat = new TextFormat(null, fontSize,color,bold,null,false);
			this.defaultTextFormat = _normalFormat;
			
			this.text = _txt;	
		}
		
		public function get defaultTF():TextFormat{
			return _normalFormat;
		}
		
		
	} //end of class
}