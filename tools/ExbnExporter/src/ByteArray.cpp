#include "ByteArray.h"

#include "stdio.h"

#define ByteArray_ALIGN_LENGTH 128//512

#ifndef bswap_16
#define bswap_16 bswap_16_impl
inline unsigned short bswap_16_impl(unsigned short X)
{
	return ((((X)&0xFF) << 8) | (((X)&0xFF00) >> 8));
}
#endif

#ifndef bswap_32
#define bswap_32 bswap_32_impl
inline unsigned int bswap_32_impl(unsigned int X)
{
	return ( (((X)&0x000000FF)<<24) | (((X)&0xFF000000) >> 24) | (((X)&0x0000FF00) << 8) | (((X) &0x00FF0000) >> 8));
}
#endif


//inline unsigned short byteswap(unsigned short  num) {return bswap_16(num);}
//inline short byteswap(short  num) {return bswap_16(num);}
//inline unsigned int byteswap(unsigned int  num) {return bswap_32(num);}
//inline int byteswap(int num) {return bswap_32(num);}

void ByteArray::FileToBuffer(FILE* fp)
{

	ASSERT(m_pData == NULL , _T("re read??"));
	unsigned int length = 0;
	if (fp)
	{
		//#define USE_SETVBUF_FOR_FILE
		fseek(fp,0,SEEK_END);
		length = ftell(fp);
		fseek(fp,0,SEEK_SET);


		int initBufferLength = (length + ByteArray_ALIGN_LENGTH - 1) & ~(ByteArray_ALIGN_LENGTH -1) ;
		m_pData = (unsigned char *)MALLOC( initBufferLength );
		ASSERT(m_pData , _T("error malloc memery"));
		memset(m_pData + length , 0 ,initBufferLength - length ); //set extra data 0

		if (length > 0)
		{
#ifdef USE_SETVBUF_FOR_FILE
			ASSERT((initBufferLength & 3) == 0 , _T("should aglin!!") );
			DEBUG_LINE(int ret = )
				setvbuf(fp, (char *)m_pData ,_IOFBF ,initBufferLength);
			ASSERT((ret == 0) ,_T("error set buffer!"));
			int tmp;
			fread(&tmp, 1,1,fp ); //first read
#else
			fread(m_pData,1,(length) ,fp);
#endif			
		}
	

		m_bufferLength = initBufferLength;
		m_length = length;

		fclose(fp);
		fp = NULL;
	}
}


ByteArray::ByteArray(const wchar_t* url)
: endian(PLATFROM_DEFAULT_ENDIAN),m_pData(NULL),m_position(0),m_length(0),m_bufferLength(0)
{
	ASSERT(url , _T("url = NULL"));
	ASSERT(wcslen(url) , _T("url is empty"));


	FILE* fp ;
	_WFOPEN(fp , url, L"rb");

	ASSERT(fp , _T("url acess error"));

	FileToBuffer(fp);
}

ByteArray::ByteArray(const char* url)
: endian(PLATFROM_DEFAULT_ENDIAN),m_pData(NULL),m_position(0),m_length(0),m_bufferLength(0)
{
	ASSERT(url , _T("url = NULL"));
	ASSERT(strlen(url) , _T("url is empty"));


	FILE* fp ;
	FOPEN(fp , url, ("rb"));

	ASSERT(fp , _T("url acess error"));

	FileToBuffer(fp);
}

ByteArray::ByteArray(const ByteArray& src)
: endian(src.endian),
m_pData(NULL),
m_position(0),
m_length(src.m_length),
m_bufferLength(src.m_bufferLength)
{
    m_pData = (unsigned char *)MALLOC(m_bufferLength);
    memset(m_pData , 0 ,m_bufferLength );
    MEMCPY_S(m_pData,m_length,src.m_pData,m_length);
	ASSERT(m_pData , _T("error malloc memery"));
}


