package   UISuit.UIComponent   {  
	import  flash.events.* ; 	
	import  flash.text.* ; 	
	import  flash.display.* ; 	
	
	//import BSS.Debugger.*;

	import Util.GRA_Util.*  ;  	
	//import BSS.Main.*;

    // import BSS.Spec.*;
    // import BSS.Core.*;
       
	
	/**
	 * @author blueshell
	 * @date 20090614
	 * @version 0.1.0
	 */


	public class BSSButton  extends  Sprite  { 

		
		protected static const   LAYER_IDLE   :   int   =   0 ; 
		protected static const   LAYER_OVER   :   int   =   1 ; 
		protected static const   LAYER_PRESSED   :   int   =   2 ; 


		public static const   SBST_IDLE   :   int   =   0 ; 
		public static const   SBST_IDLE_OVER   :   int   =   1 ; 
		public static const   SBST_PRESS   :   int   =   2 ; 
		public static const   SBST_PRESS_IDLE   :   int   =   3 ; 
		//CONST( SBST_PRESS_OVER , int , 4)


		protected static const   SBST_STATE_MAX   :   int   =   4 ; 
		
		protected static const   SBST_EXT_OUT   :   int   =   10 ; 
		protected static const   SBST_EXT_OTHER_OVER   :   int   =   11 ; 
		protected static const   SBST_EXT_OTHER_PRESS   :   int   =   12 ; 
		
		protected static const   SBST_EXT_MENU_OVER   :   int   =   13 ; 
        protected static const   SBST_EXT_CHILD_OVER   :   int   =   14 ; 
				
		protected  var stBtnArray : Array  = new Array ();
		protected  var stTextArray : Array ;// = new Array ();
		//	
		protected var state : int;
		
		protected  var areaArray : Vector.<BSSButton> ;


		public var pressFunction : Function ;
		public var releaseFunction : Function ;

		//#ifdef MOVE_ON_FUNCTION public var moveOnFunction : Function ;

	//	private var _bBlock : Boolean ;
	//	public function set  clickFunction ( func : Function )
	//	: void {
	//		if (areaArray == null)
	//			releaseFunction = func;
	//		else
	//			pressFunction = func;
	//	}

	//	private var buttonModeSp : Sprite = new Sprite();

         private  static var s_BSSButton_LastOutButton : BSSButton;
	/*		
            public static function BSSButton_init() 
             : void {
               // CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_MOUSE_STAGE_UP , BSSButton_releaseOutSide);
            }
            

            public static function BSSButton_dispose()
            : void {
                s_BSSButton_LastOutButton = null;
                //CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_MOUSE_STAGE_UP , BSSButton_releaseOutSide);
            }

            
           public  static function BSSButton_releaseOutSide( e : MouseEvent = null)
           : void {
                if (s_BSSButton_LastOutButton)
                {     
                    if (s_BSSButton_LastOutButton.state == BSSButton.SBST_PRESS_IDLE)
                        s_BSSButton_LastOutButton.state = BSSButton.SBST_IDLE;
                    s_BSSButton_LastOutButton = null;
                }
           }
	*/


		public static function createSimpleBSSButton(w : int , h : int ,hitString : String = null, autoWidth : Boolean = true , _areaArray : Vector.<BSSButton>  = null )
		: BSSButton {
			var doc : Sprite = new Sprite();
			var shape : Shape = new Shape();
			//var g : Graphics = spahe.graphics;
			Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, h , 0xFFFFFF , 0.7 , 0 ,0 ,0.1  );
			doc.addChild (shape);

			shape = new Shape();
			Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, h , 0xFFFFFF , 0.9 , 0 ,0 ,0.5  );
			doc.addChild (shape);

			shape = new Shape();
			Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, h , 0x62B0FF , 1 ,  0 , 0xFFFFFF ,0.5  );
			doc.addChild (shape);

			if (hitString != null)
			{
				var textField : TextField = new TextField();
				textField.text = hitString;
				textField.width = w;
				textField.height = h;
				doc.addChild (textField);
			}

			return (new BSSButton (doc , hitString , autoWidth , _areaArray));
		}


		public static function createHotSpotBSSButton(w : int , h : int , x : int = 0 , y : int = 0 )
		: BSSButton {
			var doc : Sprite = new Sprite();
			var shape : Shape = new Shape();
			
			Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, h , 0xFFFFFF , 0  );
			CONFIG::Debug {
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, h , 0x0000FF , 0.05  );
			}
			doc.addChild (shape);
			doc.x = x;
			doc.y = y;
			return (new BSSButton (doc));
		}

		
		public function BSSButton (data : DisplayObjectContainer , hitString : String = null, autoWidth : Boolean = false , _areaArray : Vector.<BSSButton>  = null 

		)
		{
			buttonMode = true;
			mouseChildren = false;

			//var tempWidth : Number = data.width;			
			//trace(data.width);
			var i : int;
			

			{
			
				
				var dataNumChildren : int = data.numChildren;
				var dspObj : DisplayObject ;
				
				for ( i = 0 ; i < dataNumChildren ;i++)
				{
					dspObj = data.getChildAt(i);
					//trace(dspObj);
					if (dspObj is TextField)
					{	
						if (!stTextArray) 
							stTextArray = new Array();
						
						stTextArray.push(TextField(dspObj));
					}
					else
						stBtnArray.push(dspObj);
				}
			}
			if (stBtnArray.length == 2)
				stBtnArray.push(stBtnArray[1]);
			if (stTextArray && stTextArray.length == 2)
				stTextArray.push(stTextArray[1]);
				
			CONFIG::ASSERT {
				ASSERT (!stTextArray || stTextArray.length == 1 || stTextArray.length == 3 , "error stTextArray")
				ASSERT (stBtnArray.length == 1 || stBtnArray.length == 3 , "error stBtnArray.length = " + stBtnArray.length)
			}
			
			var tempWidth : Number = stBtnArray[BSSButton.SBST_IDLE ].width;		
			//if (!stTextArray.length)
			//	stTextArray = null;
			
			for each  (var stBtn : DisplayObject in stBtnArray )
			{
				addChild (stBtn);
				stBtn.visible = false;
			}

                   
			if (stTextArray )
			{
			      //var textFormat : TextFormat;
				for each  (var stText : TextField in stTextArray ) 
				{
				      //textFormat = (stText.getTextFormat());
					//if (hitString != null)
					//	stText.text = hitString;
					//stText.setTextFormat(textFormat);
					
					stText.defaultTextFormat =  stText.getTextFormat();
                    if (hitString != null)
						stText.text = hitString;
					
					stText.selectable = false;
					addChild (stText);
					stText.visible = false;
				}
				//textFormat = null;
			}

			stBtnArray[BSSButton.LAYER_IDLE ].visible = true;
			if (stTextArray)
				stTextArray[BSSButton.LAYER_IDLE ].visible = true;

			areaArray = _areaArray;
			if (areaArray != null)
				areaArray.push (this);

			addAllListener ();
			

			if (autoWidth &&  (stTextArray != null))
			{
				var tt : TextField = new TextField();
				tt.autoSize = TextFieldAutoSize.LEFT;
				tt.text = hitString;
				tt.setTextFormat(stTextArray[0].getTextFormat());
				width = (tt.width + ( stBtnArray[0].width - stTextArray[0].width) );
			}
			else// if (setPos)
				width = tempWidth;

			setState(BSSButton.SBST_IDLE  );

			transform.matrix = data.transform.matrix;
			x = data.x;			
			y = data.y;

	//		trace(Graph;icData.totalFrames)
		}

		public function getStateLayer(st: int)
		: int {
			if (st == BSSButton.SBST_PRESS_IDLE  )
				return ( BSSButton.LAYER_IDLE );
			else
				return st;
			
		}
		
		public var statusMode : Boolean;
		public function getStateTrue (st: int)
		: int {
			
			if (st == BSSButton.SBST_EXT_OUT )
			{
				return ( state == BSSButton.SBST_PRESS  ?  BSSButton.SBST_PRESS_IDLE :  BSSButton.SBST_IDLE );
            }
            else if (st == BSSButton.SBST_EXT_OTHER_OVER )
				return ( state == BSSButton.SBST_PRESS  ? BSSButton.SBST_PRESS :  BSSButton.SBST_IDLE );
            else if (st == BSSButton.SBST_EXT_OTHER_PRESS )
                return (BSSButton.SBST_IDLE );

			else if (st == BSSButton.SBST_EXT_MENU_OVER )
			      //  return  ( state == BSSButton.SBST_PRESS  ? BSSButton.SBST_PRESS : BSSButton.SBST_IDLE_OVER);
				return ( state == BSSButton.SBST_IDLE	? BSSButton.SBST_IDLE_OVER : state );

			else				
				return st;
		}

            
		
		public function setState (st: int)
		: void {
		//	buttonMode = false;
			if (st == state)
				return ;

			if (st == BSSButton.SBST_EXT_MENU_OVER  &&  state != BSSButton.SBST_IDLE && state != BSSButton.SBST_PRESS_IDLE )			
				return ;

		    
			if (st == BSSButton.SBST_EXT_OUT )
			{
				s_BSSButton_LastOutButton = this;
			}
			
			CONFIG::ASSERT { ASSERT (state < BSSButton.SBST_STATE_MAX , "error state"); }
			
			var doLayerOld : int = getStateLayer(state);
			state = getStateTrue(st);
			CONFIG::ASSERT { ASSERT (state < BSSButton.SBST_STATE_MAX , "error state");}
			
			var doLayer : int = getStateLayer(state);

			//DBG_TRACE("new state " + state)
			CONFIG::ASSERT {
			ASSERT (state < BSSButton.SBST_STATE_MAX , "error state");
			ASSERT (doLayer < 3 , "error doLayer" + doLayer);
			ASSERT (doLayerOld < 3, "error doLayerOld" + doLayerOld);
			}
					

			if (doLayer != doLayerOld  && stBtnArray.length > 1 )
			{
				stBtnArray[doLayer].visible = true;
				stBtnArray[doLayerOld].visible = false;
				stBtnArray[doLayer].visible = true;
				
				if (stTextArray != null && stTextArray.length == 3)
				{
					stTextArray[doLayerOld].visible = false;
					stTextArray[doLayer].visible = true;
				}
			}

			
			

		}

		public  function removeAllListener ()
		: void {
			
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseRelease);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMousePress);
		
		}

		public  function addAllListener ()
		: void {
			CONFIG::ASSERT {
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_OVER) , "errorhasEventListener");
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_MOVE) , "errorhasEventListener");
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_OUT) , "errorhasEventListener");
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_DOWN) , "errorhasEventListener");
			}
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_UP, onMouseRelease);
			addEventListener(MouseEvent.MOUSE_DOWN, onMousePress);
		}
		
		
		public function set text (str: String)
		: void {
			if (stTextArray)
			{
			   //    var textFormat : TextFormat;
				for each  (var stText : TextField in stTextArray ) 
				{
				
                                stText.text = str;
				
				     // textFormat = stText.getTextFormat();
				     // stText.text = str;
				    //stText.setTextFormat(textFormat);
			       }
			 //      textFormat = null;
			}
		}
		public function set htmlText (str: String)
		: void {
			if (stTextArray)
			{
			   //    var textFormat : TextFormat;
				for each  (var stText : TextField in stTextArray ) 
				{
				
                                stText.htmlText = str;
				
				     // textFormat = stText.getTextFormat();
				     // stText.text = str;
				    //stText.setTextFormat(textFormat);
			       }
			 //      textFormat = null;
			}
		}

		public function get text ()
		: String {

			if (stTextArray != null)
				return stTextArray[0].text ;
			else
				return null;
		}
		
		
		public function setTextFormat(format:TextFormat, beginIndex:int, endIndex:int):void
		{
			if (stTextArray)
			{
				for each (var tf : TextField in stTextArray)
					tf.setTextFormat(format, beginIndex, endIndex);
			}
		}
		
		public  function onMouseOver(e : MouseEvent= null)
		: void {		

//                    DBG_TRACE("state "+ state);
			//#ifdef MOVE_ON_FUNCTION if (buttonMode && moveOnFunction!= null && state != BSSButton.SBST_IDLE_OVER )
			//#ifdef MOVE_ON_FUNCTION	moveOnFunction(this);

		
			if (buttonMode && (state == BSSButton.SBST_IDLE || state == BSSButton.SBST_PRESS_IDLE  )) 
			{
				setState(  (state == BSSButton.SBST_IDLE) ? BSSButton.SBST_IDLE_OVER : BSSButton.SBST_PRESS );
				if (areaArray != null)
				{
					for each(var otherBtn : BSSButton in areaArray)
						if (otherBtn != this )
							otherBtn.setState(BSSButton.SBST_EXT_OTHER_OVER );
				}
			}		
		}
		
		public  function onMouseOut(e : MouseEvent = null)
		: void {
			if (!statusMode || state != BSSButton.SBST_PRESS  )
			{
				setState (BSSButton.SBST_EXT_OUT  );
			}
		}

		
	

		
		public  function onMouseRelease(e : MouseEvent)
		: void {
			if (!buttonMode)
				return;
			if (state == BSSButton.SBST_PRESS)
			{
				if (!statusMode)
					setState ( BSSButton.SBST_IDLE_OVER);
				if (releaseFunction != null)
					releaseFunction(this);
			}
		}

		public  function onMousePress(e : MouseEvent)
		 : void {
			 
			if (!buttonMode)
				return;
			
			//#ifdef MOVE_ON_FUNCTIONif (state ==  BSSButton.SBST_IDLE )
			//#ifdef MOVE_ON_FUNCTION{
				//#ifdef MOVE_ON_FUNCTIONif (moveOnFunction != null)
				//#ifdef MOVE_ON_FUNCTION	moveOnFunction(this);
			//#ifdef MOVE_ON_FUNCTION}
			
			if (areaArray != null)
			{
				for each(var otherBtn : BSSButton in areaArray)
					if (otherBtn != this )
						otherBtn.setState(BSSButton.SBST_EXT_OTHER_PRESS);
			}
			
			setState(BSSButton.SBST_PRESS  );

		//	if (areaArray != null && clickFunction != null)
		//		clickFunction(this);
			if (pressFunction != null )
				pressFunction(this);
		}

		
		override public function set width ( w : Number )
		: void {
			
			//trace(arguments.callee);
			var off : Number =  w - stBtnArray[BSSButton.SBST_IDLE  ].width;

			if (stTextArray != null)
				stTextArray[BSSButton.SBST_IDLE  ].width += off;
			if (stTextArray && stTextArray.length == 3)
			{
				stTextArray[BSSButton.SBST_IDLE_OVER  ].width = stTextArray[BSSButton.SBST_IDLE  ].width;
				stTextArray[BSSButton.SBST_PRESS  ].width = stTextArray[BSSButton.SBST_IDLE  ].width;
			}
			
			for each (var btnDsp :DisplayObject in stBtnArray)
			{
				btnDsp.width += off;
			}

		}
		
		override public function get height ( )
		: Number
		{
			//trace("stBtnArray[BSSButton.SBST_IDLE  ].height" , stBtnArray[BSSButton.SBST_IDLE  ].height);
			return stBtnArray[BSSButton.SBST_IDLE  ].height;
		}
		override public function set height ( h : Number )
		: void {
			var off : Number =  h - stBtnArray[BSSButton.SBST_IDLE  ].height;

			if (stTextArray != null)
			{	
				stTextArray[BSSButton.SBST_IDLE  ].height += off;
				if ( stTextArray.length == 3)
				{
					stTextArray[BSSButton.SBST_IDLE_OVER  ].height += off;
					stTextArray[BSSButton.SBST_PRESS  ].height += off;
				}

			}
			
			if (off)
			for each (var btnDsp :DisplayObject in stBtnArray)
			{
				//trace("before " , btnDsp.height);
				btnDsp.height += off;
				//trace("after " , btnDsp.height);
			}

		}
		
