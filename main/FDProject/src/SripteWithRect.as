package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author blueshell
	 */
	public class SripteWithRect extends SpriteWH
	{
		public var redrawFunction : Function;
		
		public override function dispose()
		: void 
		{
			super.dispose();
			redrawFunction = null;
		}
		
		public override function get width()
		: Number
		{
			mouseEnabled = false;
			return rect.width + 5;
		}
		
		public override function get height()
		: Number
		{
			return rect.height + 5;
		}
		
		
		override public function recomputerWH()
		: void {
			super.recomputerWH();
			redrawRect();
		}
		
		override public function childEndChangeWH(dsp : DisplayObject)
		: void
		{
			
			childEndChangeWHCompute(dsp);
			redrawRect();
			if (parent && parent is SpriteWH)
				SpriteWH(parent).childEndChangeWH(this); 
		}
		
		private function redrawRect()
		: void {
			if (rect)
			{
				graphics.clear();
				graphics.beginFill(0xAAAAFF , 0.15);
				graphics.lineStyle(1 , 0x9999FF);
				graphics.drawRect(0, 0, rect.right + 5 , rect.bottom + 5 );
				
				if (redrawFunction != null)
					redrawFunction(this);
			}
		}
		
		public override function addChildAt(content : DisplayObject , layer : int )
		: DisplayObject {
			content = super.addChildAt(content , layer);
			redrawRect();
			return content;
		}
		
		public override function addChild(content : DisplayObject )
		: DisplayObject {
			content = super.addChild(content);
			redrawRect();	
			return content;
		}
		
		public override function removeChild(content : DisplayObject )
		: DisplayObject {
			content = super.removeChild(content);
			redrawRect();
			return content;
		}
	}

}