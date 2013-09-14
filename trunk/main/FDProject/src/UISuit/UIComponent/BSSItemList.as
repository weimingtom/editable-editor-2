package UISuit.UIComponent 
{
	import  flash.events.* ; 	
	import  flash.text.* ; 	
	import  flash.display.* ; 	
	import	Util.GRA_Util.*;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class BSSItemList extends Sprite
	{

		//private var 	m_itemList	: Array = new Array();
		private var 	m_spaceX	: int ;
		private var		m_spaceY	: int ;
		private var 	m_mask		: Shape;
	

		protected var m_itemContainer : DisplayObjectContainer;

		
		public function setSpaceY(_spaceY : Number)
		: void 
		{
			m_spaceY = _spaceY;
			//trace(m_spaceY);
		}
		
		public function BSSItemList(_spaceX	: int = 0 , _spaceY	: int = 0)
		{
			m_spaceX = _spaceX;
			m_spaceY = _spaceY;
			m_itemContainer = new Sprite();
			addChild(m_itemContainer);

			m_mask = new Shape();
			m_mask.graphics.beginFill(0);
			m_mask.graphics.drawRect(0,0,1,1);
			m_mask.graphics.endFill();
			addChild(m_mask);
			m_itemContainer.mask = (m_mask);

			
		}
		
		 public function dispose()
		 : void 
		 {
			CONFIG::Debug {
				trace("BSSItemList dispose");
			}
			
			
			m_mask = null;
			
			/*
			 * var leng : int = m_itemList.length;
			for (var i : int = 0 ; i < leng ; i++ )
				m_itemList[i] = null;
			m_itemList = null;
			*/
			
			Graphics_Util.removeAllChildrenWithDispose(this);
			 
	     }

		override public function set width(w : Number)
		: void 
		{
			m_mask.scaleX = (w);
		}
		
		override public function set height(h : Number)
		: void 
		{
			m_mask.scaleY = (h);
		}

		override public function get width() 
		: Number
		{
			return m_mask.scaleX;
		}
		override public function get height() 
		: Number
		{
			return m_mask.scaleY 
		}

		public  function get size()
		: int
		{
			return m_itemContainer.numChildren;
			//return m_itemList.length;
		}

		public  function clearAllItem(_disposeItem : Boolean = false)
		: void
		{
			/*
			CONFIG::ASSERT {		ASSERT(m_itemList.length == m_itemContainer.numChildren , ("error add other item??"));}
			if (m_itemList.length)
			{
				var len : int = m_itemList.length;
				for (var i : int = 0 ; i < len; i++ )
					m_itemList[i] = null;
				m_itemList.length = 0;
			}
			*/
			
			if (m_itemContainer.numChildren)
			{
				if (_disposeItem)
					Graphics_Util.removeAllChildrenWithDispose(m_itemContainer);
				else
					Graphics_Util.removeAllChildren(m_itemContainer);
			}
				
		}
		
		public function freshItem()
		: void
		{
			
		}

		public  function  addItem(item : DisplayObject )
		: void
		{
			CONFIG::ASSERT {
				ASSERT(!this.contains(item) );
				//var lbak : int = m_itemContainer.numChildren;
				//ASSERT(m_itemList.indexOf(item) == -1 , ("re addItem") );
			}
			if (m_itemContainer.numChildren)
			{
				var  itemLast : DisplayObject 
				//= DisplayObject(m_itemList[m_itemList.length - 1]);
				= m_itemContainer.getChildAt(m_itemContainer.numChildren - 1);
				
				
				item.y = (itemLast.getRect(itemLast.parent ).bottom + m_spaceY);
				//trace("item.y " + item.y);
			}
			
			//m_itemList.push(item);
			m_itemContainer.addChild(item);
			
			//CONFIG::ASSERT {ASSERT(m_itemContainer.numChildren == lbak+1 , ("re addItem") );}			
		}

		public  function getItemAt( _id : int ) : DisplayObject
		{
			return m_itemContainer.getChildAt(_id);// m_itemList[_id];
		}
	}
}


