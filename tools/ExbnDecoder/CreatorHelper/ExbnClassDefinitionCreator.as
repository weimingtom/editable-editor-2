package ExbnDecoder.CreatorHelper 
{
	import ExbnDecoder.ExbnClassBase;
	import ExbnDecoder.ExbnClassStruct;
	import flash.system.ApplicationDomain;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ExbnClassDefinitionCreator
	{
		
		public static function createExbnClassDefinition( a_cs : ExbnClassStruct , a_instanceUID : uint , _package : String) : ExbnClassBase
		{
			
			var classNameFull : String = a_cs.className;
			
			if (_package)
				classNameFull = _package + "::" +  classNameFull;
				
			if (ApplicationDomain.currentDomain.hasDefinition(classNameFull))
			{
				var cls : Class = ApplicationDomain.currentDomain.getDefinition(classNameFull) as Class;
				return new cls(a_instanceUID) as ExbnClassBase;
			}

			CONFIG::DEBUG {
				trace("can't get defination " + classNameFull);
			}
			
			return null;

		}
		
	}

}