package ClassInstance 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author blueshell
	 */
	public class ByteArrayUtil
	{
		
		public static function readByteOrShort(ba : ByteArray) : int
		{
			var value : int = ba.readByte();
			if ((value & 0xFF) != 0xFF)
				return value;
			else
				return ba.readShort();
			
		}
		
		public static function readShortOrInt(ba : ByteArray) : int
		{
			var value : int = ba.readShort();
			if ((value & 0xFFFF) != 0xFFFF)
				return value;
			else
				return ba.readInt();
		}
		
		public static function readByteOrShortOrInt(ba : ByteArray) : int
		{
			var value : int = ba.readByte();
			if ((value & 0xFF) != 0xFF)
				return value;
			else
				return readShortOrInt(ba);
		}
		
		
		public static function readUnsignedByteOrShort(ba : ByteArray) : uint
		{
			var value : uint = ba.readUnsignedByte();
			if (value != 0xFF)
				return value;
			else
				return ba.readUnsignedShort();
			
		}
		
		public static function readUnsignedShortOrInt(ba : ByteArray) : uint
		{
			var value : uint = ba.readUnsignedShort();
			if (value != 0xFFFF)
				return value;
			else
				return ba.readUnsignedInt();
		}
		
		public static function readUnsignedByteOrShortOrInt(ba : ByteArray) : uint
		{
			var value : uint = ba.readUnsignedByte();
			if (value != 0xFF)
				return value;
			else
				return readUnsignedShortOrInt(ba);
		}
		

		public static function writeUnsignedByteOrShort(ba : ByteArray , ushort : uint) : void
		{
			if (ushort >= 0xFF)
			{	
				ba.writeByte(0xFF);
				ba.writeShort(ushort);
				
				CONFIG::ASSERT {
					ASSERT(ushort < 0xFFFF , "error");
				}
			}
			else
			{
				ba.writeByte((ushort & 0xFF) );
			}
		}
		
		public static function writeUnsignedByteOrShortOrInt(ba : ByteArray , ushort : uint) : void
		{
			if (ushort >= 0xFF)
			{	
				ba.writeByte(0xFF);
				writeUnsignedShortOrInt(ba , ushort);
			}
			else
			{
				ba.writeByte((ushort & 0xFF) );
			}
		}

		public static function writeUnsignedShortOrInt(ba : ByteArray , ushort : uint) : void
		{
			if (ushort >= 0xFFFF)
			{	
				ba.writeShort(0xFFFF);
				ba.writeInt(ushort);
			}
			else
			{
				ba.writeShort( ushort & 0xFFFF );
			}
		}
		
		
		
		public static function writeByteOrShort(ba : ByteArray , ushort : int) : void
		{
			if (ushort > 0x7F || ushort < -128 || ushort == -1)
			{	
				ba.writeByte(0xFF);
				ba.writeShort(ushort);
				
				CONFIG::ASSERT {
					ASSERT( ushort <= 0x7FFF && ushort >0 -0x8000  , "error");
				}
			}
			else
			{
				ba.writeByte((ushort & 0xFF) );
			}
		}
		
		public static function writeByteOrShortOrInt(ba : ByteArray , ushort : int) : void
		{
			if (ushort > 0x7F || ushort < -128 || ushort == -1)
			{	
				ba.writeByte(0xFF);
				writeShortOrInt(ba , ushort);
			}
			else
			{
				ba.writeByte((ushort & 0xFF) );
			}
		}

		public static function writeShortOrInt(ba : ByteArray , ushort : int) : void
		{
			if (ushort > 0x7FFF || ushort < -0x8000 || ushort == -1)
			{	
				ba.writeShort(0xFFFF);
				ba.writeInt(ushort);
			}
			else
			{
				ba.writeShort( ushort & 0xFFFF );
			}
		}


	}
}