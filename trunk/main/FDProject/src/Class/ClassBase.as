package  Class
{
	import ClassInstance.ClassInstance;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassBase
	{
		protected var _className : String;
		public var export : String;
		public var width : int;
		public var height : int;
		
		public function ClassBase(n : String ) 
		{
			_className = n;
			
			ClassMgr.regClass(this);
			//DBG_TRACE("create class \"" + _className + "\"");
		}
		public function init(ci : ClassInstance , xml : XML)
		: void {
			
		}
		
		public function formXML(instance : ClassInstance , xml : XML)
		: void 
		{
			
		}
		
		public function toXML(instance : ClassInstance)
		: XML
		{
			var xml : XML = 
			< classInstance class= "" name = "" instanceUID=""/>

			xml["@class"] = _className;
			xml.@name = instance.instanceName;
			xml.@instanceUID = instance.instanceUID;
			
			return xml;
		}
		
		public function dispose()
		: void 
		{
			ClassMgr.unregClass(this);
			_className = null;
			export = null;
		}
		
		public function get className() : String
		{
			return _className;
		}
		
		public function createDsp (_isResident : Boolean) : DisplayObject
		{
			return null;
		}
		
	}

}