package 
{
	
	/**
	 * ...
	 * @author Blueshell
	 */
		
		public function log(_str : String) : void
		{
			if (EditableEditor2.s_logTF && _str)
			{
				EditableEditor2.s_logTF.appendText("\n");
				EditableEditor2.s_logTF.appendText(_str);
				//if (EditableEditor2.s_logTF.text.length >= 4000)
				//	EditableEditor2.s_logTF.text = EditableEditor2.s_logTF.text.substr(3800);
					
				EditableEditor2.s_logTF.scrollV = EditableEditor2.s_logTF.maxScrollV;
				
				
			}
		}
	 
	 
	 

}