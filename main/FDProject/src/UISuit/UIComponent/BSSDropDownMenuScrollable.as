package UISuit.UIComponent 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import Util.GRA_Util.Graphics_Util;
	/**
	 * ...
	 * @author blueshell
	 */
	public class BSSDropDownMenuScrollable extends BSSDropDownMenu
	{
		private var m_scrollBar : BSSScrollBar;
		private var 	m_mask		: Shape;
		
		
		public override function activate()
		: void 
		{
			super.activate();
			m_scrollBar.activate();
		}
		public override function deactivate()
		: void 
		{
			super.deactivate();
			if (m_scrollBar)
				m_scrollBar.deactivate();
		}
		
		public override function  dispose()
		: void 
		{
			if (m_scrollBar) m_scrollBar.dispose(); m_scrollBar = null;
			m_mask = null;
			super.dispose();
		}
		
		/*public override function clearAllItem() : void
		{
			super.clearAllItem();
			
			
		}*/
		
		public static function createSimpleBSSDropDownMenuScrollable (
		w : int, h   : int
		, hintString : String = null, 
		autoWidth : Boolean = true , 
		_areaArray : Vector.<BSSDropDownMenu>  = null 
		) : BSSDropDownMenuScrollable
		{
			var _allMenuBg : Shape = new Shape();
			Graphics_Util.DrawRect( _allMenuBg.graphics , 0 , 0 , w, h , 0xFFFFFF , 1 , 1 ,0x0 ,1  );

			const edge : int = 2;
			const btnW : int  = 14;

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

			var _hintText : TextField = new TextField();
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
		
			var s : BSSScrollBar = BSSScrollBar.createSimpleBSSScrollBar(btnW , false);
			s.x = w -btnW - 2;
			s.y = h + 1;
			
			var ddm : BSSDropDownMenuScrollable  = new BSSDropDownMenuScrollable( 
			_hitBtn, 
			_allMenuBg , 
			_hintText , 
			_scrollBG , 
			_scrollItem, 
			s,
			hintString , 
			_areaArray  );
			ddm.setItemTemplate(4 , 0 , (w - 8 - btnW - edge) , (int(ddm.m_itemTemplateTextFormat.size) + 8) , int(ddm.m_itemTemplateTextFormat.size) + 8, ddm.m_itemTemplateTextFormat);

			Graphics_Util.DrawRect( _scrollItem.graphics , 0 , 0 , w, (int)(int(ddm.m_itemTemplateTextFormat.size) + 6) , 0x4444FF , 0.5 );

			return ddm;
		}  
		
		override public function get height ()
		: Number
		{
			if (m_scrollBG.visible)
				return m_scrollBG.y + scaleY;
			else
				return m_scrollBG.y;
		}
		public function BSSDropDownMenuScrollable(	_hitBtn : BSSButton 
													, _allMenuBg : DisplayObject
													, _hintText : TextField 
													, _scrollBG : DisplayObject 
													, _scrollItem : DisplayObject
													, _scrollBar : BSSScrollBar
													, hintString : String = null
													, _arerArray : Vector.<BSSDropDownMenu> = null
		)
		{
			m_mask = new Shape();
			
			
			m_scrollBar = _scrollBar;
			super(_hitBtn , _allMenuBg , _hintText , _scrollBG , _scrollItem , hintString , _arerArray);
			
			m_mask.graphics.beginFill(0);
			m_mask.graphics.drawRect(0,0,this.width,1);
			m_mask.graphics.endFill();
			
			
			addChild(m_mask);
			m_scrollContainer.mask = (m_mask);
			
			m_mask.y = m_scrollContainer.y; 
			addChild(m_scrollBar);
			
			m_scrollBar.changeFunction = onScrollBarChange;
		}
		
		public function getMaxHeight () : int
		{
			if (m_mask)
				return m_mask.scaleY;
			else
				return 0;
		}
		
		public function setMaxHeight (h : int) : void
		{
			m_scrollBG.scaleY = m_scrollItemArray.length * m_itemHeight ;
			if (m_scrollBG.scaleY > h)
				m_scrollBG.scaleY = h;

			m_mask.scaleY = h;
			m_scrollBar.height = h;
			m_scrollBar.mouseEnabled = m_scrollContainer.height > h;
			if (!m_scrollBar.mouseEnabled)
				m_scrollBar.visible = false;
		}
		
		
					
		static private function onScrollBarChange( bsssb : BSSScrollBar )
		: void
		{
			var _this : BSSDropDownMenuScrollable  = (BSSDropDownMenuScrollable)(bsssb.parent);
			_this.m_scrollContainer.y = _this.m_mask.y -(bsssb.getContentData());
		}	
			
			
			
		
		public override function  addItem(text : String)
		: void {
			
			//trace(m_scrollContainer.height , m_scrollContainer.numChildren);
			super.addItem(text);
			
			m_scrollBar.mouseEnabled = (m_scrollContainer.height > getMaxHeight ());
			
			if (m_scrollBar.mouseEnabled) {
				m_scrollBar.visible =  (m_scrollBG.visible);
			}
			else {
				m_scrollBar.visible = false;
			}
				
			
				
			m_scrollBar.setContentHeight(0, m_scrollBG.scaleY);
			
			if (m_scrollBG.scaleY > getMaxHeight () )
			{	
				//trace(getMaxHeight ())
				m_scrollBG.scaleY = getMaxHeight ();
			}
		}
		
		protected override function onMouseOver( evt : MouseEvent)
		: void {
			var dsp : DisplayObject = (DisplayObject)(evt.target);
			if (dsp == m_scrollBar)
				return;
			while (dsp.parent)
			{
				if (dsp.parent == m_scrollBar)
					return;
				else if (dsp.parent == this)
					break;
					
				dsp = dsp.parent ;
				
			}
			//trace(evt.target);
			super.onMouseOver(evt);
		}
		
		protected override function onOpenMenu( btn : BSSButton)
		: void {
			super.onOpenMenu(btn);
			if (this.m_scrollContainer.visible)
			{
				BSSScrollBar.BSSScrollBar_setWheelFocusBSSScrollBar(m_scrollBar);
			}
			else
			{
				BSSScrollBar.BSSScrollBar_resetWheelFocusBSSScrollBar(m_scrollBar);
			}
		}
		protected override function onMouseDown( evt : MouseEvent)
		: void {
			var dsp : DisplayObject = (DisplayObject)(evt.target);
			if (dsp == m_scrollBar)
				return;
			if (dsp != null)
			while (dsp.parent)
			{
				if (dsp.parent == m_scrollBar)
					return;
				else if (dsp.parent == this)
					break;
					
				dsp = dsp.parent ;
			}
			//trace(evt.target);
			super.onMouseDown(evt);
			
			if (m_scrollBar.mouseEnabled) {
				m_scrollBar.visible =  (m_scrollBG.visible);
			}
			else {
				m_scrollBar.visible = false;
			}
				
			
		}
		
	}

}