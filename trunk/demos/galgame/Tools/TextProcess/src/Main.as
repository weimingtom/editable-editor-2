package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	
	/**
	 * ...
	 * @author blueshell
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var ldr : URLLoader = new  URLLoader();
			ldr.addEventListener(Event.COMPLETE , onComplete)
			ldr.load(new URLRequest("../../STR_CHS_NAME.txt"));
			
			// entry point
		}
		private var nameArr : Array;
		private var nameArrIndex : Array;
		
		private function onComplete(e:Event):void 
		{
			var str : String = String(e.currentTarget.data);
			while (str.indexOf('\r') != -1)
				str = str.replace('\r' , "");
			nameArr = str.split("\n");
			nameArrIndex = ['~'];
			
			if (nameArr[(nameArr.length - 1)] == "")
				nameArr.length --;
			//trace(arr[0]);
			//trace("a");
			//trace(arr[1]);
			
			var xmlName : String = 	'<EditableEditorHeader>	<Selector className = "NameStringSelector" valueType = "String" width = "150" showValue = "false" export="value=string"><item text = "无" value = ""/>';
					
			for each (var nameStr : String in nameArr )
			{
				if (nameStr == "")
				{
					throw("异常，名字含有空的字符");
				}
				
				if (nameArrIndex.indexOf(nameStr) == -1)
				{
					
					xmlName += '<item text = "' + nameStr + '" value = "' + nameStr +'"/>'
					nameArrIndex.push(nameStr);
				}
			}
					
			
			
			xmlName += '</Selector></EditableEditorHeader>	'
			
			//new FileReference().save(new XML(xmlName).toXMLString() , "NameString.xml");
			
			
			var fileName:String = "NameString.xml";
			var fileData:ByteArray = new ByteArray();
			fileData.writeUTFBytes(new XML(xmlName).toXMLString());
			var ze:ZipEntry = new ZipEntry(fileName);
			zipOut.putNextEntry(ze);
			zipOut.write(fileData);
			zipOut.closeEntry();
			
			
			
			var ldr : URLLoader = new  URLLoader();
			ldr.addEventListener(Event.COMPLETE , onCompleteContent)
			ldr.load(new URLRequest("../../STR_CHS.txt"));
		}
		
		private var contentArr : Array;
		private var zipOut:ZipOutput = new ZipOutput();
		

		private function onCompleteContent(e:Event):void 
		{
			var str : String = String(e.currentTarget.data);
			while (str.indexOf('\r') != -1)
				str = str.replace('\r' , "");
			contentArr = str.split("\n");
			
			if (contentArr[(contentArr.length - 1)] == "")
				contentArr.length --;
			
			//trace(contentArr[0]);
			//trace(contentArr[1]);
			//trace(contentArr[2]);
			//trace(contentArr[3]);
			//trace(contentArr[4]);
			//trace(contentArr[5]);
			//trace(contentArr[6]);
			
			var xmlName : String = 	'<EditableEditorHeader>	<Selector className = "ContentStringSelector" valueType = "int" width = "250" showValue = "false" export="value=u8_16"><item text = "无" value = "0"/>';
					
			var preContentStr : String
			for (var i : int = 0 ; i < contentArr.length ; )
			{
				var contentStr : String = contentArr[i];
				//trace(contentStr);
				if (contentStr.length >= 18)
					contentStr = contentStr.substr(0, 16) + "...";
				contentArr[i] = contentStr;
				//trace(contentStr);
				if (contentStr == "")
				{
					throw("异常，内容含有空的字符 行号" + i + "上一段文本" + preContentStr);
				}
				i++;
				xmlName += '<item text = "' + i + " " + contentStr + '" value = "' + i +'"/>'
				
				preContentStr = contentStr;
			}
					
			
			
			xmlName += '</Selector></EditableEditorHeader>	'
			
			var fileName:String = "ContentString.xml";
			var fileData:ByteArray = new ByteArray();
			fileData.writeUTFBytes(new XML(xmlName).toXMLString());
			//trace(fileData[0]);
			//trace(fileData[1]);
			
			var ze:ZipEntry = new ZipEntry(fileName);
			zipOut.putNextEntry(ze);
			zipOut.write(fileData);
			zipOut.closeEntry();
			
			//zipOut.finish();
			//var zipData:ByteArray = zipOut.byteArray;
			//new FileReference().save(zipData , "data.zip");
			genEXML();
		}
		
		private function genEXML():void
		{
			var xmlString : String = '<EditableEditorFile version="31" >'
			var optionTotal : int; 
			for (var i : int = 0 ; i < contentArr.length ; i++)
			{
				var clsName : String = "DialogBoard";
				
				if (contentArr[i] && contentArr[i].length >= 2)
				{
					var flag : String = String(contentArr[i]).substring(0, 2)
					if (flag == "$T")
					{
						clsName  = "DialogBoardTitle";
					}
				}
				
				var optionNum : int = 0;
				var option_i : int = i + 1;
				for ( option_i = i + 1 ; option_i < contentArr.length ; option_i++ )
				{
					if (contentArr[option_i] && contentArr[option_i].indexOf("$O") == 0)
					{
						optionNum++;
					}
					else
					{
						break;
					}
				}
				
				if (optionNum == 2)
				{
					clsName = "DialogBoardOption2";
				}
				else if (optionNum == 3)
				{
					clsName = "DialogBoardOption3";
				}
				optionTotal += optionNum;
				
				xmlString += '<classInstance class="' + clsName + '" name="' ;
				
				if (clsName == "DialogBoard")
					xmlString += "DB0_"
				else if (clsName == "DialogBoardTitle")
					xmlString += "DBT_"
				else if (clsName == "DialogBoardOption2")
					xmlString += "DB2_"
				else if (clsName == "DialogBoardOption3")
					xmlString += "DB3_"
				
				xmlString += (i + 1) + "_" + contentArr[i] + '">';
				if (clsName  != "DialogBoardTitle")
					xmlString += '<classInstance class="NameStringSelector" name="name" value="' + (nameArr[i]=="~" ? "" : nameArr[i])  +'"/>'
					
				
				xmlString += '<classInstance class="ContentStringSelector" name="content" value="' + (i + 1)  +'" text="' + contentArr[i] + '"/>'
				
				if (i+optionNum != contentArr.length - 1)
				{
					
					if (clsName == "DialogBoardOption2" || clsName == "DialogBoardOption3")
					{
						for ( option_i = 0 ; option_i < optionNum ; option_i++ )
						{
							xmlString += '<classInstance class="ContentStringSelector" name="optionContent' + option_i + '" value="' + (i+2+option_i)  +'" text="' + contentArr[i + 1 + option_i] + '"/>'
							xmlString += '<classInstance class="DialogBoardClick" name="optionContentNext'+ option_i + '">';
								xmlString += '<classInstance class="DialogBoardSelector" name="dialog" selectId="' + (i+2 + optionNum - optionTotal ) +'"/>'
							xmlString += '</classInstance>';
						}
							
					}
					else {
						
						xmlString += '<classInstance class="DialogBoardClick" name="next">';
						xmlString += '<classInstance class="DialogBoardSelector" name="dialog" selectId="' + (i+2 - optionTotal) +'"/>'
						xmlString += '</classInstance>'
					}
					
				}
				
				
				xmlString += '</classInstance>'
				
				i += optionNum;
				
			}
			 
			xmlString +=  '</EditableEditorFile>'
			
			trace(xmlString);
			
			
			var fileName:String = "1.exml";
			var fileData:ByteArray = new ByteArray();
			fileData.writeUTFBytes(new XML(xmlString).toXMLString());
			//trace(fileData[0]);
			//trace(fileData[1]);
			
			var ze:ZipEntry = new ZipEntry(fileName);
			zipOut.putNextEntry(ze);
			zipOut.write(fileData);
			zipOut.closeEntry();
			
			zipOut.finish();
			var zipData:ByteArray = zipOut.byteArray;
			new FileReference().save(zipData , "data.zip");
		}
	}
	
}