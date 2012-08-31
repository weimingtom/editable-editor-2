package  Class
{
	import Debugger.DBG_TRACE;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassMgr
	{
		public static var s_classList : Vector.<ClassBase> = new Vector.<ClassBase>();
		
		
		internal static function unregClass(cls : ClassBase)
		: void 
		{
			ASSERT(s_classList.indexOf(cls) != -1 , "error");
			s_classList.splice(s_classList.indexOf(cls) , 1);
			
			DBG_TRACE("unregClass \"" + cls.className +"\"");
		}
		
		internal static function regClass(cls : ClassBase)
		: void 
		{
			ASSERT(s_classList.indexOf(cls) == -1 , "error");
			s_classList.push(cls);
			
			DBG_TRACE("regClass \"" + cls.className +"\"");
		}
		
		public static function findClass(className : String)
		: ClassBase 
		{
			for each (var  c : ClassBase in s_classList)
				if (className == c.className)
					return c;
			ASSERT(false , "can't find class '" + className+"'");
			return null;
		}
		
		
		
		static public function dealInstanceSelector(xml : XML )
		: void 
		{
			var cs : ClassInstanceSelector = new ClassInstanceSelector(xml.@className);
			cs.editable = ((String)(xml.@editable) == "true");
				
			var list : XMLList = xml.elements();
			
			var valueTypeIsString : Boolean = (String(xml.@valueType) == "String");
			cs.valueType = String(xml.@valueType);
			
			cs.width = (int)(xml.@width);
			
			if (xml.@export != undefined) 
				cs.export = xml.@export;
			else
				cs.export = "selectedInstanceUID=uid";
			
				
			var rootCondition: String = String(xml.@condition) ? String(xml.@condition) : null;
				
			for each (var subXml : XML in list)
			{
				ASSERT( subXml.name() == "item" , "unknown item!" + subXml.name());
				if (subXml.name() == "item")
				{
					if (valueTypeIsString)
					{
						cs.addItemStringCondition( String(subXml.attribute("class")) , String(subXml.@text) , String(subXml.@condition) ? String(subXml.@condition) : rootCondition);
					}
					else
					{
						ASSERT(false , "not support yet " + xml.@className);
					}
				}
			}
		}
		
		static public function dealSelector(xml : XML )
		: void 
		{
			var cs : ClassSelector = new ClassSelector(xml.@className);
			var list : XMLList = xml.elements();
			
			var valueTypeIsInt : Boolean = (String(xml.@valueType) == "int");
			var valueTypeIsString : Boolean = (String(xml.@valueType) == "String");
			cs.valueType = String(xml.@valueType);
			cs.width = (int)(xml.@width);
			cs.showValue = (((String)(xml.@showValue)) == "true");
			if (xml.@export != undefined) 
				cs.export = xml.@export;
			else if (valueTypeIsInt)
				cs.export = "value=u32";
			else if (valueTypeIsString)
				cs.export = "value=string";
				
			//trace(cs.export);
			
			for each (var subXml : XML in list)
			{
				ASSERT( subXml.name() == "item" , "unknown item!" + subXml.name());
				if (subXml.name() == "item")
				{
					if (valueTypeIsInt)
					{
						cs.addItemInt( int(subXml.@value) ,  String(subXml.@text));
					}
					else if (valueTypeIsString)
					{
						cs.addItemString( String(subXml.@value) ,  String(subXml.@text));
					}
					else
					{
						ASSERT(false , "not support yet " + xml.@className);
					}
				}
			}
		}
		
		static public function dealTextFieldClass(xml : XML )
		: void 
		{

			var ct : ClassTextField = new ClassTextField(xml.@className);

			if (String(xml.@restrict))
			{	
				ct.restrict = xml.@restrict;
			}
			else
			{
				//trace("ct.restrict");
			}
			if (String(xml.@width))	
				ct.width = int(xml.@width);
			if (String(xml.@height))	
			{	
				ct.height = int(xml.@height) ;
			}
			if (String(xml.@defaultText))	
			{	
				ct.defaultText = String(xml.@defaultText) ;
			}
			if (String(xml.@editable))	
			{	
				ct.editable = String(xml.@editable) == "true" ;
			}
			

			if (String(xml.@border))		
			{
				ct.border = !( (String(xml.@border)) == "false");
			}
			if (String(xml.@background))		
				ct.background = !((xml.@background) == "false");
				
			if (String(xml.@border))	
				ct.selectable = !((xml.@selectable) == "false");
				
			if (xml.@export != undefined) 
				ct.export = ""+xml.@export;
			else
				ct.export = "text=string";
		}
		
		static public function dealDynamicClass(xml : XML )
		: void 
		{

			var cd : ClassDynamic = new ClassDynamic(xml.@className);
			var list : XMLList = xml.elements();
			
			for each (var subXml : XML in list)
			{
				ASSERT( subXml.name() == "item" , "unknown item!" + subXml.name());
				if (subXml.name() == "item")
				{
					cd.addContenct(subXml);
				}
			}
		}
		
		
		static public function dealClassCreater(xml : XML )
		: void 
		{
			var cs : ClassClassCreater = new ClassClassCreater(xml.@className);
			var list : XMLList = xml.elements();
			
			//var valueTypeIsString : Boolean = (String(xml.@valueType) == "String");
			cs.width = (int)(xml.@width);
			
			for each (var subXml : XML in list)
			{
				ASSERT( subXml.name() == "item" , "unknown item!" + subXml.name());
				if (subXml.name() == "item")
				{
					//if (valueTypeIsString)
					{
						cs.addClassString( String(subXml.attribute("class")));
					}
				}
				else
				{
					ASSERT(false , "not support yet " + subXml.name());
				}
			}
		}

	}

}