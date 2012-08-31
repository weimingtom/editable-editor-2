package  Debugger {
  
  //public function ASSERT(flag : Boolean ,txt : String) : void {if(!(flag)) throw (txt);}
  //public function PRT_STACK(txt : String) : void {trace((new Error()).getStackTrace());}
  //public function DBG_TRACE(...args) : void { DebugConsole.DebugConsole_DBG_TRACE( args );}
  public function DBG_TRACE_PLUS(flag : int , ...args)   : void 
  {
	  DBG_TRACE(args);
	  //DebugConsole.DebugConsole_DBG_TRACE_PLUS(flag  , args );
	}
}

