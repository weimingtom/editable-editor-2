package  Class
{
	import ClassInstance.ClassInstance;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import UISuit.UIComponent.BSSDropDownMenu;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassTextField extends ClassBase
	{
		public var restrict : String;
		public var border : Boolean = true;
		public var background : Boolean = true;
		public var defaultText : String;
		public var editable : Boolean = false;
		public var selectable : Boolean = true;
		
		public function ClassTextField(n : String) 
		{
			super(n);
			height = 20;
		}
		
		public override function formXML(instance : ClassInstance , xml : XML)
		: void 
		{
			(TextFieldWithWidth)(instance.referenceObject).text = xml.@text;
		}
		
		
		public override function toXML(instance : ClassInstance)
		: XML
		{
			var xml : XML = super.toXML(instance);
			
			xml.@text = (TextFieldWithWidth)(instance.referenceObject).text;
			
			return xml;
		}

		public override function init(ci : ClassInstance , xml : XML)
		: void {
			
			var tww : TextFieldWithWidth = TextFieldWithWidth(ci.getChildAt(0));
			ci.referenceObject = tww;
			if (xml.@text != undefined )
				tww.text = String(xml.@text);
			//else
			//	ASSERT(false);
			ci.recomputerWH();
			
			if (!tww.border)
				ci.graphics.clear();
				
			if (String(xml.@width))
			{
				(ci.content as TextFieldWithWidth).width = int(String(xml.@width));
				ci.removeChild(ci.content);
				ci.addChild(ci.content);
			}
		}
		
		public override function createDsp (_isResident : Boolean)
		: DisplayObject
		{
			var textField : TextFieldWithWidth = new TextFieldWithWidth();
			textField.restrict = restrict;
			textField.width = width;
			textField.height = height;
			if (height > 20)
			{	
				textField.multiline = true;
				textField.wordWrap = true;
			}
			textField.border = border;
			textField.background = background;
			textField.selectable = selectable;
			if (editable)
				textField.type = "input";
			
			if (defaultText)
				textField.text = defaultText;
			
			return textField;
		}
		
	}

}