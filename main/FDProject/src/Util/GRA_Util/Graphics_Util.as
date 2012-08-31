package  Util.GRA_Util   { 
	

	import flash.geom.*;
	import flash.display.*;

  	public class  Graphics_Util {
    
    
    
      	public static function DrawLine (g : Graphics, x : Number , y : Number , x2 : Number, y2 : Number , thickness : Number = NaN, color : Number = 0 ,alpha : Number = 1, power : Number = 1 )
	: void {
		g.lineStyle(thickness , color , alpha);
		g.moveTo (x*power,y*power);
		g.lineTo (x2*power,y2*power);
	}

	public static function DrawRect (g : Graphics, x : Number , y : Number , w : Number, h : Number , colorFill : Number , alphaFill : Number = 1 ,     thickness : Number = NaN, colorLine : Number = 0,alphaLine : Number = 1, power : Number = 1 )
	: void {

		if (!isNaN(alphaFill))
			g.beginFill (colorFill , alphaFill);
		g.lineStyle(thickness ,colorLine , alphaLine);

		g.drawRect (x*power,y*power,w*power,h*power);

		if (!isNaN(alphaFill))
			g.endFill ();

	}



	public static function removeAllChildren (container:DisplayObjectContainer)
	:void {
		if (container)
		while (container.numChildren > 0)
		{
			container.removeChildAt(0);
		}
	}

	public static function removeAllChildrenOfClass (container:DisplayObjectContainer , classType : Class)
	:void {
		if (container)
		{
			for (var i : int = 0 ; i < container.numChildren ;)
			{
				if (container.getChildAt(i) is classType)
				{
							container.removeChildAt(i);
				}
				else
					i++;
			}
		}
	}


	public static function removeAllChildrenWithDispose (container:DisplayObjectContainer)
	:void {
		if (container)
		while (container.numChildren > 0)		{
		
			var obj : DisplayObject = (container.getChildAt(0));
			if (obj.hasOwnProperty("dispose") && obj["dispose"] is Function)
			{	
			    obj["dispose"]();
			}			
			if (container.contains(obj)) 
				container.removeChild(obj);	
			obj = null; 	
		
		}

	}




				public static function Graphics_Util_init() : void {};
            
				public static function Graphics_Util_dispose() : void {};
            



    
  }
}