ByteArray::ByteArray()
: endian(PLATFROM_DEFAULT_ENDIAN),m_pData(NULL),m_position(0),m_length(0),m_bufferLength(0)
{
	ASSERT(sizeof(float) == 4 && sizeof(double) == 8, _T("spec platform!!"));

	m_pData = (unsigned char *)MALLOC(ByteArray_ALIGN_LENGTH);
	memset(m_pData , 0 ,ByteArray_ALIGN_LENGTH );
	m_bufferLength = ByteArray_ALIGN_LENGTH;
	ASSERT(m_pData , _T("error malloc memery"));
}

ByteArray::ByteArray( unsigned int initBufferLength )
: endian(PLATFROM_DEFAULT_ENDIAN),m_pData(NULL),m_position(0),m_length(0),m_bufferLength(0)
{
	ASSERT(sizeof(float) == 4 && sizeof(double) == 8, _T("spec platform!!"));
	initBufferLength = (initBufferLength + ByteArray_ALIGN_LENGTH - 1) & ~(ByteArray_ALIGN_LENGTH -1) ;
	m_pData = (unsigned char *)MALLOC( initBufferLength );
	memset(m_pData , 0 ,initBufferLength );
	m_bufferLength = initBufferLength;
	ASSERT(m_pData , _T("error malloc memery"));
}
ByteArray::~ByteArray() 
{
	clear();
}

#ifdef ByteArray_DYNAMIC_LENGTH
void ByteArray::checkLength(unsigned int requireLength)
{
	if (m_position + requireLength > m_bufferLength)
	{
		//m_pData = (unsigned char *)REALLOC_WITH_FREE(m_pData , m_bufferLength + ByteArray_ALIGN_LENGTH);
		unsigned int newLength = (m_position + requireLength + ByteArray_ALIGN_LENGTH - 1) & ~(ByteArray_ALIGN_LENGTH -1);
		m_pData = (unsigned char *)REALLOC_WITH_FREE(m_pData , newLength );
		ASSERT(m_pData , _T("error realloc memery")); 
		memset((char*)m_pData + m_bufferLength , 0 ,newLength - m_bufferLength );
		m_bufferLength = newLength;
		
	}
	ASSERT( m_position + requireLength <= m_bufferLength , _T("error m_position")); 
	
}
#endif

void ByteArray::clear()
{
	if (m_pData)
	{
		FREE(m_pData);
		m_pData = NULL;
	}
	m_length = m_position = 0;
}

//濞揿懘娅庣€涙濡弫镓矋闀勫嫬鍞寸€圭櫢绱濋猕璺虹杀 length 閸?m_position 鐏炵偞钪囧惃缂冾喕璐?0閵?
//}


void ByteArray::compress(Compress algorithm) 
{
	(void)(algorithm);
	//TODO

}

void ByteArray::uncompress(Compress algorithm) 
{
	(void)(algorithm);
	//TODO

}


//娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙х敨缁楋箑浣涢曦鍕搂阏轰紴钪?
signed char ByteArray::readByte()
{
	ASSERT(m_position < m_length , _T("error"));
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(1);
	if (m_position == m_length)
		m_length++;
	return (signed char)m_pData[m_position++] ;
#else
	if (m_position < m_length)
		return (char)(m_pData[m_position++] );
	else
		return 0;
#endif

}


u32 ByteArray::readBytes(unsigned char * bytes  , int charBufferLength , unsigned int offset, unsigned int length )
{
	if (!length)
		return 0;
	ASSERT(bytes , _T("NULL data"));
#ifdef _DEBUG
	if (m_position + length > m_length)
	{
		DBG_TRACE_PLUS(DBG_DEF::ASSERT_ERROR , _T("m_position = %d,m_length = %d,length = %d") , m_position , m_length , length );

	}
#endif

	ASSERT(m_position + length <= m_length  , _T("error read occor stream end"));
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(length);
	if (m_length < m_position + length)
		m_length = m_position + length;
#endif
	
	RELEASE_LINE(UNREFERENCED_PARAMETER(charBufferLength));
	MEMCPY_S( bytes + offset 
		, charBufferLength - offset
		, this->getData() + m_position , length );
	m_position += length;
	
	return length;
}

