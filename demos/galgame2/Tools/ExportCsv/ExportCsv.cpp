#include <string> 
#include <fstream> 
#include <cstdlib> 
#include <io.h> 
#include <stdio.h>  
#include <cstdlib>
#include <iostream>



//#include <fcntl.h> 
//#include <sys/stat.h> 

/* author blueshell 20080111
*   QQ 87453144
*   MSN blueshell@live.com
*/

using namespace std;
#define TRACE_ERROR(t) {cout << "Error : "<<t<<"\a"<<endl;			system("pause");			return 0;}
#include "unicodeIo.h"

//#define javaFileName "STR.java"
#define javaFileName "STR.h"
#define strFileNameHead "STR_"

int main(int argc, char* argv[])
{       
		cout<<"Export csv table to tst for MapString "<<endl;
		cout<<"Version 0.6.3"<<endl;
		string csvFileName;
		if (argc == 2) {
			csvFileName = argv[1];
		}
		else {
			TRACE_ERROR("plz use as ExportCsv <filename>");
		}
		
		fstream csvFile(csvFileName.c_str(),ios::in|ios::binary);
		
		if(!csvFile) 
			TRACE_ERROR("can't open file "<<csvFileName);

		int langNbr = 1;
		string* langFileName = NULL;
		fstream* langFile = NULL;
		fstream* libFile = NULL;
		
		int inChar = getChar (&csvFile);
		if (0xFEFF != inChar) 
			TRACE_ERROR("cann\'t find "<< csvFileName <<"\'s Unicode file head ");

		inChar = getChar (&csvFile);
		if (0x09 != inChar) 
			TRACE_ERROR("error file scheme of "<< csvFileName);

		while (0x0D != inChar) {
			inChar = getChar (&csvFile);
			if (0x09 == inChar) 
				langNbr++;
		} 
		cout << "find " << langNbr << " languages :"<<endl;
		csvFile.seekg(2);//unicode head
		langFileName = new string[langNbr];
		langFile = new fstream[langNbr];
		libFile = new fstream[langNbr];

		inChar =0;
		langNbr = -1;
		int i;
		while (true) {
			inChar = getChar (&csvFile);
			if (0x0D == inChar)
				break;

			if (0x09 == inChar) {
				langNbr++;
				langFileName[langNbr] = strFileNameHead;
			}
			else {
				langFileName[langNbr]+= char(inChar);
			//	cout << char(inChar)<< endl;
			//	cout << langFileName[langNbr] << endl;
			}

		} skipEnter (&csvFile);

		for (i = 0 ; i<= langNbr ; i++) {
			string t = langFileName[i] + ".txt";

			langFile[i].open(t.c_str(),ios::out|ios::binary|ios::trunc);
			putUniHead(&langFile[i]);
			cout <<"text file :\t"<<t << endl; 
			t = langFileName[i] + "_LIB.txt";
			libFile[i].open(t.c_str(),ios::out|ios::binary|ios::trunc);
			putUniHead(&libFile[i]);
			cout <<"lib file :\t"<<t << endl; 

		}
		




		fstream javaFile(javaFileName,ios::out|ios::trunc);
//		javaFile << "interface STR {"<<endl;


		i = -2; int j = -2;

		while (true) {
			
			inChar = getChar (&csvFile);
			if (!fileNotEnd)
				break;

	//		cout <<"get "<<hex<< inChar << endl;
	//		cout << char(inChar)<<endl;
	//		system("pause");

			if ('"'== inChar){
				inChar = getChar (&csvFile);
			}
			
			if ((0x0D == inChar)) {
				skipEnter(&csvFile);
				i = -2;
				if (langNbr >= 0 && j >= -1)
					exportEnd(&langFile[langNbr]);

				j++;
				continue;
			} else if (0x09 == inChar) {
				if (i >= 0 && j >= -1)
					exportEnd(&langFile[i]);
				i++;
				continue;
			} 

			
			if (i==-2) {
				if (j >= -1 )
					javaFile <<" ,  "<<j<<" )"<<endl;
				if (j >= -2 ) {
					javaFile << "\tFINAL( int , ";
					javaFile << char (inChar);
				}
				i++;
				
			} else if (i==-1) {
			//	if ( j >= -1 )
					javaFile << char (inChar);
			} else {
				if (j >= -1)
					putUniChar (&langFile[i],inChar);
				putUniChar (&libFile[i],inChar);
			}
			
		}

		if (j >= 0 )
			javaFile <<" , "<<(j)<<" )"<<endl;

		j++;
		javaFile << "\tFINAL( int , MAX_STR , "<<j<< " ) "<<endl;
	//	javaFile << "}"<<endl;
		cout << "total find "<<(j)<<" texts"<<endl;
	

		csvFile.close();
		javaFile.close();

		for (i = 0 ; i<= langNbr ; i++) {
			langFile[i].close();
		}

		delete[] langFileName;
		delete[] langFile;

}