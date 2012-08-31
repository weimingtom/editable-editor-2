package  
{
	import flash.display.Sprite;
	import UISuit.UIComponent.BSSButton;
	/**
	 * ...
	 * @author blueshell
	 */
	public class Toolbar extends SripteWithRect
	{
		
		public var btnNew : BSSButton;
		public var btnOpen : BSSButton;
		public var btnSave : BSSButton;
		public var btnCopy : BSSButton;
		public var btnExport : BSSButton;
		
		public function Toolbar() 
		{
			
			btnNew= BSSButton.createSimpleBSSButton(20, 20, StringPool.NEW , true);
			btnNew.x = 5;
			btnNew.y = 5 ;
			addChild(btnNew) ;
			
			btnOpen = BSSButton.createSimpleBSSButton(20, 20, StringPool.OPEN , true);
			btnOpen.x = btnNew.x + btnNew.width + 5;
			btnOpen.y = 5 ;
			addChild(btnOpen) ;
			
			btnSave =  BSSButton.createSimpleBSSButton(20, 20, StringPool.SAVE , true);
			btnSave.x = btnOpen.x + btnOpen.width + 5;
			btnSave.y = 5 ;
			addChild(btnSave) ;
			
			btnExport =  BSSButton.createSimpleBSSButton(20, 20, StringPool.EXPORT , true);
			btnExport.x = btnSave.x + btnSave.width + 5;
			btnExport.y = 5 ;
			addChild(btnExport) ;
			
			btnCopy =  BSSButton.createSimpleBSSButton(20, 20, StringPool.COPY , true);
			btnCopy.x = btnExport.x + btnExport.width + 5;
			btnCopy.y = 5 ;
			addChild(btnCopy) ;
			
			
			
		}
		
		public override function dispose()
		: void 
		{
			
			btnNew.dispose() ; btnNew = null;
			btnOpen.dispose() ; btnOpen = null;
			btnSave.dispose() ; btnSave = null;
			btnExport.dispose() ; btnExport = null;
			btnCopy.dispose() ; btnCopy = null;
		}
		
		
	}

}