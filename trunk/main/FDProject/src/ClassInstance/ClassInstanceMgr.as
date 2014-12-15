package  ClassInstance
{
	import Class.ClassBase;
	import Class.ClassDynamic;
	import Class.ClassInstanceSelector;
	import Class.ClassSelector;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	//import Class.ClassInstanceSelectorEdit;
	import Class.ClassInstanceSelectorMenu;
	import Class.ClassMgr;
	import Debugger.DBG_TRACE;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassInstanceMgr
	{
		
		public static var s_classInsList : Vector.<ClassInstance> = new Vector.<ClassInstance>();
		//internal static var s_classSelectorInsList : Vector.<ClassInstance> = new Vector.<ClassInstance>();
		
		
		
	/*	public static function addInstaceSelector(cis :ClassInstance)
		: void
		{
			ASSERT(cis.classType is ClassInstanceSelector , "error class type"  );
			s_classSelectorInsList.push(cis);
		}
	*/	
		public static function readClassInstance(xml: XML)
		: void
		{
			Logger.s_isOpening = true;
			Logger.s_openStartTime = getTimer();
			//trace(xml);
			ASSERT( xml.name() == "EditableEditorFile" , "unknown header!");
			
			if ( xml.name() != "EditableEditorFile")
				return;
			
			DBG_TRACE("File version: " + xml.@version);	
			
			if ( int(xml.@version) != Version.version)
			{
				ASSERT(false , "unpair config version and file version");
			}
			
			
			var list : XMLList = xml.elements();
			
			ClassInstanceLoader.s_loaderArray = new Vector.<ClassInstanceLoader>();
			
			
			
			for each (var subXml : XML in list)
			{
				if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance" )
				{
					
				//	(new ClassInstance(ClassMgr.findClass(String(subXml.attribute("class"))) , String(subXml.@name)))
				//	.isResident = true;

					
						var className : String = subXml.attribute("class");
						var classBase : ClassBase = ClassMgr.findClass(className);
						
						new ClassInstanceLoader(classBase ,  subXml );
						/*
						var ci : ClassInstance = new  ClassInstance( classBase ,  subXml.@name );
						classBase.init(ci , subXml);
						
						if (String(subXml.@instanceUID))
						{	
							ci.instanceUID = uint(String(subXml.@instanceUID));
						}
						*/	
				}
				else
				{
					ASSERT(false , "unknow item " + subXml.name())
				}
			}
			
			/////////////////////////////////////////////////////
			//pass two
			
			/*
			for each ( subXml in list)
			{
				if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance")
				{
					if (subXml.@instanceUID != undefined)
						ci = findInstanceByUid(uint(subXml.@instanceUID) , subXml.attribute("class"));
					else
						ci = findInstanceByName(subXml.@name , subXml.attribute("class"));
					if (ci)
						ci.classType.formXML(ci , subXml);
				}
			}
			*/
			
			ClassInstanceLoader.load();
			
		}
		internal static function findInstanceByUid( insUID : uint ,className : String)
		: ClassInstance
		{
			var ci : ClassInstance;
			for each (ci  in s_classInsList)
			{
				if (ci.instanceUID == insUID && ci.className == className)
				{	
					return ci;
				}
			}
			
			ASSERT(false , "error findInstance");
			return null;
		}
		
		internal static function findInstanceByName(insName : String ,className : String)
		: ClassInstance
		{
			var ci : ClassInstance;
			var ret : ClassInstance;
			for each (ci  in s_classInsList)
			{
				if (ci.instanceName == insName && ci.className == className)
				{	
					ASSERT(ret == null , "实例名重名 " + insName);
					ret = ci;
				}
			}
			
			if (ret != null)
				return ret;
			
			ASSERT(false , "error findInstance");
			return null;
		}
		
		public static function exportInstance()
		: XML
		{
			var ci : ClassInstance;
			
			var stackClassInstanceSelectorMenu : Vector.<ClassInstanceSelectorMenu> = new Vector.<ClassInstanceSelectorMenu>();
			
			for each (ci  in s_classInsList)
			{
	
				if (ci.editingClassInstanceSelectorMenu != null)
				{	
					stackClassInstanceSelectorMenu.push(ci.editingClassInstanceSelectorMenu);
					ci.editingClassInstanceSelectorMenu.closeEditing();
					ASSERT(ci.parent == null , "error");
				}
			}
		
			var dxml : XML = < EditableEditorFile version =""/>;
			
			dxml.@date = new Date();
			dxml.@version = Version.version;
			
			for each ( ci in s_classInsList)
			{
				if ( ci.isRoot && !ci.isResidentChildren 	)
				{	
					var xml : XML = ci.classType.toXML(ci);	
					//trace(xml.toXMLString());
					dxml.appendChild(xml);
				}
			}
			
			for each (var _ClassInstanceSelectorMenu : ClassInstanceSelectorMenu in stackClassInstanceSelectorMenu)
			{
				_ClassInstanceSelectorMenu.onEditing();
			}
			
			//trace(dxml);
			
			return dxml;
		}
		public static function getClassInstanceSelecterList() : Vector.<ClassInstance>
		{
			var ci : ClassInstance;
			var _classInsList : Vector.<ClassInstance> = new Vector.<ClassInstance>();
			
			
			for each ( ci in s_classInsList)
			{
				if (ci.classType is ClassInstanceSelector)
				{
					_classInsList.push(ci);
				}
			}
			
			return _classInsList;
				
		}
		
		public static function exportInstanceBin()
		: ByteArray
		{
			var ba : ByteArray = new ByteArray();
			ClassInstanceBinarize.writeFileHead(ba);
			ClassInstanceBinarize.xmlBinarize(ba , exportInstance());
			
			//ba.position = 0;
			//ClassInstanceBinarize.xmlDebinarize(ba);
			
			return ba ;
		}
		
		public static function tryDeleteClassInstance(selectedClassInstance : ClassInstance , skipTestInstance : ClassInstance):void
		{
			//不为空，且不是常驻项
			if (selectedClassInstance != null && selectedClassInstance.isResident==false)
			{	
				if (selectedClassInstance.editingClassInstanceSelectorMenu != null)
				{
					selectedClassInstance.editingClassInstanceSelectorMenu.closeEditing();
				}
				var usingCIMenu : ClassInstance; 
				var usingCI : ClassInstance;
				
				usingCIMenu = usingCI = 
				ClassInstanceMgr.getUsingClassInstance(selectedClassInstance , skipTestInstance);
				
				if (usingCI) //is using
				{
					
					for (;; )
					{
						if (usingCI.editingClassInstanceSelectorMenu != null)
						{
							usingCI.editingClassInstanceSelectorMenu.closeEditing();
						}
					
						var parentClassInstance : ClassInstance = usingCI.getChildClassInstance("parent");
						if (parentClassInstance)
						{
							usingCI = parentClassInstance;
							
						}
						else
							break;
					}
					
					CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_ALERT_INSTANCE_IS_USING , 
						[
							selectedClassInstance
							, usingCI
							, usingCIMenu
							, skipTestInstance
						]
					);
					
					//AlertPanel.getSingleton().getPanel().visible = true;
					
					usingCI = null;
				}
				else
				{
					selectedClassInstance.dispose();
				}
			}
		}
		
		public static function checkIfUsingClassInstance(beUsedCi : ClassInstance  , usingCi : ClassInstance ):ClassInstance
		{
			if (usingCi.classType is ClassInstanceSelector)
			{
				var cis : ClassInstanceSelector = ClassInstanceSelector(usingCi.classType);
				
				var cism : ClassInstanceSelectorMenu = ClassInstanceSelectorMenu(usingCi.referenceObject);
				
				var selectedClassInstance : ClassInstance = cism.selectedClassInstance;
				
				if(selectedClassInstance == beUsedCi)
				{
					trace(
						cis.className ,
						cism.selectedString
					);
					
					return usingCi;
				}
			}
			
			return null;
		}
		//测试代码
		public static function getUsingClassInstance(beUsedCi : ClassInstance , skipTestInstance : ClassInstance):ClassInstance
		{

			var clsName:String = beUsedCi.className;
			
			for each(var _ci : ClassInstance in s_classInsList)
			{
				if (_ci == skipTestInstance)
				{
					continue;
				}
				
				var usingCi : ClassInstance = checkIfUsingClassInstance(beUsedCi , _ci)
				
				if (usingCi)
					return usingCi;
			}
			
			return null;
		}
		
		
		public static function removeUnResidentClassInstance()
		: void 
		{
			CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_INSTANCE_CLEARALL);
			Logger.s_isNewing = true;
			
			var ci : ClassInstance;
			for each (ci  in s_classInsList)
			{
				if (ci.editingClassInstanceSelectorMenu != null)
				{	
					//trace("ci.close() index :"+ s_classInsList.indexOf(ci)+"  " + ci.instanceName);
					ci.editingClassInstanceSelectorMenu.closeEditing();
					ASSERT(ci.parent == null , "error");
				}
			}
			ci = null;
			var i : int = s_classInsList.length;
			
			
			var _classInsList : Vector.<ClassInstance> = new Vector.<ClassInstance>();
			
			var _poolNum : int;
			for each ( ci in s_classInsList)
			{
				if (!ci.isResidentChildren)
				{
					if (Config.s_usingPool) {
						if (!ci.isPoolInstanceChild)
						{
							_classInsList.push(ci);
						}
						else {
							_poolNum++;
						}
					}
					else
						_classInsList.push(ci);
				}
			}
			
			var _classInsList_length : int = _classInsList.length;
			for (var _ci : int = 0 ; _ci < _classInsList_length; _ci++)
			{
				ci = _classInsList[_ci];
				if (ci)
				{
					if (ci.classType is ClassSelector)
					{
						ci.dispose();
						_classInsList[_ci] = null;
					}
					else
					{
						
					}
				}
			}
			
			if (Config.s_usingPool)
			{
				for (_ci = 0 ; _ci < _classInsList_length; _ci++)
				{
					ci = _classInsList[_ci];
					if (ci)
					{
						if (ci.classType is ClassDynamic)
						{
							ci.dispose();
							_classInsList[_ci] = null;
						}
						else
						{
							
						}
					}
				}
				
			}
			
			
			
			for (_ci = 0 ; _ci < _classInsList_length; _ci++)
			{
				ci = _classInsList[_ci];
				if (ci)
				{
					if (ci.classType is ClassDynamic)
					{
					
					}
					else
					{
						ci.dispose();
						_classInsList[_ci] = null;
					}
				}
			}
			
			for (_ci = 0 ; _ci < _classInsList_length; _ci++)
			{
				ci = _classInsList[_ci];
				if (ci)
				{
					ci.dispose();
					_classInsList[_ci] = null;
				}
			}
			
			_classInsList.length = 0;
			_classInsList = null;
			
			log("dispose class ins " + (i - s_classInsList.length));
			log("cache class ins " + _poolNum);
			log("resident class ins " + (s_classInsList.length - _poolNum));
			
			DBG_TRACE("Dispose class ins " + (i-s_classInsList.length) , "Cached class ins " + _poolNum, "Resident class ins " +( s_classInsList.length - _poolNum));
			
			/*
			
			trace(_classInsListToDel.length , s_classInsList.length);
			for each ( ci in _classInsListToDel)
			{
				trace(i);
				i++;
				ci.dispose();
			}
			trace(_classInsListToDel.length , s_classInsList.length);
			
			_classInsListToDel = null;
			*/
			Logger.s_isNewing = false;
		}
	
		internal static function unregClassInstace(cls : ClassInstance)
		: void 
		{
			//trace("unregClassInstace");
			//ASSERT(s_classInsList.indexOf(cls) != -1 , "error");
			//trace(s_classInsList.indexOf(cls));
			if (s_classInsList.indexOf(cls) != -1)
			{
				s_classInsList.splice(s_classInsList.indexOf(cls) , 1);
			}
			Profiler.setStart();
			if (!Logger.s_isNewing)
				CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_INSTANCE_DELETE , [cls] );	
			Profiler.setEnd(0);
			
			Profiler.traceAll();
		}
	
		internal static function regClassInstace(cls : ClassInstance)
		: void 
		{
			ASSERT(s_classInsList.indexOf(cls) == -1 , "error");
			s_classInsList.push(cls);
			
			//if (cls.isResident || !	Logger.s_isOpening)
				CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_NEW_INSTANCE_CREATE , [cls] );
			
			//for each (var classInstanceSelector : ClassInstance in s_classSelectorInsList)
			//{
			//	ClassInstanceSelector.onNewClassCreate( classInstanceSelector , cls);
			//}
			
		}
	/*	
		internal static function findClassInstace(className : String)
		: ClassBase 
		{
			for each (var  c : ClassBase in classList)
				if (className == c.className)
					return c;
			ASSERT(false , "can't find class " + className);
			return null;
		}
	*/	

	}

}