void ByteArray::writeBytes(const unsigned char * bytes, unsigned int offset, unsigned int length )
{
	if (!length)
		return;
	ASSERT(bytes , _T("NULL data"));
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(length);
	if (m_length < m_position + length)
		m_length = m_position + length;
#else
	ASSERT(m_position + length <= m_length  , _T("error read occor stream end"));
#endif

	MEMCPY_S( this->getData() + m_position , m_bufferLength - m_position , bytes + offset , length );
	m_position += length;
}



//娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙︾娑?IEEE 754 閸椤睑绨挎惔锔肩焊64 娴ｅ稄绾уù顔惧仯閺?
double ByteArray::readDouble()
{
	ASSERT(sizeof(double) == 8 , _T("spec platform!!"));

	ASSERT(m_position + 8 <= m_length  , _T("error read occor stream end"));
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(8);
	if (m_length < m_position + 8)
		m_length = m_position + 8;
#endif

	unsigned char * p = m_pData + m_position;
	long long rt = 0;
	if (endian == PLATFROM_DEFAULT_ENDIAN)
	{
		//unsigned char * p2 = ((unsigned char*)&rt);
		//MEMCPY_S(p2,sizeof(long long),p,8);

		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		//*(p2++) = *(p++);
		m_position+=8;
		return *((double*)(p));
	}
	else //(endian == ByteArray::ENUM_BIG_ENDIAN)
	{
		unsigned char * p2 = ((unsigned char*)&rt) + 7;
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		*(p2--) = *(p++);
		m_position+=8;
		return *(double*)(void*)&rt;
	}
}




//	readMultiByte(length:uint, charSet:String) 
//娴ｈ法鏁ら幐锲х暰闀勫嫬鐡х粭锕傛肠娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙ㄥ瘹鐎规岸鏄垫惔锔炬畱婢舵癌鐡ч蒙鍌氱搂缁楋缚瑕嗛妴?

//娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙︾娑擃亜鐢粭锕€浣涢曦?16 娴ｅ秵鏆ｉ弫鑸偓?
signed short ByteArray::readShort()
{
	ASSERT(m_position + 2 <= m_length  , _T("error read occor stream end"));
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(2);
	if (m_length < m_position + 2)
		m_length = m_position + 2;
#endif
	unsigned char * p = m_pData + m_position;
	if (endian == PLATFROM_DEFAULT_ENDIAN)
	{
		//short rt = *((short*)(p)); //p[0] | (p[1]<<8);
		m_position+=2;
		return *((short*)(p));
	}
	else //(endian == ByteArray::ENUM_BIG_ENDIAN)
	{
		unsigned short rt = bswap_16(*((unsigned short*)(p)));
		m_position+=2;
		return (signed short)rt;
	}
}

//娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙︾娑擃亜鐢粭锕€浣涢曦?32 娴ｅ秵鏆ｉ弫鑸偓?
signed int ByteArray::readInt() 
{
	ASSERT(m_position + 4 <= m_length  , _T("error read occor stream end"));
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(4);
	if (m_length < m_position + 4)
		m_length = m_position + 4;
#endif
	unsigned char * p = m_pData + m_position;
	if (endian == PLATFROM_DEFAULT_ENDIAN)
	{
		//int rt = *((int*)(p)) ;//p[0] | (p[1]<<8) | (p[2]<<16) | (p[3]<<24) ;
		m_position+=4;
		return *((int*)(p));
	}
	else //(endian == ByteArray::ENUM_BIG_ENDIAN)
	{

		unsigned int rt = bswap_32(*((unsigned int*)(p)));
		m_position+=4;
		return (signed int)rt;
	}
}






