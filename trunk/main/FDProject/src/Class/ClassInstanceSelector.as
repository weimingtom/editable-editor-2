package  Class
{
	import ClassInstance.ClassInstance;
	import ClassInstance.ClassInstanceMgr;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObject;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSDropDownMenu;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassInstanceSelector extends ClassSelector
	{
		protected var conditionArray : Vector.<String> = new Vector.<String> ;
		
		
		
			
		public override function dispose()
		: void 
		{
			if (conditionArray)
			{
				var leng : int = conditionArray.length;
				for (var i : int = 0 ; i < leng ; i++ )
					conditionArray[i] = null;
				conditionArray = null;
			}
			
			
			super.dispose();
			
		}
		
		public function get needDealInstanceChange()
		: Boolean
		{
			for each (var str : String in conditionArray)
			{
				if (str != null)
				{	
					//DBG_TRACE("needDealInstanceChange" , str);
					return true;
				}
			}
			return false;
		}
		
		public function addItemIntCondition(value : int , text : String , condition : String = null ,isUnic : Boolean = true)
		: void 
		{
			
			super.addItemInt(value  , text   , isUnic );
			conditionArray.push(condition);
		}
		
		public function addItemStringCondition(value : String , text : String , condition : String = null , isUnic : Boolean = true)
		: void 
		{
			super.addItemString(value  , text   , isUnic );
			conditionArray.push(condition);
			
			//trace(condition);
		
			
		}
		
		
	/*	public override function formXML(instance : ClassInstance , xml : XML)
		: void 
		{
			if (String(xml.@selectId))
			{
				var selectedId : int =  int(String(xml.@selectId));
				
				ASSERT(instance.referenceObject is BSSDropDownMenuScrollable);
				var _BSSDropDownMenuScrollable : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable(instance.referenceObject);
					
				_BSSDropDownMenuScrollable.selectedId = selectedId ;
				
				ASSERT( String(xml.@text) == _BSSDropDownMenuScrollable.selectedString , "unpair data" );
			}
		}
		
		public override function toXML(instance : ClassInstance)
		: XML
		{
			var xml : XML = 
			< classInstance class= "" name = "" instanceUID=""/>

			xml["@class"] = _className;
			xml.@name = instance.instanceName;
			xml.@instanceUID = instance.instanceUID;
			
			ASSERT(instance.referenceObject is BSSDropDownMenuScrollable);
			var _BSSDropDownMenuScrollable : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable(instance.referenceObject);
				
			var selectedId : int = _BSSDropDownMenuScrollable.selectedId;

			if (selectedId)
			{
				xml.@text = _BSSDropDownMenuScrollable.selectedString;
				xml.@selectId = selectedId;
			}
	
			return xml;
		}
		

		
		private function onNewClassCreate(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void 
		{
			ASSERT(evtId == CALLBACK.ON_NEW_INSTANCE_CREATE , "error id");
			var ClassInstanceSelectorInstance : ClassInstance = ClassInstance(obj);
			var cls : ClassInstance = (ClassInstance)(args[0]);
			
			ASSERT((ClassInstanceSelectorInstance.classType == this ), "error");
			
			if (isFit(ClassInstanceSelectorInstance , cls))
			{
				
				ASSERT (ClassInstanceSelectorInstance.referenceObject is  BSSDropDownMenuScrollable , "error type");
				{	
					(BSSDropDownMenuScrollable(ClassInstanceSelectorInstance.referenceObject)).addItem(cls.instanceName);
				}
			}
		}
		

		private function onNewClassChange(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void 
		{
			ASSERT(evtId == CALLBACK.ON_SELECTOR_CHANGE || evtId == CALLBACK.ON_INSTANCE_DELETE, "error id");
			var ClassInstanceSelectorInstance : ClassInstance = ClassInstance(obj);
			var cls : ClassInstance = (ClassInstance)(args[0]);
			
			ASSERT((ClassInstanceSelectorInstance.classType == this ), "error");
			
			var fit : Boolean = false;
			var clsAll : ClassInstance = cls;
			var dsp:DisplayObject = cls.parent;
			
			if (evtId == CALLBACK.ON_INSTANCE_DELETE)
				fit = true;
			else
			while (clsAll)
			{
				
				//trace("isFitClass" , "ClassInstanceSelectorInstance", ClassInstanceSelectorInstance.classType , "clsAll",clsAll.className, clsAll.classType  );
				fit = isFitClass(ClassInstanceSelectorInstance , clsAll);
				if (fit)
				{
					break;
				}
				
				clsAll = null;
				while (dsp)
				{
					if (dsp is ClassInstance)
					{
						clsAll = ClassInstance(dsp);
						dsp = clsAll.parent;
						break;
					}
					else
					{
						dsp = dsp.parent;
					}
				}
			}
			
			//trace(fit);
			
			if (fit)
			{
				ASSERT (ClassInstanceSelectorInstance.referenceObject is  BSSDropDownMenuScrollable , "error type");
				var _BSSDropDownMenuScrollable : BSSDropDownMenuScrollable = (BSSDropDownMenuScrollable(ClassInstanceSelectorInstance.referenceObject));
				
				_BSSDropDownMenuScrollable.clearAllItem();
				
				for each ( cls in ClassInstanceMgr.s_classInsList)
				{
					//trace(cls , cls.className);
					if (isFit(ClassInstanceSelectorInstance,cls))
						_BSSDropDownMenuScrollable.addItem( cls.instanceName);
				}
				if (evtId == CALLBACK.ON_INSTANCE_DELETE)
					_BSSDropDownMenuScrollable.selectedId = 0;
			}
			

		}
		
		
		public override function init(ci : ClassInstance , xml : XML)
		: void {
			//trace ("ClassInstanceSelector init" + String(xml.@name));
			ci.referenceObject = ci.getChildAt(0);
			ASSERT(ci.referenceObject is BSSDropDownMenuScrollable);
				
			if (xml && String(xml.@name))
			{	
				BSSDropDownMenuScrollable(ci.referenceObject).text =  xml.@name;			
			}
			
			if (xml && String(xml.@text))
			{	
				ASSERT(ci.referenceObject is BSSDropDownMenuScrollable);
				BSSDropDownMenuScrollable(ci.referenceObject).text =  xml.@text;			
			}
			
			if (xml && String(xml.@default))
			{
				ASSERT(ci.referenceObject is BSSDropDownMenuScrollable);
				BSSDropDownMenuScrollable(ci.referenceObject).selectedId =  (int)(String(xml.@default));	
			}
			

			//ClassInstanceMgr.addInstaceSelector(ci);
			ci.disposeFunc = disposeReg;
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_NEW_INSTANCE_CREATE , onNewClassCreate , ci);
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_INSTANCE_DELETE , onNewClassChange , ci);
			
			if (ci.classType is ClassInstanceSelector && ClassInstanceSelector(ci.classType).needDealInstanceChange)
				CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_SELECTOR_CHANGE , onNewClassChange , ci);
			
		}
		
		private function disposeReg(ci : ClassInstance)
		: void {
			CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_NEW_INSTANCE_CREATE , onNewClassCreate , ci);
			CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_INSTANCE_DELETE , onNewClassChange , ci);
			
			if (ci.classType is ClassInstanceSelector && ClassInstanceSelector(ci.classType).needDealInstanceChange)
				CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_SELECTOR_CHANGE , onNewClassChange , ci);
		}
		
		*/	
		
		protected function isFitCondition( cond : String , classInstanceSelectorInstance : ClassInstance  , cls : ClassInstance)
		: Boolean
		{
			if (!cond || !classInstanceSelectorInstance)
				return true;
				
			//trace(cond);
			//trace(cls.instanceName);
		
			var arrMain  : Array = cond.split(" ");
			//trace(arrMain);
			
			ASSERT(arrMain.length == 3 , "not support yet");
			
			var leftStr : String = String(arrMain[0]);
			var rightStr : String = String(arrMain[2]);
			
			var arrSub  : Array = leftStr.split(".");
			
			var clsFind : ClassInstance = cls;
			for (var d : int = 0 ; d < arrSub.length - 1 ; d++ )
			{
				clsFind = (clsFind.getChildClassInstance(arrSub[d]));
			}
			//trace(clsFind);
			var strLeftValue : String;
			var strRightValue : String;
			
			var field : String;
			field = arrSub[arrSub.length - 1];
			if (field == "value")
			{
				if (!clsFind)
					return false;
				strLeftValue = clsFind.getChildClassInstanceValue();
				//trace("strLeftValue " + strLeftValue);
			}
			else if (field == "selectedInstanceUID")
			{
				if (!clsFind)
					return false;
				strLeftValue = ""+clsFind.getChildClassSelectedInstanceUID();
				//trace("strLeftValue " + strLeftValue);
			}
			else if (field == "instanceUID")
			{
				if (!clsFind)
					return false;
				strLeftValue = ""+clsFind.getChildClassInstanceUID();
				//trace("strLeftValue " + strLeftValue);
			}
			else if (field == "className")
			{
				if (!clsFind)
					strLeftValue = "";
				else
					strLeftValue = "" + clsFind.className;
				//trace("strLeftValue " + strLeftValue);
			}
			else if (field.charAt(0) == "\'" || field.charAt(0) == "\"")
			{
				ASSERT(field.charAt(0) == field.charAt(field.length-1) , "not support yet " + field);
				strLeftValue = field.substr(1 , field.length - 2);
			}
			else
			{
				ASSERT(false , "not support yet " + arrSub[arrSub.length - 1]);
			}
			
			///////////////
			//trace(className);
			arrSub = rightStr.split(".");
			clsFind = classInstanceSelectorInstance;
			for ( d = 0 ; d < arrSub.length - 1 ; d++ )
			{
				
				clsFind = (clsFind.getChildClassInstance(arrSub[d]));
			}
			
			
			field = arrSub[arrSub.length - 1];
			if (field == "value")
			{
				if (!clsFind)
					return false;
				strRightValue = ""+clsFind.getChildClassInstanceValue();
				//trace("strRightValue " + strRightValue);
			}
			else if (field == "instanceUID")
			{
				if (!clsFind)
					return false;
				strRightValue = ""+clsFind.getChildClassInstanceUID();
				//trace("strRightValue " + strRightValue);
			}
			else if (field == "className")
			{
				if (!clsFind)
					strRightValue = "";
				else
					strRightValue = "" + clsFind.className;
				//trace("strLeftValue " + strLeftValue);
			}
			else if (field.charAt(0) == "\'" || field.charAt(0) == "\"")
			{
				ASSERT(field.charAt(0) == field.charAt(field.length-1) , "not support yet " + field);
				strRightValue = field.substr(1 , field.length - 2);
			}
			else
			{
				ASSERT(false , "not support yet " + arrSub[arrSub.length - 1]);
			}
			
			if (arrMain[1] == "==")
				return (strRightValue == strLeftValue);
			else if (arrMain[1] == "!=")
				return (strRightValue != strLeftValue);
			else
				ASSERT(false , "not support yet " + arrMain[1]);
			
			
			return false;
		}
		
		protected function isFitClass(ClassInstanceSelectorInstance : ClassInstance , cls : ClassInstance)
		: Boolean
		{
			for each (var className : String in textArray)
			{	
				if (className == cls.className)
				{
					return true;
				}
			}
			return false;
		}
		
		protected function isFit(ClassInstanceSelectorInstance : ClassInstance , cls : ClassInstance)
		: Boolean
		{
			var i : int = 0;
			for each (var className : String in textArray)
			{	
				if (className == cls.className)
				{
					if (conditionArray[i])
					{
						return isFitCondition(conditionArray[i] , ClassInstanceSelectorInstance,  cls);
					}
					else
						return true;
				}
				i++;
			}
			return false;
		}
		
		
		
		
	/*	public override function createDsp ()
		: DisplayObject
		{
			var bddms : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable.createSimpleBSSDropDownMenuScrollable (width , 18 , className, false);
			bddms.setMaxHeight(300);
			bddms.selectFunction = onChangeSelector;
			
		
			for each (var cls : ClassInstance in ClassInstanceMgr.s_classInsList)
			{
				//trace(cls , cls.className);
				if (isFit(null,cls))
					bddms.addItem( cls.instanceName);
			}
			

			return bddms;

		}
		
	*/
		
		public function ClassInstanceSelector(n : String) 
		{
			super(n);
		}
		
		
		
		
		/////////////////////////////EDIT START/////////////////////
		
		public var editable : Boolean = false;
		
		public override function formXML(instance : ClassInstance , xml : XML)
		: void 
		{
			ASSERT(instance.referenceObject is ClassInstanceSelectorMenu);
				var _ClassInstanceSelectorMenu : ClassInstanceSelectorMenu = ClassInstanceSelectorMenu(instance.referenceObject);
			
			if (String(xml.@selectedInstanceUID))
			{
				_ClassInstanceSelectorMenu.selectedInstanceUID = uint(String(xml.@selectedInstanceUID));
				if (String(xml.@text))
					ASSERT( String(xml.@text) == _ClassInstanceSelectorMenu.selectedString , "unpair data" );
				if (String(xml.@selectId))
					ASSERT( uint(String(xml.@selectId)) == _ClassInstanceSelectorMenu.selectedId , "unpair data" );
				
			}	
			else if (String(xml.@selectId))
			{
				var selectedId : int =  int(String(xml.@selectId));
				
					
				_ClassInstanceSelectorMenu.selectedId = selectedId ;
				
				if (String(xml.@selectedInstanceUID))
					ASSERT( uint(String(xml.@selectedInstanceUID)) == _ClassInstanceSelectorMenu.selectedInstanceUID , "unpair data" );
				if (String(xml.@text))
					ASSERT( String(xml.@text) == _ClassInstanceSelectorMenu.selectedString , "unpair data" );
			}
		}
		

		
		public override function toXML(instance : ClassInstance)
		: XML
		{
			
			var xml : XML = 
			< classInstance class= "" name = "" instanceUID=""/>

			xml["@class"] = _className;
			xml.@name = instance.instanceName;
			xml.@instanceUID = instance.instanceUID;
			
			ASSERT(instance.referenceObject is ClassInstanceSelectorMenu);
			var _ClassInstanceSelectorMenu : ClassInstanceSelectorMenu = ClassInstanceSelectorMenu(instance.referenceObject);
				
			var selectedId : int = _ClassInstanceSelectorMenu.selectedId;

			if (selectedId)
			{
				//xml.@value = valueArray[selectedId - 1];
				//trace( _ClassInstanceSelectorMenu.selectedString , textArray[selectedId - 1])
				//ASSERT( _ClassInstanceSelectorMenu.selectedString == textArray[selectedId - 1])
				xml.@selectedInstanceUID = _ClassInstanceSelectorMenu.selectedInstanceUID;
				xml.@text = _ClassInstanceSelectorMenu.selectedString;
				xml.@selectId= selectedId;
			}
	
			
			return xml;
		}
		
		private function onClearAll(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void 
		{
			var ClassInstanceSelectorInstance : ClassInstance = ClassInstance(obj);
			ASSERT(evtId == CALLBACK.ON_INSTANCE_CLEARALL, "error id");
			
			{
				ASSERT (ClassInstanceSelectorInstance.referenceObject is  ClassInstanceSelectorMenu , "error type");
				var _ClassInstanceSelectorMenu : ClassInstanceSelectorMenu = (ClassInstanceSelectorMenu(ClassInstanceSelectorInstance.referenceObject));
				if (_ClassInstanceSelectorMenu.selectedClassInstance && !_ClassInstanceSelectorMenu.selectedClassInstance.isResident)
					_ClassInstanceSelectorMenu.selectedId = 0;
				_ClassInstanceSelectorMenu.clearUnResidentClassInstance();
				
				
			}
			
			if (!ClassInstanceSelectorInstance.isResident && ClassInstanceSelectorInstance.disposeFunc == disposeRegEdit)
			{
				ClassInstanceSelectorInstance.disposeFunc(ClassInstanceSelectorInstance);
			}
			
			
		}
		private function onNewClassChangeEdit(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void 
		{
			//trace("onNewClassChangeEdit");
			var ClassInstanceSelectorInstance : ClassInstance = ClassInstance(obj);
			ASSERT(evtId == CALLBACK.ON_SELECTOR_CHANGE || evtId == CALLBACK.ON_INSTANCE_DELETE , "error id");
			
			var in_cls : ClassInstance = (ClassInstance)(args[0]);
			ASSERT((ClassInstanceSelectorInstance.classType == this ), "error");
			
			ASSERT (ClassInstanceSelectorInstance.referenceObject is  ClassInstanceSelectorMenu , "error type");
			var _ClassInstanceSelectorMenu : ClassInstanceSelectorMenu = (ClassInstanceSelectorMenu(ClassInstanceSelectorInstance.referenceObject));
				
			
			var fit : Boolean = false;
			var clsAll : ClassInstance = in_cls;
			var dsp:DisplayObject = in_cls.parent;
			
			if (evtId == CALLBACK.ON_INSTANCE_DELETE)
			{	
				if (_ClassInstanceSelectorMenu.getUnResidentgetClassInstanceNum() == 0)
				{
					_ClassInstanceSelectorMenu.selectedId = 0;
					return;
				}
				fit = true;
			}
			else
			while (clsAll)
			{
				
				//trace("isFitClass" , "ClassInstanceSelectorInstance", ClassInstanceSelectorInstance.classType , "clsAll",clsAll.className, clsAll.classType  );
				fit = isFitClass(ClassInstanceSelectorInstance , clsAll);
				if (fit)
				{
					break;
				}
				
				clsAll = null;
				while (dsp)
				{
					if (dsp is ClassInstance)
					{
						clsAll = ClassInstance(dsp);
						dsp = clsAll.parent;
						break;
					}
					else
					{
						dsp = dsp.parent;
					}
				}
			}
			
			//trace(fit);
			
			if (fit)
			{
				var selectedInstanceBak : ClassInstance = _ClassInstanceSelectorMenu.selectedClassInstance;
				_ClassInstanceSelectorMenu.clearClassInstance();
				
				for each (var cls : ClassInstance in ClassInstanceMgr.s_classInsList)
				{
					//trace(cls , cls.className);
					if (isFit(ClassInstanceSelectorInstance , cls))
						_ClassInstanceSelectorMenu.addClassInstance( cls);
				}
				
				//if (evtId == CALLBACK.ON_SELECTOR_CHANGE) 
				_ClassInstanceSelectorMenu.checkSelectedInstance(selectedInstanceBak);
				selectedInstanceBak = null;
				//if (evtId == CALLBACK.ON_INSTANCE_DELETE)
				//	_ClassInstanceSelectorMenu.selectedId = 0;
			}
			
			
		}

		public function onNewClassCreateEdit(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void 
		{
			var ClassInstanceSelectorInstance : ClassInstance = ClassInstance(obj);
			ASSERT(evtId == CALLBACK.ON_NEW_INSTANCE_CREATE , "error id");
			var cls : ClassInstance = (ClassInstance)(args[0]);
			ASSERT((ClassInstanceSelectorInstance.classType == this ), "error");
			
			if (isFit(ClassInstanceSelectorInstance , cls))
			{
				ASSERT (ClassInstanceSelectorInstance.referenceObject is  ClassInstanceSelectorMenu , "error type");
				{
					(ClassInstanceSelectorMenu(ClassInstanceSelectorInstance.referenceObject)).addClassInstance(cls);
				}	
			}

		}
		
		public override function init(ci : ClassInstance , xml : XML)
		: void {
			//trace ("ClassInstanceSelector init" + String(xml.@name));
			
			//trace(xml.@name);
			
			ci.referenceObject = ci.getChildAt(0);
			if (xml && String(xml.@name))
			{	
				
				ASSERT(ci.referenceObject is ClassInstanceSelectorMenu);
				ClassInstanceSelectorMenu(ci.referenceObject).text =  xml.@name;
			}
			
			if (xml && String(xml.@text))
			{	
				ASSERT(ci.referenceObject is ClassInstanceSelectorMenu);
				ClassInstanceSelectorMenu(ci.referenceObject).text =  xml.@text;
			}
			
			if (xml && String(xml.@default))
			{
				ASSERT(ci.referenceObject is ClassInstanceSelectorMenu);
				ClassInstanceSelectorMenu(ci.referenceObject).selectedId =  (int)(String(xml.@default));	
			}
			
			if (String(xml.@active))
			{
				if ((String(xml.@active)) == "true")
				{
					ClassInstanceSelectorMenu(ci.referenceObject).activate();
				}
				else
				{
					ClassInstanceSelectorMenu(ci.referenceObject).deactivate();
				}
				
			}
			
			if (String(xml.@editable))
			{
				if ((String(xml.@editable)) == "true")
				{
					ClassInstanceSelectorMenu(ci.referenceObject).editable = true;
				}
				else
				{
					ClassInstanceSelectorMenu(ci.referenceObject).editable = false;
				}
				
			}
			
	
			//ClassInstanceMgr.addInstaceSelector(ci);
			ci.disposeFunc = disposeRegEdit;
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_NEW_INSTANCE_CREATE , onNewClassCreateEdit , ci);
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_INSTANCE_DELETE , onNewClassChangeEdit , ci);
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_INSTANCE_CLEARALL , onClearAll , ci);
			
			if (ci.classType is ClassSelector && ClassInstanceSelector(ci.classType).needDealInstanceChange)
				CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_SELECTOR_CHANGE , onNewClassChangeEdit , ci);
		}
		
		private function disposeRegEdit(ci : ClassInstance)
		: void {
			
			if (ci.disposeFunc == disposeRegEdit)
			{
				CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_NEW_INSTANCE_CREATE , onNewClassCreateEdit , ci);
				CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_INSTANCE_DELETE , onNewClassChangeEdit , ci);
				CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_INSTANCE_CLEARALL , onClearAll , ci);
			
				if (ci.classType is ClassSelector && ClassInstanceSelector(ci.classType).needDealInstanceChange)
					CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_SELECTOR_CHANGE , onNewClassChangeEdit , ci);
				ci.disposeFunc = null;
			}
			
		}
		
		
		
		protected static function onChangeSelectorEdit(bddms : BSSDropDownMenu)
		: void 
		{
			var dsp : DisplayObject = bddms;
			while (dsp)
			{
				if (dsp is ClassInstance)
					break;
				dsp = dsp.parent;
			}
			
			//trace(ClassInstance(dsp).classType);
			
			
			
			
			ASSERT(bddms.parent is ClassInstanceSelectorMenu);
			
			var sp : ClassInstanceSelectorMenu = (ClassInstanceSelectorMenu)(bddms.parent );
			
			CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_SELECTOR_CHANGE , [dsp , bddms , sp] );
			
			if (sp.isEditing)
			{
				sp.closeEditing();
				sp.onEditing();
			}
		}
		
		public override function createDsp ()
		: DisplayObject
		{
			var bddms : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable.createSimpleBSSDropDownMenuScrollable (width , 20 , className, false);
			bddms.setMaxHeight(300);
			bddms.selectFunction = onChangeSelectorEdit;

			var sp : ClassInstanceSelectorMenu = new ClassInstanceSelectorMenu();
			sp.setMenu(bddms);
			
			for each (var cls : ClassInstance in ClassInstanceMgr.s_classInsList)
			{
				//trace(cls , cls.className);
				if (isFit(null , cls))
					sp.addClassInstance( cls);
			}
			
			if (editable)
			{
				var btn : BSSButton = BSSButton.createSimpleBSSButton(20, 18, StringPool.EDIT, true);
				btn.x = width + 5;
				sp.setEditBtn(btn);
				
				var btn2 : BSSButton = BSSButton.createSimpleBSSButton(20, 18, StringPool.DEL , true);
				btn2.x = btn.x + btn.width + 5;
				//btn3.visible = false;
				sp.setDelBtn(btn2);
				
				var btn3 : BSSButton = BSSButton.createSimpleBSSButton(20, 18, StringPool.FOLD , true);
				btn3.x = btn2.x + btn2.width + 5;
				btn3.visible = false;
				sp.setFoldBtn(btn3);
			}
			
			
			return sp;

		}
		
	}

}