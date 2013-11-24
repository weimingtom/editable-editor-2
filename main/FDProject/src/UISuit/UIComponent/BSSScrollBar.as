package   UISuit.UIComponent   {  

	import Debugger.DBG_TRACE;
	import  flash.events.* ; 	
	import  flash.text.* ; 	
	import  flash.display.* ; 
	import  flash.geom.Rectangle;


	import  Util.GRA_Util.*  ;  	
	//import  BSS.Main.*;
	//import BSS.Engine.*;

	//import BSS.Core.*;
	//import BSS.Spec.*;
	//import BSS.Debugger.*;

	/**
	 * @author jasonwluck , blueshell(QQ 87453144 , MSM blueshell@live.com)
	 * @version 0.5.0
	 * @date 2009.06.29
	 * @scrollbar that can operate any Object
	 */
	public class BSSScrollBar extends Sprite 
	{
	
		//private static var s_speed:Number = 6;
		//private static var s_nSpeedLow:Number = 1;
		//private static var s_nSpeedHigh:Number = 3;

		private   var m_scrollUpButton:BSSButton;
		private   var m_scrollDownButton:BSSButton;
		//#if USE_BG_BTN private   var m_scrollBGButton:BSSButton;
		private   var m_scrollBarButton:BSSButton;

		private   var m_scrollableMinY : int ;
		private   var m_scrollableHeight : int ;
		private   var m_scrollbarEdge : int ;

		private   var m_contentMin : Number ;
		private   var m_contentHeight : Number ;

        private  var m_scrollBar_moveFlag : int;		// -1 , 0 , 1 means up stop and down
        private  var m_scrollBar_moveStep : Number = 1;
		
		//#ifdef BG_HITABLE	 
		//private  var m_liveDragging : Boolean ;           
		//public   static var s_focusBBSScrollBar : BSSScrollBar ;           
		//public   static var s_focusBBSScrollBarIsScrolling : Boolean ;      
		//#endif
		
		public var changeFunction : Function;			

		private static const MIN_BAR_HEIGHT : int = 30;
		
		public  function set isHorizontal(isH:Boolean)		
		:void {			
			this.rotation = isH ? 0 : -90;					
		}
		
		public  function get isHorizontal()		
		: Boolean {			
			return (this.rotation >  -45 && this.rotation < 45);					
		}
		
		private function onChange()
		: void {
			//#ifdef ENABLE_operatorObject
			//    s_BSSScrollBar_DragFocusBSSScrollBar.doDefaultOperator();
			//#endif	
			if (changeFunction != null)
				changeFunction(this);
		}

		public static function createSimpleBSSScrollBar ( w : int  , useArrow : Boolean = true )
		: BSSScrollBar {
			
			var containerBBSScrollBar : Sprite = new Sprite();
			var bgShape : Shape = new Shape();
			Graphics_Util.DrawRect( bgShape.graphics ,  0 , 0 , w , w<<2 , 0xF5F5F5 , 0.75 );
			containerBBSScrollBar.addChild(bgShape);
			
			var arrowWidth : int = w / 3;
			var shapeNum : int = useArrow ? 3 : 1;
			
			for (var i : int = 0; i < shapeNum ; i++ )
			{
				var doc : Sprite  = new Sprite();
				var shape : Shape ;//= new Shape();
				
                          
				
				for (var j : int = 0 ; j < 3 ; j ++ )
				{	
					shape = new Shape();
					Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, w , (i==0 ? -0x0606 : 0 ) + ((j == 2) ? 0xFF3333  :  ((j == 1) ? 0xFFDDDD : 0xFFFFFF )) , 0.5 + j * 0.1 , 0 , 0 ,0.15  );
					
					if (i == 1)
					{
						shape.graphics.beginFill(0);
						shape.graphics.moveTo(arrowWidth>>1 , arrowWidth << 1);
						shape.graphics.lineTo(w >> 1 , arrowWidth);
						shape.graphics.lineTo(w - (arrowWidth>>1) , arrowWidth << 1);
						shape.graphics.endFill();
					}
					else if (i == 2)
					{
						shape.graphics.beginFill(0);
						shape.graphics.moveTo(arrowWidth>>1 , arrowWidth );
						shape.graphics.lineTo(w >> 1 , arrowWidth << 1);
						shape.graphics.lineTo(w - (arrowWidth>>1) , arrowWidth);
						shape.graphics.endFill();
					}
					doc.addChild (shape);
				}
				
				if (i == 2) 
				{
					doc.y = w * (3);	//down
				}
				else if (i == 0 && shapeNum == 3) 
				{
					doc.y = w;	//bar
				}
				
				
				containerBBSScrollBar.addChild (doc);	
			}
			
			//var BSSS : BSSScrollBar = new BSSScrollBar(containerBBSScrollBar ); 
			//Graphics_Util.removeAllChildren(containerBBSScrollBar);
			
			return new BSSScrollBar(containerBBSScrollBar );
		}

		//public static function BSSScrollBar_init()	: void {           }

		//public static function BSSScrollBar_dispose()
		//: void {  BSSScrollBar_onDragFocusBSSScrollBarMouseUp(); BSSScrollBar_setWheelFocusBSSScrollBar(null); }

		public   static var s_BSSScrollBar_DragFocusBSSScrollBar : BSSScrollBar;
		
		
            public  static function BSSScrollBar_onBSSScrollBarClick ( btn : BSSButton  )
            : void { 
 				CONFIG::ASSERT {ASSERT(btn.parent is BSSScrollBar , "error scroll bar");}
				
				BSSScrollBar_setDragFocusBSSScrollBar( BSSScrollBar(btn.parent));
				
				btn.startDrag(false , new Rectangle(btn.x , s_BSSScrollBar_DragFocusBSSScrollBar.m_scrollableMinY, 0 , s_BSSScrollBar_DragFocusBSSScrollBar.m_scrollableHeight - btn.height));
				//MouseManager.setDragingObject(btn , new Rectangle(btn.x , s_BSSScrollBar_DragFocusBSSScrollBar.m_scrollableMinY, 0 , s_BSSScrollBar_DragFocusBSSScrollBar.m_scrollableHeight - btn.height), false);
			}
		
//////////////////////////////////
            public  static function BSSScrollBar_setDragFocusBSSScrollBar(fBSSScrollBar_DragFocusBSSScrollBar : BSSScrollBar)
            : void {
                
                if (!s_BSSScrollBar_DragFocusBSSScrollBar) //不为空 以前添加过 还没删除
                {
					fBSSScrollBar_DragFocusBSSScrollBar.addEventListener(MouseEvent.MOUSE_OUT , BSSScrollBar_onDragFocusBSSScrollBarMouseUp);
					fBSSScrollBar_DragFocusBSSScrollBar.addEventListener(MouseEvent.MOUSE_UP , BSSScrollBar_onDragFocusBSSScrollBarMouseUp);
					fBSSScrollBar_DragFocusBSSScrollBar.addEventListener(MouseEvent.MOUSE_MOVE , BSSScrollBar_onDragFocusBSSScrollBarMouseMove);
                    //CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_MOUSE_STAGE_MOVE , BSSScrollBar_onDragFocusBSSScrollBarMouseMove);
                    //CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_MOUSE_STAGE_UP , BSSScrollBar_onDragFocusBSSScrollBarMouseUp);
                }

				s_BSSScrollBar_DragFocusBSSScrollBar = fBSSScrollBar_DragFocusBSSScrollBar;
                BSSScrollBar_setWheelFocusBSSScrollBar(fBSSScrollBar_DragFocusBSSScrollBar)
            }
            
            public  static function BSSScrollBar_onDragFocusBSSScrollBarMouseMove( e : MouseEvent)
            : void {
				 //trace(s_BSSScrollBar_DragFocusBSSScrollBar);
                 if (s_BSSScrollBar_DragFocusBSSScrollBar)
                 {
					 s_BSSScrollBar_DragFocusBSSScrollBar.onChange();
                    
                 }
                 else //ԉԚδ֪քԭӲѻט׃
                 {   
                        BSSScrollBar_onDragFocusBSSScrollBarMouseUp(e);
                 }
            }
			
            public   static function BSSScrollBar_onDragFocusBSSScrollBarMouseUp( e : MouseEvent = null)
            : void {
                if (s_BSSScrollBar_DragFocusBSSScrollBar)
                {
					s_BSSScrollBar_DragFocusBSSScrollBar.stopDrag();
					s_BSSScrollBar_DragFocusBSSScrollBar.removeEventListener(MouseEvent.MOUSE_OUT , BSSScrollBar_onDragFocusBSSScrollBarMouseUp);
					s_BSSScrollBar_DragFocusBSSScrollBar.removeEventListener(MouseEvent.MOUSE_UP , BSSScrollBar_onDragFocusBSSScrollBarMouseUp);
					s_BSSScrollBar_DragFocusBSSScrollBar.removeEventListener(MouseEvent.MOUSE_MOVE , BSSScrollBar_onDragFocusBSSScrollBarMouseMove);
                    //CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_MOUSE_STAGE_MOVE , BSSScrollBar_onDragFocusBSSScrollBarMouseMove);
                    //CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_MOUSE_STAGE_UP , BSSScrollBar_onDragFocusBSSScrollBarMouseUp);
                    s_BSSScrollBar_DragFocusBSSScrollBar = null;
                }
            }

//////////////////////////////////

//#ifdef ENABLE_SB_WHEEL

			public   static var s_BSSScrollBar_WheelFocusBSSScrollBar : BSSScrollBar;
            public static function BSSScrollBar_resetWheelFocusBSSScrollBar(fBSSScrollBar_WheelFocusBSSScrollBar : BSSScrollBar)
            : void {
                 if (s_BSSScrollBar_WheelFocusBSSScrollBar == fBSSScrollBar_WheelFocusBSSScrollBar || fBSSScrollBar_WheelFocusBSSScrollBar == null)  
                    BSSScrollBar_setWheelFocusBSSScrollBar(null) ;
            }
			
			
            public static function BSSScrollBar_setWheelFocusBSSScrollBar(fBSSScrollBar_WheelFocusBSSScrollBar : BSSScrollBar)
            : void {
                if (fBSSScrollBar_WheelFocusBSSScrollBar)
                {
                    if (!s_BSSScrollBar_WheelFocusBSSScrollBar) //不为空 以前添加过 还没删除
                    {
                        CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_STAGE_MOUSE_WHEEL , BSSScrollBar_onWheelFocusBSSScrollBarMouseWheel);
                    }
                }
                else
                {
                    if (s_BSSScrollBar_WheelFocusBSSScrollBar) //为空 以前就已经删除了
                    {
                        CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_STAGE_MOUSE_WHEEL , BSSScrollBar_onWheelFocusBSSScrollBarMouseWheel);
                    }
                }
                s_BSSScrollBar_WheelFocusBSSScrollBar = fBSSScrollBar_WheelFocusBSSScrollBar;
                
            }

            private  function setWheelFocus  (e : FocusEvent ) : void {BSSScrollBar_setWheelFocusBSSScrollBar(this) ; }
            private  function resetWheelFocus (e : FocusEvent ) : void {BSSScrollBar_resetWheelFocusBSSScrollBar(this);}
         
            public  static function BSSScrollBar_onWheelFocusBSSScrollBarMouseWheel (evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
			:void
			{	
					//DBG_TRACE(s_BSSScrollBar_WheelFocusBSSScrollBar.m_contentHeight, s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBar_moveStep);
					var e : MouseEvent = (MouseEvent)(args[0]);
					CONFIG::ASSERT {
						ASSERT(s_BSSScrollBar_WheelFocusBSSScrollBar != null , "null wheel scrollbar");
					}
                    if (e.delta != 0 && s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.visible)
                    {
							//DBG_TRACE("AA" , s_BSSScrollBar_WheelFocusBSSScrollBar.getContentData());
					
                           // s_BSSScrollBar_WheelFocusBSSScrollBar.contentData = s_BSSScrollBar_WheelFocusBSSScrollBar.getContentData() + ((e.delta > 0)  ?  -s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBar_moveStep : s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBar_moveStep);
							//DBG_TRACE("BB" , s_BSSScrollBar_WheelFocusBSSScrollBar.getContentData());    
							var backY : Number = s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y;
                            if (e.delta > 0) 
                            {		
                                if (s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y != s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollableMinY)
                                {   
                                    s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y-= s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBar_moveStep;	
                                    if (s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y < s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollableMinY)
                                        s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y = s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollableMinY;
                                    s_BSSScrollBar_WheelFocusBSSScrollBar.onChange();		
                                }                              
                            }
                            else //if (e.delta < 0)
                            {		
                                var scrollableMaxY : Number = s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollableMinY + s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollableHeight - s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.height;
                                if (s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y != scrollableMaxY)
                                {   
                                     s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y += s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBar_moveStep;
                                      if (s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y > scrollableMaxY)
                                            s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y = scrollableMaxY;
                                    s_BSSScrollBar_WheelFocusBSSScrollBar.onChange();				
                                }                            
                            }
							
							 s_BSSScrollBar_WheelFocusBSSScrollBar.contentData =  s_BSSScrollBar_WheelFocusBSSScrollBar.getContentData(); 
                            if (backY != s_BSSScrollBar_WheelFocusBSSScrollBar.m_scrollBarButton.y && s_BSSScrollBar_WheelFocusBSSScrollBar.changeFunction != null)
                                s_BSSScrollBar_WheelFocusBSSScrollBar.changeFunction(s_BSSScrollBar_WheelFocusBSSScrollBar);
                   				
                    }
		}
//#endif //#ifdef ENABLE_SB_WHEEL		

            
		public function BSSScrollBar(data : DisplayObjectContainer , minContent : Number = 0 , maxContent : Number = NaN , specEdgeOff : Number = 0)
		{
			this.x = data.x;
			this.y = data.y;

			if (isNaN(maxContent))
			    maxContent = data.height;
			
            //m_contentHeight = data.height;        
			//#if USE_BG_BTNm_scrollBGButton = BSSButton.createHotSpotBSSButton(0,0,data.width , data.height);
			//#ifdef BG_HITABLE
			//m_scrollBGButton.pressFunction =  function ( btn : BSSButton  ) : void {s_focusBBSScrollBarIsScrolling = true;  };
			//m_scrollBGButton.releaseFunction =  function ( btn : BSSButton  ) : void {s_focusBBSScrollBarIsScrolling = false;  };
			//#endif
			//0 is BG

                   
			m_scrollBarButton = new BSSButton(DisplayObjectContainer(data.getChildAt(1)));
			m_scrollBarButton.pressFunction = BSSScrollBar.BSSScrollBar_onBSSScrollBarClick;
			
			//m_scrollBarButton.releaseFunction = 
			//function ( btn : BSSButton  ) : void { 
			//	MouseManager.resetDragingObject(m_scrollBarButton ) ;
			//}
			
			
			if (data.numChildren > 2)
			{
					m_scrollUpButton = new BSSButton(DisplayObjectContainer(data.getChildAt(2)));    
					m_scrollUpButton.releaseFunction = scrollUpButton_MouseUp; //MOUSE_UP
					m_scrollUpButton.pressFunction = scrollUpButton_MouseDown;		
					
					m_scrollDownButton = new BSSButton(DisplayObjectContainer(data.getChildAt(3)));  
					m_scrollDownButton.transform.matrix = data.getChildAt(3).transform.matrix;
					m_scrollDownButton.releaseFunction = scrollDownButton_MouseUp;	
					m_scrollDownButton.pressFunction = scrollDownButton_MouseDown;	
			}
			
			
			

			
			addChild(data.getChildAt(0));
			
			//#if USE_BG_BTN if (m_scrollBGButton)
			//#if USE_BG_BTN 	addChild(m_scrollBGButton);

			if (m_scrollUpButton && m_scrollDownButton)
			{
			    addChild(m_scrollUpButton);
			    addChild(m_scrollDownButton);
				
			    m_scrollableMinY = m_scrollUpButton.getRect(this).bottom + specEdgeOff;
			    m_scrollableHeight = m_scrollDownButton.getRect(this).top - specEdgeOff - m_scrollableMinY ;
			    m_scrollbarEdge = height - m_scrollableHeight;
			}
			else
			{
                m_scrollableMinY = 0;
                m_scrollableHeight = height;
                m_scrollbarEdge = 0;
			}
			
			
			addChild(m_scrollBarButton);
			setContentHeight(minContent , maxContent);

			//#ifdef ENABLE_SB_WHEEL
			addEventListener(FocusEvent.FOCUS_IN, setWheelFocus ); 
			addEventListener(FocusEvent.FOCUS_OUT, resetWheelFocus ); 
			//#endif
		}
		
		private function scrollUpdate(e : Event)
		: void {
			if (m_scrollBar_moveFlag == -1)
			{
				scrollUp();
			}
			else if (m_scrollBar_moveFlag == 1)
			{
				scrollDown();
			}
			else
			{
				if (hasEventListener(Event.ENTER_FRAME))
					removeEventListener(Event.ENTER_FRAME, scrollUpdate );
			}
		}
		
		public  function  scrollDownButton_MouseUp(btn : BSSButton = null)	: void
		{
           
			CONFIG::ASSERT {
				if (m_scrollBar_moveFlag == 1)
				{
					ASSERT(m_scrollDownButton == btn , "error scroll btn");
				}
				else
				{
					ASSERT(false , "error scroll btn");
				}
			}
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, scrollUpdate );
			m_scrollBar_moveFlag = 0;
		}
		
		public  function scrollUpButton_MouseUp(btn : BSSButton = null)	 	: void
		{
		   
			CONFIG::ASSERT {
				if (m_scrollBar_moveFlag == -1)
				{	
					
					ASSERT(m_scrollUpButton == btn , "error scroll btn");
					
				}
				else
				{
					ASSERT(false , "error scroll btn");
				}
			}
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, scrollUpdate );
			m_scrollBar_moveFlag = 0;
		}
		
		public  function scrollUpButton_MouseDown (btn : BSSButton)
		:void
		{
			CONFIG::ASSERT {
                ASSERT(btn.parent is BSSScrollBar , "error scroll btn");
				ASSERT(m_scrollUpButton == btn , "error scroll btn");
			}
			
            m_scrollBar_moveFlag = -1;
			if (!hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, scrollUpdate);	
		}
		
		public  function scrollUp ( e : Event = null )           
		: void {                

			//if(m_scrollBar_moveFlag)
			{                
				if (m_scrollBarButton.y > m_scrollableMinY){ 
					m_scrollBarButton.y--;				
					onChange();		
				}                           
				
			}            
		}		

			
		public  function scrollDownButton_MouseDown(btn : BSSButton =null)	
			:void {
				CONFIG::ASSERT {
					ASSERT(btn.parent is BSSScrollBar , "error scroll btn");
					ASSERT(m_scrollDownButton == btn , "error scroll btn");
				}
				
                m_scrollBar_moveFlag = 1;
				if (!hasEventListener(Event.ENTER_FRAME))
					addEventListener(Event.ENTER_FRAME,scrollUpdate );
		}
		
		
		
		public  function scrollDown ( e : Event = null )        
		: void {            
			//if(m_scrollBar_moveFlag)
			{     
				
				//s_BSSScrollBar_DragFocusBSSScrollBar.m_scrollableMinY, 0 , s_BSSScrollBar_DragFocusBSSScrollBar.m_scrollableHeight - btn.height
				if (m_scrollBarButton.y < m_scrollableMinY + m_scrollableHeight - m_scrollBarButton.height)
				{ 
					m_scrollBarButton.y++;					
					onChange();		
				}                              			
			}          
		}			
		
		public function setScrollbarEdge( sbe : Number)
		:void 
		{
			m_scrollbarEdge = sbe;
		}
		
		public override function set height( newHeight : Number )
		: void {

			var contentDataBak : Number = getContentData();
			var step : int = newHeight - (m_scrollbarEdge + m_scrollableHeight); //m_scrollbarEdge = height - m_scrollableHeight ==  height
			

			m_scrollableHeight += step;	
			getChildAt(0).height += step;//bg
			
			if (m_scrollDownButton)
				m_scrollDownButton.y += step;
			setContentHeight(m_contentMin , m_contentHeight - m_contentMin);

			contentData = contentDataBak;
			//trace (m_contentHeight , m_scrollableHeight);
            //if (m_scrollBarButton.visible)
             //   m_scrollBarButton.height = 	Math.max(10,(m_scrollableHeight * m_scrollableHeight) / m_contentHeight);
                    
		}	
		public function setContentHeight(contentMin : Number , contentMax : Number , moveStep : Number = NaN) 
		: void {
			
            var contentDataBak : Number = getContentData();
			
			m_contentMin = contentMin;
			//var newContentHeight : int = contentMax - contentMin;
            m_contentHeight  = contentMax - contentMin;
			
             if (!isNaN(moveStep))
			    m_scrollBar_moveStep = moveStep;
			else
				m_scrollBar_moveStep = Math.max(1 , int(m_scrollableHeight / 50));
				
				
			//trace(m_scrollableHeight , m_scrollbarEdge);
            if (m_contentHeight > m_scrollableHeight + m_scrollbarEdge) //目标大小 > 滚动区域大小
			{        
			        
                        if (!m_scrollBarButton.visible)
                        {
                            m_scrollBarButton.activate();
                            m_scrollBarButton.visible = true;
                        }


                        m_scrollBarButton.height = 	int(Math.max(MIN_BAR_HEIGHT, (m_scrollableHeight * (m_scrollableHeight + m_scrollbarEdge)) / m_contentHeight));
			}
		      else {
			        m_scrollBarButton.height = 10;
			      
					if (m_scrollBarButton.visible)
					{
						m_scrollBarButton.deactivate();
						m_scrollBarButton.visible = false;
                    }

			}

			contentData = contentDataBak;
			
		}

		public function set contentData(newData : Number  )
		: void {
				//DBG_TRACE("CC" , newData);
                 var scrollDataMax : Number = m_contentHeight - m_scrollbarEdge -  m_scrollableHeight;
                 if (newData < m_contentMin)
                    newData = m_contentMin;
                 else if  (newData > scrollDataMax)
                    newData = scrollDataMax;
		
                  if (newData !=  getContentData())
                  {
                    
                     m_scrollBarButton.y = ((newData - m_contentMin ) / (scrollDataMax ))  *  (m_scrollableHeight - m_scrollBarButton.height) + m_scrollableMinY;

                    
                    onChange();	
                        
                  }

		}
		
		public function getContentData() : Number
		{	
			
			if (m_scrollBarButton.visible)
			{
				return ( m_contentHeight - m_scrollbarEdge -  m_scrollableHeight ) * (((m_scrollBarButton.y - m_scrollableMinY) / (m_scrollableHeight - m_scrollBarButton.height)) ) + m_contentMin;
			}
			else
			    return m_contentMin;
		}							
		
		public function getIsActive()
		: Boolean
		{
			return mouseEnabled;
		}
		
		public function activate() : void {
			mouseChildren = true;
			mouseEnabled = true;

			if (m_scrollUpButton) m_scrollUpButton.activate();
			if (m_scrollDownButton) m_scrollDownButton.activate();
			//#if USE_BG_BTN m_scrollBGButton.activate();
			m_scrollBarButton.activate();
			
			//#ifdef ENABLE_SB_WHEEL
			if (!hasEventListener(FocusEvent.FOCUS_IN))
			{   
				addEventListener(FocusEvent.FOCUS_IN, setWheelFocus ); 
				addEventListener(FocusEvent.FOCUS_OUT, resetWheelFocus );
			}
			//#endif

		}					
		public function deactivate() : void {
			mouseChildren = false;
			mouseEnabled = false;

			if (m_scrollUpButton) m_scrollUpButton.deactivate();
			if (m_scrollDownButton) m_scrollDownButton.deactivate();
			//#if USE_BG_BTN m_scrollBGButton.deactivate();
			m_scrollBarButton.deactivate();
			//#ifdef ENABLE_SB_WHEEL
			BSSScrollBar_resetWheelFocusBSSScrollBar(this);
			if (hasEventListener(FocusEvent.FOCUS_IN))
			{   
				removeEventListener(FocusEvent.FOCUS_IN, setWheelFocus ); 
				removeEventListener(FocusEvent.FOCUS_OUT, resetWheelFocus );
			}
			//#endif
			
		}
	////////////////////////////////////////////////////
		
	//#ifdef ENABLE_operatorObject
	/*
	public  var m_operatorObject : Object;
	public  var m_operatorString : String;
	public  var m_operatorFunc : Function;
	
	public function setOperator (operatorObject : Object , operatorString : String , operatorFunc : Function = null) 
	: void {
		m_operatorObject = operatorObject;
		m_operatorString = operatorString;
		m_operatorFunc = operatorFunc;
		
		CONFIG::ASSERT {
			ASSERT (!m_operatorObject ||(Boolean(operatorObject.hasOwnProperty(operatorString)) && Boolean(operatorString)), "object has no content of " + operatorString);
		}
	}
	
	public  function doDefaultOperator () 
	: void {
		if (m_operatorObject && m_operatorString)
		{
			m_operatorObject[m_operatorString] = (m_operatorFunc == null) ?  getContentData() : m_operatorFunc(getContentData());
                  //  if (m_liveDragging && changeFunction != null)
                   //     changeFunction(this);
                        
		}
	}*/
	//#endif //ENABLE_operatorObject
	
	////////////////////////////////////////////////////

	public function dispose()  : void 
	{
		
		CONFIG::Debug {
			trace("BSSScrollBar dispose");
		}
		
		if (hasEventListener(Event.ENTER_FRAME))
		{
			removeEventListener(Event.ENTER_FRAME , scrollUpdate );
		}
		
		//#ifdef ENABLE_SB_WHEEL
	    BSSScrollBar_resetWheelFocusBSSScrollBar(this);
		if (hasEventListener(FocusEvent.FOCUS_IN))
		{   
			removeEventListener(FocusEvent.FOCUS_IN, setWheelFocus ); 
			removeEventListener(FocusEvent.FOCUS_OUT, resetWheelFocus );
		}
		//#endif
		
		if (this == s_BSSScrollBar_DragFocusBSSScrollBar)
		{
			BSSScrollBar_onDragFocusBSSScrollBarMouseUp(); 
		}
			
		if ( m_scrollUpButton ) { 	m_scrollUpButton .dispose();  m_scrollUpButton  = null;		} ;
		if ( m_scrollDownButton ) {	m_scrollDownButton .dispose();  m_scrollDownButton  = null;		} ;
		//#if USE_BG_BTN if ( m_scrollBGButton ) { m_scrollBGButton .dispose();  m_scrollBGButton  = null;} ;
		if ( m_scrollBarButton ) { m_scrollBarButton .dispose();  m_scrollBarButton  = null; } ;
		
		changeFunction = null;
		
		//#ifdef ENABLE_operatorObject
		//m_operatorObject = null;
		//m_operatorString = null;
		//m_operatorFunc = null;
		//#endif
		
		Graphics_Util.removeAllChildren(this);
		 if (parent)
			parent.removeChild(this);
			
		CONFIG::ASSERT {
			ASSERT(!this.hasEventListener(MouseEvent.MOUSE_MOVE) , "errorhasEventListener");
		}
	}


	}
}



/*
	changeFunction
set height //控件的大小
set contentHeight(min , max) //内容的大小
activate //激活监听
deactivate //移除监听 不能被按
和 dispose //联级释放所有东西
get postion
接口
setOperateParam(XXX : Object , paramName : String)
*/