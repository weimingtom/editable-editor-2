package  
{
	import Class.ClassBase;
	import Class.ClassInstanceSelector;
	import Class.ClassMgr;
	import ClassInstance.ClassInstance;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import Plug.PlugMgr;
	/**
	 * ...
	 * @author blueshell
	 */
	public class XmlConfig
	{
		
		private var m_isRoot : Boolean;
		private var m_currentXML : XML;
		
		public function XmlConfig(a_isRoot : Boolean)
		{
			m_isRoot = a_isRoot;
		}
		internal function loadXml(url : String)
		: void 
		{
			trace("load config: " + url);
			
			//if (url.indexOf("ProtocolEditor") != -1)
			//	url = url;
			
			var uldr : URLLoader = new URLLoader();
			uldr.addEventListener(Event.COMPLETE,onLoadXmlComp);
			uldr.load(new URLRequest(url));
		}
		
		public var endFunction : Function;
		public var pageFunction : Function;
		internal function onLoadXmlComp(event : Event)
		: void 
		{
			var uldr : URLLoader = URLLoader(event.currentTarget);
			//event.currentTarget
			uldr.removeEventListener(event.type, arguments.callee);
			
			m_currentXML = new XML(uldr.data);
			onXMLLoaded();
			
		}
		
		private function onXMLLoaded():void
		{
			dealXmlConfig(m_currentXML);
			
			if (m_currentXML.Include.length() == 0)
			{
				if (endFunction != null)
				{	
					if (endFunction.length == 0)
						endFunction();
					else if (endFunction.length == 1)
						endFunction(m_currentXML);
				}
				m_currentXML = null;
			}
		}
		
		private function onXMLIncludeLoaded(a_includeExpandXml : XML) : void 
		{
			var includeXML : XML = m_currentXML.Include[0];
			
			var xmlString : String = m_currentXML.toXMLString();
			
			var a_includeExpandXmlString : String = "";
			var list : XMLList = a_includeExpandXml.elements();
			for each (var subXml : XML in list)
			{
				a_includeExpandXmlString += "\n" + subXml.toXMLString() ;
			}
			
			var rawString : String = includeXML.toXMLString();
			xmlString = xmlString.replace( rawString , a_includeExpandXmlString);
			
			m_currentXML = new XML(xmlString);
			
			
			
			onXMLLoaded();
		}
		
		
		
		internal function dealXmlConfig(xml : XML)
		: void 
		{
			
			ASSERT( xml.name() == "EditableEditorHeader" , "unknown header!");
			if ( xml.name() != "EditableEditorHeader")
				return;
					
			if (m_isRoot)
			{
				
			}
			else
			{
				trace("include xml loaded");
				//return;
			}
			
			//trace("xml.Include.length() " + xml.Include.length());
			if (xml.Include.length())
			{
				var includeXML : XML = xml.Include[0];
				
				var _includeXmlConfig : XmlConfig = new XmlConfig(false);
				_includeXmlConfig.endFunction = onXMLIncludeLoaded;
				_includeXmlConfig.loadXml(""+includeXML.@filename);
				
				return;
			}
		
			if (!m_isRoot)
				return;
			
			//trace(xml.toXMLString());
			
			Version.version = int(xml.@version);
			
			DBG_TRACE("Config version: " + Version.version);
				
			//trace(xml.toXMLString());
			
			var list : XMLList = xml.elements();
			for each (var subXml : XML in list)
			{
				if (subXml.name() == "StringPool")
				{
					var attributes : XMLList = subXml.attributes();
					 for each (var obj : XML in attributes)
					 {
						 StringPool[ String(obj.name())] = obj.toString();
						 //trace(obj.name() , obj.toString());
					 }
					//ClassMgr.dealSelector(subXml);
				}
				else if (subXml.name() == "Selector")
				{
					ClassMgr.dealSelector(subXml);
				}
				else if (subXml.name() == "InstanceSelector")
				{
					ClassMgr.dealInstanceSelector(subXml);
				}
				else if (subXml.name() == "TextField")
				{
					ClassMgr.dealTextFieldClass(subXml);
				}
				else if (subXml.name() == "class" || subXml.name() == "Class" )
				{
					ClassMgr.dealDynamicClass(subXml);
				}
				else if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance")
				{
					var _cCB : ClassBase = ClassMgr.findClass(String(subXml.attribute("class")));
					var ci : ClassInstance = new ClassInstance( _cCB, String(subXml.@name));
					_cCB.init(ci , subXml);
					
					ci.isResident = true;
					if (String(subXml.@instanceUID))
						ci.instanceUID = int(String(subXml.@instanceUID));	
						
					ci.classType.formXML(ci , subXml);
				}
				else if (subXml.name() == "ClassCreater")
				{
					ClassMgr.dealClassCreater(subXml);
				}
				else if (subXml.name() == "Page")
				{
					if (pageFunction != null)
						pageFunction(subXml);
				}
				else if (subXml.name() == "Plugin")
				{
					PlugMgr.addPlug(subXml.@data , subXml);
				}
				else
				{
					ASSERT(false , "unknow item " + subXml.name())
				}
			}
			
			if (pageFunction != null)
			{	
				var _xml : XML = new XML( < Page name = "LOG" ></Page>);
				var _page : Page = pageFunction(_xml);
				
				if (EditableEditor2.s_logTF)
				{
					_page.addItem(EditableEditor2.s_logTF);
				}
				
			}
			
		}		///////////////////////////////////////////
		
	}

}