package  
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Blueshell
	 */
	public class Profiler 
	{

		
		private static var m_timeArray : Array = [];
		private static var m_startTime : int;
		public static function setStart() : void
		{
			m_startTime = getTimer();
		}
		
		public static function setEnd(id:int) : void
		{
			while (id >= m_timeArray.length)
			{
				m_timeArray.push(0);
			}
			m_timeArray[id] +=  getTimer() - m_startTime;
		
		}
		
		public static function traceAll():void
		{
			for (var i : int = 0 ; i < m_timeArray.length ; i++ )
				trace("T" + i + ": " + m_timeArray[i] + " ms");
		}
	}

}