package ExbnDecoder
{
	import ExbnDecoder.*;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author blueshell
	 */
	dynamic public class ExbnClassDynamic extends ExbnClassBase
	{
		
		protected var m_cs : ExbnClassStruct;
		
		public function ExbnClassDynamic(a_instanceUID : uint , a_cs : ExbnClassStruct) 
		{
			super(a_instanceUID);
			m_cs = a_cs;
		}
		
		
		protected static function getVariableBinData(vbs : ExbnVariableStruct , ba : ByteArray , a_env : ExbnEnv) : Object
		{
			var ret : Object;
			switch (vbs.type)
			{
				case ExbnVariableStruct.TYPE_INT_S8 : ret = ba.readByte(); break;
				case ExbnVariableStruct.TYPE_INT_S16 : ret = ba.readShort(); break;
				case ExbnVariableStruct.TYPE_INT_S32 : ret = ba.readInt(); break;
				case ExbnVariableStruct.TYPE_INT_S8_16 : ret = ByteArrayUtil.readByteOrShort(ba); break;
				case ExbnVariableStruct.TYPE_INT_S8_16_32 :  ret = ByteArrayUtil.readByteOrShortOrInt(ba); break;
				case ExbnVariableStruct.TYPE_INT_S16_32 :  ret = ByteArrayUtil.readShortOrInt(ba); break;


				case ExbnVariableStruct.TYPE_UINT_U8 : ret = ba.readUnsignedByte(); break;
				case ExbnVariableStruct.TYPE_UINT_U16 : ret = ba.readUnsignedShort(); break;
				case ExbnVariableStruct.TYPE_UINT_U32 : ret = ba.readUnsignedInt(); break;
				case ExbnVariableStruct.TYPE_UINT_U8_16 : ret = ByteArrayUtil.readUnsignedByteOrShort(ba); break;
				case ExbnVariableStruct.TYPE_UINT_U8_16_32 : ret = ByteArrayUtil.readUnsignedByteOrShortOrInt(ba); break;
				case ExbnVariableStruct.TYPE_UINT_U16_32 : ret = ByteArrayUtil.readUnsignedShortOrInt(ba); break;

				case ExbnVariableStruct.TYPE_NUMBER_F32 : ret = ba.readFloat() break;
				case ExbnVariableStruct.TYPE_NUMBER_D64 : ret = ba.readDouble(); break;

				case ExbnVariableStruct.TYPE_STRING_ID : ret = a_env.getString(ByteArrayUtil.readUnsignedByteOrShort(ba)); break;

				
					CONDIF::ASSERT {
						ASSERT(false , "WTF");
					}
					
				break;
				case ExbnVariableStruct.TYPE_INSTANCE_UID :
					ret = a_env.getClassInstance(ba.readUnsignedInt()); 
				break;
				case ExbnVariableStruct.TYPE_INSTANCE_UID_INLINE : 
					CONFIG::ASSERT {
						ASSERT(false , "WTF");
					}
				default:
					CONFIG::ASSERT
					{
						ASSERT(false, "error param " + vbs.type);
					}
			}
			
			return ret;
		}
		
		public function getClassName() : String
		{
			if (m_cs)
				return m_cs.className;
			else
				return null;
		}
		
		public override function decode(ba : ByteArray , a_env : ExbnEnv) : void
		{
			for (var vi : int = 0 ; vi < m_cs.variableArray.length; vi++ )
			{
				var vbs : ExbnVariableStruct = m_cs.variableArray[vi];
				var value : Object = getVariableBinData(vbs , ba , a_env);
				
				this[vbs.variableName] = value;
				
				CONFIG::DEBUG {
					trace("  var " + vbs.variableName + " = "+ value);
				}
			}
		}
		
		public override function dispose():void
		{
			m_cs = null;
		}
		
		public function toString() : String 
		{
			if (m_cs)
				return  "[object ExbnClassDynamic<" + m_cs.className  +">]";
			else
				return "[object ExbnClassDynamic<" + null  +">]";
		}
		
	}

}