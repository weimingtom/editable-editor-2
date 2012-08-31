
package {
    

    public class CALLBACK {

    /////////////// Game include

       // public static var CONST_INFO_ARRAY : Array  = new Array (); 

		public static const   ON_ENTER_FRAME    :    int    =    0  ; //;CONST_INFO_ARRAY[  0 ] = "ON_ENTER_FRAME"; 
		
		public static const   ON_STAGE_MOUSE_WHEEL    :    int    =    10  ;
		public static const   ON_NEW_INSTANCE_CREATE    :    int    =    128  ; //;CONST_INFO_ARRAY[  1 ] = "ON_LANGUAGE_CHANGE"; 
		public static const   ON_SELECTOR_CHANGE    :    int    =    129  ; //;CONST_INFO_ARRAY[  2 ] = "ON_MOUSE_STAGE_DOWN"; 
		public static const   ON_INSTANCE_DELETE    :    int    =    130 ; 
		public static const   ON_INSTANCE_CLEARALL    :    int    =    131 ; 
		
		public static const   ON_ALERT_INSTANCE_IS_USING    :    int    =    132 ; 
		
		public static const   CALLBACK_MAX    :    int    =    140  ; //;CONST_INFO_ARRAY[  6 ] = "CALLBACK_MAX"; 

		//public var type : ine;
		public var obj : Object;
		public var func : Function;
		
		public function CALLBACK(_func : Function , _obj : Object) 
		{
			func = _func;
			obj = _obj;
		}
		
		public function dispose()
		: void {
			func = null;
			obj = null;
		}
		
    }
}
