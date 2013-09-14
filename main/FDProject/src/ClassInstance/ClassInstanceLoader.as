package ClassInstance 
{
	import Class.ClassBase;
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
		
		private static var s_timeout : int = 0;
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
					s_loaderArray = null;
					return;
				}
				
				var _t : Number = getTimer();
				
				var _secPass : Boolean = s_loaderArray[s_loaderArray.length - 1].m_step == 1;
				var _cl : ClassInstanceLoader;
				var _ci : ClassInstance;
				
				if (_secPass)
				{
					var i : int;
					while ( s_loaderArray.length )
					{
						_cl = s_loaderArray[0];
						ASSERT(_cl.m_xml.name() == "classInstance" || _cl.m_xml.name() == "ClassInstance" , "ERROR");
							
						if (_cl.m_xml.@instanceUID != undefined)
							_ci = ClassInstanceMgr.findInstanceByUid(uint(_cl.m_xml.@instanceUID) , _cl.m_xml.attribute("class"));
						else
							_ci = ClassInstanceMgr.findInstanceByName(_cl.m_xml.@name , _cl.m_xml.attribute("class"));
						if (_ci)
						{	
							_ci.classType.formXML(_ci , _cl.m_xml);
							log("classInstance name" + _ci.instanceName +"(" + _ci.instanceUID + ") formXML");
						}
						_cl.m_classBase = null;
						_cl.m_xml = null;
						
						s_loaderArray.splice(0 , 1);
						
						if (getTimer() - _t > 500)
							break;
					}
				}
				else
				{
					
					for each (_cl in s_loaderArray)
					{
						if (_cl.m_step == 1)
							continue;
							
						_ci = new  ClassInstance( _cl.m_classBase ,  _cl.m_xml.@name );
						_cl.m_classBase.init(_ci , _cl.m_xml);
						
						if (String(_cl.m_xml.@instanceUID))
						{	
							_ci.instanceUID = uint(String(_cl.m_xml.@instanceUID));
						}	
						_cl.m_step = 1;
						
						log("classInstance name" + _ci.instanceName +" created");
						
						if (getTimer() - _t > 500)
							break;
					}
					
					
				}
			
				s_timeout = setTimeout(load , 15);
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