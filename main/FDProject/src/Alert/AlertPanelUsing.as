package Alert 
{
	import Class.ClassInstanceSelector;
	import ClassInstance.ClassInstance;
	import ClassInstance.ClassInstanceMgr;
	import UISuit.UIComponent.BSSButton;
	import UISuit.UIController.BSSPanel;
	/**
	 * ...
	 * @author BluesLiu
	 */
	public class AlertPanelUsing 
	{
		private var m_currentDelingCI  : ClassInstance;

		private var m_currentUsingCI : ClassInstance;
		private var m_currentUsingCIMenu : ClassInstance;
		private var m_currentSkipTestCI  : ClassInstance;
		
		public function AlertPanelUsing() 
		{
			CallBackMgr.CallBackMgr_registerCallBack(CALLBACK.ON_ALERT_INSTANCE_IS_USING , onAlertInstanceIsUsing , this);
		}
		
		public function dispose() : void {
			
			m_currentDelingCI = null;

			m_currentUsingCI = null;
			m_currentUsingCIMenu = null;
			
			m_currentSkipTestCI = null;
			
			CallBackMgr.CallBackMgr_unregisterCallBack(CALLBACK.ON_ALERT_INSTANCE_IS_USING , onAlertInstanceIsUsing , this);
		}
	
		
		private function onRetryUsing(btn:BSSButton) : void {
			
			if (m_currentUsingCI)
			{
				
				if (ClassInstanceMgr.checkIfUsingClassInstance(m_currentDelingCI , m_currentUsingCIMenu ))
				{
					//do nothing 
					return;
				}
				else
				{
					var _currentDelingCI : ClassInstance = m_currentDelingCI;
					var _currentSkipTestCI : ClassInstance = m_currentSkipTestCI;
					
					m_currentDelingCI = null;

					m_currentUsingCI = null;
					m_currentUsingCIMenu = null;
			
					m_currentSkipTestCI = null;
					
					AlertPanel.getSingleton().getPanel().visible = false;
					AlertPanel.getSingleton().removeAllChildren(false);
					
					ClassInstanceMgr.tryDeleteClassInstance(_currentDelingCI , _currentSkipTestCI);
					
					
					_currentDelingCI  = null;
					_currentSkipTestCI = null;
					
				}
				
			}
			
		}
		
		private function onCancelUsing(btn:BSSButton) : void {
			m_currentUsingCI = null;
			m_currentDelingCI  = null;
			AlertPanel.getSingleton().getPanel().closeFunction(AlertPanel.getSingleton().getPanel());
		}
		
		private  static function onAlertInstanceIsUsing (evtId :int , args : Array  , param1 : int , param2 : int , obj : Object )
		:void
		{	
				var _this : AlertPanelUsing = AlertPanelUsing(obj);
				
				
				
				//ASSERT(obj == AlertPanel.getSingleton() , "error");
				
				var selectInstance : ClassInstance = args[0] as ClassInstance;
				
				var titleText : String = StringPool.CLASS_INSRANCE_IS_USED;
				
				
				while (titleText.indexOf("%1") != -1)
					titleText = titleText.replace("%1" , selectInstance.className);
				while (titleText.indexOf("%2") != -1)
					titleText = titleText.replace("%2" , selectInstance.instanceName);
				
				AlertPanel.getSingleton().getPanel().visible = true;
				AlertPanel.getSingleton().getPanel().titleText = titleText;
				AlertPanel.getSingleton().removeAllChildren(false);
				
				//var ci : ClassInstance = 
				
				
				ASSERT(_this.m_currentDelingCI == null);
				ASSERT(_this.m_currentUsingCI == null);
				ASSERT(_this.m_currentUsingCIMenu == null);
				ASSERT(_this.m_currentSkipTestCI == null);
				
				_this.m_currentDelingCI = ClassInstance(args[0]);
				_this.m_currentUsingCI = ClassInstance(args[1]);
				_this.m_currentUsingCIMenu = ClassInstance(args[2]);
				_this.m_currentSkipTestCI = ClassInstance(args[3]);
				
					
				
				var tf:TextFieldWithWidth = new TextFieldWithWidth();
				//tf.text = "类 '"+ _this.m_currentUsingCI.className + "'" +  + "正在使用！";
				var label : String = StringPool.CLASS_INSRANCE_IS_USING_THIS_CLASS;
				while (label.indexOf("%1") != -1)
					label = label.replace("%1" , _this.m_currentUsingCI.className);
				while (label.indexOf("%2") != -1)
					label = label.replace("%2" , _this.m_currentUsingCI.instanceName);
				tf.text = label;
				AlertPanel.getSingleton().addChild(tf);
				
				var ci : ClassInstance = _this.m_currentUsingCI;

				if (ci)
				{
					ci.x = 20;
					ci.y = 20;
					
					AlertPanel.getSingleton().addChild(ci);
				}
				
				
				var btnRetry : BSSButton = BSSButton.createSimpleBSSButton(20 , 18 , StringPool.RETRY , true);
				
				var w : int = AlertPanel.getSingleton().getContainer().width;
				
				if (w < 200)
					w = 200;
					
				btnRetry.x = (w >> 1) - btnRetry.width - 20;
				btnRetry.y = ci.y + ci.height + 5;
				
				
				var btnCancel : BSSButton = BSSButton.createSimpleBSSButton(20 , 18 , StringPool.CANCEL , true);
				
				btnCancel.x = (w >> 1) + 20;
				btnCancel.y = btnRetry.y;
				
				
				AlertPanel.getSingleton().addChild(btnRetry);
				AlertPanel.getSingleton().addChild(btnCancel);
				
				btnRetry.releaseFunction = _this.onRetryUsing;
				btnCancel.releaseFunction = _this.onCancelUsing;

		}
	}
	

}