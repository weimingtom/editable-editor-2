package ClassInstance 
{
	import Class.ClassBase;
	import Class.ClassDynamic;
	import Class.ClassInstanceSelector;
	import Class.ClassMgr;
	import Class.ClassSelector;
	import Debugger.DBG_TRACE;
	import flash.media.ID3Info;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ClassInstanceBinarize
	{
		
		public static function writeFileHead(ba : ByteArray) : void 
		{
			var date :  Date = new Date();
			var time : Number = date.getTime();
			time -= 0x13770000000;
			
			//trace(time.toString(16));
			
			
			ba.writeByte('e'.charCodeAt(0));
			ba.writeByte('x'.charCodeAt(0));
			ba.writeByte('b'.charCodeAt(0));
			ba.writeByte('n'.charCodeAt(0));
			ba.writeByte(1); //version
			ba.writeUnsignedInt(time);
			ba.writeShort(Version.version);
		}
		
		
		public static function readFileHead(ba : ByteArray) : Boolean 
		{
			
			
			if (ba.readByte() == 'e'.charCodeAt(0)
			&& ba.readByte() == 'x'.charCodeAt(0)
			&& ba.readByte() == 'b'.charCodeAt(0)
			&& ba.readByte() == 'n'.charCodeAt(0)
			&& ba.readByte() == 1
			)
			{
				var time : Number = ba.readUnsignedInt() + 0x13770000000;
				DBG_TRACE("create at time" + new Date(time));
				
				var version : int = ba.readShort();
				
				DBG_TRACE("File bin version: " + version);	
			
				if ( version != Version.version)
				{
					ASSERT(false , "unpair config version and file version");
					return false;
				}
				
				return true;
			}
			else
				return false;
		
		}
		
		private static var s_stringPool : Vector.<String>;
		private static var s_classPool : Vector.<ClassBinStruct>;
		private static var s_outPutBuffer : ByteArray;
		private static var s_outPutIntanceNum : int;
		
		private static function getStringId(str : String) : int
		{
			var idx : int = s_stringPool.indexOf(str);
			if (idx == -1)
			{ 
				s_stringPool.push(str);
				return s_stringPool.length - 1;
			}
			else
			{
				return idx;
			}
		}
		
		private static function fillVariableBinStructType(classBase : ClassBase , vbs :  VariableBinStruct)
		: void {
			CONFIG::ASSERT {
				ASSERT(!(classBase is ClassDynamic) , "ClassDynamic");
				ASSERT(vbs != null , "fillVariableBinStructType vbs");
				ASSERT(classBase.export != null , "fillVariableBinStructType export");
			}
			
			var _exportArray : Array = classBase.export.split("=");

			switch (_exportArray[1])
			{
				case "u8" : 		vbs.type = VariableBinStruct.TYPE_UINT_U8; break;
				case "u16" : 		vbs.type = VariableBinStruct.TYPE_UINT_U16; break;
				case "u32" : 		vbs.type = VariableBinStruct.TYPE_UINT_U32; break;
				case "u8_16" : 		vbs.type = VariableBinStruct.TYPE_UINT_U8_16; break;
				case "u16_32" : 		vbs.type = VariableBinStruct.TYPE_UINT_U16_32; break;
				case "u8_16_32" : 		vbs.type = VariableBinStruct.TYPE_UINT_U8_16_32; break;
				
				
				case "s8" : 		vbs.type = VariableBinStruct.TYPE_INT_S8; break;
				case "s16" : 		vbs.type = VariableBinStruct.TYPE_INT_S16; break;
				case "s32" : 		vbs.type = VariableBinStruct.TYPE_INT_S32; break;
				case "s8_16" : 		vbs.type = VariableBinStruct.TYPE_INT_S8_16; break;
				case "s16_32" : 		vbs.type = VariableBinStruct.TYPE_INT_S16_32; break;
				case "s8_16_32" : 		vbs.type = VariableBinStruct.TYPE_INT_S8_16_32; break;
				
				case "f32" : 		vbs.type = VariableBinStruct.TYPE_NUMBER_F32; break;
				case "d64" : 		vbs.type = VariableBinStruct.TYPE_NUMBER_D64; break;
				
				case "string" : 		vbs.type = VariableBinStruct.TYPE_STRING_ID; break;
				case "uid" : 		vbs.type = VariableBinStruct.TYPE_INSTANCE_UID; break;
				default:
					CONFIG::ASSERT
					{
						ASSERT(false, "error param " + _exportArray[1]);
					}
			}
		}
		
		private static function genAClassBinStruct(className : String , ClassDynamicXML : XML) : ClassBinStruct
		{
			var classBase : ClassBase = ClassMgr.findClass(className);
			//trace(classBase);
			
			var cbs : ClassBinStruct = new ClassBinStruct();
			cbs.classNameId = getStringId(className);
			
			
			
			if (classBase is ClassDynamic)
			{
				CONFIG::ASSERT {
					ASSERT(classBase.export == null , "error");
				}
				
				var list : XMLList = ClassDynamicXML.elements();
				for each (var subXml : XML in list)
				{
					//trace(subXml.toXMLString());

					if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance" )
					{
						var _subClassName : String = subXml.attribute("class");
						var _fieldName : String = subXml.attribute("name");
						
						var _subClassBase : ClassBase = ClassMgr.findClass(_subClassName);

						
						vbs = new VariableBinStruct();
						vbs.variableNameId = getStringId(_fieldName);
						
						if (_subClassBase is ClassDynamic)
						{
							vbs.type = VariableBinStruct.TYPE_INSTANCE_UID;
							vbs.inlineClassId = getClassId(_subClassName , subXml);

						}
						else
						{
							vbs.type = VariableBinStruct.TYPE_INSTANCE_UID_INLINE;
							vbs.inlineClassId = getClassId(_subClassName , subXml);
						}
						
						cbs.variableArray.push(vbs);
						cbs.variableNum++;
					}
					else
					{
						ASSERT(false , "unknow item " + subXml.name())
					}
				}
				
				
			}
			else
			{
				
				
				CONFIG::ASSERT {
					ASSERT(classBase.export != null , "error");
				}
				
				var vbs : VariableBinStruct = new VariableBinStruct();
				
				var _exportArray : Array = classBase.export.split("=");
				vbs.variableNameId = getStringId(_exportArray[0]);
				fillVariableBinStructType(classBase , vbs);
				
				cbs.variableNum = 1;
				cbs.variableArray.push(vbs);
			}
			
			return cbs;
		}
		
		private static function getClassId(className : String , ClassDynamicXML : XML) : int
		{
			for ( var i : int = 0 ; i < s_classPool.length;i++ )
			{
				var cbs : ClassBinStruct = s_classPool[i];
				if (s_stringPool[cbs.classNameId] == className)
				{
					return i;
				}
			}
			
			s_classPool.push(genAClassBinStruct(className , ClassDynamicXML));
			return s_classPool.length - 1; 
			
		}
		
		/*
		private static function getVariableBinStruct(_fieldName : String , cbs : ClassBinStruct)
		: VariableBinStruct {
			for each (var vbs : VariableBinStruct in cbs.variableArray)
			{
				if (s_stringPool[vbs.variableNameId] == _fieldName)
				{
					return vbs;
				}
			}
			
			CONFIG::ASSERT {
				ASSERT(false , "error VariableBinStruct");
			}
			return null;
		}
		*/
		
		
		public static function xmlBinarizeClass(xml : XML) : ByteArray
		{
			var ba : ByteArray = new ByteArray();
			
			ASSERT( String(xml.name()).toUpperCase() == "CLASSINSTANCE" , "unknown header!");
			
			DBG_TRACE("xmlBinarizeClass " + xml.@name);
			
			
			var className : String = xml.attribute("class");
			var clsId : int = (getClassId(className , xml));
			var cbs : ClassBinStruct = s_classPool[clsId];
			
			var instanceUID : uint = uint(String(xml.@instanceUID));
			
			ByteArrayUtil.writeUnsignedByteOrShort(ba , clsId);
			ba.writeUnsignedInt(instanceUID);
			
			var list : XMLList = xml.elements();
			var idx : int =0;
			for each (var subXml : XML in list)
			{
				//trace(subXml.toXMLString());

				if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance" )
				{
					var _subClassName : String = subXml.attribute("class");
					var _fieldName : String = subXml.attribute("name");
					
					var vbs : VariableBinStruct = cbs.variableArray[idx];
					CONFIG::ASSERT {
						ASSERT( s_stringPool[vbs.variableNameId] == _fieldName  , "error _fieldName");
					}
					//getVariableBinStruct(_fieldName , cbs);
					idx++;
					//v3
					//ByteArrayUtil.writeUnsignedByteOrShort(ba , vbs.variableNameId);

					if (vbs.type == VariableBinStruct.TYPE_INSTANCE_UID_INLINE)
					{
						
						var _inlineClsId : int = vbs.inlineClassId;// (getClassId(_subClassName , subXml));
						//ByteArrayUtil.writeUnsignedByteOrShort(ba , _inlineClsId);

						var _inlineCbs : ClassBinStruct = s_classPool[_inlineClsId];
						
						CONFIG::ASSERT {
							ASSERT(_inlineCbs.variableNum == 1 , "error");
						}
						
						//DBG_TRACE("ba.position :" + ba.position);
						
						var inlineVariableBinStruct : VariableBinStruct = _inlineCbs.variableArray[0];
						var fieldName : String = s_stringPool[inlineVariableBinStruct.variableNameId];
						
						if ("selectedInstanceUID" == fieldName || "value" == fieldName) 
						{
							if (!subXml.hasOwnProperty("@"+fieldName))
							{
								DBG_TRACE("###warning: instanceUID " + instanceUID + ":"+ xml.attribute("name") + "." + subXml.attribute("name") + " has no data!!");
							}
						}
						else
						{
							CONFIG::ASSERT {
								ASSERT(subXml.hasOwnProperty("@"+fieldName) , "error no fieldName " + "@"+fieldName );
							}
						
						}
						
						var inlineValue : String = subXml.attribute(fieldName);
						var inlineValueInt : int = int(inlineValue);
						var inlineValueUInt : uint = uint(inlineValue);
						
						switch (inlineVariableBinStruct.type)
						{
							case VariableBinStruct.TYPE_INT_S8 : ba.writeByte(inlineValueInt); break;
							case VariableBinStruct.TYPE_INT_S16 : ba.writeShort(inlineValueInt); break;
							case VariableBinStruct.TYPE_INT_S32 : ba.writeInt(inlineValueInt); break;
							case VariableBinStruct.TYPE_INT_S8_16 : ByteArrayUtil.writeByteOrShort(ba , inlineValueInt); break;
							case VariableBinStruct.TYPE_INT_S8_16_32 :  ByteArrayUtil.writeByteOrShortOrInt(ba , inlineValueInt); break;
							case VariableBinStruct.TYPE_INT_S16_32 :  ByteArrayUtil.writeShortOrInt(ba , inlineValueInt); break;


							case VariableBinStruct.TYPE_UINT_U8 : ba.writeByte(inlineValueUInt); break;
							case VariableBinStruct.TYPE_UINT_U16 : ba.writeShort(inlineValueUInt); break;
							case VariableBinStruct.TYPE_UINT_U32 : ba.writeUnsignedInt(inlineValueUInt); break;
							case VariableBinStruct.TYPE_UINT_U8_16 : ByteArrayUtil.writeUnsignedByteOrShort(ba , inlineValueUInt); break;
							case VariableBinStruct.TYPE_UINT_U8_16_32 : ByteArrayUtil.writeUnsignedByteOrShortOrInt(ba , inlineValueUInt); break;
							case VariableBinStruct.TYPE_UINT_U16_32 : ByteArrayUtil.writeUnsignedShortOrInt(ba , inlineValueUInt); break;

							case VariableBinStruct.TYPE_NUMBER_F32 : ba.writeFloat(Number(inlineValue)); break;
							case VariableBinStruct.TYPE_NUMBER_D64 : ba.writeDouble(Number(inlineValue)); break;

							case VariableBinStruct.TYPE_STRING_ID : 
								 ByteArrayUtil.writeUnsignedByteOrShort(ba , getStringId(inlineValue)); break;
							break;
							case VariableBinStruct.TYPE_INSTANCE_UID : 
								CONFIG::ASSERT
								{
									ASSERT(  ClassMgr.findClass(_subClassName) is ClassInstanceSelector, "error param " + inlineVariableBinStruct);
								}
								ba.writeUnsignedInt(inlineValueUInt); break;
							
							break;

							
							
							default:
								CONFIG::ASSERT
								{
									ASSERT(false, "error param " + inlineVariableBinStruct);
								}
						}
					}
					else
					{
						CONFIG::ASSERT {
							ASSERT(vbs.type == VariableBinStruct.TYPE_INSTANCE_UID , "error");
						}
						
						//ASSERT(false , "neead test");
						
						var subInstanceUID : uint = uint(String(subXml.@instanceUID));
						ba.writeUnsignedInt(subInstanceUID);

						
						var _subBa : ByteArray = xmlBinarizeClass(subXml);						
						s_outPutIntanceNum++;
						ByteArrayUtil.writeUnsignedByteOrShort(s_outPutBuffer , _subBa.length);
						s_outPutBuffer.writeBytes(_subBa);
						DBG_TRACE("outPutIntance " + subXml.@name);
						
						_subBa = null;
					}
					
				}
				else
				{
					ASSERT(false , "unknow item " + subXml.name())
				}
			}

			return ba;
		}
		
		
		
		public static function xmlBinarize(ba : ByteArray , xml : XML) : void 
		{
			s_stringPool = new Vector.<String>;
			s_classPool = new Vector.<ClassBinStruct>();
			s_outPutBuffer = new ByteArray();
			s_outPutIntanceNum = 0;
			
			ASSERT( xml.name() == "EditableEditorFile" , "unknown header!");
			
			if ( xml.name() != "EditableEditorFile")
				return;

			if ( int(xml.@version) != Version.version)
			{
				ASSERT(false , "unpair config version and file version");
			}
				
			var list : XMLList = xml.elements();
			for each (var subXml : XML in list)
			{
				if (subXml.name() == "classInstance" || subXml.name() == "ClassInstance" )
				{
					var _classBa : ByteArray = xmlBinarizeClass(subXml);
					s_outPutIntanceNum++;
					ByteArrayUtil.writeUnsignedByteOrShort(s_outPutBuffer , _classBa.length);
					s_outPutBuffer.writeBytes(_classBa);
					DBG_TRACE("outPutIntance " + subXml.@name);
					_classBa = null;
				}
				else
				{
					ASSERT(false , "unknow item " + subXml.name())
				}
			}
			
			////////////out put string pool/////////////
			ByteArrayUtil.writeUnsignedByteOrShort(ba , s_stringPool.length);
			var strBa : ByteArray = new ByteArray();
			
			for (var s : int = 0 ; s < s_stringPool.length; s++ )
			{
				var str : String = s_stringPool[s];
				strBa.position = 0;
				strBa.length = 0;
				strBa.writeUTFBytes(str);
				ByteArrayUtil.writeUnsignedByteOrShort(ba , strBa.length);
				ba.writeBytes(strBa);
			}
			strBa = null;
			
			////////////out put classPool pool/////////////
			
			var byteArrayBuffer : ByteArray = new ByteArray();
			
			ByteArrayUtil.writeUnsignedByteOrShort(byteArrayBuffer, s_classPool.length);
			for (var c : int = 0 ; c < s_classPool.length; c++ )
			{
				var _cbs: ClassBinStruct = s_classPool[c];
				ByteArrayUtil.writeUnsignedByteOrShort(byteArrayBuffer , _cbs.classNameId);
				ByteArrayUtil.writeUnsignedByteOrShort(byteArrayBuffer , _cbs.variableNum);
				for (var vi : int = 0 ; vi < _cbs.variableNum; vi++ )
				{
					ByteArrayUtil.writeUnsignedByteOrShort(byteArrayBuffer , _cbs.variableArray[vi].variableNameId);
					byteArrayBuffer.writeByte(_cbs.variableArray[vi].type);
					
					if (_cbs.variableArray[vi].type == VariableBinStruct.TYPE_INSTANCE_UID_INLINE || _cbs.variableArray[vi].type == VariableBinStruct.TYPE_INSTANCE_UID)
					{
						ByteArrayUtil.writeUnsignedByteOrShort(byteArrayBuffer , _cbs.variableArray[vi].inlineClassId);
					}
					
				}
			}
			//ByteArrayUtil.writeUnsignedShortOrInt(ba , byteArrayBuffer.length);
			ba.writeBytes(byteArrayBuffer);
			byteArrayBuffer = null;
			////////////out put class instance pool/////////////
			ByteArrayUtil.writeUnsignedByteOrShort(ba , s_outPutIntanceNum);
			ba.writeBytes(s_outPutBuffer);
			
			s_stringPool = null;
			s_classPool = null;
			s_outPutBuffer = null;
		}
		
		public static function getVariableBinData(vbs : VariableBinStruct , ba : ByteArray) : Object
		{
			var ret : Object;
			switch (vbs.type)
			{
				case VariableBinStruct.TYPE_INT_S8 : ret = ba.readByte(); break;
				case VariableBinStruct.TYPE_INT_S16 : ret = ba.readShort(); break;
				case VariableBinStruct.TYPE_INT_S32 : ret = ba.readInt(); break;
				case VariableBinStruct.TYPE_INT_S8_16 : ret = ByteArrayUtil.readByteOrShort(ba); break;
				case VariableBinStruct.TYPE_INT_S8_16_32 :  ret = ByteArrayUtil.readByteOrShortOrInt(ba); break;
				case VariableBinStruct.TYPE_INT_S16_32 :  ret = ByteArrayUtil.readShortOrInt(ba); break;


				case VariableBinStruct.TYPE_UINT_U8 : ret = ba.readUnsignedByte(); break;
				case VariableBinStruct.TYPE_UINT_U16 : ret = ba.readUnsignedShort(); break;
				case VariableBinStruct.TYPE_UINT_U32 : ret = ba.readUnsignedInt(); break;
				case VariableBinStruct.TYPE_UINT_U8_16 : ret = ByteArrayUtil.readUnsignedByteOrShort(ba); break;
				case VariableBinStruct.TYPE_UINT_U8_16_32 : ret = ByteArrayUtil.readUnsignedByteOrShortOrInt(ba); break;
				case VariableBinStruct.TYPE_UINT_U16_32 : ret = ByteArrayUtil.readUnsignedShortOrInt(ba); break;

				case VariableBinStruct.TYPE_NUMBER_F32 : ret = ba.readFloat(); break;
				case VariableBinStruct.TYPE_NUMBER_D64 : ret = ba.readDouble(); break;

				case VariableBinStruct.TYPE_STRING_ID : ret = s_stringPool[ByteArrayUtil.readUnsignedByteOrShort(ba)]; break;

				case VariableBinStruct.TYPE_INSTANCE_UID_INLINE : 
					//DBG_TRACE("r ba.position :" + ba.position);

					var _inlineClsId : int = vbs.inlineClassId;//ByteArrayUtil.readUnsignedByteOrShort(ba);
					var _inlineCbs : ClassBinStruct = s_classPool[_inlineClsId];
					
					DBG_TRACE(" inline class " + s_stringPool[_inlineCbs.classNameId]);
					
					var vbs : VariableBinStruct = _inlineCbs.variableArray[0];
					ret = getVariableBinData(vbs , ba);
				
				break;
				case VariableBinStruct.TYPE_INSTANCE_UID :
					ret = "uid_" + ba.readUnsignedInt(); 
				break;
					
				default:
					CONFIG::ASSERT
					{
						ASSERT(false, "error param " + vbs.type);
					}
			}
			
			return ret;
		}
		
		
		public static function xmlClassDebinarize(ba : ByteArray) : void 
		{
			var clsId : int =  ByteArrayUtil.readUnsignedByteOrShort(ba);
			var instanceUID : uint = ba.readUnsignedInt();
			var _cbs : ClassBinStruct = s_classPool[clsId];
			
			DBG_TRACE("find class instance " + s_stringPool[_cbs.classNameId] + " instanceUID = " + instanceUID);
			
			for (var vi : int = 0 ; vi < _cbs.variableNum; vi++ )
			{
				
				//v3
				//var vid : int = ByteArrayUtil.readUnsignedByteOrShort(ba);
				///CONFIG::ASSERT {
				//	ASSERT (vid == vbs.variableNameId , "error");
				///}

				var vbs : VariableBinStruct = _cbs.variableArray[vi];
				var value : Object = getVariableBinData(vbs , ba);
				
				DBG_TRACE("  var " + s_stringPool[vbs.variableNameId] + ": "+ value);
			}
		}
		
		public static function xmlDebinarize(ba : ByteArray) : void 
		{
			s_stringPool = new Vector.<String>;
			s_classPool = new Vector.<ClassBinStruct>();
			
			//trace(ba.endian);
			
			if (readFileHead(ba))
			{
				var strPoolLength : int = 	ByteArrayUtil.readUnsignedByteOrShort(ba);
				DBG_TRACE("strPoolLength " + strPoolLength);
				
				for (var i : int = 0 ; i < strPoolLength; i++ )
				{
					var strLeng : int = ByteArrayUtil.readUnsignedByteOrShort(ba);
					s_stringPool.push(ba.readUTFBytes(strLeng));
					
					
				}
				
				//for each (var str : String in s_stringPool)
				//	trace(str);
				
				//var classPoolDataLength : int = ByteArrayUtil.readUnsignedShortOrInt(ba);
				//var destEnd : int = ba.position + classPoolDataLength;
				
				var classPoolLength : int =  ByteArrayUtil.readUnsignedByteOrShort(ba);
				
				DBG_TRACE("classPoolLength " + classPoolLength);
				
				for (i  = 0 ; i < classPoolLength; i++ )
				{
					var _cbs: ClassBinStruct = new ClassBinStruct();
					s_classPool.push(_cbs);
					_cbs.classNameId = ByteArrayUtil.readUnsignedByteOrShort(ba);
					_cbs.variableNum = ByteArrayUtil.readUnsignedByteOrShort(ba);
					
					DBG_TRACE("find class " + s_stringPool[_cbs.classNameId] , "variableNum " + _cbs.variableNum);
					for (var vi : int = 0 ; vi < _cbs.variableNum; vi++ )
					{
						var vbs : VariableBinStruct = new VariableBinStruct();
						vbs.variableNameId = ByteArrayUtil.readUnsignedByteOrShort(ba);
						vbs.type = ba.readByte();
						
						if (vbs.type == VariableBinStruct.TYPE_INSTANCE_UID_INLINE || vbs.type == VariableBinStruct.TYPE_INSTANCE_UID)
							vbs.inlineClassId = ByteArrayUtil.readUnsignedByteOrShort(ba);
						_cbs.variableArray.push(vbs);
						
						if (vbs.type == VariableBinStruct.TYPE_INSTANCE_UID_INLINE)
							DBG_TRACE("var  " + vi + ": " +  s_stringPool[vbs.variableNameId] , "type " + vbs.type + " inline " + s_stringPool[s_classPool[vbs.inlineClassId].classNameId]);
						else if (vbs.type == VariableBinStruct.TYPE_INSTANCE_UID)
							DBG_TRACE("var  " + vi + ": " +  s_stringPool[vbs.variableNameId] , "type " + vbs.type + " class type " + s_stringPool[s_classPool[vbs.inlineClassId].classNameId]);
						else
							DBG_TRACE("var  " + vi + ": " +  s_stringPool[vbs.variableNameId] , "type " + vbs.type);
					}					
				}
				//ASSERT(destEnd == ba.position , "error");
				
				var classInstanceLength : int =  ByteArrayUtil.readUnsignedByteOrShort(ba);
				DBG_TRACE("classInstanceLength " + classInstanceLength);
				for (i  = 0 ; i < classInstanceLength; i++ )
				{
					var classLength : int = ByteArrayUtil.readUnsignedByteOrShort(ba );
					var pos : int = ba.position;
					xmlClassDebinarize(ba);
					
					CONFIG::ASSERT {
						ASSERT(ba.position == pos + classLength , "error file");
					}
				}
				
				
			}
			
			s_stringPool = null;
			s_classPool = null;
			s_outPutBuffer = null;
		}
	}
}

