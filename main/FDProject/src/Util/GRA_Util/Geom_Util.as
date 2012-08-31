package  Util.GRA_Util   { 
	

	import flash.geom.*;
	import flash.display.*;
  	public class  Geom_Util {
    
    
    
      

	public static function isPointInArea ( pyx : Number , pty : Number , x1 : Number, y1: Number , x2 : Number ,  y2 : Number)
	: Boolean
	{
		return ((pyx>= x1 && pyx < x2) &&  (pty>= y1 && pty < y2));
	}

	public static function isPointInARect ( pyx : Number , pty : Number , x : Number,  y : Number,  w : Number,  h : Number)
	: Boolean
	{
		return ((pyx >= x && pyx < x+w) &&  (pty >= y && pty < y+h));
	}
	
	public static function isPointInARectangle ( pyx : Number , pty : Number , rect : Rectangle )
	: Boolean
	{
		return ((pyx  >= rect.left && pyx  < rect.right ) &&  (pty >= rect.top && pty< rect.bottom));
	}
	
	public static function setLimitRect ( displayObj : DisplayObject , x : int , y : int , w : int , h : int )
	: void {
		displayObj.x = Math.min ( (x + w - displayObj.width) , (Math.max (x , displayObj.x)));
		displayObj.y = Math.min ( (y + h - displayObj.height), (Math.max (y , displayObj.y)));
	}
/*
	public static function limitXY (container:DisplayObjectContainer)
	:void
	{
		container.x = Math.max (0 , container.x);
		container.y = Math.max (0 , container.y);

		container.x = Math.min (DEF_STAGE_WIDTH - container.width , container.x);
		container.y = Math.min (DEF_STAGE_HEIGHT- container.height, container.y);
	}
*/
	

				public static function Geom_Util_init() : void {};
            
				public static function Geom_Util_dispose() : void {};
            



    
  }
}
