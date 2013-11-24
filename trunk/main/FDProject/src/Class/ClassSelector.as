package  Class
{
	import ClassInstance.ClassInstance;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import UISuit.UIComponent.BSSDropDownMenu;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassSelector extends ClassBase
	{
		
		protected var valueArray : Array = new Array();
		protected var textArray : Vector.<String> = new Vector.<String> ;
		public var showValue : Boolean;
		public var valueType : String;
		
		public override function formXML(instance : ClassInstance , xml : XML)
		: void 
		{
			ASSERT(instance.referenceObject is BSSDropDownMenuScrollable);
				var _BSSDropDownMenuScrollable : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable(instance.referenceObject);
				
			if (String(xml.@selectId) && String(xml.@value))
			{
				var selectedId : int =  int(String(xml.@selectId));
				
				if (String(xml.@value) == String(valueArray[selectedId - 1]))
				{
					_BSSDropDownMenuScrollable.selectedId = selectedId ;
					if (String(xml.@text))
						ASSERT( String(xml.@text) == _BSSDropDownMenuScrollable.selectedString , "unpair data " ,  String(xml.@text) , _BSSDropDownMenuScrollable.selectedString);
				}
				else
				{
					log("unpair data!!! will use 'value' instead of  'selectId'");
					ASSERT(false , "unpair data" ,  String(xml.@value) , String(valueArray[selectedId - 1]));
				}
			}
			
			if (String(xml.@value))
			{
				//trace(xml.@value)
				var valueString : String = String(xml.@value);
				if (valueType == "String")
				{
					selectedId = valueArray.indexOf(valueString) + 1;
					_BSSDropDownMenuScrollable.selectedId = selectedId ;
				}
				else if  (valueType == "int")
				{
					selectedId = valueArray.indexOf(int(valueString)) + 1;
					//if (! (this is ClassInstanceSelector))
					//ASSERT(selectedId > 0 , "error can't find id " + valueString);
					_BSSDropDownMenuScrollable.selectedId = selectedId ;
				}
				else
				{
					ASSERT(false , "unknown valueType " + valueType);
				}
				
			} else if (String(xml.@selectId))
			{
				selectedId =  int(String(xml.@selectId));
				
				_BSSDropDownMenuScrollable.selectedId = selectedId ;
				
				if (String(xml.@text))
					ASSERT( String(xml.@text) == _BSSDropDownMenuScrollable.selectedString , "unpair data " ,  String(xml.@text) , _BSSDropDownMenuScrollable.selectedString);
				
				if (String(xml.@value))
					ASSERT( String(xml.@value) == String(valueArray[selectedId - 1]) , "unpair data" ,  String(xml.@value) , String(valueArray[selectedId - 1]));				
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
				xml.@value = valueArray[selectedId - 1];
				
				ASSERT( _BSSDropDownMenuScrollable.selectedString == textArray[selectedId - 1])
				
				xml.@text = _BSSDropDownMenuScrollable.selectedString;
				xml.@selectId = selectedId;
			}
	
			return xml;
		}

		
		public override function dispose()
		: void 
		{
			if (valueArray)
			{
				var leng : int = valueArray.length;
				for (var i : int = 0 ; i < leng ; i++ )
					valueArray[i] = null;
				valueArray = null;
			}
			
			if (textArray)
			{
				leng  = textArray.length;
				for ( i  = 0 ; i < leng ; i++ )
					textArray[i] = null;
				textArray = null;
			}
			
			
			super.dispose();
			
		}
		
		public function ClassSelector(n : String) 
		{
			super(n);
		}
		

		
		public function getValue(id : int ): Object
		{
			return valueArray[id];
		}
		
		protected static function onChangeSelector(bddms : BSSDropDownMenu)
		: void 
		{
			var dsp : DisplayObject = bddms;
			while (dsp)
			{
				if (dsp is ClassInstance)
					break;
				dsp = dsp.parent;
			}
			CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_SELECTOR_CHANGE , [dsp , bddms] );
		}
		
		public override function createDsp ()
		: DisplayObject
		{
			var sp : SpriteWH = new SpriteWH();
			
			var bddms : BSSDropDownMenuScrollable = BSSDropDownMenuScrollable.createSimpleBSSDropDownMenuScrollable (width , 20 , className, false);
			bddms.setMaxHeight(300);
			bddms.selectFunction = onChangeSelector;
			
			for each (var str : String in textArray )
				bddms.addItem(str);
			
			sp.addChild	(bddms);
			
			if (showValue)
			{
				var textField : TextField = new TextField();
				textField.width = 60;
				textField.height = 18;
				textField.border = true;
				textField.background = true;
				textField.selectable = true;
				textField.x = width + 5;
				sp.addChild	(textField);
				
				bddms.selectFunction = onSelectorChangeText;
			}
				
			return sp;
		}
		
		public override function init(ci : ClassInstance , xml : XML)
		: void {
			
			ci.referenceObject = ((SpriteWH)(ci.getChildAt(0))).getChildAt(0);
			ASSERT(ci.referenceObject is BSSDropDownMenuScrollable);
			if (xml)
			{
				if ( String(xml.@name))
				{		
					BSSDropDownMenuScrollable(ci.referenceObject).text =  xml.@name;			
				}
			
				if ( String(xml.@text))
				{	
					BSSDropDownMenuScrollable(ci.referenceObject).text =  xml.@text;			
				}
			
				//trace("String(xml.@default)" , String(xml.@default) ,String(xml.@name) );
				if ( String(xml.@default))
				{
					//trace("String(xml.@default)" , String(xml.@default));
					ASSERT(ci.referenceObject is BSSDropDownMenuScrollable);
					BSSDropDownMenuScrollable(ci.referenceObject).selectedId =  (int)(String(xml.@default));	
				}
			
				if (String(xml.@active))
				{
					if ((String(xml.@active)) == "true")
					{
						BSSDropDownMenuScrollable(ci.referenceObject).activate();
					}
					else
					{
						BSSDropDownMenuScrollable(ci.referenceObject).deactivate();
					}
					
				}
		}
			
		}
		
		private static function onSelectorChangeText(bddms : BSSDropDownMenu) 
		: void
		{
			var selectId : int = bddms.selectedId;
			
			
			ASSERT (bddms.parent && bddms.parent is SpriteWH && SpriteWH(bddms.parent).getChildAt(1) is TextField);
			
			var tf :  TextField =  TextField(SpriteWH(bddms.parent).getChildAt(1));
			
			if (selectId)
			{
				var cs : ClassSelector = ClassSelector(((ClassInstance)(bddms.parent.parent)).classType);
				
				tf.text = "" + cs.valueArray[selectId - 1];
			}
			else
			{
				tf.text = "";
			}
			
			onChangeSelector(bddms);
			
			
		}
		
		
		public function addItemInt(value : int , text : String , isUnic : Boolean = true)
		: void 
		{
			
			//DBG_TRACE("addItemInt " , value , text);
			if (isUnic)
			{
				ASSERT(valueArray.indexOf(value) == -1 , "dupclicate value " + value + " text " + text + " is same to item " + valueArray.indexOf(value) );
			}
			
			valueArray.push(value);
			if (!(text))
			{
				text = "" + value;
			}
			
			textArray.push(text);
		}
		
		public function addItemString(value : String , text : String ,  isUnic : Boolean = true)
		: void 
		{
			//DBG_TRACE("addItemInt " , value , text);
			if (isUnic)
			{
				ASSERT(valueArray.indexOf(value) == -1 , "dupclicate value " + value + " text " + text);
			}
			
			valueArray.push(value);
			if (!(text))
			{
				text = "" + value;
			}
			
			textArray.push(text);
			
			//trace(condition);
		
			
		}
	}

}