package  
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class TextFieldWithWidth extends TextField
	{
		private var _widthBack : int;
		override public function set width(w : Number)
		: void 
		{
			super.width = w;
			_widthBack = w;
		}
		override public function set text(t : String)
		: void 
		{
			super.text = t;
			if(_widthBack == 0)
			{
				autoSize = TextFieldAutoSize.LEFT;
				width = 1000;
				//trace(textWidth , t);
				width = textWidth + 5;
			}
		}
		
		public function TextFieldWithWidth() 
		{
			
		}
		
	}

}