package  Class 
{ 
	import ClassInstance.ClassInstance;
	
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassClassCreater extends ClassBase
	{
		
		internal var classNameList : Vector.<String> = new Vector.<String>();
		
		public function ClassClassCreater (n : String) 
		{
			super(n);
		}
		
		
		public override function dispose()
		: void 
		{
			if (classNameList)
			{
				var leng : int = classNameList.length;
				for (var i : int = 0 ; i < leng ; i++ )
					classNameList[i] = null;
				classNameList = null;
			}
			super.dispose();
			
		}
		
		public override function createDsp ()
		: DisplayObject
		{
			//trace("createDsp");
			var sp : SpriteWH = new SpriteWH();
			
			var textField : TextField = new TextField;
			textField.width = width - 25;
			textField.height = 18;
			textField.border = true;
			textField.background = true;
			textField.type = "input";
			
			sp.addChild(textField);
			
			var btn : BSSButton = BSSButton.createSimpleBSSButton(20, 18, StringPool.ADD , true);
			btn.x = width - 20;
			btn.releaseFunction = onAddClass;
			sp.addChild(btn);
			
			
			var bddms : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable.createSimpleBSSDropDownMenuScrollable (width , 18 , className, false);
			bddms.setMaxHeight(300);
			
			for each (var str : String in classNameList )
			{	
				bddms.addItem(str);
			}
			(bddms).y = 24;	
			sp.addChild(bddms).y ;
			
			
			return sp;
		}
		
		
		public override function init(ci : ClassInstance , xml : XML)
		: void {
			//trace ("ClassInstanceSelector init" + String(xml.@name));
			
			
			ci.referenceObject = (SpriteWH(ci.getChildAt(0))).getChildAt(2);
			
			if (xml && String(xml.@name))
			{	
				
				ASSERT(ci.referenceObject is BSSDropDownMenuScrollable);
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
			
		}
		
		private static function onAddClass(btn : BSSButton )
		: void {
			ASSERT(btn.parent is SpriteWH , "error");
			var _this : SpriteWH = SpriteWH(btn.parent );
			
			var textField : TextField = (TextField)(_this.getChildAt(0));
			
			if (textField.text)
			{
				
				var bddm : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable(btn.parent.getChildAt(2));
				if (bddm.selectedId > 0)
				{
					//trace (
					//	(textField.text),
					//	bddm.selectedString
					//);
					(new ClassInstance(ClassMgr.findClass(bddm.selectedString) , String(textField.text))) ;
				}
			}
			
		}
		
		internal function addClassString(cn :String)
		: void 
		{
			classNameList.push(cn);
		}
		
		
	}

}