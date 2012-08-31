package   UISuit.UIConf
{
    
	public class BSSLayoutInfo 
	{
    
		public function BSSLayoutInfo(_offsetX : int , _offsetY  : int , _align : int = 0)
		{
			LayoutInfo_offsetX = _offsetX;
			LayoutInfo_offsetY = _offsetY ;
			LayoutInfo_align = _align;
		}
	
		public var LayoutInfo_offsetX : int;
		public var LayoutInfo_offsetY : int;
		public var LayoutInfo_align : int;

		
    
	}
	
}
