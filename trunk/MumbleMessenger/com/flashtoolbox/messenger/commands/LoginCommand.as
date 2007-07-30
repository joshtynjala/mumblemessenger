package com.flashtoolbox.messenger.commands
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.rpc.IResponder;
	import com.adobe.cairngorm.commands.ICommand;
	import com.flashtoolbox.messenger.model.MessengerModelLocator;
	import com.flashtoolbox.mumble.IMessengerService;
	import com.flashtoolbox.messenger.events.LoginEvent;
	import com.flashtoolbox.mumble.MessengerServiceEvent;
	import com.flashtoolbox.mumble.MessengerServiceErrorEvent;
	import com.flashtoolbox.messenger.business.AIMServiceDelegate;
	import com.flashtoolbox.mumble.aim.AIMService;

	public class LoginCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var loginEvent:LoginEvent = event as LoginEvent;
			var service:IMessengerService = new loginEvent.serviceType();		
			switch(loginEvent.serviceType)
			{
				case AIMService:
					var aimDelegate:AIMServiceDelegate = new AIMServiceDelegate(service, loginEvent.screenName, loginEvent.password);
					break;
			}
		}
		
	}
}