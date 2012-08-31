package  
{
	import ClassInstance.ClassInstance;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import UISuit.UIComponent.BSSItemList;
	import Util.GRA_Util.Graphics_Util;
	/**
	 * ...
	 * @author blueshell
	 */
	public class SpriteWH extends Sprite
	{
		protected var rect : Rectangle = new Rectangle();
		protected var heightBak : int;
		public var extraHeight : int = 0;	
		

		public var layerIndex : Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		public function dispose()
		: void 
		{
			rect = null;
			if (layerIndex)
			{
				var leng : int = layerIndex.length;
				for (var i : int = 0 ; i < leng ; i++ )
					layerIndex[i] = null;
				layerIndex = null;
			}
			Graphics_Util.removeAllChildrenWithDispose(this);
		}
		
		
		public function childWillChangeWH(dsp : DisplayObject)
		: void
		{
			
			
			ASSERT(contains(dsp) , "error call childWillChangeHeight");
			heightBak = dsp.height;
			
			//trace("heightBak " + heightBak);
			
			//for (var i : int = 0 ; i < numChildren ; i++  )
			//{	
			//	if (getChildAt(i) is ClassInstance )
			//		trace("layer " + i  + "is " + ClassInstance(getChildAt(i)).className , ClassInstance(getChildAt(i)).instanceName)
			//}
			
			if (parent && parent is SpriteWH)
				SpriteWH(parent).childWillChangeWH(this);
		}
		
		protected function childEndChangeWHCompute(dsp : DisplayObject)
		: void 
		{
			ASSERT(contains(dsp) , "error call childWillChangeHeight");
			var heightNew  : int = dsp.height;
			var off : int = heightNew - heightBak;
			rect.bottom += off;
			
			//trace("off " + off);
			//trace("from " + getChildIndex(dsp) + " numChildren " +  numChildren);
			
			
			

			var i : int;
			//for ( i = 0 ; i < layerIndex.length ; i++  )
			//{
			//	if ((layerIndex[i]) is ClassInstance)
			//		trace("layer " + i  + "is " + ClassInstance(layerIndex[i]).className , ClassInstance(layerIndex[i]).instanceName)
			//}
		
			
			for ( i = layerIndex.indexOf(dsp) + 1 ; i < layerIndex.length ; i++  )
			{
				//trace(getChildAt(i));
				if (layerIndex[i].y > dsp.y)
					layerIndex[i].y += off;

			}
			
			rect.right = 0;
			for ( i = 0 ; i < numChildren ; i++  )
			{
				var dsp : DisplayObject = getChildAt(i);
				if (rect.right < dsp.width + dsp.x)
					rect.right = dsp.width + dsp.x;
			}
		}
		
		public function childEndChangeWH(dsp : DisplayObject)
		: void
		{
			childEndChangeWHCompute(dsp);

			if (parent && parent is SpriteWH)
				SpriteWH(parent).childEndChangeWH(this); 
			if (parent && parent.parent && parent.parent is BSSItemList)
			{
				//trace("00000000000here!!");
				var bSSItemList :BSSItemList = BSSItemList(parent.parent);
				extraHeight = 300;
				bSSItemList.freshItem();
				extraHeight = 0;
				//bSSItemList.clearAllItem();
				//bSSItemList.addItem(this);
			}
		}
		
		
		public override function get width()
		: Number
		{
			return rect.width;
		}
		
		
		public override function get height()
		: Number
		{
			
			return rect.height + extraHeight;
		}
		
		//public function reLayout(id : int = 0)
		//: void
		//{
			//for (var i : int = id ; i < numChildren ; i++)
			//{
			//	if (i > 0)
			//	{
				//	getChildAt(i).x 
			//	}
			//}
		//}
		
		public override function addChildAt(content : DisplayObject , layer : int )
		: DisplayObject {
			ASSERT(false , "not support yet");
			content = super.addChildAt(content , layer);
			
			if (rect.right < content.width + content.x)
				rect.right = content.width + content.x;
				
				
			if (rect.bottom < content.height + content.y)
				rect.bottom = content.height + content.y;	
			return content;
		}
		
		public override function addChild(content : DisplayObject )
		: DisplayObject {
			
			content = super.addChild(content);
			
			if (rect.right < content.width + content.x)
				rect.right = content.width + content.x;
				
				
			if (rect.bottom < content.height + content.y)
				rect.bottom = content.height + content.y;
				
			ASSERT(layerIndex.indexOf(content) == -1 , "error on addChild");
			if (layerIndex.indexOf(content) == -1)
				layerIndex.push(content);
			return content;
		}
		
		
		public function recomputerWH()
		: void {
			if (!rect)
				return;
			rect.right = rect.bottom = 0;
			
			for (var i : int = 0 ; i < numChildren ; i++ )
			{
				var dsp : DisplayObject = getChildAt(i);
				if (rect.right < dsp .width + dsp .x)
					rect.right = dsp .width + dsp .x;
				
				
				if (rect.bottom < dsp .height + dsp .y)
					rect.bottom = dsp .height + dsp .y;
			}
		}
		
		public override function removeChild(content : DisplayObject )
		: DisplayObject {
			content = super.removeChild(content);
			if (layerIndex)
			layerIndex.splice(layerIndex.indexOf(content) , 1);
			recomputerWH();
			return content;
		}
		
		

		public override function removeChildAt(i : int)
		: DisplayObject
		{
			var content : DisplayObject  = super.removeChildAt(i);
			if (layerIndex)
				layerIndex.splice(layerIndex.indexOf(content) , 1);
			recomputerWH();
			
			//ASSERT(false , "not support yet");
			return null;
		}
	}

}