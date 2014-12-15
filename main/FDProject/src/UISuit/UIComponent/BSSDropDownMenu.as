package   UISuit.UIComponent   {  
	import  flash.events.* ; 	
	import  flash.text.* ; 	
	import  flash.display.* ; 	
	import   flash.geom.* ; 
	import Util.GRA_Util.Graphics_Util;

	/**
	 * @author blueshell
	 */

	public class BSSDropDownMenu  extends  Sprite  { 

		public static const   SBST_IDLE   :   int   =   0 ;  
		public static const   SBST_IDLE_OVER   :   int   =   1 ; 
		public static const   SBST_START_SELECT   :   int   =   2 ; 


		public static const   RES_BG   :   int   =   0 ;  
		public static const   RES_BSSButton  :   int   =   1 ;  
		public static const   RES_EFFECT   :   int   =   2 ;  
		public static const   RES_TEXT_0  :   int   =   3 ;  
		public static const   RES_TEXT_1  :   int   =   4 ;  

		public static const   DEFAULT_VALUE  :   int   =   -1 ;  
    


		protected var m_hoverId : int = -1 ;
		public var m_selectedId : int ;

		
		
		protected var state : int;
		

		protected var m_hitBtn : BSSButton;
		protected var m_scrollContainer : DisplayObjectContainer	;
		protected var m_scrollBG : DisplayObject	;
		protected var m_scrollItem : DisplayObject;
		protected var m_itemTemplateTextFormat : TextFormat;
		protected var m_hintText :TextField	;
		
		private var areaArray : Vector.<BSSDropDownMenu>;
		protected var m_scrollItemArray : Vector.<TextField> = new Vector.<TextField>();
		
		protected var  m_itemXOff : int ;
		protected var  m_itemYOff : int ;
		protected var  m_itemWidth : int ;
		protected var  m_itemHeight : int ;
		protected var  m_itemTextHeight : int ;
		protected var  m_isHitButton : Boolean ;
		
		public var pressFunction : Function ;
		public var selectFunction : Function ;

		public function dispose()
		: void {
			if (parent)
				parent.removeChild(this);
				
			if (m_hitBtn) {m_hitBtn.dispose(); m_hitBtn = null;}
			if (m_scrollContainer) { Graphics_Util.removeAllChildren(m_scrollContainer); m_scrollContainer = null; }
			m_scrollBG  = null;
			m_scrollItem  = null;

			m_hintText  = null;
			m_itemTemplateTextFormat = null;
			Graphics_Util.removeAllChildren(this);
			
			if (m_scrollItemArray)
			{
				var i : int;
				var leng : int = m_scrollItemArray.length ;
				for (i = 0 ; i < leng ; i++)
					m_scrollItemArray[i] = null;
				m_scrollItemArray = null;
			}
			
			if (areaArray && areaArray.length)
			{
				areaArray.splice(areaArray.indexOf(this) , 1);
				areaArray = null;
			}
			
			deactivate();
		
			pressFunction =
			selectFunction =
			null;
		}
		
        public static function createSimpleBSSDropDownMenu(
		w : int, h   : int
		, hintString : String = null, 
		autoWidth : Boolean = true , 
		_areaArray : Vector.<BSSDropDownMenu>  = null 
		) : BSSDropDownMenu
		{
			var _allMenuBg : Shape = new Shape();
			Graphics_Util.DrawRect( _allMenuBg.graphics , 0 , 0 , w, h , 0xFFFFFF , 1 , 1 ,0x0 ,1  );

			const edge : int = 2;
			const btnW : int  = 11;

			var _hitBtn : BSSButton ;
			{
				
				var  doc : Sprite = new Sprite();
				var shape : Shape = new Shape();
				//var g : Graphics = spahe.graphics;
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , btnW, h - (edge<<1) , 0xEEEEFF , 0.5 , 0 ,0x0 ,0.2  );
				doc.addChild(shape);

				shape = new Shape();
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , btnW, h - (edge<<1) , 0xEEEEFF , 0.9 , 0 ,0x0 ,0.5  );
				doc.addChild (shape);

				shape = new Shape();
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , btnW, h - (edge<<1) , 0xCCCCFF , 1 ,  0 , 0xFFFFFF ,0.5  );
				doc.addChild (shape);
				const centerY :int  = (int)(h / 2) - 3;
				const centerX :int  = (int)(btnW / 2);

				for (var i : int = 0 ; i < 3 ; i++)
				{
					shape = Shape(doc.getChildAt(i));
					shape.graphics.lineStyle(-1);
					shape.graphics.beginFill(0);

					shape.graphics.moveTo( centerX - 3 , centerY);
					shape.graphics.lineTo( centerX + 3 , centerY);
					shape.graphics.lineTo( centerX  , centerY + 3);
					shape.graphics.lineTo( centerX - 3 , centerY);


					shape.graphics.endFill();

					shape.x = (w - btnW - edge);
					shape.y = (edge);

				}


				_hitBtn = (new BSSButton (doc , hintString , autoWidth , null));
			}
			//DELETE( doc);

			var _hintText : TextField= new TextField();
			//textField.setText(hintString);
			_hintText.width = (w - 8 - btnW - edge);
			_hintText.x = (4);
			_hintText.height = (h) ;
			_hintText.defaultTextFormat.size = 18;
			
			var _scrollItem : Shape = new Shape();
			
			
			var _scrollBG : Shape= new Shape();
			_scrollBG.y = (h);
			_scrollBG.graphics.beginFill (0xFFFFFF , 0.9);
			_scrollBG.graphics.lineStyle(1 ,0xFFFFFF , 1 , true , LineScaleMode.NONE);
			_scrollBG.graphics.drawRect (0, 0, w - 1, 1);
		
			var ddm : BSSDropDownMenu  = new BSSDropDownMenu( _hitBtn, _allMenuBg , _hintText , _scrollBG , _scrollItem, hintString , _areaArray  );
			ddm.setItemTemplate(4 , 0 , (w - 8 - btnW - edge) , (int(ddm.m_itemTemplateTextFormat.size) + 6) , int(ddm.m_itemTemplateTextFormat.size) + 6, ddm.m_itemTemplateTextFormat);

			Graphics_Util.DrawRect( _scrollItem.graphics , 0 , 0 , w, (int)(int(ddm.m_itemTemplateTextFormat.size) + 6) , 0x4444FF , 0.5 );

			return ddm;
		}  
		
		public function BSSDropDownMenu( _hitBtn : BSSButton ,  _allMenuBg : DisplayObject , _hintText : TextField , _scrollBG : DisplayObject  
		, _scrollItem : DisplayObject   , hintString : String = null , _arerArray : Vector.<BSSDropDownMenu> = null
		//*, bool autoWidth = false*/, VECTOR_PTR(BSSDropDownMenu*)* _arerArray /*= NULL*/ ) : m_scrollBG(NULL)
		)
		{
			m_hitBtn = _hitBtn;
			
			m_scrollBG = _scrollBG;
			m_scrollItem = _scrollItem;
			
			
			m_hintText = _hintText;
			ASSERT(m_hitBtn && m_scrollItem && m_hintText, ("m_hitBtn should not be NULL"));

			areaArray = _arerArray;

			if (m_scrollBG)
			{	
				addChild(m_scrollBG);
				m_scrollBG.visible = (false);
			}
			
			


			m_scrollContainer = new Sprite();
			var  maxY : Number = Math.max(	m_hitBtn.y+ m_hitBtn.height , m_hintText.y+ m_hintText.height);

			m_scrollContainer.y = (maxY);
			m_scrollContainer.mouseChildren = false;
			m_scrollContainer.visible = (false);
			addChild(m_scrollContainer);
			
			activate();
			//m_scrollContainer.addEventListener(MouseEvent.MOUSE_MOVE ,BSSDropDownMenu.onMouseOver );

			m_scrollContainer.addChild(m_scrollItem);	
			m_scrollItem.visible = (false);
			//m_scrollItem.mouesEnabled = false;
			
			if (_allMenuBg)
				addChild(_allMenuBg);

			addChild(m_hintText);
			addChild(m_hitBtn);
			m_hitBtn.pressFunction = onOpenMenu;

			m_itemWidth = m_hintText.width;
			m_itemTextHeight = m_itemHeight = m_hintText.height;
			m_itemXOff = m_hintText.x;
			m_itemYOff = m_hintText.y;


			
			m_itemTemplateTextFormat = m_hintText.defaultTextFormat;
			if (hintString)
			{	
				m_hintText.text = (hintString);
				addItem(hintString);
			}

		}
		
		public function activate()
		: void 
		{
			m_hitBtn.activate();
			if (!this.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				this.addEventListener(MouseEvent.MOUSE_MOVE ,onMouseOver );
				this.addEventListener(MouseEvent.MOUSE_DOWN ,onMouseDown );
			}
		}
		public function deactivate()
		: void 
		{
			if (m_hitBtn)
				m_hitBtn.deactivate();
			
			if (this.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				this.removeEventListener(MouseEvent.MOUSE_MOVE ,onMouseOver );
				this.removeEventListener(MouseEvent.MOUSE_DOWN , onMouseDown );
			}
		}


		protected function onMouseDown( evt : MouseEvent)
		: void {

			if (this.m_isHitButton)
				this.m_isHitButton = false;
			else
			if (this.m_scrollContainer.visible)
			{

				var StagePt : Point = new Point();
				StagePt.x = evt.stageX;
				StagePt.y = evt.stageY;
				var localPt : Point = globalToLocal(StagePt);
				
				if (localPt.y < this.m_scrollContainer.y)
				{
					closeMenu();
					return 
				}

				var hoverId : int = (int)((localPt.y - this.m_scrollContainer.y - 0.1) / this.m_itemHeight);

				//DBG_TRACE(_T("select %d %f") , hoverId , mEvt.getMouseEventStruct().localY - this.m_scrollContainer.getY() );


				ASSERT(hoverId >= 0 && hoverId < this.m_scrollItemArray.length, ("error select " + hoverId));

				if (hoverId < 0)
					hoverId = 0 ;
				else if (hoverId >=(int)(this.m_scrollItemArray.length))
					hoverId = this.m_scrollItemArray.length - 1;

				this.selectedId = (hoverId);
				this.closeMenu();

			}


			return;
		}
		
		
		private function closeMenu()
		: void {
			if (this.m_scrollContainer.visible)
			{
				this.m_scrollContainer.visible = (false);

				if (this.m_scrollBG)
					this.m_scrollBG.visible = (false);
				this.setHoverId(-1);
			}
		}
		
		

		protected function onOpenMenu( btn : BSSButton)
		: void {
			ASSERT(btn.parent == this , ("error"));

			this.m_isHitButton = true;
			if (!this.m_scrollContainer.visible)
			{
				this.m_scrollContainer.visible = (true);
				
				if (this.m_scrollBG)
					this.m_scrollBG.visible = (true);
			}
			else
			{
				this.closeMenu();
			}
		}
				
		
		private function setHoverId( hoverId :  int )
		: void {
			if (m_hoverId != hoverId)
			{
				if (hoverId == -1)
				{
//					ASSERT(m_scrollItem.visible , ("error "));
					m_scrollItem.y = 0;
					m_scrollItem.visible = (false);
				}
				else
				{
					if (m_hoverId == -1)
					{
						ASSERT(!m_scrollItem.visible, ("error "));
						m_scrollItem.visible = (true);
					}
					m_scrollItem.y = (m_itemHeight * hoverId );
				}

				m_hoverId = hoverId;
			}
		}
						
		public function setItemTemplate(_itemXOff : int  , _itemYOff : int  ,_itemWidth : int  , _itemHeight : int   ,_itemTextHeight : int   ,ItemTemplateTextFormat : TextFormat  )
		: void {
			m_itemXOff = _itemXOff;
			m_itemYOff = _itemYOff;

			m_itemWidth = _itemWidth;

			m_itemTextHeight = _itemTextHeight;

			if (m_itemHeight != _itemHeight)
			{
				m_itemHeight = _itemHeight;
				m_scrollBG.height = (m_scrollItemArray.length * m_itemHeight ) ;
			}


			if(ItemTemplateTextFormat)  
			{
				m_itemTemplateTextFormat = ItemTemplateTextFormat ;
			}

			for(var i : int = 0 ; i < m_scrollItemArray.length; i++)
			{
				var  newItem : TextField = m_scrollItemArray[i];
				if(ItemTemplateTextFormat)  
					newItem.defaultTextFormat = (m_itemTemplateTextFormat);

				setItemPos(newItem , i);

			}

		}
		
		
		 protected function setItemPos(newItem : TextField  , id : int )
		: void{
			
			newItem.x =((int)(m_itemXOff));
			newItem.y = ((int)((m_itemYOff + id * m_itemHeight)));
			newItem.width= (m_itemWidth);
			newItem.height = (m_itemTextHeight);
		}

		public function set text (str: String)
		: void {

			if (m_hintText.text == selectedString)
			{
				m_hintText.text = str;
				m_scrollItemArray[0].text = str;
				selectedString = str;
			}
			else
				m_scrollItemArray[0].text = str;
			
		}
		
		public function setState (st: int)
		: void {
			
		//	trace ("state "+state);
		//	if (st == BSSDropDownMenu_SBST_IDLE  )	
			if (st != state  )	
			{
			//	addChildAt(stBtnArray[st],1);
			//	removeChild(stBtnArray[state]);
			//	stBtnArray[st].visible = true;
			//	stBtnArray[state].visible = false;
			//	m_hitBtn.setState(BSSButton_SBST_IDLE);
				m_hitBtn.setState(st);
			}
		//	else if (st == BSSDropDownMenu_SBST_START_SELECT  )
		//		m_hitBtn.setState(BSSButton_SBST_PRESS);
			
		//	m_hoverId = 0;
			m_scrollBG.visible = (st >= BSSDropDownMenu.SBST_START_SELECT );
			//trace("m_scrollBG.visible " + m_scrollBG.visible);
			if (!m_scrollBG.visible) 
			{
				m_scrollBG.alpha = 0;
			}
			state = st;
		}


		public function get isSelecting ()
		: Boolean {
			return m_scrollBG.visible;
		}
