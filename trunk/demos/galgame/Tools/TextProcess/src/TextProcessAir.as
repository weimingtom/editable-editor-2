package  
{
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
			
		}
		
		public override function saveData(_zipData:ByteArray , _dataArray : Array) : void
		{
			for (var i: int = 0 ; i < _dataArray.length; i++ )
			{
				var f:File = new File(_dataArray[i]);
				var fs:FileStream = new FileStream();
				fs.open(f,FileMode.WRITE);
				fs.writeBytes(_dataArray[i + 1]);
				fs.close();
			}
			
			fscommand("quit", "true");
			
			
		}
		
	}

}