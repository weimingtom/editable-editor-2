package Alert 
{
	import Class.ClassInstanceSelector;
	import ClassInstance.ClassInstance;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIConf.BSSLayoutInfo;
	import UISuit.UIConf.BSSUIDEF;
	import UISuit.UIController.BSSPanel;
	import Util.GRA_Util.Graphics_Util;
	/**
	 * ...
	 * @author blueshell
	 */
	public class AlertPanel 
	{
		private var m_panel : BSSPanel;
		private var m_container : SripteWithRect;
		
		public function getPanel() : BSSPanel
		{
			return m_panel;
		}
		
		public function getContainer() : DisplayObjectContainer
		{
			return m_container;
		}
		
		private static var sm_singleton : AlertPanel ;
		public static function getSingleton() : AlertPanel
		{
			return sm_singleton;
		}
		
		
		private function onRedrawRect(_container : SripteWithRect) : void
		{
			
			m_container.parent.removeChild(m_container);
			
			var wNew : int = m_container.width + 8;
			if (wNew < 40)
				wNew = 40;
			m_panel.width = wNew;
			
			var hNew : int = m_container.height  + m_container.y + 5 ;
			if (hNew < 40)
				hNew = 40;
			m_panel.height = hNew ;
			
			m_panel.addChildAt(m_container , 0);
		}
		
		public function addChildAt(content : DisplayObject , layer : int )
		: DisplayObject {
			
			m_container.addChildAt(content , layer);

			return content;
		}
		
		public function removeAllChildren(withDispose : Boolean = true) : void
		{
			if (m_container)
			{
				if (withDispose)
					Graphics_Util.removeAllChildrenWithDispose(m_container);
				else
					Graphics_Util.removeAllChildren(m_container);
					
				m_container.parent.removeChild(m_container);
				
				m_panel.width = 40;
				m_panel.height = 40;
				
				m_panel.addChildAt(m_container , 0);
			}
		}
		public function addChild(content : DisplayObject )
		: DisplayObject {
			m_container.addChild(content);
			
			return content;
		}
		
		public function dispose():void
		{
			if (m_panel)
			{
				m_panel.dispose();
				m_panel = null;
			}
			
			if (m_container)
			{
				m_container.dispose();
				m_container = null;
			}
			
			

		}
		
		public function AlertPanel() 
		{
			ASSERT(sm_singleton == null , "error");
			
			if (sm_singleton == null)
				sm_singleton = this;
			
			var _flag : int = 
			BSSPanel.ENABLE_TITLE
		//|	BSSPanel.ENABLE_CONTENT
		|	BSSPanel.ENABLE_MOVE
		|	BSSPanel.ENABLE_CLOSE;
			
			var w : int = 40;
			var h : int = 40;
			//BSSPanel.createSimpleBSSPanel(300 , 400)
			
			
			var bgShape : Shape = new Shape();
			bgShape.graphics.clear();
			bgShape.graphics.beginFill(0xAAAAFF , 0.15);
			bgShape.graphics.lineStyle(0 , 0x9999FF);
			bgShape.graphics.drawRect(0, 0, w , h );
			
			
			m_container = new SripteWithRect();
			//m_container.graphics.beginFill(0);
			//m_container.graphics.drawRect(0 ,0, 100, 100);
			
			
			  if (_flag)
			  {
				var buttonList : Array  = new Array();
				var buttonAlignList : Array  = new Array();
				
         
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

/*				
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
*/
				
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
					var btn : BSSButton = new BSSButton(sprite);
			        buttonList.push(btn);
			        offsetX = -closeBtnH - 2;
			        btn.x = w + offsetX;
			        btn.y = 2;

			        
			        
			        buttonAlignList.push(
						new BSSLayoutInfo( btn.x - w , 2, BSSUIDEF.ALIGN_RIGHT )
						//null
					);

			    }


			    if (titleTextField)
			        titleTextField.width = w - 8 + offsetX;
                }

			   
				
				m_panel =  new BSSPanel(bgShape , null , null ,buttonList ,buttonAlignList ,_flag  );
				//m_panel.width = 1;
				//m_panel.height = 1;
				
				 m_panel.addChildAt(m_container , 0);
				 m_container.x = 5;
				 m_container.y = titleHeight;
				 m_container.redrawFunction = onRedrawRect;
				 
				 
				 m_panel.closeFunction = removeAllCi;
				 
		}
		
		private function removeAllCi(panel:BSSPanel):void
		{
			Graphics_Util.removeAllChildrenOfClass(m_container , ClassInstance);
			m_panel.visible = false;
			Graphics_Util.removeAllChildrenWithDispose(m_container);
		}
		
		
		
		
	}

}