/*
		public function setSelectedIdByValue (value : int )
		: Boolean
		{
                if (valueArray)
                {
                    for (var i : int = 0 ; i < valueArray.length;i++)
                        if (valueArray[i] == value)
                        {
                            setSelectedId(i);
                            return true;
                        }
		    }

			return false;        
		}
*/
		public function get selectedId ()
		: int {
			return m_selectedId;
		}

		public function set selectedId (destSelectedId: int)
		: void {
				if (m_selectedId != destSelectedId)
				{

					m_selectedId = destSelectedId;
					ASSERT(m_selectedId >= 0 && m_selectedId < this.m_scrollItemArray.length,("error setSelectedId"));

					m_hintText.text = ( (m_scrollItemArray[m_selectedId]).text);

					if (selectFunction != null)
					{
						selectFunction(this);
					}
				}
		}

		
		protected function onMouseOver(evt : MouseEvent)
		: void {


			var StagePt : Point = new Point();
			StagePt.x = evt.stageX;
			StagePt.y = evt.stageY;
			var localPt : Point = m_scrollContainer.globalToLocal(StagePt);
			
			if (localPt.y < 0)
			{
				this.setHoverId(-1);
				return;
			}

			var  hoverId : int = (int)((localPt.y - 1/*- 0.1f*/) / this.m_itemHeight);

			//DBG_TRACE(_T("hover %d %f") , hoverId , mEvt.getMouseEventStruct().localY - this.m_scrollContainer.getY() );


			ASSERT(hoverId >= 0 && hoverId < this.m_scrollItemArray.length , ("error hoverId"));

			if (hoverId < 0)
				hoverId = 0 ;
			else if (hoverId >= this.m_scrollItemArray.length)
				hoverId = this.m_scrollItemArray.length - 1;

			if (this.m_scrollContainer.visible)
				this.setHoverId(hoverId);
		}
		
		/*
		private function onMouseOut(e : MouseEvent) : void {
			
			if (state < BSSDropDownMenu.SBST_START_SELECT )
				setState (BSSDropDownMenu.SBST_IDLE );
		}*/
		
		override public function set width ( w : Number )
		: void {
			var off : Number =  w - m_scrollBG.width;
			m_hitBtn.width += off;
			//ScrollItemEffect.width += off;
			m_scrollItemArray[0].width += off;
			m_scrollBG.width = w;
		//	stBtnArray[BSSDropDownMenu_SBST_IDLE].width = w;
		//	stBtnArray[BSSDropDownMenu_SBST_IDLE_OVER].width = w;
		//	stBtnArray[BSSDropDownMenu_SBST_START_SELECT].width = w;
			m_hitBtn.width = w;
			
		//	trace (ScrollBtn.width,ScrollBtn.x)
		}
		
		override public function get height ()
		: Number {
			if (m_scrollBG.visible)
				return m_scrollBG.getRect(this).bottom * this.scaleY;
			else 
				return getChildAt(0).getRect(this).bottom * this.scaleY;
		}
		
		public function clearAllItem()
		: void
		{
			var leng : int = m_scrollItemArray.length;
			
			var back : String = m_scrollItemArray[i].text;
			
			for (var i : int = 0 ;  i < leng ; i ++ )
			{
				m_scrollItemArray[i].parent.removeChild(m_scrollItemArray[i]);
				m_scrollItemArray[i] = null;
			}
			m_scrollItemArray.length = 0;
			if (m_scrollBG)
				m_scrollBG.height = 0 ;
			m_scrollItem.visible = (false);
			setHoverId(-1);
			
			addItem(back);
		}
		
		public function addItem(text : String)
		: void {
			
			var newItem : TextField = new TextField();
			setItemPos(newItem ,m_scrollItemArray.length);
			m_scrollItemArray.push (newItem);
			newItem.defaultTextFormat = m_itemTemplateTextFormat;
			newItem.selectable = false;
			newItem.mouseEnabled = false;
			//newItem.border = true;
			
			if (m_scrollBG)
			{	
			//	trace(m_scrollItemArray.length * m_itemHeight);
				m_scrollBG.scaleY = m_scrollItemArray.length * m_itemHeight ;
			}


			newItem.text = (text != null) ? text : "" ;
			
			m_scrollContainer.addChild (newItem);

			//setState(state);
		}
