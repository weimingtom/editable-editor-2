package ExbnDecoder 
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ExbnEnv
	{
		public var time : Number;
		public var version :  int;
		
		//private var m_stringPool : Vector.<String>;
		//private var m_classPool : Vector.<ExbnClassStruct>;
		private var m_stringPool : Array = new Array();
		private var m_classPool : Array = new Array();
		private var m_classInstancePool : Dictionary = new Dictionary();
		
		public static var createFunction : Function;
		public static var endFunction : Function;
		
		public static function readFileHead(ba : ByteArray , a_ExbnEnv : ExbnEnv) : Boolean 
		{
			
			if (ba.readByte() == 'e'.charCodeAt(0)
			&& ba.readByte() == 'x'.charCodeAt(0)
			&& ba.readByte() == 'b'.charCodeAt(0)
			&& ba.readByte() == 'n'.charCodeAt(0)
			&& ba.readByte() == 1
			)
			{
				var time : Number = ba.readUnsignedInt() + 0x13770000000;
				//DBG_TRACE("create at time" + new Date(time));
				if (a_ExbnEnv)
					a_ExbnEnv.time = time;
				
				var version : int = ba.readShort();
				if (a_ExbnEnv)
					a_ExbnEnv.version = version;
				//DBG_TRACE("File bin version: " + version);	
			
				//if ( version != Version.version)
				//{
				//	ASSERT(false , "unpair config version and file version");
				//	return false;
				//}
				
				
				return true;
			}
			else
				return false;
		
		}
		
		private static var s_classInstancePoolResident : Dictionary;
		public static function addResidentClassInstance(ecb : ExbnClassBase) : void
		{
			if (ecb)
			{
				if (!s_classInstancePoolResident)
					s_classInstancePoolResident = new Dictionary();
				
				if (s_classInstancePoolResident[ecb.instanceUID])
				{
					CONFIG::ASSERT {
						ASSERT(s_classInstancePoolResident[ecb.instanceUID] == ecb , "error duplicate ResidentClassInstance " + ecb.instanceUID)
					}
				}
				else
					s_classInstancePoolResident[ecb.instanceUID] = ecb;
			}
		}
		
		public static function getResidentClassInstance(a_instanceUID : uint) : ExbnClassBase
		{
			
			CONFIG::ASSERT {
				ASSERT(s_classInstancePoolResident && s_classInstancePoolResident[a_instanceUID] != null , "error a_instanceUID " + a_instanceUID);
			}
			
			if (s_classInstancePoolResident)
				return ExbnClassBase(s_classInstancePoolResident[a_instanceUID]);
			else
			{
				CONFIG::ASSERT {
					ASSERT( false , "get Resident instanceis null uid =" + a_instanceUID);
				}
				return null;
			}
		}
		public static function decode(ba : ByteArray) : void
		{
			if (createFunction == null)
			{
				CONFIG::ASSERT {
					ASSERT(createFunction == null , "plz use ExbnClassDefinitionCreator.createExbnClassDefinition or ExbnClassDynamicCreator.createExbnClassDynamic");
				}
				return;
			}
			
			
			var _env : ExbnEnv = new ExbnEnv();
			if (readFileHead(ba , _env))
			{
				//////////////////////////////////////////////////////////////
				var strPoolLength : int = 	ByteArrayUtil.readUnsignedByteOrShort(ba);
				CONFIG::DEBUG {
					trace("strPoolLength " + strPoolLength);
				}
				
				for (var i : int = 0 ; i < strPoolLength; i++ )
				{
					var strLeng : int = ByteArrayUtil.readUnsignedByteOrShort(ba);
					_env.m_stringPool.push(ba.readUTFBytes(strLeng));
					
					
				}
				CONFIG::DEBUG {
					for each (var str : String in _env.m_stringPool)
						trace(str);
				}
				
				//////////////////////////////////////////////////////////////
				var classPoolLength : int =  ByteArrayUtil.readUnsignedByteOrShort(ba);
				CONFIG::DEBUG {
					trace("classPoolLength " + classPoolLength);
				}
				var startPos : int = ba.position;

				CONFIG::DEBUG {
					trace("class pool pass one");
				}
				ba.position = startPos;
				for (i  = 0 ; i < classPoolLength; i++ )
				{
					if (!_env.m_classPool[i])
					{	
						_env.m_classPool[i] = new ExbnClassStruct();
					}
						
					var _cbs: ExbnClassStruct;
					var classNameId : int;
					var variableNum : int;
					
					_cbs = _env.m_classPool[i];
					classNameId = ByteArrayUtil.readUnsignedByteOrShort(ba);
					variableNum =  ByteArrayUtil.readUnsignedByteOrShort(ba);
					
					_cbs.className = _env.m_stringPool[classNameId];
					_cbs.variableArray.length = variableNum;
					CONFIG::DEBUG {
						trace("find class " + _cbs.className);
					}
					
					for (var vi : int = 0 ; vi < variableNum; vi++ )
					{
						if (!_cbs.variableArray[vi])
							_cbs.variableArray[vi] =  new ExbnVariableStruct();
						
						var vbs : ExbnVariableStruct;
						var variableNameId : int;
						var variableType : int;
						var inlineClassId : int;
						
						variableNameId = ByteArrayUtil.readUnsignedByteOrShort(ba);
						variableType = ba.readByte();
						
						vbs = _cbs.variableArray[vi] ;
						vbs.variableName = _env.m_stringPool[variableNameId];
						vbs.type = variableType;
						
						
						if (variableType == ExbnVariableStruct.TYPE_INSTANCE_UID_INLINE  || variableType == ExbnVariableStruct.TYPE_INSTANCE_UID)
							inlineClassId = ByteArrayUtil.readUnsignedByteOrShort(ba);
						
						CONFIG::DEBUG {
						if (variableType == ExbnVariableStruct.TYPE_INSTANCE_UID_INLINE)
							trace("    var " + vi + ": " +  vbs.variableName , "type " + vbs.type + " inline " + (_env.m_classPool[inlineClassId] ? _env.m_classPool[inlineClassId].className : "not prepair") );
						else if (variableType == ExbnVariableStruct.TYPE_INSTANCE_UID_INLINE)
							trace("    var " + vi + ": " +  vbs.variableName , "type " + vbs.type + " class type " + (_env.m_classPool[inlineClassId] ? _env.m_classPool[inlineClassId].className : "not prepair") );
						
						else
							trace("    var " + vi + ": " +  vbs.variableName , "type " + vbs.type);
						}
					}					
				}

				CONFIG::DEBUG {
					trace("class pool pass two");
				}
				ba.position = startPos;
				
				for (i  = 0 ; i < classPoolLength; i++ )
				{
					
					
					_cbs = _env.m_classPool[i];
					classNameId = ByteArrayUtil.readUnsignedByteOrShort(ba);
					variableNum =  ByteArrayUtil.readUnsignedByteOrShort(ba);
					CONFIG::DEBUG {
						trace(_cbs.className + "expanding...");
					}
					for (vi  = 0 ; vi < variableNum; vi++ )
					{
					
						variableNameId = ByteArrayUtil.readUnsignedByteOrShort(ba);
						variableType = ba.readByte();
						if (variableType == ExbnVariableStruct.TYPE_INSTANCE_UID_INLINE  || variableType == ExbnVariableStruct.TYPE_INSTANCE_UID)
							inlineClassId = ByteArrayUtil.readUnsignedByteOrShort(ba);
						
						vbs = _cbs.variableArray[vi] ;
							
						if (vbs.type ==  ExbnVariableStruct.TYPE_INSTANCE_UID_INLINE)
						{
							vbs.type = ExbnVariableStruct(ExbnClassStruct(_env.m_classPool[inlineClassId]).variableArray[0]).type;
							
							CONFIG::DEBUG {
								trace("    var " + vi + ": expand to" +  vbs.variableName , "type " + vbs.type);
							}
						}
						
					}		
					
					
				}
				
				
					
				//////////////////////////////////////////////////////////////
				


				var classInstanceLength : int =  ByteArrayUtil.readUnsignedByteOrShort(ba);
				CONFIG::DEBUG {
					trace("classInstanceLength " + classInstanceLength);
				}
				startPos = ba.position;
					
				
				CONFIG::DEBUG {
					trace("class instance pass one");
				}
				var _classInstanceSeq : Array = new Array(classInstanceLength);
				
				for (i  = 0 ; i < classInstanceLength; i++ )
				{
					var classLength : int;
					classLength = ByteArrayUtil.readUnsignedByteOrShort(ba );
					var posEnd : int = ba.position + classLength;
					
					//xmlClassDebinarize(ba);
					var clsId : int; 
					var instanceUID : uint;
					
					clsId =  ByteArrayUtil.readUnsignedByteOrShort(ba);
					instanceUID = ba.readUnsignedInt();
					var ecb : ExbnClassBase ;
					if (createFunction != null)
					{	
						ecb = createFunction(_env.m_classPool[clsId] , instanceUID);
						
						CONFIG::ASSERT {
							ASSERT(ecb != null , "error");
						}
					}
					
					
					_env.m_classInstancePool[instanceUID] = ecb;
					_classInstanceSeq[i] = ecb;
					
					ba.position = posEnd;
					 
					CONFIG::ASSERT {
						ASSERT(ba.position == posEnd , "error file");
					}
				}
				
				
				
				CONFIG::DEBUG {
					trace("class instance pass two");
				}
				ba.position = startPos;
				for (i  = 0 ; i < classInstanceLength; i++ )
				{
					classLength = ByteArrayUtil.readUnsignedByteOrShort(ba );
					posEnd = ba.position + classLength;
					
					
					clsId =  ByteArrayUtil.readUnsignedByteOrShort(ba);
					CONFIG::DEBUG {
						trace("class " + _env.m_classPool[clsId].className);
					}
					instanceUID = ba.readUnsignedInt();
					ecb = _env.m_classInstancePool[instanceUID];
					ecb.decode(ba , _env);
					 
					CONFIG::ASSERT {
						ASSERT(ba.position == posEnd , "error file");
					}
				}
				
				
				
			} else {
				
				CONFIG::ASSERT {
					ASSERT(false , "not a exbn file");
				}
			}
			
			
			
			
			if (_env)
			{
				if (endFunction != null)
					endFunction(_env.m_classInstancePool , _classInstanceSeq);
				
				_env.dispose();
				_env = null;
			}
			
			_classInstanceSeq = null;
		}
		
		
		public function ExbnEnv() 
		{
			
		}
		
		public function dispose() : void 
		{
			m_stringPool = null;
			m_classPool = null;
			m_classInstancePool = null;
			
		}
		public function getClassInstance(a_instanceUID : uint) : ExbnClassBase
		{
			if (a_instanceUID == 0)
				return null;
			else if (a_instanceUID > 20000)
			{
				CONFIG::ASSERT {
					ASSERT(m_classInstancePool[a_instanceUID] != null , "error a_instanceUID " + a_instanceUID);
				}
				
				return ExbnClassBase(m_classInstancePool[a_instanceUID]);
			}
			else
			{
				
				CONFIG::ASSERT {
					ASSERT(s_classInstancePoolResident && s_classInstancePoolResident[a_instanceUID] != null , "error a_instanceUID " + a_instanceUID);
				}
				
				if (s_classInstancePoolResident)
					return ExbnClassBase(s_classInstancePoolResident[a_instanceUID]);
				else
				{
					CONFIG::ASSERT {
						ASSERT( false , "get Resident instanceis null uid =" + a_instanceUID);
					}
					return null;
				}
			}
		}
		
		public function getString(a_StringID : uint) : String
		{
			CONFIG::ASSERT {
				ASSERT(a_StringID < m_stringPool.length , "error");
			}
			return m_stringPool[a_StringID];
		}
	}

}