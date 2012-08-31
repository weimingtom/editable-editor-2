package ExbnDecoder 
{
	import ExbnDecoder.*;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ExbnClassBase 
	{
		
		CONFIG::DEBUG {
			public var instanceName : String;
		}
		
		private var m_instanceUID : uint;
		public function get instanceUID() : uint {
			return m_instanceUID;
		}
		
		
		
		public function ExbnClassBase(a_instanceUID : uint) 
		{
			m_instanceUID = a_instanceUID;
		}
		
		public function decode(ba : ByteArray , a_env : ExbnEnv) : void {
			
		}
		
		public function dispose():void
		{
			CONFIG::DEBUG {
				instanceName = null;
			}
		}
		
	}

}