/*
		public function resetItem( )
		: void {
		      var absInitItem_space_fromLoad : Number = Math.abs(initItem_space_fromLoad);
		        
			while (m_scrollItemArray.length > 1) {
				m_scrollContainer.removeChild(m_scrollItemArray.pop());
				m_scrollBG.height -= absInitItem_space_fromLoad;
				if (initItem_space_fromLoad < 0)
					m_scrollBG.y -= initItem_space_fromLoad;
			}
                    if (valueArray)
                        valueArray.length = 1;

			
			setSelectedId(0);
		//	ScrollItemEffect.y = initItem_y_fromLoad;
		//	MAIN_SPRITE.removeAllChildren (m_scrollBG);
		//	m_scrollBG.addChild (m_scrollBG);
		//	m_scrollBG.addChild (ScrollItem);
			
		//	m_scrollItemArray.length = 1;
		//	m_scrollBG.addChild (m_scrollItemArray[0]);
		
			maxItem = 1;
			setState(state);		
		}

		public function setItemArray (iarr : Array )
		: void {
			resetItem();
			if (iarr)
			for (var i : int = 0 ; i  < iarr.length ; i++)
				addItem (iarr[i]);
		}

               public var valueArray : Array;
                
		public function setItemValueArray (iarr : Array )
		: void {
			resetItem();

                    if (!valueArray)
                    {
                        valueArray = new Array();
                        valueArray.push(BSSDropDownMenu.DEFAULT_VALUE );
			}
			
			if (iarr)
			for (var i : int = 0 ; i  < iarr.length ; i+=2)
			{	
			   addItem (iarr[i]);
                        valueArray.push(int(iarr[i+1]));
			}
		}

		public function addItemValue (text : String , value : int)
		: void {
                    if (!valueArray)
                    {
                        valueArray = new Array();
                        valueArray.push(BSSDropDownMenu.DEFAULT_VALUE );
			}

			 addItem (text);
			 valueArray.push(value);
		}
*/
		
		public function set selectedString( str : String ) 
		: void {
			var i : int = 0;
			for each (var tf : TextField in m_scrollItemArray)
			{
				if (m_scrollItemArray[i].text == str)
				{
					selectedId = i;
					return;
				}
				i++;
			}
			
			ASSERT(false , "can't find str " + str);
		}

		public function get selectedString( ) 
		: String {
			if (m_selectedId >= 0)
				return m_scrollItemArray[m_selectedId].text ;
			else 
				return null;
		}
		/*
        public function get selectedValue( ) 
		: int {
		        if (valueArray)
			    return valueArray[m_selectedId] ;
			 else
			    return 0;
		}
		*/
		
				
	} 
} 



