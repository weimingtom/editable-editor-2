package Class 
{
	import Alert.AlertPanel;
	import ClassInstance.ClassInstance;
	import ClassInstance.ClassInstanceMgr;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.ConvolutionFilter;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassInstanceSelectorMenu extends SpriteWH
	{
		private var bddm : BSSDropDownMenuScrollable;
		private var editBtn : BSSButton;
		private var flodBtn : BSSButton;
		private var delBtn:BSSButton;
		private var editingClassInstance : ClassInstance;
		private var instanceList : Vector.<ClassInstance> = new Vector.<ClassInstance>();
		private var residentNum : int = 0;
		
		public function set editable(b : Boolean)
		: void
		{
			if (!b)
				editBtn.visible = false;
		}
		
		public function get isEditing()
		: Boolean {
			return editingClassInstance != null;
		}
		
		public override function dispose()
		: void 
		{
			if (bddm) bddm.dispose(); bddm = null;
			if (editBtn) editBtn.dispose(); editBtn = null;
			if (flodBtn) flodBtn.dispose(); flodBtn = null;
			if (delBtn) delBtn.dispose(); delBtn = null;
			
			editingClassInstance = null;
			
			if (instanceList)
			{
				var leng : int = instanceList.length;
				for (var i : int = 0 ; i < leng ; i++ )
					instanceList[i] = null;
				instanceList = null;
			}
			
			
			
			
			super.dispose();
			
		}
		
		
		public function set selectedId (destSelectedId: int)
		: void {
			bddm.selectedId  = destSelectedId;
		}
		
		public function get selectedId ()
		: int {
			return bddm.selectedId ;
		}
		
		public function activate ()
		: void {
			bddm.activate() ;
		}
		public function deactivate ()
		: void {
			bddm.deactivate () ;
		}
		
		public function get selectedInstanceUID ()
		: uint {
			return  selectedClassInstance.instanceUID;
		}
		
		public function set selectedInstanceUID ( uid : uint)
		: void {
			
			for each (var instance:  ClassInstance in instanceList)
			{
				if (instance.instanceUID == uid)
				{
					selectedClassInstance = instance;
					return;
				}
			}
			
			ASSERT(false , "can't find uid " + uid);
		}
		
		public function get selectedString ()
		: String {
			return bddm.selectedString ;
		}
		
		
		public function setEditBtn(_editBtn : BSSButton)
		: void
		{
			addChild(_editBtn);
			editBtn = _editBtn;
			editBtn.releaseFunction = onEditInstance;
		}
		
		public function setFoldBtn(_flodBtn : BSSButton)
		: void
		{
			addChild(_flodBtn);
			flodBtn = _flodBtn;
			
			flodBtn.releaseFunction = onFoldInstance;
			flodBtn.visible = false;
		}
		
		public function setDelBtn(_delBtn:BSSButton):void
		{
			addChild(_delBtn);
			delBtn = _delBtn;
			
			_delBtn.releaseFunction = onDelInstance;
			//_delBtn.visible = false;
		}
		
		public function setMenu(_bddm : BSSDropDownMenuScrollable)
		: void
		{
			bddm = _bddm;
			addChild(bddm);
		}
		
		internal function getClassInstanceNum()
		: int 
		{
			
			return instanceList.length;
		}
		
		internal function getUnResidentgetClassInstanceNum()
		: int 
		{
			
			return instanceList.length - residentNum;
		}
		
		internal function clearUnResidentClassInstance()
		: void {
			var leng : int = instanceList.length;
			var instanceListTemp : Vector.<ClassInstance> = new Vector.<ClassInstance>();
			for (var i : int = 0 ; i < leng ; i++ )
			{
				if (instanceList[i].isResident)
					instanceListTemp.push(instanceList[i]);
				instanceList[i] = null;
			}
			residentNum = 0;
			instanceList.length = 0;
			bddm.clearAllItem();
			
			
			for each (var ci : ClassInstance in instanceListTemp )
			{
				addClassInstance( ci);
			}
			instanceListTemp = null;
		}
		
		internal function clearClassInstance()
		: void {
			var leng : int = instanceList.length;
			for (var i : int = 0 ; i < leng ; i++ )
			{
				instanceList[i] = null;
			}
			residentNum = 0;
			instanceList.length = 0;
			bddm.clearAllItem();
		}
		internal function checkSelectedInstance(c : ClassInstance)
		: void
		{
			if (instanceList.indexOf(c) == -1)
			{
				selectedId = 0;
			}
			else
				selectedClassInstance = c;
		}
		internal function addClassInstance(c : ClassInstance)
		: void {
			//trace("********************addClassInstance At " + instanceList.length + "  " + c.instanceName);
			ASSERT(instanceList.indexOf(c) == -1 , "error on add");
			instanceList.push(c);
			bddm.addItem(c.instanceName);
			
			if (c.isResident)
				residentNum++;
		}
		
		public function set text (str : String)
		: void 
		{
			bddm.text = str;
		}
		
		public function set selectedClassInstance(ins : ClassInstance)
		: void
		{
			var selectedId : int = instanceList.indexOf(ins) + 1;
			ASSERT(selectedId > 0 , "error ins");
			
			if (selectedId)
			{
				bddm.selectedId = selectedId;
			}
		}
		
		public function get selectedClassInstance()
		: ClassInstance
		{
			if (bddm.selectedId == 0)
				return null;
			else
			{
				//trace(bddm.selectedId);
				//trace(instanceList.length);
				var ci : ClassInstance = instanceList[bddm.selectedId - 1];
				
				ASSERT(ci.instanceName == bddm.selectedString , "un pair data instanceName " + ci.instanceName + " selectedString " + bddm.selectedString);
				return ci;
				
			}
		}
		
		/////////////////////////
		public function closeEditing()
		: void	{
			onFoldInstance(flodBtn);
		}
		
		public function onEditing()
		: void	{
			editBtn.releaseFunction(editBtn);
		}
		
		private static function onFoldInstance(btn : BSSButton)
		: void
		{
			ASSERT(btn.parent && btn.parent is ClassInstanceSelectorMenu && BSSDropDownMenuScrollable , "error");
			
			var classInstanceSelectorMenu : ClassInstanceSelectorMenu = 
			ClassInstanceSelectorMenu(btn.parent);
			
			if (classInstanceSelectorMenu.editingClassInstance && classInstanceSelectorMenu.editingClassInstance.parent)
			{
				ASSERT(classInstanceSelectorMenu.editingClassInstance.editingClassInstanceSelectorMenu == classInstanceSelectorMenu);
				classInstanceSelectorMenu.editingClassInstance.editingClassInstanceSelectorMenu = null;
				if (classInstanceSelectorMenu.parent.parent &&classInstanceSelectorMenu.parent.parent is SpriteWH)
				{	
					((SpriteWH)(classInstanceSelectorMenu.parent.parent)).childWillChangeWH(classInstanceSelectorMenu.parent);
				}	
				classInstanceSelectorMenu.editingClassInstance.parent.removeChild(classInstanceSelectorMenu.editingClassInstance);
				classInstanceSelectorMenu.editingClassInstance = null;
				
				if (classInstanceSelectorMenu.parent.parent && classInstanceSelectorMenu.parent.parent is SpriteWH)
					((SpriteWH)(classInstanceSelectorMenu.parent.parent)).childEndChangeWH(classInstanceSelectorMenu.parent);
			}
			
			btn.visible = false;
		}
		
		private static function onDelInstance(btn:BSSButton):void
		{
			if (AlertPanel.getSingleton().getPanel().visible) 
				return;
			
			ASSERT(btn.parent is ClassInstanceSelectorMenu && BSSDropDownMenuScrollable , "error");
			
			var classInstanceSelectorMenu : ClassInstanceSelectorMenu = 
			ClassInstanceSelectorMenu(btn.parent);
			
			var ci : ClassInstance = ClassInstance(classInstanceSelectorMenu.parent);
			
			ASSERT(ci.referenceObject == classInstanceSelectorMenu , "error parent");
			
			
			var  selectedClassInstance : ClassInstance = classInstanceSelectorMenu.selectedClassInstance;
			
			ClassInstanceMgr.tryDeleteClassInstance(selectedClassInstance , ci);
			
			
			
			//selectedClassInstance.dispose();
			ci = null;
			classInstanceSelectorMenu = null;
			selectedClassInstance = null;
		}
		
		private static function onEditInstance(btn : BSSButton)
		: void
		{
			if (AlertPanel.getSingleton().getPanel().visible) return;
			
			
			ASSERT(btn.parent is ClassInstanceSelectorMenu && BSSDropDownMenuScrollable , "error");
			
			var classInstanceSelectorMenu : ClassInstanceSelectorMenu = 
			ClassInstanceSelectorMenu(btn.parent);
			
			var  selectedClassInstance : ClassInstance = classInstanceSelectorMenu.selectedClassInstance;
			
			
			//trace(classInstanceSelectorMenu.selectedClassInstance , classInstanceSelectorMenu.selectedClassInstance.instanceName , classInstanceSelectorMenu.selectedClassInstance.className);
			if (selectedClassInstance)
			{
				//trace
				var dsp : DisplayObject = classInstanceSelectorMenu;
				while (dsp)
				{
					if (dsp == selectedClassInstance)
					{
						DBG_TRACE("edit self");
						return;
					}	
					dsp = dsp.parent;
				}
				
				onFoldInstance(classInstanceSelectorMenu.flodBtn);
				
				//trace(selectedClassInstance.parent ,selectedClassInstance.editingClassInstanceSelectorMenu );
				if (selectedClassInstance.parent)
				{
					ASSERT(selectedClassInstance.editingClassInstanceSelectorMenu.parent == selectedClassInstance.parent);
					onFoldInstance(selectedClassInstance.editingClassInstanceSelectorMenu.flodBtn);	
				}
				
				classInstanceSelectorMenu.editingClassInstance = selectedClassInstance;
				selectedClassInstance.editingClassInstanceSelectorMenu = classInstanceSelectorMenu;
				
				selectedClassInstance.y = classInstanceSelectorMenu.y + classInstanceSelectorMenu.height + 5;
				selectedClassInstance.x = 20;
				classInstanceSelectorMenu.flodBtn.visible = true;
				
				if (classInstanceSelectorMenu.parent)
				{
					if (classInstanceSelectorMenu.parent.parent &&classInstanceSelectorMenu.parent.parent is SpriteWH)
						((SpriteWH)(classInstanceSelectorMenu.parent.parent)).childWillChangeWH(classInstanceSelectorMenu.parent);
					
					
					classInstanceSelectorMenu.parent.addChild(selectedClassInstance);
					
					if (classInstanceSelectorMenu.parent.parent && classInstanceSelectorMenu.parent.parent is SpriteWH)
						((SpriteWH)(classInstanceSelectorMenu.parent.parent)).childEndChangeWH(classInstanceSelectorMenu.parent);
					
				}
			}
		}
		
		
		
	}

}