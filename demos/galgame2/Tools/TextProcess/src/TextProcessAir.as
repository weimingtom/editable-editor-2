package  
{
	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.fscommand;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Blueshell
	 */
	public class TextProcessAir extends TextProcess 
	{
		
		public function TextProcessAir() 
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent); 

			trace("TextProcessAir");
		}
		
		public function onInvokeEvent(invocation:InvokeEvent):void { 
			if((invocation.currentDirectory != null)&&(invocation.arguments.length > 0))
			{
				
				filePath = (invocation.arguments[0]);
				startLoad();
			}
		}

		
		public override function saveData(_zipData:ByteArray , _dataArray : Array) : void
		{
			for (var i: int = 0 ; i < _dataArray.length; i+=2 )
			{
				trace(filePath + _dataArray[i]);
				var f:File = new File(filePath + _dataArray[i]);
				//trace(f);
				
				var fs:FileStream = new FileStream();
				fs.open(f,FileMode.WRITE);
				fs.writeBytes(_dataArray[i + 1]);
				fs.close();
			}
			
			NativeApplication.nativeApplication.exit();
			
			
		}
		
	}

}