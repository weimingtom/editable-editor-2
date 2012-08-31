package  Class
{
	import ClassInstance.ClassInstance;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.xml.XMLNode;
	import UISuit.UIComponent.BSSDropDownMenu;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassDynamic extends ClassBase
	{
		private var contenctArray : Vector.<XML> = new Vector.<XML>();
		
		
		public override function formXML(instance : ClassInstance , xml : XML)
		: void 
		{
			var list : XMLList = xml.elements();
			var subInstance : ClassInstance;
			
			for each (var subXml : XML in list)
			{
				if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance" )
				{
					subInstance = instance.getChildClassInstance(subXml.@name);
					if (String(subXml.@instanceUID))
					{	
						subInstance.instanceUID = uint(String(subXml.@instanceUID));
					}
					
					ASSERT(subInstance != null , "error find subInstance " + subXml.@name +" in " + instance.className);
					
					if (subInstance)
					{
						subInstance.classType.formXML(subInstance , subXml);
					}
				}
				else
				{
					ASSERT(false , "unknow item " + subXml.name())
				}
			}
		}
		
		public override function toXML(instance : ClassInstance)
		: XML
		{
			var xml : XML = super.toXML(instance);
			
						
			//trace(instance.content.layerIndex.length , instance.content.layerIndex);
			
			var spContent : SpriteWH = instance.content as SpriteWH;
			if (spContent)
			for each (var dsp : DisplayObject in spContent.layerIndex)
			{
				if (dsp is ClassInstance)
				{	
					if (ClassInstance(dsp).instanceName)
					{
						//trace(ClassInstance(dsp) , ClassInstance(dsp).classType);
						xml.appendChild(
							ClassInstance(dsp).classType.toXML(ClassInstance(dsp))
						);
					}
					
				}
			}
				
			return xml;
		}
		
		public override function dispose()
		: void 
		{
			if (contenctArray)
			{
				var leng : int = contenctArray.length;
				for (var i : int = 0 ; i < leng ; i++ )
					contenctArray[i] = null;
				contenctArray = null;
			}
			super.dispose();
			
		}
		
		public function ClassDynamic (n : String) 
		{
			super(n);
		}
		
		public override function createDsp ()
		: DisplayObject
		{
			var sp : SpriteWH = new SpriteWH();
			var _width : Number = 0;
			var _height : Number = 0;
			var _maxHeight : Number = 0;
			for each (var xml : XML in contenctArray )
			{
				var className : String = xml.attribute("class");
				
				if (className == "ENTER")
				{
					_width = 0;
					_height += (5 + (_maxHeight == 0 ? 18 : _maxHeight));
					_maxHeight = 0;
					continue;
				}
				else if (className == "GAP")
				{
					_width += int(xml.@width);
					continue;
				}
				//item class = "NPC Selector" name = "NPC Name"
				var classBase : ClassBase = ClassMgr.findClass(className);
				var ci : ClassInstance = new  ClassInstance( classBase , xml.@name );
				classBase.init(ci , xml);
				
				ci.x = _width;
				ci.y = _height;
				
				//trace(ci , ci.width);
				
				//trace("_height " + _height);
				
				_maxHeight = Math.max(_maxHeight , ci.height);
				sp.addChild(ci);
				_width += ci.width + 5;
				
			
				
				//trace (xml.attribute("class") , xml.@name);
			}
			return sp;
		}
		
		
		public function addContenct(xml : XML)
		: void 
		{
			contenctArray.push(xml);
		}
		
	}

}