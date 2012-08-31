package   UISuit.UIController 
{
 
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSScrollBar;
	import UISuit.UIComponent.BSSSlider;
	import UISuit.UIComponent.BSSTabulation;
	import UISuit.UIConf.UIDEF;
	import Util.GRA_Util.GraphicsUtil;
	
	import flash.display.*;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.*;

	 

	public class BSSDataGrid extends Sprite
	{
				
		
		private var m_getBoardButtonFunc : Function;
		private var m_getSliderButtonFunc : Function;
		private var m_slider : BSSSlider;
		private  var m_tabulation : BSSTabulation;
		private var m_boardButtonArray  : Array  = new Array();
		public  var m_boardTypeArray  : Array  = new Array();
		private var m_boardButtonSprite : Sprite = new Sprite();
		private var m_line : DisplayObject ;
		
		private var m_scrollbar : BSSScrollBar;

            

		public var selectFunction : Function;  
    
		public function initStringData ( iRow : int)
		: void {
			m_tabulation.initStringData ( iRow);    
			if (m_scrollbar)
			    m_scrollbar.setContentHeight ( 0 , m_tabulation.contentHeight + m_tabulation.y);
			
			
			m_scrollbar.changeFunction = 
			function(sb:BSSScrollBar):void
			{
				m_tabulation.translate = sb.getContentData();
				//	(m_operatorFunc == null) ?   : m_operatorFunc(getContentData());
				//  if (m_liveDragging && changeFunction != null)
				//     changeFunction(this);
			}
				
			//TODO	
			//m_scrollbar.setOperator(m_tabulation , "translate"  );
		
		}

		 public function activate() 
		 : void {
		if (m_slider)
		    m_slider.activate();
		if (m_scrollbar)
		{    
		    m_scrollbar.activate();
		    if (!hasEventListener(FocusEvent.FOCUS_IN))
		{   
		
		   addEventListener(FocusEvent.FOCUS_IN, setFocusBSSScrollBar ); 
		   addEventListener(FocusEvent.FOCUS_OUT, resetFocusBSSScrollBar );
		}
		}
		 if (m_tabulation)
		    m_tabulation.activate();
		var i : int;
		for each (var btn : BSSButton in m_boardButtonArray)
		{    
		    if (!m_boardTypeArray || !(m_boardTypeArray[i] & UIDEF.BSSDATAGRID_NOT_SORT))
		        btn.activate();
		    i++;
		}
		
		
		 }
		
		 public function deactivate() 
             : void {
                     if (m_slider) {
                        m_slider.deactivate();}
                    if (m_scrollbar)
                    {   
                        m_scrollbar.deactivate();
                        if (hasEventListener(FocusEvent.FOCUS_IN))
			    {   
				
			        removeEventListener(FocusEvent.FOCUS_IN, setFocusBSSScrollBar ); 
			       removeEventListener(FocusEvent.FOCUS_OUT, resetFocusBSSScrollBar );
			    }
                    }

                     if (m_tabulation)
                        m_tabulation.deactivate();  
                    for each (var btn : BSSButton in m_boardButtonArray)
                        btn.deactivate();
                    
             }
             

		private function sortOnBar ( boardBtn : BSSButton)
		: void {


			
			var index : int = m_boardButtonArray.indexOf (boardBtn);
			CONFIG::ASSERT {
			ASSERT(index != -1 , "error button");
			}
			
			var sortStr : Array  = m_tabulation.getStringData();

            if (!sortStr || !sortStr.length)
                return;
                        
			var sortCache : Array = new Array(sortStr.length);
			
			var i : int = 0;
			var stringList : Array ;
			
			if (m_boardTypeArray[index] & Array.NUMERIC)
			{
				for each (stringList in sortStr)
				{
					sortCache[i++] = {   sortId  : Number(stringList[index]),  sortData : stringList.slice()	};
				}
			}
			else
			{
				for each (stringList in sortStr)
				{
					sortCache[i++] = {   sortId  : stringList[index],  sortData : stringList.slice()	};
				}
			}
			
			
			
			sortCache.sortOn("sortId"  , m_boardTypeArray[index] );
			m_boardTypeArray[index] ^= Array.DESCENDING;
			
		 
			
			i = 0;
			for each  (var obj : Object in sortCache)
			{
				 
				m_tabulation.setStringRowData(i++  ,  obj .sortData , false );
				delete obj.sortId;
				delete obj.sortData;
			}
			m_tabulation.updateDisplay();
			
			
			if( sortCache  ){    i  =  sortCache  .length;  { while(  i --)   {  sortCache  [  i ] = null;}};  sortCache   = null; } ;
			obj = null;
			sortStr = null;
			stringList = null;
		}
            




            
		
		public function updateDisplay()
		: void {
			m_tabulation.updateDisplay();
		}
		 
		public function  setAStringData ( ix : int , iy : int , data : String  , bUpdateDisplay : Boolean = true)
		: void {
			m_tabulation.setAStringData( ix , iy  , data , bUpdateDisplay);
		}

		public function  setStringData ( data : Array  , bUpdateDisplay : Boolean = true)
		: void {
			m_tabulation.setStringData(data , bUpdateDisplay);
		}

		public function  setStringRowData ( rowIndex : int ,  data : Array    , bUpdateDisplay : Boolean = true)
		: void {         
			m_tabulation.setStringRowData(rowIndex  ,  data , bUpdateDisplay );
		}

		public function setStringColumeData ( colIndex : int ,data : Array  , bUpdateDisplay : Boolean = true)
        : void {         
            m_tabulation.setStringColumeData ( colIndex  ,data , bUpdateDisplay );
        }

		
		public function dispose ()
		: void {
			GraphicsUtil.removeAllChildren(this);
			if (this.parent)
				this.parent.removeChild(this);
			if (m_boardButtonSprite)
			{
				GraphicsUtil.removeAllChildren(m_boardButtonSprite);
				m_boardButtonSprite = null;
			}
			m_line = null;
			
			var leng : int;

			if (m_scrollbar)
			{
			    if (hasEventListener(FocusEvent.FOCUS_IN))
			    {   
					//TODO
			       removeEventListener(FocusEvent.FOCUS_IN, setFocusBSSScrollBar ); 
			       removeEventListener(FocusEvent.FOCUS_OUT, resetFocusBSSScrollBar );
			    } 
			     m_scrollbar .dispose();  m_scrollbar  = null; ;

			}
			
			if ( m_slider ) { m_slider .dispose();  m_slider  = null;} ;
			if ( m_tabulation ) { m_tabulation .dispose();  m_tabulation  = null;} ;
	
			if( m_boardButtonArray  ){   leng  =  m_boardButtonArray  .length;  { while( leng --)   { if (  m_boardButtonArray  [ leng ] ) {  m_boardButtonArray  [ leng ] .dispose();   m_boardButtonArray  [ leng ]  = null;} ;}};  m_boardButtonArray   = null; }  
			
			m_getBoardButtonFunc =
			m_getSliderButtonFunc =
			selectFunction = 
			null;

			
			
		}
		
		public function BSSDataGrid ( w : int , h : int ,  tabulation : BSSTabulation ,_slider : BSSSlider , scrollbar : BSSScrollBar, line : DisplayObject , getBoardButtonFunc : Function ,  getSliderButtonFunc : Function)
		{
			CONFIG::ASSERT {
			ASSERT (tabulation && _slider , "tabulation or slider should not be null");
			}
			
			m_tabulation = tabulation;
			m_slider = _slider;
			m_line = line;
			m_scrollbar = scrollbar;
			
			addChild(m_tabulation);
			m_tabulation.selectFunction = transBSSTabulationSelectFunction;
			
			addChild(m_boardButtonSprite);
			addChild(m_slider);
			
			if (m_scrollbar)
			{    
			    addChild(m_scrollbar);
                addEventListener(FocusEvent.FOCUS_IN, setFocusBSSScrollBar ); 
			    addEventListener(FocusEvent.FOCUS_OUT, resetFocusBSSScrollBar ); 
			}
                    if (m_line)
			{	
				addChild(m_line);
				m_line.visible = false;
			}

                    width = w;
                    height = h;
                    
			
			m_slider.x = m_slider.y = 0;
			m_tabulation.x = 0;

			
			
			
			m_getBoardButtonFunc = getBoardButtonFunc ; 
			m_getSliderButtonFunc = getSliderButtonFunc ;
			
			
			if (m_getBoardButtonFunc != null )
			{
				addABoardButton( m_getBoardButtonFunc(m_boardButtonArray));
			}
			
			
			m_slider.dragFunction = onDragSilder;
			m_slider.changeFunction = onChangeSilder;

		}

        private function transBSSTabulationSelectFunction( tabulation : BSSTabulation , index : int , strData : Array    )
        : void {
            if (selectFunction != null)
                selectFunction(this , tabulation ,index , strData );
        }
		
		public function initBoardColumn (colNum : int , textFieldArray : Array  = null)
		: void {
			CONFIG::ASSERT {
			ASSERT(colNum > 0 && m_getBoardButtonFunc.length == 1 , "it is has been inited");
			ASSERT(m_getBoardButtonFunc != null , "no func to get a board button");
			}
			var i : int;
			var avgWidth : int = (this.width - (m_scrollbar ? m_scrollbar.width : 0)) / colNum;
			while (--colNum)
			{
				addABoardButton( m_getBoardButtonFunc(m_boardButtonArray));
				m_tabulation.addColumnAt(avgWidth , textFieldArray ? textFieldArray[i++] : null);
			}
			m_tabulation.addColumnAt(avgWidth , textFieldArray ? textFieldArray[i++] : null);
			
			i = 0;
			for each ( var boardButton : BSSButton in m_boardButtonArray)
			{	
				boardButton.x = i * avgWidth;
				boardButton.width = avgWidth;
				if (i > 0)
					m_slider.setThumbPos(i - 1 , i * avgWidth , false);
				i++
			}

			textFieldArray = null;
			
			
			
		}
		
		private function setFocusBSSScrollBar( e : FocusEvent)
		: void {
			//BSSScrollBar.BSSScrollBar_setWheelFocusBSSScrollBar(m_scrollbar) ;
		}
		private function resetFocusBSSScrollBar (e : FocusEvent)
		: void {
			//BSSScrollBar.BSSScrollBar_resetWheelFocusBSSScrollBar(m_scrollbar) ;        
		}

		 public function getBoardName(index : int )
		 : String {
		 
		 CONFIG::ASSERT {
				ASSERT(m_boardButtonArray && index <= m_boardButtonArray.length && m_boardButtonArray[index] , "error index" + index);
		 }
				return m_boardButtonArray[index].text;
		
		 }
		
		public function setBoardNameAndWidth (dataString : Array , widthArray : Array  , boardTypeArray  : Array   = null  , startPos : int = 0 	)
		: void {
			var endIndex : int = startPos + dataString ? dataString.length : 0;
			CONFIG::ASSERT {
			ASSERT(endIndex <= m_boardButtonArray.length , "error index" + endIndex);
			ASSERT( !widthArray || ! dataString || widthArray.length == dataString.length , "un pair data!");
			}
			var maxIndex : int = m_boardButtonArray.length - 1;
			
			var j : int = 0 ;
			for (var i : int = startPos ; i < endIndex ; ++i , ++j )
			{
				if (dataString)
					m_boardButtonArray[i].text = dataString[j];
				if (widthArray)
				{
					m_boardButtonArray[i].width = widthArray[i];
					m_tabulation.setColumnWidth(i , ( widthArray[i]) , true);
					if (i < maxIndex)
					{	
						m_boardButtonArray[i + 1].x = m_boardButtonArray[i].x + widthArray[i];
						m_slider.setThumbPos(i  , m_boardButtonArray[i+1].x , false );
					}
				}
				
				if (boardTypeArray)
				{
					m_boardTypeArray[i] = boardTypeArray[j];
					if ((m_boardTypeArray[i] & UIDEF.BSSDATAGRID_NOT_SORT) && m_boardButtonArray[i])
					    m_boardButtonArray[i].deactivate();
				}
			
			}


			
			dataString = null  ;
			widthArray = null;
		}
		
		
		private function onChangeSilder ( btn : BSSSlider)
		: void {
			CONFIG::ASSERT {
			ASSERT(m_slider == btn , "error func of callback");
			}
			if (m_line)
				m_line.visible = false;

				
			var i : int;
                    for each (var boardBtn : BSSButton in m_boardButtonArray)
                    {    
                        if (!m_boardTypeArray || !(m_boardTypeArray[i] & UIDEF.BSSDATAGRID_NOT_SORT))
                            boardBtn.activate();
                        i++;
                    }
			
			var focusBSSSliderBtnIndex : int = btn.focusBSSSliderBtnIndex;
			var oriWidth : int = m_boardButtonArray[focusBSSSliderBtnIndex].width + m_boardButtonArray[focusBSSSliderBtnIndex + 1].width
			var centerX : int = btn.getThumbPos(focusBSSSliderBtnIndex);
			m_tabulation.setColumnWidth(focusBSSSliderBtnIndex , (centerX - m_boardButtonArray[focusBSSSliderBtnIndex].x) , true);
			
			m_boardButtonArray[focusBSSSliderBtnIndex].width = (centerX - m_boardButtonArray[focusBSSSliderBtnIndex].x);
			m_boardButtonArray[focusBSSSliderBtnIndex + 1].x = centerX;
			m_boardButtonArray[focusBSSSliderBtnIndex + 1].width = oriWidth - m_boardButtonArray[focusBSSSliderBtnIndex].width;
			
			
		}
		
		private function onDragSilder ( btn : BSSSlider)
		: void {
			 ;

			if (m_line)
			{	
				m_line.visible = true;
				m_line. x = btn.getThumbPos(btn.focusBSSSliderBtnIndex);
			}
			if (!m_boardButtonArray[0].isBlock)
			for each (var boardBtn : BSSButton in m_boardButtonArray)
			{
				boardBtn.deactivate();
			}
		}
		
		private function addABoardButton( btn : BSSButton)
		: void {
			 ;
			
			btn.releaseFunction = sortOnBar;
			if (m_boardButtonArray.length > 1)
			{	
				
				var preBtn : BSSButton = m_boardButtonArray[m_boardButtonArray.length - 2];
				preBtn.width /= 2;
				
				preBtn.width >>= 0;  
				
				btn.x = preBtn.x + preBtn.width;
				 
				 
				btn.width = this.width - (m_scrollbar ? m_scrollbar.width : 0) - btn.x;
				
				 
				
				if (m_getSliderButtonFunc != null )
				{
					preBtn =  m_getSliderButtonFunc();
					m_slider.addAThumb(preBtn);
					preBtn.x = btn.x;
					
				}
				preBtn = null;
			}
			else
				m_boardButtonArray[0].width = this.width - (m_scrollbar ? m_scrollbar.width : 0);
				
			m_boardButtonSprite.addChild(btn ); // ASSERT(getChildIndex(m_slider) == numChildren - 1 , "erro index");
			m_boardTypeArray.push(0);
			
			
		}

		public override function set width ( w : Number)
		: void {
                	if (m_scrollbar) 
			{
				w -= m_scrollbar.width;
				m_scrollbar.x = w;
			}
			

			
			m_slider.width = w;
			
			m_tabulation.width = w;
		}

        public override function set height ( h : Number)
		: void {
                if (m_scrollbar) 
                {
                    m_scrollbar.height = h ;
                }
                
                if (m_line)
                {   
                    m_line.height = h;
                }
                m_tabulation.height = h - m_tabulation.y;
                m_tabulation.updateDisplay();
		}


		public static function createSimpleDataGrid ( w : int , h : int ,selectble : Boolean = false )
		: BSSDataGrid {
			
			var silderBg : Shape = new Shape();
			GraphicsUtil.DrawRect(silderBg.graphics, 0, 18, 1, 1, 0xFFFF00);
			//silderBg.graphics.lineStyle(1);
			//silderBg.graphics.moveTo(0, 18);
			//silderBg.graphics.lineTo(1, 18);
			
			var tabulation : BSSTabulation = BSSTabulation.createSimpleBSSTabulation(20,h,selectble);
			tabulation.y = 18;
			
			var linebg : Shape = new Shape();
			GraphicsUtil.DrawRect(linebg.graphics, 0, 0, 1, 1, 0,0.5);
			
			//linebg.graphics.lineStyle(1, 0, 1, true, "none");
			//linebg.graphics.moveTo(0, 0);
			//linebg.graphics.lineTo(0, 100);
			
			//var srollBar : BSSScrollBar = ;
			//srollBar.y = 18;

            var _BSSScrollBar : BSSScrollBar = BSSScrollBar.createSimpleBSSScrollBar(18);
            _BSSScrollBar.setContentHeight(0 , 1 , 20) ;
			
			return new BSSDataGrid (
				w , h , 
				tabulation,
				new BSSSlider(silderBg),
				_BSSScrollBar,
				linebg ,
				createSimpleDataGridBoardButton , createSimpleDataGridButtonButton
			);
			
			
			//getButtonFunc = createSimpleDataGridButtonData;
			
		}
		
		private  static function createSimpleDataGridBoardButton ( _areaArray : Array  )
		: BSSButton {
			CONFIG::ASSERT {
				ASSERT(_areaArray != null , "should not be null");
			}
			return BSSButton.createSimpleBSSButton(100, 18 , "",  true  , _areaArray);
		}
		
		private  static function createSimpleDataGridButtonButton ()
		: BSSButton {
			var shape : Shape = new Shape();
			GraphicsUtil.DrawRect(shape.graphics, -4, 0, 8, 18, 0, 0.0);
			GraphicsUtil.DrawRect(shape.graphics, -1, 0, 1, 18, 0, 0.5);
			GraphicsUtil.DrawRect(shape.graphics, 0, 0, 1, 18, 0, 0.1);
			
			var ctSP : Sprite = new Sprite();
			ctSP.addChild(shape);
			
			shape  = new Shape();
			GraphicsUtil.DrawRect(shape.graphics, -4, 0, 8, 18, 0x0000FF, 0.0);
			GraphicsUtil.DrawRect(shape.graphics, -2, 0, 2, 18, 0x0000FF, 0.8);
			GraphicsUtil.DrawRect(shape.graphics, 0, 0, 2, 18, 0x0000FF, 0.2);
			
			ctSP.addChild(shape);
			
			shape  = new Shape();
			GraphicsUtil.DrawRect(shape.graphics, -4, 0, 8, 18, 0x0000FF, 0.0);
			GraphicsUtil.DrawRect(shape.graphics, -2, 0, 2, 18, 0x0000FF, 0.8);
			GraphicsUtil.DrawRect(shape.graphics, 0, 0, 2, 18, 0x0000FF, 0.2);
			
			ctSP.addChild(shape);
			
			return new BSSButton(ctSP);
		}



	}
	
}
