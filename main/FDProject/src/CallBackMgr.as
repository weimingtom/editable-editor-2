package {
	import Debugger.DBG_DEF;
	import Debugger.DBG_TRACE_PLUS;
    
    

    
    public class CallBackMgr{


	private static var s_CallBackMgr_CallBackList : Vector.<Vector.<CALLBACK>>  = 
	new Vector.<Vector.<CALLBACK>> (  CALLBACK.CALLBACK_MAX , true ) ;





	public static function CallBackMgr_notifyEvent (evtId : int , args : Array = null , param0 : int = 0 , param1 : int = 0)
	: void {
		ASSERT(evtId < CALLBACK.CALLBACK_MAX , "errorEventId" + evtId);

		
		
		var CallBackMgr_CallBackList : Vector.<CALLBACK>  = s_CallBackMgr_CallBackList[evtId];

		if (CallBackMgr_CallBackList)
		{     
			var callBackFunc : CALLBACK;

			for (var i : int = 0 ; i < CallBackMgr_CallBackList.length;)
			{
				callBackFunc = CALLBACK(CallBackMgr_CallBackList[i]);
				callBackFunc.func(evtId , args , param0  , param1, callBackFunc.obj );
				
				if (i < CallBackMgr_CallBackList.length && callBackFunc == CallBackMgr_CallBackList[i]) //not delete it self
					i++;
			}
				
			 //for each (callBackFunc in CallBackMgr_CallBackList)
			//	callBackFunc.func(evtId , args , param0  , param1, callBackFunc.obj );
			
			CallBackMgr_CallBackList = null;
		 }
	}


	public static function CallBackMgr_registerCallBack(evtId : int , callBackFunc : Function , obj : Object = null)
	:void{
		ASSERT(evtId < CALLBACK.CALLBACK_MAX , "errorEventId" + evtId);

		if (s_CallBackMgr_CallBackList[evtId] == null)
		{
			s_CallBackMgr_CallBackList[evtId] = new Vector.<CALLBACK>();
		}
		var CallBackList : Vector.<CALLBACK>  = s_CallBackMgr_CallBackList[evtId];
		
		CONFIG::Debug {
			for each (var cb :CALLBACK in CallBackList)
			{
				ASSERT (((cb.func != callBackFunc) || (cb.obj != obj)), "s_CallBackMgr_CallBackList regisiter twice !!");
			}
		}
		

		CallBackList.push(new CALLBACK(callBackFunc , obj));
	}


	public static function CallBackMgr_unregisterCallBack(evtId : int , callBackFunc : Function , obj : Object = null)
	:void {
		
		if (!s_CallBackMgr_CallBackList)
		{
			DBG_TRACE_PLUS(DBG_DEF.WARNING , "CallBackMgr is dispose already when CallBackMgr_unregisterCallBack " );
			return;
		}

		ASSERT(evtId < CALLBACK.CALLBACK_MAX , "errorEventId" + evtId);
		ASSERT(s_CallBackMgr_CallBackList[evtId] , "eventId List is Empty"  );
		
		var CallBackList : Vector.<CALLBACK>  = s_CallBackMgr_CallBackList[evtId];
		var funcIndex : int =  -1;
		
		var i : int = 0;
		for each (var cb :CALLBACK in CallBackList)
		{
			if ((cb.func == callBackFunc) && (cb.obj == obj))
			{
				funcIndex = i;
				break;
			}
			i++;
		}
		ASSERT (funcIndex != -1 , "has not register this function !!" );
		
		if( funcIndex != -1)
			CallBackList.splice(funcIndex,1);
		else
			DBG_TRACE_PLUS(DBG_DEF.WARNING , "cann't find callback the func of callback ");
	}



		public static function CallBackMgr_dispose()
		:void{
			var leng : int;
			if (s_CallBackMgr_CallBackList)
			{
				for (var i : int = 0 ; i < CALLBACK.CALLBACK_MAX ; i++)
				{
					if ( s_CallBackMgr_CallBackList[i]  )
					{    
						leng  =  s_CallBackMgr_CallBackList[i]  .length;  
						{ 
							while (  leng --)   
							{
								s_CallBackMgr_CallBackList[i][  leng ].dispose();
								s_CallBackMgr_CallBackList[i][  leng ] = null; 
							}
						}
					};  
					s_CallBackMgr_CallBackList[i] = null;
				} ;
			}
			s_CallBackMgr_CallBackList = null;

		}

    }
}