//readUTF():String
//娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙︾娑?UTF-8 鐎涙顑佹稉灞傗偓?

//readUTFBytes(length:uint):String
//娴犲骸鐡ч蒙鍌涚ウ娑擃叀顕伴崣镙︾娑擃亚鏁?length 閸椤倹鏆熼幐锲х暰闀?UTF-8 鐎涙濡惔蹇揿灙阌涘苯鑻熸潻鏂挎礀娑撯偓娑擃亜鐡х粭锔胯閵?


//閸愭い鍙嗙敮鍐ㄧ毜阈剧钪?
void ByteArray::writeBoolean(bool value)
{
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(1);
	if (m_position == m_length)
		m_length++;
	m_pData[m_position++] = value;
#else
	ASSERT(m_position < m_length , _T("error"));
	m_pData[m_position++] = value;
#endif
}

//閸︺刿鐡ч蒙鍌涚ウ娑擃厼鍟挞岗銉ょ娑擃亜鐡ч蒙浼炩偓?
void ByteArray::writeByte(unsigned char value) 
{
	
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(1);
	if (m_position == m_length)
		m_length++;
	m_pData[m_position++] = value;
#else
	ASSERT(m_position < m_length , _T("error"));
	if (m_position < m_length)
		m_pData[m_position++] = value;
#endif
}

//writeBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void
//鐏忓棙瀵氱€规癌鐡ч蒙鍌涙殶缂?bytes阌涘牐鎹ｆ慨瀚斾焊缁夊鍣烘稉?bytes阌涘奔绮?0 瀵偓婵娈戠槐銏犵穿阌涘鑵戦岽锻儓 length 娑擃亜鐡ч蒙鍌沧畱鐎涙濡惔蹇揿灙閸愭い鍙嗙€涙濡ù骞垛偓?

//閸︺刿鐡ч蒙鍌涚ウ娑擃厼鍟挞岗銉ょ娑?IEEE 754 閸椤睑绨挎惔锔肩焊64 娴ｅ稄绾уù顔惧仯閺佽埇钪?
void ByteArray::writeDouble(double dvalue) 
{
	ASSERT(sizeof(double) == 8 , _T("spec platform!!"));
	
	
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(8);
	if (m_position + 8 > m_length)
		m_length = m_position + 8;
#else
	ASSERT(m_position+8 <= m_length , _T("error"));
#endif
	if (endian == PLATFROM_DEFAULT_ENDIAN)
	{
	//	MEMCPY_S(m_pData , m_bufferLength - m_position , (&dvalue) , 8 );
		*(double*)(m_pData + m_position) = dvalue;
	/*	m_pData[m_position]	= (value)&0xFF;
		m_pData[m_position+1] = (value >> 8)&0xFF;
		m_pData[m_position+2] = (value >> 16)&0xFF;
		m_pData[m_position+3] = (value >> 24)&0xFF;
		m_pData[m_position+4]	= (value >> 32)&0xFF;
		m_pData[m_position+5] = (value >> 40)&0xFF;
		m_pData[m_position+6] = (value >> 48)&0xFF;
		m_pData[m_position+7] = (value >> 56)&0xFF;
	*/
	}
	else //if (endian == ByteArray::ENUM_BIG_ENDIAN)
	{
		long long value = *(long long*)(void*)&dvalue;
		m_pData[m_position]	= (value >> 56)&0xFF;
		m_pData[m_position+1] = (value >> 48)&0xFF;		
		m_pData[m_position+2] = (value >> 40)&0xFF;
		m_pData[m_position+3]	= (value >> 32)&0xFF;
		m_pData[m_position+4]	= (value >> 24)&0xFF;
		m_pData[m_position+5] = (value >> 16)&0xFF;
		m_pData[m_position+6] = (value >> 8)&0xFF;
		m_pData[m_position+7] = (value)&0xFF;
	}
	m_position+=8;
}




