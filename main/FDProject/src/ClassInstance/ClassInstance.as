package ClassInstance 
{
	import Class.ClassBase;
	import Class.ClassDynamic;
	import Class.ClassInstanceSelector;
	import Class.ClassInstanceSelectorMenu;
	import Class.ClassSelector;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import UISuit.UIComponent.BSSDropDownMenu;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassInstance extends SripteWithRect
	{
		public var classType : ClassBase;
		public var instanceName : String;
		public var referenceObject : Object;
		public var disposeFunc : Function;
		public var editingClassInstanceSelectorMenu : ClassInstanceSelectorMenu;
		public var content : DisplayObject;
		public var isResident : Boolean = false;
		public var instanceUID : uint;
		
		public function get isResidentChildren()
		: Boolean
		{
			if (isResident)
				return true;
			
			var dsp : DisplayObject = parent;
			while (dsp)
			{
				if (dsp is ClassInstance)
				{
					if (ClassInstance(dsp).isResident)
						return true;
				}
				dsp = dsp.parent;
			}
			
			return false;
		}
		
		public override function  dispose()
		: void
		{
			ClassInstanceMgr.unregClassInstace(this);
			if (disposeFunc != null)
				disposeFunc(this);
			disposeFunc = null;
			
			classType = null;
			instanceName = null;
			referenceObject = null;
			instanceUID = 0;
			
			if (editingClassInstanceSelectorMenu )
			{	
				editingClassInstanceSelectorMenu.closeEditing();
				ASSERT(parent == null , "error");
				editingClassInstanceSelectorMenu = null;
			}
			
			content = null;
			super.dispose();
		}
		
		
		public function get className()
		: String
		{
			if (classType)
				return classType.className;
			else
				return null;
		}
		
		public function getChildClassInstanceUID()
		: uint
		{
			return instanceUID;
		}
		
		public function getChildClassSelectedInstanceUID()
		: uint
		{
			
			ASSERT(referenceObject is ClassInstanceSelectorMenu);
			if (ClassInstanceSelectorMenu(referenceObject).selectedId)
				return ClassInstanceSelectorMenu(referenceObject).selectedInstanceUID;
			else
				return 0 ;
			
				
		}
		public function getChildClassInstanceValue()
		: String
		{
			
			if (content is DisplayObjectContainer)
			{
				var contentC : DisplayObjectContainer = (DisplayObjectContainer)(content);
			}
			else
			{
				//trace()
				return null;
			}
			var id :int;
		//	for (var i : int = 0 ; i < contentC.numChildren ; i++)
			{
				var dsp : DisplayObject = contentC.getChildAt(0);
				
				
				ASSERT(dsp is BSSDropDownMenu);
				id = ((BSSDropDownMenu)(dsp)).selectedId;
			}
			
			ASSERT(classType is ClassSelector);
			
			if (id == 0)
				return null;
			else
				return String(ClassSelector(classType).getValue(id-1));
		}
		
		public function getChildClassInstanceText()
		: String
		{
			if (content is DisplayObjectContainer)
			{
				var contentC : DisplayObjectContainer = (DisplayObjectContainer)(content);
			}
			else if (content is TextFieldWithWidth)
			{
				return TextFieldWithWidth(content).text;
			}
			else
			{
				return null;
			}
			
		//	for (var i : int = 0 ; i < contentC.numChildren ; i++)
			{
				var dsp : DisplayObject = contentC.getChildAt(0);
				
				
				ASSERT(dsp is BSSDropDownMenu);
				return ((BSSDropDownMenu)(dsp)).selectedString;
			}
		}
		
		public function setChildClassInstanceText( str : String)
		: void
		{
			if (content is DisplayObjectContainer)
			{
				var contentC : DisplayObjectContainer = (DisplayObjectContainer)(content);
			}
			else if (content is TextFieldWithWidth)
			{
				TextFieldWithWidth(content).text = str;
				return;
			}
			else
			{
				return;
			}
			
		//	for (var i : int = 0 ; i < contentC.numChildren ; i++)
			{
				var dsp : DisplayObject = contentC.getChildAt(0);
				
				
				ASSERT(dsp is BSSDropDownMenu);
				((BSSDropDownMenu)(dsp)).selectedString = str;
			}
		}
		
		public function getChildClassInstance (str : String)
		: ClassInstance
		{
			
			if (str == "parent")
			{
				var dsp:DisplayObject = this.parent;
				
				while (dsp)
				{
					if (dsp is ClassInstance)
					{
						return  ClassInstance(dsp);
					}
					dsp = dsp.parent;
				}

				//ASSERT(false , "error find parent");
				return null;
				
			}
			
			
			if (content is DisplayObjectContainer)
			{
				var contentC : DisplayObjectContainer = (DisplayObjectContainer)(content);
			}
			else
			{
				return null;
			}
			
			//trace("getChildClassInstance " + str);
			//trace("classType " + classType);
			//trace("numChildren " + contentC.numChildren);
			
			for (var i : int = 0 ; i < contentC.numChildren ; i++)
			{
				dsp  = contentC.getChildAt(i);
				
				
				//if (str == "value")
				//{
				//	trace(dsp);
				//}
				//else 
				{	
					//trace(dsp);
					ASSERT(dsp is ClassInstance)
					var classInstance : ClassInstance = ClassInstance(dsp);
					
					//trace(classInstance.instanceName);
					
					if (classInstance.instanceName == str)
						return classInstance;
				
				}
				
			}
			
			
			
			//DBG_TRACE(new Error().getStackTrace() + "\ncan't find " + str + "all child is list as follows:\n");
			
			DBG_TRACE("can't find " + str + "all child is list as follows:\n");
			for ( i  = 0 ; i < contentC.numChildren ; i++)
			{
				dsp  = contentC.getChildAt(i);
				
				DBG_TRACE( i + " " +  ClassInstance(dsp).instanceName);
			}
			
			return null;
		}
		
		public function get isRoot()
		: Boolean
		{
			return (parent == null);
		}
		
		private static var timeOffset : int = 0;
		
		public function ClassInstance( _classType : ClassBase , _instanceName : String) 
		{
			classType = _classType;
			instanceName =  _instanceName;
			
			content = classType.createDsp();
			content.x = 5 ;
			content.y = 5 ;
			addChild(content);
			
			if (_classType is ClassDynamic && content is DisplayObjectContainer)
			{
				var _dspc : DisplayObjectContainer = DisplayObjectContainer(content);
				
				for (var __ci : int = 0 ; __ci < _dspc.numChildren;  __ci++)
				{
					var _child : ClassInstance = _dspc.getChildAt(__ci) as ClassInstance;
					if (_child && _child.classType is ClassDynamic)
					{	
						CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_SELECTOR_CHANGE , [_child] );
					}
				}
			}
			

			
			var date : Date = new Date();
			
			//trace ((date.fullYear - 2010) , date.getMonth() , date.getDate() , date.getHours() , date.getMinutes() , date.getSeconds() , date.getMilliseconds());
			
			var timestamp : uint = ((((((((date.fullYear - 2010) * 12 + date.getMonth()) * 31 +  date.getDate()) * 24) + date.getHours()) * 60) + date.getMinutes() * 60) + date.getSeconds()) * 1000 + date.getMilliseconds();
			timeOffset = (timeOffset + 1);
			
			instanceUID = timestamp * 100 + timeOffset;
			
			ClassInstanceMgr.regClassInstace(this);
		}
		
	}

}