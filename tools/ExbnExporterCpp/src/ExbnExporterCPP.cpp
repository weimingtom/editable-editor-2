#include <ByteArray.h>
#include <stdio.h>

const extern int STAGE_WIDTH;
const extern int STAGE_HEIGHT;

extern int FRAME_RATE;
const extern int BACKGROUND_COLOR;

const int STAGE_WIDTH = 640;
const int STAGE_HEIGHT = 480;
const int BACKGROUND_COLOR = 0x666666;
int FRAME_RATE = 30;
const TCHAR* APP_NAME = _T("ExbnExporter");

#include <direct.h>

bool readFileHead(ByteArray& ba ) 
{


	if (ba.readByte() == 'e'
		&& ba.readByte() == 'x'
		&& ba.readByte() == 'b'
		&& ba.readByte() == 'n'
		&& ba.readByte() == 1
		)
	{
		long long time = ba.readUnsignedInt(); + 0x13770000000;
		DBG_TRACE(_T("create at time %ld") , time);

		int version  = ba.readShort();

		DBG_TRACE(_T("File bin version: %d") , version);	

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




struct VariableBinStruct {

public:
	enum eVType{

		TYPE_INT_S8 = 1,
		TYPE_INT_S16 = 2,
		TYPE_INT_S32 = 3,
		TYPE_INT_S8_16 = 4,
		 TYPE_INT_S8_16_32 = 5,
		 TYPE_INT_S16_32 = 6,


		 TYPE_UINT_U8 = 11,
		 TYPE_UINT_U16 = 12,
		 TYPE_UINT_U32 = 13,
		 TYPE_UINT_U8_16 = 14,
		 TYPE_UINT_U8_16_32 = 15,
		 TYPE_UINT_U16_32 = 16,

		 TYPE_NUMBER_F32 = 21,
		 TYPE_NUMBER_D64 = 22,

		 TYPE_STRING_ID = 31,

		 TYPE_INSTANCE_UID = 41,
		 TYPE_INSTANCE_UID_INLINE = 42,

	};
	

	int variableNameId ; //id in String pool;
	const char* variableName;
	eVType type;
	int inlineClassId;

};

struct ClassBinStruct
{
	int classNameId ; //id in String pool;
	const char* className;
	int variableNum ;
	VariableBinStruct variableArray[128];

	bool needExport;

};








char* s_stringPool[2048] = {NULL};
int s_stringPool_index = 0;

ClassBinStruct s_classPool[2048] = {{0}};
int s_classPool_index = 0;

#define countof(a)  (sizeof(s_stringPool) / sizeof(s_stringPool[0]))

bool getInlineTypeNeedDispose (const VariableBinStruct& vbs)
{
	VariableBinStruct::eVType _type;
	if (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID_INLINE)
	{
		_type = s_classPool[vbs.inlineClassId].variableArray[0].type;
	}
	else
		_type = vbs.type;

	switch (_type)
	{
	case VariableBinStruct::TYPE_STRING_ID :
	case VariableBinStruct::TYPE_INSTANCE_UID :
		return true;
	default:
		return false;
	}

}


const char* getInlineTypeType (const VariableBinStruct& vbs)
{
	VariableBinStruct::eVType _type;
	if (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID_INLINE)
	{
		_type = s_classPool[vbs.inlineClassId].variableArray[0].type;
	}
	else
		_type = vbs.type;


	switch (_type)
	{
	case VariableBinStruct::TYPE_INT_S8 :
	case VariableBinStruct::TYPE_INT_S16 :
	case VariableBinStruct::TYPE_INT_S32 :
	case VariableBinStruct::TYPE_INT_S8_16 :
	case VariableBinStruct::TYPE_INT_S8_16_32 :
	case VariableBinStruct::TYPE_INT_S16_32 :
		return "int";

	case VariableBinStruct::TYPE_UINT_U8 :
	case VariableBinStruct::TYPE_UINT_U16 :
	case VariableBinStruct::TYPE_UINT_U32 :
	case VariableBinStruct::TYPE_UINT_U8_16 :
	case VariableBinStruct::TYPE_UINT_U8_16_32 :
	case VariableBinStruct::TYPE_UINT_U16_32 :
		return "unsigned int";
	case VariableBinStruct::TYPE_NUMBER_F32 :
		return "float";
	case VariableBinStruct::TYPE_NUMBER_D64 :
		return "double";
	case VariableBinStruct::TYPE_STRING_ID :
		return  "const TCHAR*";
	case VariableBinStruct::TYPE_INSTANCE_UID :
		if (vbs.inlineClassId != -1 && (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID))
			return s_classPool[vbs.inlineClassId].className;
		else
			return  "ExbnClassBase";
	default:
		ASSERT(false , _T("error type"));
	}

	return NULL;

}



const char* getInlineTypeRead (const VariableBinStruct& vbs)
{
	VariableBinStruct::eVType _type;
	if (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID_INLINE)
	{
		_type = s_classPool[vbs.inlineClassId].variableArray[0].type;
	}
	else
		_type = vbs.type;


	switch (_type)
	{
	case VariableBinStruct::TYPE_INT_S8 :
		return "ba.readByte();";
	case VariableBinStruct::TYPE_INT_S16 :
		return "ba.readShort();";
	case VariableBinStruct::TYPE_INT_S32 :
		return "ba.readInt();";
	case VariableBinStruct::TYPE_INT_S8_16 :
		return "ba.readByteOrShort();";
	case VariableBinStruct::TYPE_INT_S8_16_32 :
		return "ba.readByteOrShortOrInt();";
	case VariableBinStruct::TYPE_INT_S16_32 :
		return "ba.readShorteOrInt();";

	case VariableBinStruct::TYPE_UINT_U8 :
		return "ba.readUnsignedByte();";
	case VariableBinStruct::TYPE_UINT_U16 :
		return "ba.readUnsignedShort();";
	case VariableBinStruct::TYPE_UINT_U32 :
		return "ba.readUnsignedInt();";
	case VariableBinStruct::TYPE_UINT_U8_16 :
		return "ba.readUnsignedByteOrShort();";
	case VariableBinStruct::TYPE_UINT_U8_16_32 :
		return "ba.readUnsignedByteOrShortOrInt();";
	case VariableBinStruct::TYPE_UINT_U16_32 :
		return "ba.readUnsignedShorteOrInt();";
	case VariableBinStruct::TYPE_NUMBER_F32 :
		return "ba.readFloat();";
	case VariableBinStruct::TYPE_NUMBER_D64 :
		return "ba.readDouble();";
	case VariableBinStruct::TYPE_STRING_ID :
		return  "a_env.getString(ba.readUnsignedByteOrShort());";
	case VariableBinStruct::TYPE_INSTANCE_UID :
		if (vbs.inlineClassId != -1 && (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID))
		{	
			static char buffer[2048];
			sprintf_s(buffer , 2048 ,  "%s(a_env.getClassInstance(ba.readUnsignedInt()));" , s_classPool[vbs.inlineClassId].className);
			
			return buffer;
		
		}
		else
			return  "a_env.getClassInstance(ba.readUnsignedInt());";
	default:
		ASSERT(false , _T("error type"));
	}

	return NULL;

}


int _tmain(int argc, _TCHAR* argv[])
{	
	bool enableEnum = false;
	bool enableName = false;

	argv++;
	argc--;
	
	bool okArgs = false;

	if (argc == 1)
		okArgs = true;
	else if (argc == 2)
	{
		if (argv[1][0] == '-'
			&& (argv[1][1] == 'e' || argv[1][1] == 'E' || argv[2][1] == 's' || argv[2][1] == 'S')
			)
		okArgs = true;
	}
	else if (argc == 3)
	{
		if (argv[1][0] == '-' && argv[2][0] == '-'
			&& (argv[1][1] == 'e' || argv[1][1] == 'E' || argv[1][1] == 's' || argv[1][1] == 'S')
			&& (argv[2][1] == 'e' || argv[2][1] == 'E' || argv[2][1] == 's' || argv[2][1] == 'S') 
			)
		okArgs = true;
	}

	if (okArgs)
	{
		if (argc >= 2)
		{	
			if (argv[1][1] == 'e' || argv[1][1] == 'E')
				enableEnum = true;
			if (argv[1][1] == 's' || argv[1][1] == 'S')
				enableName = true;

		}

		if (argc >= 3)
		{	
			if (argv[2][1] == 'e' || argv[2][1] == 'E')
				enableEnum = true;
			if (argv[2][1] == 's' || argv[2][1] == 'S')
				enableName = true;

		}

		if (!enableEnum && !enableName)
			enableEnum = true;

		TCHAR* inputFilename = argv[0];
		//TCHAR* inputFilename = _T("D:\\Projects\\Tools\\EditableEditor2\\exml\\EditorSave.exbn");
		//int _len = _tcslen(argv[0]);

		char package[256] = {0};

		if (argc == 3)
		{
			char* _package = package;

			wcharToChar(argv[2] , &_package , 256 );
		}

		//if (argc < 3)
		{	
			_tprintf(_T("input file\n"));
			DBG_TRACE(inputFilename);

			ByteArray ba(inputFilename);
			ba.endian = Endian::BIG;

			for (int i = _tcslen(inputFilename) ; i >=0 ; i-- )
			{
				if (inputFilename[i] == '\\' || inputFilename[i] == '/')
				{
					TCHAR back = inputFilename[i];
					inputFilename[i] = '\0';

					char path[256] = {0};
					char* _path = path;
					wcharToChar(inputFilename , &_path , 256 );

					_chdir(path);

					inputFilename[i] = back;
					break;
				}
			}


			if (readFileHead(ba))
			{
				_tprintf(_T("file head ok!!\n"));

				//////////////////////////////////////////////////////////////////////////
				int strPoolLength= 	ba.readUnsignedByteOrShort();
				DBG_TRACE(_T("strPoolLength %d") , strPoolLength);
				ASSERT(strPoolLength < countof(s_stringPool) , _T("too much strPoolLength"));

				for (int i = 0 ; i < strPoolLength; i++ )
				{
					int strLeng = ba.readUnsignedByteOrShort(); 
					char* _name = new char[strLeng+1];
					ba.readBytes((unsigned char* )(_name) ,strLeng+1 , 0 , strLeng );
					_name[strLeng] = '\0';


					printf("Get string[%d]: %s\n" , s_stringPool_index , _name );

					s_stringPool[s_stringPool_index++] = _name;

					
				}
				//////////////////////////////////////////////////////////////////////////

				//int classPoolDataLength = ba.readUnsignedShortOrInt();
				//int destEnd = ba.getPosition() + classPoolDataLength;

				int classPoolLength  =  ba.readUnsignedByteOrShort();
				DBG_TRACE(_T("classPoolLength %d") , classPoolLength);
				ASSERT(classPoolLength < countof(s_classPool) , _T("too much classPoolLength"));

				for (int i  = 0 ; i < classPoolLength; i++ )
				{
					ClassBinStruct& _cbs = s_classPool[s_classPool_index++];
					_cbs.needExport = false;

					_cbs.classNameId = ba.readUnsignedByteOrShort();
					ASSERT(_cbs.classNameId  < s_stringPool_index , _T("error string"));
					_cbs.className = s_stringPool[_cbs.classNameId];
					_cbs.variableNum = ba.readUnsignedByteOrShort();

					ASSERT(_cbs.variableNum < countof(_cbs.variableArray) , _T("too much variableNum"));

					printf("find class %s _cbs.className %d\n" , _cbs.className , _cbs.variableNum);

					for (int vi = 0 ; vi <  _cbs.variableNum; vi++ )
					{
						VariableBinStruct& vbs = _cbs.variableArray[vi];
						vbs.variableNameId = ba.readUnsignedByteOrShort();
						ASSERT(vbs.variableNameId  < s_stringPool_index , _T("error string"));
						vbs.variableName = s_stringPool[vbs.variableNameId];

						vbs.type = (VariableBinStruct::eVType)ba.readByte();
						vbs.inlineClassId = -1;

						if (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID_INLINE || vbs.type == VariableBinStruct::TYPE_INSTANCE_UID)
							vbs.inlineClassId = ba.readUnsignedByteOrShort();
						else
							vbs.inlineClassId = -1;

						if (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID_INLINE)
						{	
							printf(("    var %d %s type %d inline class %s\n") ,  vi , vbs.variableName , vbs.type , s_classPool[vbs.inlineClassId].className);
						}
						else if (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID)
						{	
							printf(("    var %d %s type %d class %s\n") ,  vi , vbs.variableName , vbs.type , s_classPool[vbs.inlineClassId].className);
						}
						else
						{	
							printf(("    var %d %s type %d\n") ,  vi , vbs.variableName , vbs.type);
						}
					} 

				}
				//ASSERT(destEnd == ba.getPosition() , _T("error"));

				//////////////////////////////////////////////////////////////////////////

				//find root class
				int classInstanceLength  =  ba.readUnsignedByteOrShort();
				
				//int instancPose = ba.getPosition();

				printf("classInstanceLength %d\n" , classInstanceLength);

				for (int i  = 0 ; i < classInstanceLength; i++ )
				{
					int classDataLength = ba.readUnsignedByteOrShort();
					int pos = ba.getPosition();
					int endPos = pos + classDataLength;
					int clsId =  ba.readUnsignedByteOrShort();

					ASSERT(clsId < s_classPool_index , _T("error string"));

					ClassBinStruct& _cbs = s_classPool[clsId];
					_cbs.needExport = true;

					ba.setPosition(endPos);

				}


				for (int classi = 0; classi < s_classPool_index ; classi++)
				{
					ClassBinStruct& _cbs = s_classPool[classi];
					if (_cbs.needExport)
					{	
						printf("export class %s\n" , _cbs.className);
						
						bool hasInstance = false;

						ByteArray output;
						output.writeMultiByte("#ifndef __EXBN_");
						output.writeMultiByte(_cbs.className);
						output.writeMultiByte("_H__\n");
						output.writeMultiByte("#define __EXBN_");
						output.writeMultiByte(_cbs.className);
						output.writeMultiByte("_H__\n");

						//output.writeMultiByte("\timport ExbnDecoder.*;\n");
						//output.writeMultiByte("\timport flash.utils.ByteArray;\n");

						output.writeMultiByte("\nclass ");
						output.writeMultiByte(_cbs.className);
						output.writeMultiByte(" : public ExbnClassBase {\n");

						output.writeMultiByte("\npublic : \n");
						output.writeMultiByte("\n\t");
						output.writeMultiByte(_cbs.className);
						output.writeMultiByte("(unsigned int a_instanceUID) : ExbnClassBase(a_instanceUID) {");
							
						if (enableEnum)
						{
							output.writeMultiByte("\n\t\t");
							output.writeMultiByte("EXBN_CLS_ENUM = EXBN_ENUM_");
							output.writeMultiByte(_cbs.className);
							output.writeMultiByte(";");
						}
						if (enableName)
						{
							output.writeMultiByte("\n\t\t");
							output.writeMultiByte("EXBN_CLS_NAME = _T(\"");
							output.writeMultiByte(_cbs.className);
							output.writeMultiByte("\");");
						}

						output.writeMultiByte("\n\t}\n");

						for (int vi = 0 ; vi <  _cbs.variableNum; vi++ )
						{

							VariableBinStruct& vbs = _cbs.variableArray[vi];

							if (getInlineTypeNeedDispose(vbs))
								hasInstance = true;

							output.writeMultiByte("\t");
							output.writeMultiByte(getInlineTypeType(vbs));
							output.writeMultiByte(" ");
							output.writeMultiByte(vbs.variableName);

							output.writeMultiByte(";\n");

						}

						output.writeMultiByte("\n\n");
						{

							
							output.writeMultiByte("\tvoid virtual decode(ByteArray& ba , ExbnEnv& a_env ) {\n");
							
							for (int vi = 0 ; vi <  _cbs.variableNum; vi++ )
							{

								VariableBinStruct& vbs = _cbs.variableArray[vi];

								output.writeMultiByte("\t\t");
								output.writeMultiByte(vbs.variableName);
								output.writeMultiByte(" = ");
								output.writeMultiByte(getInlineTypeRead(vbs));


								output.writeMultiByte("\n");

							}
							

							output.writeMultiByte("\n\t}\n\n");
						}
						
					
						


						/*
						if (hasInstance)
						{
							output.writeMultiByte("\n\n");
							output.writeMultiByte("\t\tpublic override function dispose() : void {\n");
							
							for (int vi = 0 ; vi <  _cbs.variableNum; vi++ )
							{

								VariableBinStruct& vbs = _cbs.variableArray[vi];

								if (getInlineTypeNeedDispose(vbs))
								{
									
									if (vbs.inlineClassId != -1 && (vbs.type == VariableBinStruct::TYPE_INSTANCE_UID))
									{
										output.writeMultiByte("\t\t\tif (");
										output.writeMultiByte(vbs.variableName);
										output.writeMultiByte(") ");

										output.writeMultiByte(vbs.variableName);
										output.writeMultiByte(".dispose();\n");

									}
									output.writeMultiByte("\t\t\t");
									output.writeMultiByte(vbs.variableName);
									output.writeMultiByte(" = null;\n");


									
								}	

							}

							output.writeMultiByte("\n\t\t\t");
							output.writeMultiByte("super.dispose();");
							output.writeMultiByte("\n");

							output.writeMultiByte("\n\t\t}\n\n");
						}

						output.writeMultiByte("\t}\n");*/

						output.writeMultiByte("};\n#endif\n\0");
						
						char outputfilename[256];
						sprintf_s(outputfilename, 256, "%s.hpp" , _cbs.className);


						output.save(outputfilename);

					}
				}
				//////////////////////////////////////////////////////////////////////////
				//system("pause");

			}

		}

	}
	else
	{
		_tprintf(_T("\a"));//di
		_tprintf( _T("plz use as ExbnExporter inputFilename (-enum -string) \ne.g. ExbnExporter c:\\a.exbn -enum -string\n"));
		
		
		for (int i = 0 ; i< argc; i++)
		{	
			_tprintf(_T("\n %d:") , i );
			_tprintf(argv[i]);

		}
		_tprintf(_T("\n"));
		system("pause");
	}
	




	return 0;
}


void charToWchar (const char* pc , wchar_t** pwc ,  int wcharBufferLengthInByte , int charMultiStrlen )
{
	if (charMultiStrlen == -1)
	{ 
		charMultiStrlen = MultiByteToWideChar (CP_ACP, 0, pc, -1, NULL, 0);
	}
	else
	{
		charMultiStrlen++;
	}

	if (*pwc == NULL)
	{
		ASSERT(wcharBufferLengthInByte == 0 ,_T("error pwc and wcharLength"));
		wcharBufferLengthInByte = charMultiStrlen * sizeof(wchar_t) ;
		*pwc = ((wchar_t*)MALLOC(wcharBufferLengthInByte));
		ASSERT(*pwc , _T("error malloc!"));
	}

	ASSERT(wcharBufferLengthInByte >= (int)(charMultiStrlen * sizeof(wchar_t)) , _T("out of buffer!!") );

	if (*pwc)
		MultiByteToWideChar				  (CP_ACP, 0,pc, -1, *pwc, wcharBufferLengthInByte);
}


unsigned int mutilStrlen(const char* pc)
{
	unsigned int dwNum = MultiByteToWideChar (CP_ACP, 0, pc, -1, NULL, 0);

	ASSERT(dwNum >= 1 , _T("error length!"));

	return dwNum - 1;
}

void wcharToChar( const wchar_t* pwc , char** pc , int charBufferLength , int /*wcharStrlen*/ )
{
	//if (wcharStrlen == -1)
	//{ 
	//	wcharStrlen = wcslen(pwc);
	//}
	const char defaultChar = ' ';
	BOOL 	bUsedDefaultChar;
	if (*pc == NULL)
	{
		ASSERT(charBufferLength == 0 ,_T("error pc and charBufferLength"));
		charBufferLength = WideCharToMultiByte(CP_ACP, 0,pwc, -1, NULL, 0 , &defaultChar , &bUsedDefaultChar);//one wchar for 2 chars , + 1 means \0  need only one
		*pc = ((char*)MALLOC(charBufferLength));
		ASSERT(*pc , _T("error malloc!"));
	}

	ASSERT(charBufferLength >= WideCharToMultiByte(CP_ACP, 0,pwc, -1, NULL, 0 ,&defaultChar, &bUsedDefaultChar) , _T("out of buffer!!") );

	if (*pc)
	{	
		WideCharToMultiByte	(CP_ACP, 0,pwc, -1, *pc, charBufferLength ,&defaultChar , &bUsedDefaultChar);
		if (bUsedDefaultChar)
		{
			DBG_TRACE_PLUS(DBG_DEF::WARNING , _T("at least one char not change corrent , change it to \' \'"));
		}
	}

}