//閸︺刿鐡ч蒙鍌涚ウ娑擃厼鍟挞岗銉ょ娑擃亜鐢粭锕€浣涢曦?32 娴ｅ秵鏆ｉ弫鑸偓?
void ByteArray::writeInt(unsigned int value) 
{
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(4);
	if (m_position + 4 >= m_length)
		m_length = m_position + 4;
#else
	ASSERT(m_position+2 <= m_length , _T("error"));
#endif
	if (endian == PLATFROM_DEFAULT_ENDIAN)
	{
		*((int*)(m_pData + m_position)) = value;
	//	m_pData[m_position]	= (value)&0xFF;
	//	m_pData[m_position+1] = (value >> 8)&0xFF;
	//	m_pData[m_position+2] = (value >> 16)&0xFF;
	//	m_pData[m_position+3] = (value >> 24)&0xFF;
	}
	else //if (endian == ByteArray::ENUM_BIG_ENDIAN)
	{

		unsigned int value2 = bswap_32(((unsigned int)(value)));
		*((unsigned int*)(m_pData + m_position)) = value2;

		//m_pData[m_position]	= (value >> 24)&0xFF;
		//m_pData[m_position+1] = (value >> 16)&0xFF;
		//m_pData[m_position+2] = (value >> 8)&0xFF;
		//m_pData[m_position+3] = (value)&0xFF;
	}
	m_position+=4;
}



//writeMultiByte(value:String, charSet:String):void
//娴ｈ法鏁ら幐锲х暰闀勫嫬鐡х粭锕傛肠鐏忓枣顦跨€涙濡€涙顑佹稉鎻掑晸閸忋儱鐡ч蒙鍌涚ウ閵?

//閸︺刿鐡ч蒙鍌涚ウ娑擃厼鍟挞岗銉ょ娑?16 娴ｅ秵鏆ｉ弫鑸偓?
void ByteArray::writeShort(unsigned short value) 
{
#ifdef ByteArray_DYNAMIC_LENGTH
	checkLength(2);
	if (m_position + 2 >= m_length)
		m_length = m_position + 2;
#else
	ASSERT(m_position+2 <= m_length , _T("error"));
#endif

	if (endian == PLATFROM_DEFAULT_ENDIAN)
	{
		*((short*)(m_pData + m_position)) = value;
		//m_pData[m_position] = value&0xFF;
		//m_pData[m_position+1] = (value >> 8)&0xFF;
	}
	else //if (endian == ByteArray::ENUM_BIG_ENDIAN)
	{
		unsigned short value2 = bswap_16(((unsigned short)(value)));
		*((unsigned short*)(m_pData + m_position)) = value2;

	}
	m_position+=2;
}


//ByteArray::writeUTF(value:String):void
//鐏?UTF-8 鐎涙顑佹稉鎻掑晸閸忋儱鐡ч蒙鍌涚ウ閵?


//ByteArray::writeUTFBytes(value:String):void
//鐏?UTF-8 鐎涙顑佹稉鎻掑晸閸忋儱鐡ч蒙鍌涚ウ閵?

void ByteArray::setLength(unsigned int newLength) 
{
	if (newLength < m_length)
	{
		m_length = newLength;
	}
	else if  (newLength > m_length)
	{
		unsigned int newBuffer = (newLength +  ByteArray_ALIGN_LENGTH - 1) & (~(ByteArray_ALIGN_LENGTH - 1));
		if (newLength > m_bufferLength)
		{
			m_pData = (unsigned char*)REALLOC_WITH_FREE(m_pData , newBuffer);
			m_bufferLength = newBuffer;
		}
		ASSERT(m_pData , _T("error realloc memery")); 

		
		m_length = newLength;

	}
}

