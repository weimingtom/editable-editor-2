package 
{
	import Debugger.*;
	/**
	 * ...
	 * @author Blueshell
	 */
	
		//CONFIG::ASSERT 
		public function ASSERT (flag : Boolean , ...args):void {
			CONFIG::ASSERT {
				if (!flag)
				{
					DBG_TRACE(new Error().getStackTrace());
					throw ("" + args);
					
				}
			}
		}
	 
	 
	 

}