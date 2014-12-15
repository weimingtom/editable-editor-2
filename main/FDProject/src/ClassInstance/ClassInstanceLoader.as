package ClassInstance 
{
	import Class.ClassBase;
	import Class.ClassInstanceSelector;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author Blueshell
	 */
	public class ClassInstanceLoader 
	{
		public static var s_loaderArray : Vector.<ClassInstanceLoader>;
		
		private var m_xml : XML;
		private var m_classBase : ClassBase;
		private var m_step : int = 0;
		private var m_ci : ClassInstance;
		
		private static var s_timeout : int = 0;
		


		public static var s_icsArray : Vector.<ClassInstance>;
		public static function load():void
		{
			if (s_timeout)
			{
				clearTimeout(s_timeout);
				s_timeout = 0;
			}
			
			if (s_loaderArray)
			{
				if (s_loaderArray.length == 0)
				{
					log("====load complete cost time " + (getTimer() - Logger.s_openStartTime) + "ms====");
					Logger.s_isOpening = false;
					s_loaderArray = null;
					return;
				}
				
				var _t : Number = getTimer();
				
				var _pass : int = s_loaderArray[s_loaderArray.length - 1].m_step;
				var _cl : ClassInstanceLoader;
				var _ci : ClassInstance;
				
				if (_pass == 1)
				{	
					_startTime = getTimer();
					if (!s_icsArray)
						s_icsArray = ClassInstanceMgr.getClassInstanceSelecterList();
					
					while (s_icsArray.length)
					{
						_ci = s_icsArray[0];
						ClassInstanceSelector(_ci.classType).rescanInstance(_ci);
						s_icsArray.splice(0 , 1);
						
						if (getTimer() - _t > 500)
							break;
						
					}
					
					
					_endTime = getTimer();
					log("scan ClassInstanceSelecter cost time " + (_endTime - _startTime) + "ms , " + s_icsArray.length + " remained");
					
					if (s_icsArray.length == 0)
					{	
						s_icsArray = null;
						s_loaderArray[s_loaderArray.length - 1].m_step = 2;
					}
				}
				else if (_pass == 2)
				{
					//trace("$$0 " + s_time[0]);
					//trace("$$1 " + s_time[1]);
					//trace("$$2 " + s_time[2]);
					//trace("$$3 " + s_time[3]);
					//trace("$$4 " + s_time[4]);
					
					
					var i : int;
					while ( s_loaderArray.length )
					{
						_cl = s_loaderArray[0];
						ASSERT(_cl.m_xml.name() == "classInstance" || _cl.m_xml.name() == "ClassInstance" , "ERROR");
							
						
						_ci = _cl.m_ci;
						
						//if (_cl.m_xml.@instanceUID != undefined)
						//	_ci = ClassInstanceMgr.findInstanceByUid(uint(_cl.m_xml.@instanceUID) , _cl.m_xml.attribute("class"));
						//else
						//	_ci = ClassInstanceMgr.findInstanceByName(_cl.m_xml.@name , _cl.m_xml.attribute("class"));
						if (_ci)
						{	
							_ci.classType.formXML(_ci , _cl.m_xml);
							log("classInstance name <" + _ci.instanceName +"> (" + _ci.instanceUID + ") formXML");
						}
						_cl.m_classBase = null;
						_cl.m_xml = null;
						_cl.m_ci = null;
						
						s_loaderArray.splice(0 , 1);
						
						if (getTimer() - _t > 500)
							break;
					}
				}
				else
				{
					var _startTime : Number;
					var _endTime : Number;
					
					for each (_cl in s_loaderArray)
					{
						if (_cl.m_step >= 1)
							continue;
							
						_startTime = getTimer();
						
						//var _t0 : int;
						//_t0 = getTimer();
						_ci = new  ClassInstance( _cl.m_classBase ,  _cl.m_xml.@name , false );
						//ClassInstanceLoader.s_time[0] += getTimer() - _t0;
						
						_cl.m_classBase.init(_ci , _cl.m_xml);

						
						if (String(_cl.m_xml.@instanceUID))
						{	
							_ci.instanceUID = uint(String(_cl.m_xml.@instanceUID));
						}	
						_cl.m_ci = _ci;
						_cl.m_step = 2;//no scan mode
						_endTime = getTimer();
						
						log("classInstance name <" + _ci.instanceName +"> created cost time " + (_endTime - _startTime));
						
						//trace(_ci.instanceUID);
						 
						if (_endTime - _t > 500)
							break;
					}
					
					
				}
			
				s_timeout = setTimeout(load , 1);
			}
		}
		
		public function ClassInstanceLoader(a_classBase : ClassBase , a_xml : XML) 
		{
			m_classBase = a_classBase;
			m_xml = a_xml;
			
			if (s_loaderArray)
				s_loaderArray.push(this);
		}
		
	}

}