#ifndef __BYTEARRAY_H__
#define __BYTEARRAY_H__

#include "tchar.h"
#include <stdlib.h>
#include <string.h>

//#define assertMB(_Expression) ( (!!(_Expression)) || MessageBox(NULL, _T(#_Expression)_T("\nAt file: ")_T(__FILE__)_T("\nAt Func: ") _T(__FUNCTION__) , _T("intenal error"),MB_OK | MB_ICONERROR))
//define ASSERT(flag , info)	{ breakable_assert(((flag) != NULL ), info ,_T(__FILE__) , __LINE__ , _T(__FUNCTION__)) ; assertMB((flag) && (info));} //{if(!(flag && 

void breakable_assert(bool flag, TCHAR* info , const TCHAR* filename , int line ,const TCHAR* funcName );

#define ASSERT(flag , info) {  breakable_assert(((flag) != NULL ), info ,_T(__FILE__) , __LINE__ , _T(__FUNCTION__)) ; }
#define MALLOC malloc
#define FREE free


#ifdef  _UNICODE
#define T_VSPRINTF VSWPRINTF
#define T_SPRINTF   SWPRINTF
#define T_FOPEN	_WFOPEN
#define T_STRCPY _TCSCPY
#define _TS L"%ls"
#define _TSTR() L"%ls"
#else
#define T_VSPRINTF VSPRINTF
#define T_SPRINTF   SPRINTF
#define T_FOPEN FOPEN
#define T_STRCPY STRCPY
#define _TS "%s"
#define _TSTR() "%s"
#endif

#define FOPEN(fp , url , mode)		fopen_s(&(fp) , url , mode)
#define _WFOPEN(fp , url , mode)	_wfopen_s(&(fp) , url , mode)
#define MEMCPY_S(dest,sizeInBytes,src,count )	memcpy_s(dest ,sizeInBytes, src,count)
#define DBG_TRACE_PLUS(f , t , ...)		{_tprintf(t ,__VA_ARGS__); _tprintf(_T("\n"));}
#define DBG_TRACE(t,...)		{_tprintf(t ,__VA_ARGS__); _tprintf(_T("\n"));}
#define REALLOC_WITH_FREE realloc

#ifdef _DEBUG
#define RELEASE_LINE(...)	
#else
#define RELEASE_LINE(...)	__VA_ARGS__
#endif


typedef char		s8;
typedef short		s16;
typedef int			s32;
typedef long long	s64;

typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned int   u32;
typedef unsigned long long u64;

typedef float	f32;
typedef double  f64;

typedef bool	b8;
//#include "Core/Platform/PlatformMacros.h"







class CharSet
{
public:
	enum eCharSet
	{
		ISO_8859_1,
	};
};


class Endian
{
public :
	enum eEndian {
		LITTLE,
		BIG
	};
};

#ifndef PLATFROM_DEFAULT_ENDIAN
#define PLATFROM_DEFAULT_ENDIAN (Endian::LITTLE)
#endif

#define ByteArray_DYNAMIC_LENGTH

class ByteArray
{
public :

	enum Compress {
		ZLIB,
		LZMA
	};
public :
	
	ByteArray();

    explicit ByteArray(const ByteArray& src);
	explicit ByteArray(unsigned int initBufferLength);

	explicit ByteArray(const wchar_t* url);
	explicit ByteArray(const char* url);

	~ByteArray();


	Endian::eEndian endian;

	void clear();
	
 	 	
	void compress(Compress algorithm = ZLIB);
	void uncompress(Compress algorithm = ZLIB);
 
 	 	
	bool inline readBoolean() {return (readByte() != 0);}; 
	
 	 	
	signed char readByte();

	
	inline u32 readBytes(ByteArray &bytes  , unsigned int offset = 0, unsigned int length = 0xFFFFFFF)
	{
		if (length == 0xFFFFFFFF)
			length = bytes.getBytesAvailable();
		ASSERT(offset + length <= bytes.getLength() , _T("End of dest Data") );
		ASSERT(getPosition() + length <= getLength() , _T("End of src Data") );

		return readBytes(bytes.getData() ,bytes.getBytesAvailable() ,offset, length);
	}


	u32 readBytes(unsigned char* bytes ,int charBufferLength  , unsigned int offset = 0, unsigned int length = 0);


