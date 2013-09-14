package  
{
	import Class.ClassBase;
	import Class.ClassMgr;
	import ClassInstance.ClassInstance;
	import flash.display.Sprite;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSItemList;
	import UISuit.UIComponent.BSSItemListScrollBar;
	import UISuit.UIComponent.BSSScrollBar;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class Page extends Sprite
	{
		public static var s_pageBtnArray : Vector.<BSSButton> = new Vector.<BSSButton>();
		public static var s_pageArray : Vector.<Page> = new Vector.<Page>();
		
		
		private var content : BSSItemListScrollBar;// = new BSSItemListScrollBar(BSSScrollBar.createSimpleBSSScrollBar( 18 , true));
		
		public function Page(__xml : XML) 
		{
			
			var scrollBar : BSSScrollBar = BSSScrollBar.createSimpleBSSScrollBar( 16 , true);
			scrollBar.x = EditableEditor2.STAGE_WIDTH - 30;
			//scrollBar.y = 600;
			content = new BSSItemListScrollBar(scrollBar);
		
		
		
			var btn :BSSButton = 
			BSSButton.createSimpleBSSButton(50 , 18 , __xml.@name , true , s_pageBtnArray);
			addChild(btn);
			btn.statusMode = true;
			
			if (s_pageBtnArray.length > 1)
				btn.x = s_pageBtnArray[s_pageBtnArray.length - 2].x  + s_pageBtnArray[ s_pageBtnArray.length - 2].width + 5;
			else
			{
				btn.x += 5;
				graphics.lineStyle(1);
				graphics.moveTo(5, 28);
				graphics.lineTo(500, 28);
			}
			
			s_pageArray.push(this);
			
			btn.y = 5;
			
			btn.releaseFunction = function (btn : BSSButton): void
			{
				for each (var p : Page in s_pageArray)
				{
					p.content.visible = false;
				}
				ASSERT(btn.parent is Page , "error");
				((Page)(btn.parent)).content.visible = true;
				//trace()
			}
			
			addChild(content);
			
			content.width = scrollBar.x;
			content.height = EditableEditor2.STAGE_HEIGHT - 65;
			content.x = 5;
			content.y = 35;
			content.visible = false;
			
			var contentWH : SpriteWH = new SpriteWH();
			content.addItem(contentWH);
			
			var _width : Number = 0;
			var _height : Number = 0;
			var _maxHeight : Number = 0;
					
			var list : XMLList = __xml.elements();
			for each (var subXml : XML in list)
			{
				ASSERT(subXml.name() == "classInstance" || subXml.name() == "ClassInstance" , "unknow name " + subXml.name());
				
				if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance" )
				{
					
						var className : String = subXml.attribute("class");
						//trace("className " + className);
						if (className == "ENTER")
						{
							_width = 0;
							_height += (5 + (_maxHeight == 0 ? 18 : _maxHeight));
							_maxHeight = 0;
							continue;
						}
						else if (className == "GAP")
						{
							_width += int(subXml.@width);
							continue;
						}
						//item class = "NPC Selector" name = "NPC Name"
						var classBase : ClassBase = ClassMgr.findClass(className);
						var ci : ClassInstance = new  ClassInstance( classBase ,  subXml.@name );
						ci.isResident = true;
						//trace("classBase.ini" , classBase)
						//trace(subXml.@default)
						classBase.init(ci , subXml);
						//trace("classBase.ini2")
						ci.x = _width;
						ci.y = _height;
						
						//trace(ci , ci.width);
						
						//trace("_height " + _height);
						
						_maxHeight = Math.max(_maxHeight , ci.height);
						contentWH.addChild(ci);
						_width += ci.width + 5;
						

				}
				
			}
			
		}
		
	}

}