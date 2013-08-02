#include <string> 
#include <fstream> 
#include <cstdlib> 
#include <io.h> 
#include <stdio.h>  
#include <cstdlib>
#include <iostream>

/* author blueshell 20080111
*   zibei.gu@gameloft.com
*   replace a string in ANSI files
*   QQ 87453144
*   MSN blueshell@live.com
*/

#include <fcntl.h> 
#include <sys/stat.h> 

using namespace std;

bool fileNotEnd;

int getUniChar (fstream* in) {

	char readInR , readInL;
	int readIn;
	if (!((in->get(readInR)) && (in->get(readInL))))
		fileNotEnd =false;

	readIn = ((readInL & 0xFF)<<8)|(readInR & 0xFF); 
	return readIn;
}
int geFileLength (const char* fileName)
{

#define VS_2005
#ifdef VS_2005
	int j;
	int leng = _filelength((_sopen_s( &j,fileName, _O_RDWR|  _O_BINARY,  _SH_DENYNO,   _S_IREAD))); 
	leng = _filelength(j);
	_close(j);
#else
	int j = (open(fileName,ios::binary|ios::in));
	int leng = filelength(j); 
	close(j);
#endif
	return leng;

}

#define TRACE_ERROR(t) {cout << "Error : "<<t<<"\a"<<endl;			system("pause");			return 0;}



int main(int argc, char* argv[])
{       
		
	if (argc < 3) {
		TRACE_ERROR("plz use as follows: StringToBin.exe <filename> <dest fileName> <BIG_ENDIAN true|false defaut false>");
	}
	
        
        
		string oriFileName = argv[1];
        string destFileName = argv[2];

		bool bSwap = false;
		if (argc >= 4) {
			bSwap = (argv[3][0] == 't');
		}


		fstream oriFile(oriFileName.c_str(),ios::binary|ios::in);
		fstream destFile(destFileName.c_str(),ios::binary|ios::out|ios::trunc); 
		
		if (!oriFile.is_open() || !destFile.is_open() )
		{
			TRACE_ERROR("File name error: couldn't open the file:\n" << oriFileName );
			return (0);
		}
		else {

			
			int inChar = getUniChar (&oriFile);
			if (0xFEFF != inChar) 
			{	
				TRACE_ERROR("cann\'t find "<< oriFileName.c_str() <<"\'s Unicode file head ");
				return (0);
			}

			int fileLength = geFileLength(oriFileName.c_str());
			if ((fileLength & 1) != 0)
			{	
				TRACE_ERROR("error unicode textFile ");
				return (0);
			}

			fileLength >>=1;
			fileLength -= 1; //file head;

			bool startAns = false;
			int findLine = 0;
	
			while (fileLength--)
			{
				inChar = getUniChar (&oriFile);
				if (startAns)
				{
					startAns = false;
					if (inChar == '\\')
					{
							
					}
					else if (inChar == 't')
					{
						inChar = '\t';
					}
					else if (inChar == 'n')
					{
						inChar = '\n';
					}
					else if (inChar == '\'')
					{
						inChar = '\'';
					}
					else if (inChar == '\"')
					{
						inChar = '\"';
					}
					else 
					{
						TRACE_ERROR("character translate \\" << wchar_t(inChar));
						return (0);
					}
				}
				else if (inChar == '\\')
				{
					startAns = true;
					continue;
				}
				else if (inChar == '\\')
				{
					startAns = true;
					continue;
				}
				else if (inChar == 0x0D)
				{
					
					

					if (fileLength)
					{
						streamoff etrPt;
						etrPt = oriFile.tellg();
						inChar = getUniChar (&oriFile);
						if (inChar != 0x0A) {
							oriFile.seekg(etrPt);
						}
						else
						{
							fileLength--;
						}
					}
					findLine++;
					inChar = '\0';
					
				}
				else if (inChar == 0x0A)
				{
					inChar = '\0';
					findLine++;

				}

				if (!bSwap)
				{
					destFile.put((inChar) & 0xff);
					destFile.put((inChar>>8) & 0xff);

				}
				else
				{
					destFile.put((inChar>>8) & 0xff);
					destFile.put((inChar) & 0xff);
				}
			}
			cout << "totally find " << findLine << " strings in file " << oriFileName.c_str()<<endl;
		}
		
		oriFile.close();
		destFile.close();

		return 0;
}
