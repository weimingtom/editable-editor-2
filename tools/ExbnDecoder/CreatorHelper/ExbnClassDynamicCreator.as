package ExbnDecoder.CreatorHelper 
{
	import ExbnDecoder.ExbnClassDynamic;
	import ExbnDecoder.ExbnClassStruct;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ExbnClassDynamicCreator
	{
		public static function createExbnClassDynamic( a_cs : ExbnClassStruct , a_instanceUID : uint) : ExbnClassDynamic
		{
			return new ExbnClassDynamic(a_instanceUID , a_cs);

		}
		
	}

}