//#ifdef BSSButton_CAN_BLOCK_BUTTON
		/*public function set bBlock ( lock : Boolean)
		: void {
                    if (lock == buttonMode) //lock != bBlock  => lock != !buttonMode
                    {
		
        			buttonMode = mouseEnabled = mouseChildren = !lock;
        			
        			if (lock) {
        				removeAllListener ();
        			}
        			else {
        				//mouseEnabled = true;
        				
        			}
			}
	
		}
            */
            
             public function activate() 
             : void {
                 buttonMode = mouseEnabled /*= mouseChildren*/ = true;
                 if (!this.hasEventListener(MouseEvent.MOUSE_OVER))
					addAllListener ();
             }

             public function deactivate() 
             : void {
                    removeAllListener ();
                    buttonMode = mouseEnabled /*= mouseChildren*/ = false;  
                    
             }
		
		public function get isBlock (  )
		: Boolean {
			return !buttonMode;
	
		}
//#endif
		

		public function dispose()
		: void {
			CONFIG::Debug {
				trace("BSSButon dispose");
			}
			mouseEnabled = false;
			
			pressFunction =
			releaseFunction =
			//#ifdef MOVE_ON_FUNCTION moveOnFunction = 
			null;

			var leng : int;
			if( stBtnArray  ){    leng  =  stBtnArray  .length;  { while(  leng --)   {  stBtnArray  [  leng ] = null;}};  stBtnArray   = null; } ;
			if( stTextArray  ){    leng  =  stTextArray  .length;  { while(  leng --)   {  stTextArray  [  leng ] = null;}};  stTextArray   = null; } ;

			if (areaArray && areaArray.length) //may totally del out side
			{
				CONFIG::ASSERT { ASSERT(areaArray.indexOf(this) != -1 , "error add button areaArray");}
				areaArray.splice(areaArray.indexOf(this),1);
			}
			areaArray = null;

			if (parent)
				parent.removeChild (this);
			if (hasEventListener(MouseEvent.MOUSE_OVER))
				removeAllListener ();
				
			if (this == s_BSSButton_LastOutButton)
		        s_BSSButton_LastOutButton = null;
			
			CONFIG::ASSERT {
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_OVER) , "errorhasEventListener");
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_MOVE) , "errorhasEventListener");
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_OUT) , "errorhasEventListener");
				ASSERT(!this.hasEventListener(MouseEvent.MOUSE_DOWN) , "errorhasEventListener");
			}
		}


	} 
} 