	double readDouble();

 	 	
	float inline readFloat() {
		int tmp = readInt();
		return *(float*)((void*)(&(tmp)));

	};


 	 
	signed int readInt();


 	 	
	//	readMultiByte(length:uint, charSet:String) 


 	 	
	signed short readShort();

	
 	 	
	inline unsigned char readUnsignedByte() {return (readByte() & 0xFF);} ;

	
 	 	
	inline unsigned int readUnsignedInt() {return (unsigned int)(readInt());};

 	 	
	inline unsigned short readUnsignedShort() {return (readShort() & 0xFFFF);} ;

	unsigned short readUnsignedByteOrShort();
	unsigned int readUnsignedShortOrInt ();
	int readShortOrInt ();
 	 	
	//readUTF():String

 	 	
	//readUTFBytes(length:uint):String

	 	
 	 	
	void writeBoolean(bool value) ;

 	 	
	void writeByte(unsigned char value)  ;



	


	void writeBytes(const unsigned char* bytes ,  unsigned int offset = 0, unsigned int length = 0);

	void writeBytes(unsigned char* bytes ,  unsigned int offset = 0, unsigned int length = 0)
	{
		writeBytes((const unsigned char*) bytes ,  offset, length);
	}
	inline void writeBytes(ByteArray& bytes ,  unsigned int offset = 0, unsigned int length = 0xFFFFFFFF)
	{
		if (length == 0xFFFFFFFF)
			length = bytes.getLength() - offset;
		ASSERT(offset + length <= bytes.getLength() , _T("End of src Data") );
#ifndef ByteArray_DYNAMIC_LENGTH
		ASSERT(getPosition() + length <= getLength() , _T("End of dest Data") );
#endif
		writeBytes(bytes.getData() 	,offset, length);
	}

	void writeDouble(double value) ;

	void inline writeFloat(float fvalue) {writeInt(*(int*)((void*)(&fvalue)));};

 	 	
	void writeInt(unsigned int value) ;

 	 	
	void writeMultiByte(const char* c, CharSet::eCharSet = CharSet::ISO_8859_1);
	void writeMultiByte(const wchar_t* wc, CharSet::eCharSet = CharSet::ISO_8859_1);

	void writeShort(unsigned short value) ;
 	
	//writeUTF(value:String):void
	
	//writeUTFBytes(value:String):void

	void writeUnsignedByteOrShort (unsigned short ushort);
	void writeUnsignedShortOrInt (unsigned int ushort);
	void writeShortOrInt (int ashort);



private :
	unsigned char * m_pData;
	unsigned int 	m_position;
	unsigned int	m_length;
	unsigned int	m_bufferLength;

public :

	inline unsigned char* getData(void) const {	return m_pData; } ;
	inline unsigned int	getLength(void) const {	return m_length; } ;
	void	setLength(unsigned int length) ;
	
	inline unsigned int getBytesAvailable (void) const {	return m_length - m_position; };

	inline unsigned int	getPosition(void) const {	return m_position; } ;
	inline void setPosition(unsigned int pos)
	{

		ASSERT( pos <= m_length  , _T("Invalid Position"));
		m_position = pos;
	};
	inline void skip(unsigned int step)
	{

		ASSERT( m_position + step<= m_length  , _T("Invalid Position"));
		m_position += step;
	};

	
	void solid (void);

	inline unsigned char& operator [] (int index) const
	{
		return *(m_pData + index);
	}


	inline unsigned char& operator [] (int index)
	{
		return *(m_pData + index);
	}

	void save (const char* _Filename /*, TCHAR*  _Mode*/) const;
	void save (const wchar_t* _Filename /*, TCHAR*  _Mode*/) const;
private:
	void checkLength(unsigned int requireLength);
	void FileToBuffer(FILE* fp);
};





#endif


#ifndef __MULTICHAR_H___
#define __MULTICHAR_H___


#include <windows.h>
#include <commctrl.h>
#include <locale.h>

void charToWchar (const char* pc , wchar_t** pwc ,  int wcharBufferLengthInByte , int charMultiStrlen );
unsigned int mutilStrlen(const char* pc);
void wcharToChar( const wchar_t* pwc , char** pc , int charBufferLength , int wcharStrlen = -1 );


#endif