class VariableBinStruct {
	
	public static const TYPE_INT_S8 : int = 1;
	public static const TYPE_INT_S16 : int = 2;
	public static const TYPE_INT_S32 : int = 3;
	public static const TYPE_INT_S8_16 : int = 4;
	public static const TYPE_INT_S8_16_32 : int = 5;
	public static const TYPE_INT_S16_32 : int = 6;
	
	
	public static const TYPE_UINT_U8 : int = 11;
	public static const TYPE_UINT_U16 : int = 12;
	public static const TYPE_UINT_U32 : int = 13;
	public static const TYPE_UINT_U8_16 : int = 14;
	public static const TYPE_UINT_U8_16_32 : int = 15;
	public static const TYPE_UINT_U16_32 : int = 16;
	
	public static const TYPE_NUMBER_F32 : int = 21;
	public static const TYPE_NUMBER_D64 : int = 22;
	
	public static const TYPE_STRING_ID : int = 31;
	
	public static const TYPE_INSTANCE_UID : int = 41;
	public static const TYPE_INSTANCE_UID_INLINE : int = 42;

	public var variableNameId : int; //id in String pool;
	public var type : int;
	public var inlineClassId : int;
	
}

class ClassBinStruct
{
	public var classNameId : int; //id in String pool;
	public var variableNum : int;
	public var variableArray : Vector.<VariableBinStruct> = new Vector.<VariableBinStruct>();
	
	public function dispose() : void
	{
		if (variableArray)
		{	
			variableArray.length = 0;
			variableArray = null;
		}
	}
	
}







