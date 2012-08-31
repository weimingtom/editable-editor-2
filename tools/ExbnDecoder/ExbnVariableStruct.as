package ExbnDecoder 
{
	/**
	 * ...
	 * @author blueshell
	 */
	public class ExbnVariableStruct
	{
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

		public var variableName : String; //id in String pool;
		public var type : int;
		//public var inlineClassId : int;
	
		public function ExbnVariableStruct() 
		{
			
		}
		
	}

}