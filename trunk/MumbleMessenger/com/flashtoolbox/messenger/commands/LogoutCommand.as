package com.flashtoolbox.messenger.commands
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.flashtoolbox.messenger.events.LogoutEvent;
	import com.flashtoolbox.mumble.IMessengerService;

	public class LogoutCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var logoutEvent:LogoutEvent = event as LogoutEvent;
			var service:IMessengerService = logoutEvent.service;
			service.disconnect();
		}
		
	}
}