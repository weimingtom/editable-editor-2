package  Plug
{
	import ClassInstance.ClassInstanceMgr;
	import Debugger.DBG_TRACE;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import Plug.Plugin;
	import UISuit.UIComponent.BSSButton;
	/**
	 * ...
	 * @author blueshell
	 */
	public class PlugMgr
	{

		public static var s_hasPlug : Boolean = false;
		public static var s_plugBar : SripteWithRect;
		
		
		public static var s_plugArray : Vector.<Plugin> = new Vector.<Plugin>();
		public static var s_plugXmlInfoArray : Vector.<XML> = new Vector.<XML>();
		public static var s_plugBtnArray : Vector.<BSSButton> = new Vector.<BSSButton>();
		
		public static var s_plugLoaderArray : Vector.<Loader> = new Vector.<Loader>();
		
		public static function addPlug(data : String , xmlInfo : XML ): void
		{
			DBG_TRACE("addPlug " + xmlInfo.@name , data);
			if (!s_hasPlug)
			{
				s_hasPlug = true;
				s_plugBar  = new SripteWithRect();
			}
			var ldr : Loader = new Loader();
			
			var id : int = s_plugArray.length;
			
			s_plugXmlInfoArray.push(xmlInfo);
			s_plugArray.push(null);
			ldr.name = "" + id + "|" + data; // xmlInfo.@name;
			
			//DBG_TRACE("ldr.name ",ldr.name , s_plugXmlInfoArray[id].@name );
			
			//ldr.contentLoaderInfo.addEventListener(Event.COMPLETE , onLoadComp);
			//var context : LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
			//context.applicationDomain = ApplicationDomain.currentDomain;
			//ldr.load(new URLRequest(data) , context);

			s_plugLoaderArray.push(ldr);
			if (s_plugLoaderArray.length == 1)
			{
				s_plugLoaderArray[0].contentLoaderInfo.addEventListener(Event.COMPLETE , onLoadComp);
				s_plugLoaderArray[0].load(new URLRequest(s_plugLoaderArray[0].name.split("|")[1]) , new LoaderContext(true, ApplicationDomain.currentDomain));
			}
			
		}
		
		
		private static function onLoadComp(e : Event)
		: void 
		{
			var ldrInfo : LoaderInfo = (LoaderInfo)(e.target);
			ldrInfo.removeEventListener(Event.COMPLETE , onLoadComp);

			var ldr : Loader = ldrInfo.loader;
			var id : int = int(ldrInfo.loader.name.split("|")[0]);
			//DBG_TRACE(ldrInfo.loader.name , id ,ldrInfo.loader.name.split("|"),ldrInfo.loader.name.split("|")[0], s_plugXmlInfoArray[id].@name);
			
			var btn : BSSButton = BSSButton.createSimpleBSSButton(100 , 20, s_plugXmlInfoArray[id].@name , true , s_plugBtnArray);
			if (s_plugBtnArray.length <  id + 1)
				s_plugBtnArray.length =  id + 1;
			s_plugBtnArray[id]  = btn;
			//if (s_plugBtnArray[id] != btn)
			//{
			//	var sBtn : BSSButton = s_plugBtnArray[id];
			//}
			btn.y = 5 ;
			 
			 if (s_plugBar.numChildren)
			 {
				btn.x = 5 + s_plugBar.getChildAt(s_plugBar.numChildren - 1).x + s_plugBar.getChildAt(s_plugBar.numChildren - 1).width;
			}
			else
				btn.x = 5;
			s_plugBar.addChild(btn);
			btn.releaseFunction = onPlug;
			
			ASSERT(ldrInfo.content is Plugin, ("error get class"));
			s_plugArray[id] = (ldrInfo.content as Plugin);
			s_plugArray[id].xmlInfo = s_plugXmlInfoArray[id];
			s_plugArray[id].newFunction = EditableEditor2.onNew;
			s_plugArray[id].dealFunction = EditableEditor2.onDeal;
			s_plugArray[id].init();
			
			ldrInfo.loader.unload();
			
			
			ASSERT(s_plugLoaderArray.length == 0 || s_plugLoaderArray[0] == ldrInfo.loader);
			s_plugLoaderArray.shift();
			//trace(s_plugLoaderArray.length)
			if ( s_plugLoaderArray.length )
			{
				s_plugLoaderArray[0].contentLoaderInfo.addEventListener(Event.COMPLETE , onLoadComp);
				s_plugLoaderArray[0].load(new URLRequest(s_plugLoaderArray[0].name.split("|")[1]) , new LoaderContext(true, ApplicationDomain.currentDomain));
			}
			
			ldrInfo = null;
		}		
		
		
		
		static private function onPlug( btn : BSSButton)
		:void
		{
			var id : int = s_plugBtnArray.indexOf(btn);
			
			var plugin : Plugin = s_plugArray[id];
			
			if (plugin is PlugOutput)
			{
				PlugOutput(plugin).setData(ClassInstanceMgr. exportInstance());
			}
			else if (plugin is PlugInput)
			{
				PlugInput(plugin).getData();
			}
			else if (plugin is PlugView)
			{
				var dsp : DisplayObject = PlugView(plugin).getDisplayObject();
				if (dsp.x < 20)
					dsp.x = 20;
				if (dsp.y < 80) 
					dsp.y = 80;
				//dsp.y = EditableEditor.STAGE_HEIGHT- dsp.height - 120;
				s_plugBar.stage.addChild(dsp);
			}
			else
			{
				ASSERT(false , "unknow data");
			}
			
		}
	}

}