void ByteArray::solid (void) 
{
	unsigned int neededBufferLength = (m_length +  ByteArray_ALIGN_LENGTH - 1) & (~(ByteArray_ALIGN_LENGTH - 1));
	ASSERT  (neededBufferLength <= m_bufferLength , _T("error length and buffer!!"));
	if (neededBufferLength < m_bufferLength)
	{
		m_pData = (unsigned char*)REALLOC_WITH_FREE( m_pData, neededBufferLength);
		ASSERT(m_pData , _T("error realloc memery"));
	}
}

void ByteArray::save (const char* _Filename) const
{
	FILE* fp ;
	FOPEN(fp , _Filename, "wb" /*_Mode*/);
	ASSERT(fp , _T("url = NULL"));
	fwrite(getData(),1,getLength() ,fp);
	fclose(fp);
}


void ByteArray::save (const wchar_t* _Filename) const
{
	FILE* fp ;
	_WFOPEN(fp , _Filename, L"wb" /*_Mode*/);
	ASSERT(fp , _T("url = NULL"));
	fwrite(getData(),1,getLength() ,fp);
	fclose(fp);
}

void ByteArray::writeMultiByte( const char* c, CharSet::eCharSet /*= CharSet::ISO_8859_1*/ )
{
	writeBytes((unsigned char*)c , 0 , strlen(c));
}

void ByteArray::writeMultiByte( const wchar_t* wc, CharSet::eCharSet /*= CharSet::ISO_8859_1*/ )
{
	char* pc = NULL;
	wcharToChar(wc , &pc , 0);
	writeBytes((unsigned char*)pc , 0 , strlen(pc));
	FREE(pc);
}

unsigned int ByteArray::readUnsignedShortOrInt()
{
	unsigned int ushort  = readUnsignedShort();
	if (ushort != 0xFFFF)
		return ushort;
	else
		return readInt();
}

void ByteArray::writeUnsignedByteOrShort( unsigned short ushort )
{
	if (ushort >= 0xFF)
	{	
		writeByte(0xFF);
		writeShort(ushort);
	}
	else
	{
		writeByte((unsigned char)(ushort & 0xFF) );
	}
}

void ByteArray::writeUnsignedShortOrInt( unsigned int ushort )
{
	if (ushort >= 0xFFFF)
	{	
		writeShort(0xFFFF);
		writeInt(ushort);
	}
	else
	{
		writeShort( (unsigned short)( ushort & 0xFFFF ) );
	}
}

void ByteArray::writeShortOrInt( int ashort )
{
	if (ashort < -32768 || ashort > 0x7FFF || ashort == -1 ) 
	{	
		writeShort(0xFFFF);
		writeInt(ashort);
	}
	else
	{
		writeShort(( unsigned short)( ashort & 0xFFFF ) );
	}
}

int ByteArray::readShortOrInt()
{
	int ashort = readShort();
	if ((ashort & 0xFFFF) != 0xFFFF)
		return (ashort);
	else
		return (readInt());
}

unsigned short ByteArray::readUnsignedByteOrShort()
{
	unsigned char ushort  = readUnsignedByte();
	if (ushort != 0xFF)
		return ushort;
	else
		return readUnsignedShort();
}





void breakable_assert(bool flag, TCHAR* info , const TCHAR* filename , int line ,const TCHAR* funcName )
{
	////UNREFERENCED_PARAMETER(info);
	//UNREFERENCED_PARAMETER(filename);
	//UNREFERENCED_PARAMETER(line);
	//UNREFERENCED_PARAMETER(funcName);

	static int breakLine = 0;
	if (!flag)
	{
		DBG_TRACE_PLUS(DBG_DEF::ASSERT_ERROR , info);
		DBG_TRACE_PLUS(DBG_DEF::ASSERT_ERROR , _T("assert error "_TS)_T(" line %d at func "_TS) , filename , line ,funcName);
		breakLine++; //add break point here!!
		__asm{int 3};
	}
}