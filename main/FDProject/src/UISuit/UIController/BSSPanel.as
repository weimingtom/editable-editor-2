package   UISuit.UIController 
{
	
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIConf.BSSLayoutInfo;
	import UISuit.UIConf.BSSLayoutInfo;
	import UISuit.UIConf.BSSUIDEF;
	import Util.GRA_Util.Graphics_Util;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	

	/**
	 * @author blueshell
	 */
	public class BSSPanel extends Sprite {
	
	    public static const   ENABLE_TITLE   :   int   =   1  ; 
	    public static const   ENABLE_CONTENT   :   int   =   2  ; 
	    public static const   ENABLE_MOVE   :   int   =   4  ; 
	    public static const   ENABLE_CLOSE   :   int   =   8  ; 
	    public static const   ENABLE_MAXSIZE   :   int   =   16  ; 
	    public static const   ENABLE_MINSIZE   :   int   =   32  ; 
	    public static const   ENABLE_RESIZE   :   int   =   64  ; 
	
	    public static const   HAS_OTHER_ITEM   :   int   =   128  ; 
	
	    public static const   ENABLE_DEFAULT   :   int   =   15  ;  // BSSPanel.ENABLE_TITLE BSSPanel.ENABLE_CONTENT BSSPanel.ENABLE_MOVE BSSPanel.ENABLE_CLOSE


		public  var m_bgData : DisplayObject;
		public  var m_tilteField : TextField;
		public  var m_contentField : TextField;

		//private var m_tilteAlign : LayoutInfo ;
		//private var m_contentAlign : LayoutInfo;

        public  var m_buttonList :Array ;
		public  var m_buttonAlignList : Array ;
		
		public var closeFunction : Function ;
		

		public function BSSPanel (
				bgData : DisplayObject , 
                titleString : String = null , 
                contentString : String = null , 
                buttonList : Array  = null  ,
                buttonAlignList : Array  = null ,
                _flag : int = BSSPanel.ENABLE_DEFAULT
		)
		{		
                    m_buttonList = buttonList ;
                    m_buttonAlignList = buttonAlignList;

			
			//m_contentAlign = contentAlign;
			//m_tilteAlign = tilteAlign;
			
                    /*m_tilteField = tilteField;
                    if (m_tilteField ) 
                    {
                        addChild (m_tilteField);
                        if(titleString != null)
                            m_tilteField.text = titleString;
                     }

                    m_contentField = contentField;
                    if (m_contentField )
                    {
                        addChild (m_contentField);
                        if( contentString != null)
                            m_contentField.text = contentString; 
                    }*/
			
			m_bgData = bgData;
			if (m_bgData) {
			    addChild (m_bgData);
			//    var h : Number  = bgData.height;
			//    var w : Number  = bgData.width;
			}



			//if (m_contentField)
			//    addChild (m_contentField);
			    
                   //if (m_tilteField)
                  //   addChild (m_tilteField);

                    if (m_buttonList && buttonAlignList)
                    {
						CONFIG::ASSERT{
                        ASSERT(m_buttonList.length && buttonAlignList.length , "error data!!");
						}
						var index : int = 0

                        
                        if (_flag & BSSPanel.ENABLE_TITLE)
                        {
							CONFIG::ASSERT{
                            ASSERT (m_buttonList[index] is TextField , "error m_contentField");
							}
                            m_tilteField = TextField(m_buttonList[index]);
                             if (m_tilteField ) 
                            {
                                addChild (m_tilteField);
                                if(titleString != null)
                                    m_tilteField.text = titleString;
                             }
                             index ++;
                            
                        }
                        
                        if (_flag & BSSPanel.ENABLE_CONTENT)
                        {  
							CONFIG::ASSERT{
                            ASSERT (m_buttonList[index] is TextField , "error m_contentField");
							}
							
							m_contentField = TextField(m_buttonList[index]);
                                if (m_contentField )
                                {
                                    addChild (m_contentField);
                                    if( contentString != null)
                                        m_contentField.text = contentString; 
                                }
                                index ++;
                        }
                        
                        var btn : BSSButton;
                        if (_flag & BSSPanel.ENABLE_MOVE)
                        {   
							CONFIG::ASSERT{
                            ASSERT(m_buttonList[index] is DisplayObjectContainer, "error BSSPanel.ENABLE_MOVE");
							}
							
							btn = (m_buttonList[index] is BSSButton) ? BSSButton(m_buttonList[index] ) : new BSSButton(DisplayObjectContainer(m_buttonList[index]) );
                            addChild (btn);
                            btn.pressFunction = onStartDrag;
							btn.releaseFunction = onStopDrag;
							
                            btn = null;
                            index++;
                        }

                        if (_flag & BSSPanel.ENABLE_CLOSE)
                        {   
							CONFIG::ASSERT{
                            ASSERT(m_buttonList[index] is DisplayObjectContainer, "error BSSPanel.ENABLE_CLOSE");
							}
							btn = (m_buttonList[index] is BSSButton) ? BSSButton(m_buttonList[index] ) : new BSSButton(DisplayObjectContainer(m_buttonList[index]) );
                            addChild (btn);
		              		btn.releaseFunction = onCloseRelease;
                            btn = null;
                            index++;
                        }


                        var leng : int = m_buttonList.length;

                        for (; index <  leng ; index++)
                        {
                            addChild (m_buttonList[index]);
                        }
                        
                     }

			
			CONFIG::ASSERT{
				ASSERT ( (( !m_buttonList && !m_buttonAlignList) || (m_buttonList.length == m_buttonAlignList.length)) ,   "error btn data!!");
			}
                    
			
		}
		
		public override function set height ( h : Number )
		: void 
		{
			var off : Number = h - height ;
		//	dragBtn.height += off;
		//	tilteField.height += off;

		  /*    if (m_contentField) {
		            if (!m_contentAlign || !(m_contentAlign.LayoutInfo_align&UIDEF.FIXED_HEIGHT))
		                m_contentField.height += off;
		      }
		  */    
		      
		      if (m_bgData) {m_bgData.height += off; }
			
		}

		public override function set width ( w : Number )
		: void 
		{
			
			var off : Number = w - width ;
			
			if (m_bgData) m_bgData.width += off;
			
			for (var i : int = 0 ; i < m_buttonList.length; i++ )
			{
				var dsp : DisplayObject = DisplayObject(m_buttonList[i]);
				var li : BSSLayoutInfo = BSSLayoutInfo(m_buttonAlignList[i]);
				var align : int = li ? li.LayoutInfo_align : 0;
				var offsetX : int = li ? li.LayoutInfo_offsetX : 0;
				
				if (align & BSSUIDEF.ALIGN_RIGHT)
				{
					dsp.x = w + offsetX;
				}
				else if (align & BSSUIDEF.ALIGN_HCENTER)
				{
					dsp.x = int(w /2) + offsetX;
				}
				else {
					if (li)
					{
						
					}
					else {
						//if (!(align & BSSUIDEF.FIXED_WIDTH))
						{
							//trace("BSSPanel off = " +off);
							dsp.width += int(off);
						}
					}
				}
			}
			
			
		}

            public function dispose ()
            : void {
                 removeTitle ();
				removeContent();

				Graphics_Util.removeAllChildrenWithDispose(this);
                m_bgData = null; //dispose by removeAllChildrenWithDispose

                 //m_tilteAlign = null;
				//m_contentAlign = null;
				m_tilteField = null;
				m_contentField = null;
			
				if (parent)
					parent.removeChild(this);

					var leng : int;
					if( m_buttonList  ){    leng  =  m_buttonList  .length;  { while(  leng --)   {  m_buttonList  [  leng ] = null;}};  m_buttonList   = null; } ;
					if( m_buttonAlignList  ){    leng  =  m_buttonAlignList  .length;  { while(  leng --)   {  m_buttonAlignList  [  leng ] = null;}};  m_buttonAlignList   = null; } ;

            }

            public var limitRectangle : Rectangle;
            public var limitToStage : Boolean = true;
		
		public function onStartDrag (  caller : BSSButton )
		: void {
			//TODO
			//MouseManager.setDragingObject (this , limitRectangle , limitToStage );
			this.startDrag(false , limitRectangle);
		}
		
		public function onStopDrag (caller : BSSButton )
		: void {
			//MouseManager.resetDragingObject (this);
			this.stopDrag();
		}

		public function onCloseRelease (  caller : BSSButton )
		: void {
			if (closeFunction != null)
				closeFunction(this);
			else
				visible = false;	
		}

		public function set htmlText ( str : String )
			: void {
			m_contentField.htmlText =  str;
		}
		
		public function set text ( str : String )
		: void {
			m_contentField.text =  str;
		}
		public function get text ()
		: String {
			return m_contentField.text ;
		}

		
		public function set titleText ( str : String )
		: void {
			m_tilteField.text =  str;
		}
		public function get titleText ()
		: String {
			return m_tilteField.text;
		}


		public function removeTitle (  )
		: void 
		{
			if (m_tilteField)
			{
				removeChild(m_tilteField);
				m_tilteField = null;
			}
		}

            public function removeContent(  )
		: void 
		{
			if (m_contentField)
			{
				removeChild(m_contentField);
				m_contentField = null;
			}
		}


		public function set selectable ( _selectable : Boolean )
		: void 
		{
			m_contentField.selectable =  _selectable;
		}

        public function addAItem ( Item : DisplayObject , layoutInfo : BSSLayoutInfo )
		: void 
		{
			CONFIG::ASSERT{
				ASSERT(Item != null , "can't add a null Object");
			}
			
			if (Item)
			{    
			        addChild(Item);
			//TODO 
			//       if (layoutInfo)
			//          UIMain.UIMain_setLayoutPos(Item , this.getRect(this) ,layoutInfo);
        			
					
					if (m_buttonList  && m_buttonAlignList )
        			{
                                m_buttonList.push(Item);
                                m_buttonAlignList.push(layoutInfo);
        			}
			}
			
		}

		public function addItems ( buttonList : Array  , buttonAlignList : Array  )
		: void 
		{
			CONFIG::ASSERT{
			ASSERT(buttonList && buttonAlignList && buttonAlignList.length == buttonList.length , "error data" );
			}
			var leng : int = buttonList.length;
            for (var i : int = 0 ; i < leng ; i++)
               addAItem(buttonList[i] , buttonAlignList[i])
		}

		

            public static function  createSimpleBSSPanel (w : Number , h : Number , _flag : int = BSSPanel.ENABLE_DEFAULT)
            : BSSPanel  {
                    var bgShape : Shape = new Shape();
					Graphics_Util.DrawRect (bgShape.graphics , 0, 0, w, h, 0xEEEEEE , 0.8, 1, 0xCCCCFF);
					Graphics_Util.DrawRect (bgShape.graphics , 0, 0, w, 18, 0xBBBBFF , 0.8);

                      if (_flag)
                      {
                                var buttonList : Array  = new Array();
                                var buttonAlignList : Array  = new Array();
				
                        //CONST( ENABLE_TITLE , int , 1 )
                        //CONST( ENABLE_CONTENT , int , 2 )
                        //CONST( ENABLE_MOVE , int , 4 )
                        //CONST( ENABLE_CLOSE , int , 8 )
                        //CONST( ENABLE_MAXSIZE , int , 16 )
                        //CONST( ENABLE_MINSIZE , int , 32 )
                        //CONST( ENABLE_RESIZE , int , 64 )
                        var titleHeight : int ;
                          if (_flag & BSSPanel.ENABLE_TITLE)
				{
				    titleHeight = 20;
				    var titleTextField : TextField = new TextField();
				    titleTextField.width =  w - 8;
				    titleTextField.x = 4;
				    titleTextField.height = titleHeight;
				    titleTextField.selectable = false;

				    buttonList.push(titleTextField);
				    buttonAlignList.push(null);
				}

				 if (_flag & BSSPanel.ENABLE_CONTENT)
				{  
				    var contentTextField : TextField = new TextField();
				    contentTextField.width = w - 8;
				    contentTextField.x = 4;
				    contentTextField.height = Math.max( 10 , h - titleHeight);
				    contentTextField.y = titleHeight;
                              contentTextField.multiline = true;
                              contentTextField.wordWrap = true; 
				    buttonList.push(contentTextField);
				    buttonAlignList.push(null);
				}

				var sprite : Sprite ;

                        if (_flag & BSSPanel.ENABLE_MOVE)
			    {	
			        
			        buttonList.push(BSSButton.createHotSpotBSSButton(w , titleHeight == 0 ? h : titleHeight));
			        buttonAlignList.push(null);

			    }


                       var offsetX : int ;
                       
			    if (_flag & BSSPanel.ENABLE_CLOSE)
			    {	
			        sprite = new Sprite();
			        var closeBtnH : int = 14;
        			for (var j : int = 0 ; j < 3 ; j ++ )
        			{	
        				var shape : Shape = new Shape();
        				//var closeBtnH : int = h - 6;
        				Graphics_Util.DrawRect( shape.graphics , 0 , 0 ,closeBtnH, closeBtnH , ((j == 2) ? 0xFF3333  :  ((j == 1) ? 0xFFDDDD : 0xFFFFFF )) , 0.5 + j * 0.1 , 0 , 0 ,0.15  );
        				
        				shape.graphics.lineStyle(1);
        				shape.graphics.moveTo(2, 2);
        				shape.graphics.lineTo(closeBtnH-2, closeBtnH-2);
        				
        				shape.graphics.moveTo(2, closeBtnH-2);
        				shape.graphics.lineTo(closeBtnH-2, 2);
        				
        				sprite.addChild (shape);
        			} 
			
			        buttonList.push(sprite);
			        offsetX -= closeBtnH + 2;
			        sprite.x = w + offsetX;
			        sprite.y = 2;

			        
			        
			        buttonAlignList.push(
						//new LayoutInfo( offsetX , 2, UIDEF.ALIGN_RIGHT )
						null
					);

			    }


			    if (titleTextField)
			            titleTextField.width = w - 8 + offsetX;
                }

			    
				
				return new BSSPanel(bgShape , null , null ,buttonList ,buttonAlignList ,_flag  );
            }

	}
}
