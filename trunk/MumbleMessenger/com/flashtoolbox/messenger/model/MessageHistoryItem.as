package com.flashtoolbox.messenger.model
{
	[Bindable]
	public class MessageHistoryItem
	{
		public function MessageHistoryItem(screenName:String, message:String):void
		{
			this.screenName = screenName;
			this.message = message;
		}
		
		public var screenName:String;
		public var message:String;
	}
}