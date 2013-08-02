static bool fileNotEnd = true;

void putUniHead (fstream* destFile) {
		destFile->put(char(0xFF));
		destFile->put(char(0xFE));
}

void putUniChar (fstream* destFile,int charInt) {
		destFile->put( (charInt >> 0 ) & 0xFF);
		destFile->put( (charInt >> 8 ) & 0xFF);
}

static char buffer[34];

void exportNumber (fstream* out,int i) {
/*
	if (i >= 1000) {
		putUniChar (out, (i / 1000) + '0');
		i/=10;
	}
	if (i >= 100) {
		putUniChar (out, (i / 100) + '0');
		i/=10;
	}
	if (i >= 10) {
		putUniChar (out, (i / 10) + '0');
	}

	putUniChar (out, (i % 10) + '0');*/
	/*	
	int pt = 0;
	
	if (i == 0) {
		pt = 1;
		buffer[0] = 0;
		break;
	}
	else if (i > 0) {
		while (i > 0) {
			buffer[pt] = i%10;
			i /= 10;
			pt ++;
		}
	}
	else {
		TRACE_ERROR("unsupport negative number yet");
	}
		
	for (pt--; pt >= 0 ; pt-- ) {
		putUniChar (out, (buffer[pt] % 10) + '0');	
	}
*/
	int j;
	for (j = 0; j < 34 ; j++ )
		buffer[j] = 0;
	_itoa_s(i, buffer, 10);
	j = 0;
	while (true)
	{
		if (buffer[j] == '\0')
			break;
		else 
			putUniChar (out, buffer[j]);
		j++;
	}


}

void exportEnd(fstream* out) {	putUniChar (out, 0x0D);	putUniChar (out, 0x0A);}

void exportString (fstream* out,char * str) {
	int i=0;
	while (true) {
		if (str[i] == '\0')
			break;
		putUniChar (out ,str[i++]);
	}

}


int getChar (fstream* in) {

		static char readInR , readInL;
		static int readIn;
		if (!((in->get(readInR)) && (in->get(readInL))))
			fileNotEnd =false;

		readIn = ((readInL & 0xFF)<<8)|(readInR & 0xFF); 
		return readIn;
}

void skipEnter (fstream* in) {
	static streamoff etrPt;
	static int a;

	etrPt = in->tellg();
	a = getChar(in);//0x0A
	if (a != 0x0A) {
		in->seekg(etrPt);
	}
}

