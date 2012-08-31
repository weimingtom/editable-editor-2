
  
  package Debugger {
  

	public class DBG_DEF {

    
      public static var CONST_INFO_ARRAY : Array  = new Array (); 
          
    public static const   COLOR_MASK     :     int     =    0xFF ;  // max 256 color 8bit
    
    public static const   COLOR_NORMAL_ID     :     int     =    0 ; 
		public static const   COLOR_RED_ID     :     int     =    1 ;  // (DBG_DEF.COLOR_NORMAL_ID + 1)
		public static const   COLOR_GREEN_ID     :     int     =    2 ;  // (DBG_DEF.COLOR_RED_ID + 1)
		public static const   COLOR_BLUE_ID     :     int     =    3 ;  // (DBG_DEF.COLOR_GREEN_ID + 1)
		public static const  COLOR_CYAN_ID     :     int     =    4 ; //cyan opposite to red
		public static const  COLOR_MAGENTA_ID   :    int     =    5 ; //magenta opposite to green
		public static const  COLOR_YELLOW_ID     :    int     =    6 ; //yellow opposite to blue
		public static const  COLOR_ORANGE_ID    :     int    =     7 ; //seems a little confusing
		public static const  COLOR_NAVY_ID      :     int    =     8 ; 
		public static const  COLOR_BLUIE_ID      :     int    =     9 ; 
		
		
        public static const   COLOR_NORMAL_COLOR  :     int     =    0x000000 ; 
		public static const   COLOR_RED_COLOR     :     int     =    0xFF0000 ; 
		public static const   COLOR_GREEN_COLOR     :     int     =    0x00FF00 ; 
		public static const   COLOR_BLUE_COLOR     :     int     =    0x0000FF ; 
              public static const  COLOR_CYAN_COLOR     :     int     =   0x00FFFF ; 
              public static const  COLOR_MAGENTA_COLOR  :   int   =   0xFF00FF ; 
              public static const  COLOR_YELLOW_COLOR    :   int   =   0xFFFF00 ; 
              public static const  COLOR_ORANGE_COLOR    :   int   =   0xFFA500 ; 
			  public static const  COLOR_NAVY_COLOR      :   int   =   0x000080 ; 
			  public static const  COLOR_BLUIE_COLOR      :   int   =   0x8080FF ; 
		
		/////////////////////////////////////////
		
		public static const   OUTPUT_MASK     :     int     =    0xFF00 ;  // (0xFF << 8)   max 256 out put 8bit
		
		public static const   OUTPUT_NORAML     :     int      =    0x0000 ;  //
		public static const   OUTPUT_SERVER     :     int      =    0x0100 ;  //  (DBG_DEF.COLOR_MASK + 1)
		public static const   OUTPUT_LOGFILE       :     int   =    0x0200 ;  //  (DBG_DEF.OUTPUT_LOGFILE + 1)
		public static const   OUTPUT_TRACE       :     int     =    0x0300 ;  //  (DBG_DEF.OUTPUT_TRACE + 1)
		
		
		/////////////////////////////////////////
		public static const   FONTTYPE_MASK          :     int      =   0x70000 ;  // (7<<16)  7 = 111(2) 3bit 
		public static const   FONTTYPE_BOLD          :     int      =   0x10000 ;  //(DBG_DEF.OUTPUT_MASK + 1)
		public static const   FONTTYPE_ITALIC        :     int      =   0x20000 ;  //(DBG_DEF.FONTTYPE_BOLD<<1)
		public static const   FONTTYPE_UNDERLINE     :     int      =   0x40000 ;  //(DBG_DEF.FONTTYPE_ITALIC<<1)
		
		
		
		
		
		/////////////////////////////////
		public static const   PRINT_STATUS     :     int     =   (DBG_DEF.COLOR_BLUE_ID|DBG_DEF.FONTTYPE_BOLD) ;  
		public static const   IMPORTANT     :     int     =    DBG_DEF.COLOR_RED_ID ; 
		public static const   FREE_DATA     :     int     =    DBG_DEF.COLOR_GREEN_ID ; 
		public static const   LOAD_URL     :     int     =     (DBG_DEF.COLOR_BLUE_ID|DBG_DEF.FONTTYPE_UNDERLINE) ; 
		public static const   LOAD_RES     :     int     =     (DBG_DEF.COLOR_NAVY_ID) ; 
		public static const   FLAG_SOUND     :     int     =        (DBG_DEF.COLOR_ORANGE_ID|DBG_DEF.FONTTYPE_BOLD) ; 
		public static const   WARNING     :     int     =        (DBG_DEF.COLOR_RED_ID|DBG_DEF.FONTTYPE_BOLD) ; 
		

    
    
    

	}
}
	
