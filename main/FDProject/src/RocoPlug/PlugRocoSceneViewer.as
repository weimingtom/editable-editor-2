package RocoPlug 
{
	import Class.ClassInstanceSelector;
	import Class.ClassInstanceSelectorMenu;
	import ClassInstance.ClassInstance;
	import Debugger.DBG_TRACE;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Plug.Plugin;
	import Plug.PlugView;
	import UISuit.UIComponent.BSSCheckBox;
	import UISuit.UIComponent.BSSDropDownMenu;
	
	
	
	
	public class PlugRocoSceneViewer extends Plugin implements PlugView
	{
		private var m_viewDsp : SceneViewer;
		public static var resRoot : String = "http://res.17roco.qq.com/res/scene/";
		private var s_currentInstance : ClassInstance;
		
		private function onSceneDelete(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void {
			var cls : ClassInstance = (ClassInstance)(args[0]);

			//DBG_TRACE(cls.instanceName , (s_editingSceneWithNPCInstance == null) ? null :  s_editingSceneWithNPCInstance.instanceName )
			if (cls == s_currentInstance )
			{
				s_currentInstance = null;
			}
		}
		
		private function onSceneChange(evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		: void 
		{
			if (args.length == 3)
			{
				//var cls : ClassInstance = (ClassInstance)(args[0]);
				//var bddms : ClassInstanceSelectorMenu = (ClassInstanceSelectorMenu)(args[2]);
				
			}
			else if (args.length == 2)
			{
				var cls : ClassInstance = (ClassInstance)(args[0]);
				s_currentInstance = cls;
				
				if (cls.classType.className == "SceneSelector")
				{
					var _bddm : BSSDropDownMenu = (BSSDropDownMenu)(args[1]);
					
					if (_bddm.selectedId)
					{
						var sId : int = int(cls.getChildClassInstanceValue());
						m_viewDsp.setSceneId( sId, _bddm.selectedString , resRoot);
					}
					else
						m_viewDsp.setSceneId( 0, null , resRoot);
				}
				
			}
			
		
		}
		
		public override function init() : void
		{
			if (xmlInfo && String(xmlInfo.@resRoot))
			{	
				resRoot = String(xmlInfo.@resRoot);
				DBG_TRACE("set resRoot " + resRoot);
			}
			m_viewDsp = new SceneViewer();
			//m_viewDsp.changeFunction = onAimposChange;
			
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_SELECTOR_CHANGE , onSceneChange , null);
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_INSTANCE_DELETE , onSceneDelete , null);
		}
		public function getDisplayObject() : DisplayObject
		{
			return m_viewDsp;
		}
		
		public function PlugRocoSceneViewer() 
		{
			plugName = "PlugRocoSceneViewer";
			
			//init();
		//	m_viewDsp.setSceneId( 1, "日" , resRoot);
			//addChild(getDisplayObject());
		}
		
		public function dispose() : void
		{
			m_viewDsp.dispose();
			m_viewDsp = null;
			CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_SELECTOR_CHANGE , onSceneChange , null);
			CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_INSTANCE_DELETE , onSceneDelete , null);
		}
	}
	
	
}
	


	import ClassInstance.ClassInstance;
	import Debugger.DBG_TRACE;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIComponent.BSSCheckBox;
	import Util.GRA_Util.Graphics_Util;
	/**
	 * ...
	 * @author blueshell
	 */
	
	 

	class AreaIndicate extends Sprite
	{
		public function AreaIndicate()
		{
			graphics.beginFill(0x44FF44 , 1);
			graphics.drawCircle(0, 0, 0.5);
			scaleX = scaleY = 50;
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_WHEEL , onChangeArea);
			addEventListener(MouseEvent.MOUSE_DOWN , onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP , onMouseUp);
			alpha = 0.5;
			
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			if (changeFunction != null)
				changeFunction(this);
		}
		public var changeFunction : Function;
		private function onMouseUp(e:MouseEvent):void 
		{
			alpha = 0.5;
			
			stopDrag();
			if (hasEventListener(MouseEvent.MOUSE_MOVE))
				removeEventListener(MouseEvent.MOUSE_MOVE , onMouseMove);
			
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			alpha = 0.75;
			
			parent.setChildIndex(this , parent.numChildren - 1);
			
			startDrag();
			if (!hasEventListener(MouseEvent.MOUSE_MOVE))
				addEventListener(MouseEvent.MOUSE_MOVE , onMouseMove);
		}
		
		private function onChangeArea(e:MouseEvent):void 
		{
			if (e.delta > 0)
			{
				scaleY += (e.shiftKey) ? 10 : 1;
				scaleX = scaleY ;
			}
			else if (e.delta < 0)
			{
				scaleY -= (e.shiftKey) ? 10 : 1;
				if (scaleY < 10)
					scaleY = 10;
				scaleX = scaleY ;
			} 
			
			if (changeFunction != null)
				changeFunction(this);
		}
		
		public function dispose()
		: void
		{
			if (!hasEventListener(MouseEvent.MOUSE_MOVE))
				addEventListener(MouseEvent.MOUSE_MOVE , onMouseMove);
			removeEventListener(MouseEvent.MOUSE_WHEEL , onChangeArea);
			removeEventListener(MouseEvent.MOUSE_DOWN , onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP , onMouseUp);
			changeFunction = null;
		}
	}
	 
	
	class NpcLoader extends Sprite
	{
		private var m_loader : Loader;
		private var m_btn : BSSButton;
		private var m_editingDNPCInstance : ClassInstance; //以后移到外面去
		
		
		public function onPosChange(npcLoader : NpcLoader)
		: void {
			
			if (m_editingDNPCInstance)
			{
				m_editingDNPCInstance.getChildClassInstance("xPos").setChildClassInstanceText("" + x );
				m_editingDNPCInstance.getChildClassInstance("yPos").setChildClassInstanceText("" + y );
			}
		}
		
		public function  NpcLoader()
		{
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_DOWN , onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP , onMouseUp);
		
			m_loader = new Loader();
			addChild(m_loader);
			m_loader.mouseChildren = m_loader.mouseEnabled = false;
			
			m_btn = BSSButton.createSimpleBSSButton(100 , 20 , "加载资源(尚未完成)" , true);
			m_btn.scaleX = m_btn.scaleY = 2;
			//m_btn.y = -40;
			//btn.visible = false;
			addChild(m_btn);
			
			m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE , onLoadComp);
			m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR , onLoadError);
			//m_loader.load(new URLRequest(resRoot + id +"/scene.swf"));
			
			changeFunction = onPosChange;
		}
	
		static private function onLoadError(e:IOErrorEvent):void 
		{
			var ldrInfo : LoaderInfo = (LoaderInfo)(e.target);
			ASSERT(false , "无法加载资源文件 [" + e.toString().split("URL:")[1] /*+ "\n"+ e*/);
		}
		public function resetNPC()
		: void
		{
			visible = false;
			graphics.clear();
			m_btn.visible = true;
			m_loader.unloadAndStop();
			m_editingDNPCInstance = null;
		}
		public function setNPC(_editingDNPCInstance : ClassInstance , rect : Rectangle)
		: void
		{
			graphics.lineStyle( 4 , 0xFFFF00, 0.8);
			graphics.beginFill(0, 0.125);
			graphics.drawRect(0 , -rect.height , rect.width , rect.height);
			x = rect.x ;
			y = rect.y
			m_editingDNPCInstance = _editingDNPCInstance;
		}
		
		private function onLoadComp(e : Event)
		: void 
		{
			graphics.clear();
			m_btn.visible = false;
			
			var ldrInfo : LoaderInfo = (LoaderInfo)(e.target);
			
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			if (changeFunction != null)
				changeFunction(this);
		}
		
		public var changeFunction : Function;
		private function onMouseUp(e:MouseEvent):void 
		{
			alpha = 1;
			stopDrag();
			if (hasEventListener(MouseEvent.MOUSE_MOVE))
				removeEventListener(MouseEvent.MOUSE_MOVE , onMouseMove);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			parent.parent.setChildIndex(parent , parent.parent.numChildren - 1); // fuck code 
			
			alpha = 0.5;
			startDrag();
			if (!hasEventListener(MouseEvent.MOUSE_MOVE))
				addEventListener(MouseEvent.MOUSE_MOVE , onMouseMove);
		}
		
		public function dispose()
		: void 
		{
			if (!hasEventListener(MouseEvent.MOUSE_MOVE))
				addEventListener(MouseEvent.MOUSE_MOVE , onMouseMove);
			removeEventListener(MouseEvent.MOUSE_DOWN , onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP , onMouseUp);
			
			m_btn.dispose() ; m_btn = null;
			
			Graphics_Util.removeAllChildrenWithDispose(this);
			
			
			m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE , onLoadComp);
			m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR , onLoadError);
			m_loader = null;
			
			m_editingDNPCInstance = null;

		}
		
	}
	class SceneViewer extends Sprite
	{

		private var m_sceneName : String;
		private var m_sceneId : int;
		private var m_loader : Loader;
		private var m_textField : TextField;
		
		private var m_fullSprite : Sprite = new Sprite();
		private var m_placehodeSprite : Sprite = new Sprite();
		private var m_content : Sprite  = new Sprite();
		private var m_dragBtn : BSSButton;
		
		private var m_nowSelectedRNPC : Boolean;
		private var m_nowSelectedDNPC : Boolean;
		private var m_rectIndicate : Shape = new Shape;
		//public static var resRoot : String = "http://res.17roco.qq.com/res/scene/"
		private var m_walkAreaBD : BitmapData;
		private var m_walkAreaBitmap : Bitmap;
		private var m_showWalkArea : BSSCheckBox = (BSSCheckBox.createSimpleBSSCheckBox(15));
		
		private var m_useAimPosTF : TextField;
		private var m_useAimPos : BSSCheckBox = (BSSCheckBox.createSimpleBSSCheckBox(15));
		private var m_useAimPosIndicate : AreaIndicate = new AreaIndicate();
		public var changeFunction : Function;
		
		private var m_npcLoader : NpcLoader = new NpcLoader();
		
		
		public function SceneViewer() 
		{
			m_content  = new Sprite();
			addChild(m_content);
			{	
				const titleHeight : int = 24;
				
				m_fullSprite.graphics.clear();
				m_fullSprite.graphics.beginFill(0xAAAAFF , 0.375);
				m_fullSprite.graphics.lineStyle(1 , 0x9999FF);
				m_fullSprite.graphics.drawRect(0, 0, 960 / 2 + 10 , 560 / 2 + titleHeight + 5);
				
				m_textField = new TextField();
				m_textField.width = 200;
				m_textField.height = titleHeight - 2;
				m_textField.x = 5;
				m_textField.y = 2;
				m_textField.selectable = false;
				m_textField.text = "选择场景时自动加载";
				m_fullSprite.addChild(m_textField);
								
				m_loader = new Loader();
				m_loader.x = 5;
				m_loader.y = titleHeight;
				m_loader.scaleX = m_loader.scaleY = 0.5;
				
				var maskShape : Shape = new Shape();
				maskShape.graphics.clear();
				maskShape.graphics.beginFill(0 );
				maskShape.graphics.drawRect(0, 0, 960 / 2  , 560 / 2 );
				maskShape.x = m_loader.x;
				maskShape.y = m_loader.y;
				
				m_loader.mask = maskShape;
				
				m_rectIndicate.x = m_loader.x;
				m_rectIndicate.y = m_loader.y;
				m_rectIndicate.scaleX = m_loader.scaleX;
				m_rectIndicate.scaleY = m_loader.scaleY;
				
				
				m_fullSprite.addChild(m_loader);
				m_fullSprite.addChild(maskShape);
				
				m_fullSprite.addChild(m_rectIndicate);
				
				
				
				
				m_content.addChild(m_fullSprite);
			}
			
			{
				var _textField : TextField = new TextField();
				_textField.width = 200;
				_textField.height = 20;
				_textField.x = 2;
				_textField.y = 2;
				_textField.text = "双击展开场景浏览器";
				_textField.selectable = false;
				_textField.width = _textField.textWidth + 4;
				m_placehodeSprite.addChild(_textField);
				
				m_placehodeSprite.graphics.clear();
				m_placehodeSprite.graphics.beginFill(0xAAAAFF , 0.1);
				m_placehodeSprite.graphics.lineStyle(1 , 0x9999FF);
				m_placehodeSprite.graphics.drawRect(0, 0, _textField.width + 2 , 20);
				m_content.addChild(m_placehodeSprite);
				m_placehodeSprite.visible = false;
				
				
				
				{
					_textField = new TextField();
					_textField.width = 100;
					_textField.height = titleHeight - 2;
					_textField.x = 180;
					_textField.y = 2;
					_textField.selectable = false;
					_textField.text = "显示行走区域";
					
					m_fullSprite.addChild(_textField);
					
				}
	
				{
					m_useAimPosTF = new TextField();
					m_useAimPosTF.width = 200;
					m_useAimPosTF.height = titleHeight - 2;
					m_useAimPosTF.x = 290;
					m_useAimPosTF.y = 2;
					m_useAimPosTF.selectable = false;
					m_useAimPosTF.text = "需指定行走目标(滚轮缩放(shift))";
					m_useAimPosTF.visible = false;
					m_fullSprite.addChild(m_useAimPosTF);
					
				}
				

			}
			m_content.mouseChildren = false;
			m_content.doubleClickEnabled = true;
			
			m_content.addEventListener(MouseEvent.DOUBLE_CLICK , swituchVisible);
			
			m_dragBtn = BSSButton.createHotSpotBSSButton( 1 , titleHeight);
			addChild(m_dragBtn);
			m_dragBtn.scaleX = m_fullSprite.width;
			m_dragBtn.pressFunction = function (btn : BSSButton) : void { startDrag();	}
			m_dragBtn.releaseFunction = function (btn : BSSButton) : void { stopDrag();	}
			
			m_dragBtn.doubleClickEnabled = true;
			m_dragBtn.addEventListener(MouseEvent.DOUBLE_CLICK , swituchVisible);
			
			m_showWalkArea.y = 3;
			m_showWalkArea.x = 260;
			addChild(m_showWalkArea);
			m_showWalkArea.selectFunction = function(cb : BSSCheckBox) : void { 
				if (m_walkAreaBitmap)
				{
					m_walkAreaBitmap.visible = m_showWalkArea.selected;
				}
				//m_walkAreaBitmap.x = 200;
				//DBG_TRACE(m_walkAreaBitmap.visible , m_walkAreaBitmap.parent, m_walkAreaBitmap.parent.parent);
			}
			
			m_useAimPos.y = 3;
			m_useAimPos.x = 465;
			m_useAimPos.visible = false;
			m_useAimPos.selectFunction = function(cb : BSSCheckBox) : void { 
				if (m_useAimPosIndicate)
				{	
					m_useAimPosIndicate.visible = m_useAimPos.visible && m_useAimPos.selected;
					useAimPosIndicateChangeFunction(m_useAimPosIndicate);
				}
			}
			
			
			addChild(m_useAimPosIndicate);
			m_useAimPosIndicate.changeFunction = useAimPosIndicateChangeFunction;
			m_useAimPosIndicate.visible = false;
			addChild(m_useAimPos);
			
			var _npcLoaderSp : Sprite = new Sprite();
			
			_npcLoaderSp.x = m_loader.x;
			_npcLoaderSp.y = m_loader.y;
			
			_npcLoaderSp.scaleX = m_loader.scaleX;
			_npcLoaderSp.scaleY = m_loader.scaleY;
			_npcLoaderSp.addChild(m_npcLoader); m_npcLoader.x = m_npcLoader.y = 100; m_npcLoader.visible = false;
			addChild(_npcLoaderSp);
			
			
			
			//setSceneId(57 , "宠物医院" , "");
			//setRect(new Rectangle(100, 20, 480, 50));
			
		}
		private function useAimPosIndicateChangeFunction(_useAimPosIndicate : AreaIndicate)
		: void 
		{
			if (changeFunction != null)
			{
				changeFunction(
				m_useAimPos
				,new Point((_useAimPosIndicate.x - m_loader.x) * 2 , (_useAimPosIndicate.y - m_loader.y) * 2)
				,_useAimPosIndicate.scaleX
				);
			}	

		}
		
		public function get isTinyMode()
		: Boolean
		{
			return !m_fullSprite.visible;
		}
		
		private function swituchVisible(e:MouseEvent):void 
		{
			//trace("swituchVisible");
			if (m_placehodeSprite)
			m_placehodeSprite.visible = !m_placehodeSprite.visible;
			if (m_fullSprite)
			m_fullSprite.visible = !m_fullSprite.visible;
			
			if (!m_fullSprite.visible)
				m_content.removeChild(m_fullSprite);
			else {
				m_content.addChild(m_fullSprite);
			}
			
			if (m_placehodeSprite.visible)
			{
				m_dragBtn.scaleX = m_placehodeSprite.width;
			}
			else
			{
				m_dragBtn.scaleX = m_fullSprite.width;
			}
			
			
			
			if (m_showWalkArea)
			m_showWalkArea.visible = m_fullSprite.visible;
			if (m_walkAreaBitmap)
			m_walkAreaBitmap.visible = m_fullSprite.visible && m_showWalkArea.selected;
			
			if (m_useAimPos)
			m_useAimPos.visible = m_useAimPosTF.visible = ((m_nowSelectedRNPC||m_nowSelectedDNPC) && !isTinyMode);
			if (m_useAimPosIndicate)
			m_useAimPosIndicate.visible = m_useAimPos.visible && m_useAimPos.selected;
			if (m_npcLoader)
			m_npcLoader.visible = (m_nowSelectedDNPC && !isTinyMode);
			
		}
		
		public function setCurrentRNPC(rect : Rectangle , pt : Point , area : int = 0)
		: void
		{
			m_nowSelectedRNPC = (rect != null );
			m_nowSelectedDNPC = false;
			
			m_rectIndicate.graphics.clear();
			if (rect)
			{
				m_rectIndicate.graphics.lineStyle( 4 , 0xFFFF00, 0.8);
				m_rectIndicate.graphics.drawRect(rect.x , rect.y , rect.width , rect.height);
			}
			
			

			m_useAimPos.visible = m_useAimPosTF.visible = (m_nowSelectedRNPC && m_fullSprite.visible);
			m_useAimPosIndicate.visible = false;
			
			if (pt)
			{
				m_useAimPos.selected = true;
				m_useAimPosIndicate.visible = m_useAimPos.visible;
				m_useAimPosIndicate.x =  m_loader.x + pt.x / 2;
				m_useAimPosIndicate.y =  m_loader.y + pt.y / 2;
				
				m_useAimPosIndicate.scaleX = m_useAimPosIndicate.scaleY = Math.max(5, area);
			}
			else
			{
				m_useAimPos.selected = false;
			}
		}
		
		
		public function setCurrentDNPC(_editingDNPCInstance : ClassInstance ,rect : Rectangle , aimposPt : Point , area : int = 0)
		: void
		{
			m_nowSelectedRNPC = false;
			m_nowSelectedDNPC = (rect != null );
			
			m_npcLoader.resetNPC();
		
			if (rect)
			{
				m_npcLoader.visible = (m_nowSelectedDNPC && !isTinyMode);
				m_npcLoader.setNPC(_editingDNPCInstance , rect);
			}
			
			m_useAimPos.visible = m_useAimPosTF.visible = (m_nowSelectedDNPC && !isTinyMode);
			m_useAimPosIndicate.visible = false;
			
			if (aimposPt)
			{
				m_useAimPos.selected = true;
				m_useAimPosIndicate.visible = (m_nowSelectedDNPC && !isTinyMode);
				m_useAimPosIndicate.x =  m_loader.x + aimposPt.x / 2;
				m_useAimPosIndicate.y =  m_loader.y + aimposPt.y / 2;
				
				m_useAimPosIndicate.scaleX = m_useAimPosIndicate.scaleY = Math.max(5, area);
			}
			else
			{
				m_useAimPos.selected = false;
			}
		}
		
		public function setSceneId(id : int , _sceneName : String , resRoot : String)
		: void
		{
			DBG_TRACE(_sceneName , id);
			if (m_sceneId != id)
			{
				if (m_walkAreaBD)
					m_walkAreaBD.fillRect(new Rectangle(0, 0, m_walkAreaBD.width , m_walkAreaBD.height) , 0x0);
				
				m_sceneId = id;
				m_loader.unloadAndStop();
				
				if (m_sceneId)
				{
					m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE , onLoadComp);
					DBG_TRACE("load: " + resRoot + id +"/scene.swf");
					
					m_loader.load(new URLRequest( resRoot + id +"/scene.swf"));
					
					m_sceneName = _sceneName;
				}
				else
				{
					m_sceneName = "";
				}
				m_textField.text = m_sceneName;
			}
		}
		
		private function dealWalkArea(walkDataArr : Array)
		: void 
		{						
				if (!walkDataArr)
					ASSERT(false , "无法获得行走区域数据 getWalkData() 返回null");
				if (!walkDataArr)
					return;
					
				if ( walkDataArr[0] == null)
					ASSERT(false , "无法获得行走区域数据 getWalkData[0] == null");
				if ( walkDataArr[0] == null)
					return;
					
				if ( !(walkDataArr[0] is Array))
					ASSERT(false , "无法获得行走区域数据 getWalkData[0] 不是数组" + typeof(walkDataArr[0]));
					
				if ( !(walkDataArr[0] is Array))
					return;
					
					
				if (m_walkAreaBD == null)
				{
					
					var rowArray : Array = (walkDataArr[0] as Array);
					m_walkAreaBD = new BitmapData(walkDataArr.length , rowArray.length  , true , 0 );
					//DBG_TRACE("m_walkAreaBD NEW")
					m_walkAreaBD.lock();
					
					m_walkAreaBitmap = new Bitmap(m_walkAreaBD);
					m_walkAreaBitmap.scaleX = m_walkAreaBitmap.scaleY = 5;
					m_walkAreaBitmap.x = m_loader.x;
					m_walkAreaBitmap.y = m_loader.y;
					m_fullSprite.addChild(m_walkAreaBitmap);

				}
				else
				{
					m_walkAreaBD.lock();
					//DBG_TRACE("m_walkAreaBD clear")
					m_walkAreaBD.fillRect(new Rectangle(0, 0, m_walkAreaBD.width , m_walkAreaBD.height) , 0x0);
					
				}
				
				for (var l : int = 0 ; l < walkDataArr.length; l++ )
				{
					rowArray = (walkDataArr[l] as Array);
					for (var  r : int = 0 ; r < rowArray.length; r++  ) 
					{
						if (rowArray[r] != 0)
						{
							m_walkAreaBD.setPixel32(l, r, 0x80FF0000);
						}
					}
				}
				m_walkAreaBD.unlock();
				m_walkAreaBitmap.visible = m_showWalkArea.selected;
				walkDataArr = null;
		}
		
		private function onLoadComp(e : Event)
		: void 
		{
			DBG_TRACE("load COMPLETE.");
			var ldrInfo : LoaderInfo = (LoaderInfo)(e.target);
			ldrInfo.removeEventListener(Event.COMPLETE , onLoadComp);
			
			
			var scene : Object = ldrInfo.content;
			if (scene["getWalkData"] as Function)
			{
				dealWalkArea((scene["getWalkData"] as Function)());
			}
			
			
			//ldrInfo.loader.unload();
		}
		
		public function dispose()
		: void
		{
			m_dragBtn.removeEventListener(MouseEvent.DOUBLE_CLICK , swituchVisible);
			m_dragBtn.dispose();
			m_dragBtn = null;
			
			Graphics_Util.removeAllChildrenWithDispose(m_content);
			m_content = null;
			m_content.removeEventListener(MouseEvent.DOUBLE_CLICK , swituchVisible);
			
			Graphics_Util.removeAllChildren(m_placehodeSprite);
			m_placehodeSprite = null;
			
			Graphics_Util.removeAllChildren(m_fullSprite);
			m_fullSprite = null;
			
			Graphics_Util.removeAllChildren(this);
			m_loader.unloadAndStop();
			m_loader = null;
			m_textField = null;
			m_sceneName = null;
			m_rectIndicate = null;
			

			m_npcLoader.dispose();  m_npcLoader = null;

			if (m_showWalkArea)
			{
				m_showWalkArea.dispose();
				m_showWalkArea = null;
			}
			
			if (m_walkAreaBD)
			{
				m_walkAreaBD.dispose();
				m_walkAreaBD = null;
			}
			m_walkAreaBitmap = null;
			
			if (m_useAimPos)
			{
				m_useAimPos.dispose();
				m_useAimPos = null;
			}
			m_useAimPosTF = null;
			m_useAimPosIndicate = null;
			Graphics_Util.removeAllChildrenWithDispose(m_content);
		}
		
	}