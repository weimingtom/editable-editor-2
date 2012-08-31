
package   UISuit.UIComponent   {
//	IMPORT(flash.events.*)	
	import  flash.text.* ; 	
	import  flash.display.* ; 	
	import Util.GRA_Util.Graphics_Util;

	/**
	 * @author blueshell
	 */
	public class BSSCheckBox extends Sprite {
		
		private var selectBtn : BSSButton;
		private var unselectBtn : BSSButton;
			
		public var selectFunction : Function ;
		
		public function dispose()
		: void 
		{
			if (selectBtn)
			{
				selectBtn.dispose()
				selectBtn = null;
			}
			if (unselectBtn)
			{
				unselectBtn.dispose()
				unselectBtn = null;
			}
			selectFunction = null;
			

		}
		public function BSSCheckBox(data : DisplayObjectContainer)
		{
			
			selectBtn = new BSSButton((DisplayObjectContainer)(data.getChildAt(0)));
			unselectBtn = new BSSButton((DisplayObjectContainer)(data.getChildAt(1)));
			
			addChild (selectBtn);
			addChild (unselectBtn);
			selected = false;
			selectBtn.releaseFunction = setSelected;
			unselectBtn.releaseFunction = setSelected;

			x = data.x;
			y = data.y;
		}
		
		public function setSelected (caller : BSSButton )
		: void {
			selected = !selected;
			
			if (selectFunction!=null)
				selectFunction (this);
		}
		
		public static function createSimpleBSSCheckBox(w : int )
		: BSSCheckBox {
			var docRoot : Sprite = new Sprite();
			
			for (var i : int = 0 ; i < 2 ; i++ )
			{
				var doc : Sprite = new Sprite();
				
				var shape : Shape = new Shape();
				//var g : Graphics = spahe.graphics;
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, w , 0xFFFFFF , 0.7 , 0 ,0 ,0.1  );
				if (i == 1)
				{
					shape.graphics.lineStyle(w > 15 ? 1.5 : 1, 0);
					shape.graphics.moveTo(w * 0.15, w * 0.40);
					shape.graphics.lineTo(w * 0.30, w * 0.85);
					shape.graphics.lineTo(w * 0.95, w * 0.20);
				}
				
				doc.addChild (shape);

				shape = new Shape();
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, w , 0xFFFFFF , 0.9 , 0 ,0 ,0.5  );
				if (i == 1)
				{
					shape.graphics.lineStyle(w > 15 ? 1.5 : 1, 0);
					shape.graphics.moveTo(w * 0.15, w * 0.40);
					shape.graphics.lineTo(w * 0.30, w * 0.85);
					shape.graphics.lineTo(w * 0.95, w * 0.20);
				}
				doc.addChild (shape);

				shape = new Shape();
				Graphics_Util.DrawRect( shape.graphics , 0 , 0 , w, w , 0x62B0FF , 0.7 ,  0 , 0xFFFFFF ,0.5  );
				if (i == 0)
				{
					shape.graphics.lineStyle(w > 15 ? 1.5 : 1, 0);
					shape.graphics.moveTo(w * 0.15, w * 0.40);
					shape.graphics.lineTo(w * 0.30, w * 0.85);
					shape.graphics.lineTo(w * 0.95, w * 0.20);
				}
				doc.addChild (shape);
				docRoot.addChild (new BSSButton (doc , null , false , null));
			}

			return new BSSCheckBox(docRoot);
		}
		
		
		public function get selected  ( )
		: Boolean {
			
			return unselectBtn.visible;
		}
		
		 public function activate() 
		 : void {
			if (unselectBtn.visible)
				unselectBtn.activate();

			if (selectBtn.visible)
				selectBtn.activate();
		 }
		 
		 public function deactivate() 
		 : void {
			 unselectBtn.deactivate();
			 selectBtn.deactivate();
		 }
		 
		public function set selected( _selected : Boolean )
		: void {
			unselectBtn.visible = _selected;
			selectBtn.visible = !_selected;
			
			
			if (unselectBtn.visible)
				unselectBtn.activate();
			else
				unselectBtn.deactivate();
				
			if (selectBtn.visible)
				selectBtn.activate();
			else
				selectBtn.deactivate();
				
				
		}

/*
		public function set text ( str : String )
		: void 
		{
			unselectBtn.text =  str;
			selectBtn.text =  str;
		}
		public function get text (   )
		: String 
		{
			return selectBtn.text ;
		}
*/
		
	} 
} 
