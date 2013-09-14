package 
{
	import Alert.AlertPanelUsing;
	import Class.ClassMgr;
	import ClassInstance.ClassInstance;
	import ClassInstance.ClassInstanceMgr;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import Plug.PlugMgr;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSDropDownMenuScrollable;
	import UISuit.UIController.BSSPanel;
	import Alert.AlertPanel;
	
	/**
	 * ...
	 * @author blueshell
	 */
//	[SWF(frameRate = "30",width="770",height="740",backgroundColor="0xCCCCCC")]

	public class EditableEditor2 extends Sprite 
	{
		public static const STAGE_WIDTH : int = 1100;
		public static const STAGE_HEIGHT : int = 780;
		
		//public static var ins : EditableEditor2;
		public static var s_logTF : TextField;
		

		public function EditableEditor2() : void 
		{
			s_logTF = new TextField();
			s_logTF.width = STAGE_WIDTH - 45;
			s_logTF.height = STAGE_HEIGHT - 80;
			//s_logTF.border = true;
			
			s_logTF.x = 10;
			s_logTF.y = 40;
			
			//ins = this;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public static function onNew( btn : BSSButton = null)
		: void 
		{
			ClassInstanceMgr.removeUnResidentClassInstance();
		}
		
		private static function onSave( btn : BSSButton)
		: void 
		{
			var xml : XML = ClassInstanceMgr. exportInstance();
			new FileReference().save(xml , Version.filename);
		}
		
		private static function onExport( btn : BSSButton)
		: void 
		{
			var ba : ByteArray = ClassInstanceMgr.exportInstanceBin();
			new FileReference().save(ba , Version.filenameBin);
		}
		
		
		private static function onCopy( btn : BSSButton)
		: void 
		{
			var xml : XML = ClassInstanceMgr. exportInstance();
			System.setClipboard(xml);
		}
		
		private static var s_fbOpen : FileReference;
		private static function onOpen(btn : BSSButton)
		: void {
			s_fbOpen = new FileReference();
			s_fbOpen.addEventListener(Event.SELECT, onSelect);
			//fb.addEventListener(Event.CANCEL, onCancel);
			s_fbOpen.browse([new FileFilter("EditableEditor2 Save Files (*.exml)" , "*.exml")]);
			
		}
		

		private static function onSelect(event : Event)
		: void 
		{
			var fb : FileReference = FileReference(event.currentTarget);
			fb.removeEventListener(event.type, arguments.callee);
			Version.filename = fb.name;
			
			if (Version.filename.lastIndexOf(".exml") != -1)
				Version.filenameBin = Version.filename.replace(".exml" , ".exbn");
			
			trace("onSelect " + fb.name);
			
			fb.addEventListener(Event.COMPLETE , onSelectLoad);
			fb.load();
		}
		
		public static function onDeal(xml : XML)
		: void 
		{
			ClassInstanceMgr.readClassInstance(xml);
		}
		
		private static function onSelectLoad(event : Event)
		: void 
		{
			
			//DBG_TRACE("onSelectLoad ");
			var fb : FileReference = FileReference(event.currentTarget);
			fb.removeEventListener(event.type, arguments.callee);
			
			
			
			var xml : XML = new  XML((fb.data));
			s_fbOpen = null;
			
			onNew();
			onDeal(xml);
			
			//trace(xml);
		}
		

		private function init(e:Event = null):void 
		{
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = "noScale";
			stage.align = "LT";
			// entry point
			
			graphics.beginFill(0xEEEEEE);
			graphics.drawRect( 0 , 0 , stage.stageWidth , stage.stageHeight)
			
			var xmlConfig : XmlConfig = new XmlConfig(true);
			
			
			xmlConfig.endFunction = function () : void 
			{
				//addChild(new ClassInstance(ClassMgr.findClass("NPC")));
				//addChild(new ClassInstance(ClassMgr.findClass("ConditionList")));
				 var tb : Toolbar = new Toolbar();
				addChild(tb);
				tb.btnNew.releaseFunction = onNew;
				tb.btnSave.releaseFunction = onSave;
				tb.btnOpen.releaseFunction = onOpen;
				tb.btnCopy.releaseFunction = onCopy;
				tb.btnExport.releaseFunction = onExport;
				
				
				
				if (Page.s_pageArray.length <= 1)
				{
					Page.s_pageBtnArray[0].releaseFunction(Page.s_pageBtnArray[0]);
					Page.s_pageBtnArray[0].visible = false;
					Page.s_pageArray[0].y -= Page.s_pageBtnArray[0].height;
				}
				
				
				if (PlugMgr.s_hasPlug)
				{
					PlugMgr.s_plugBar.x = tb.x + tb.width + 20;
					addChild(PlugMgr.s_plugBar);
				}
			}
			xmlConfig.loadXml("config.xml");
			xmlConfig.pageFunction = pageFunction;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN , switchLayer);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL , onMouseWheel);
			
			
			var ap : AlertPanel = new AlertPanel();
			var _panel : BSSPanel = ap.getPanel();
			var _container : DisplayObjectContainer = ap.getContainer();
			addChild(_panel);

			ap.getPanel().x = 200;
			ap.getPanel().y = 200;
						
			AlertPanel.getSingleton().getPanel().visible = false;
			new AlertPanelUsing();
		}
		
		private function pageFunction(xml : XML)
		: Page 
		{
			var _page : Page = new Page(xml);
			addChild(_page).y = 28;
			return _page;
		}
		
		private static function switchLayer(e : MouseEvent)
		: void 
		{
			//return;
			
			var dsp : DisplayObject = DisplayObject(e.target);
			if (!dsp || !dsp.parent)
				return;
			do
			{
				if (dsp is SpriteWH)
				{	
					var p : DisplayObjectContainer = (dsp.parent);
					//p.removeChild(dsp);
					//p.addChild(dsp); //to top layer
					var total : int = p.numChildren - 1;
					for (var i : int = p.getChildIndex(dsp) ;  i < total; i++ )
						p.swapChildrenAt(
							i ,
							i+1
						); //change index but remain layerIndex
					
					//(dsp.parent).swapChildrenAt(
					//	(dsp.parent).getChildIndex(dsp)
					//	, ((dsp.parent).numChildren - 1)
					//);
				}
				dsp = dsp.parent;
			}
			while (dsp && dsp.parent && !(dsp is EditableEditor2));
		}
		
		private static function onMouseWheel(e : MouseEvent)
		: void 
		{
			CallBackMgr.CallBackMgr_notifyEvent(CALLBACK.ON_STAGE_MOUSE_WHEEL , [e] );
		}
	}
}