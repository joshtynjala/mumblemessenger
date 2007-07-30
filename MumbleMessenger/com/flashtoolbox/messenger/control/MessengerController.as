package com.flashtoolbox.messenger.control
{
	import com.adobe.cairngorm.control.FrontController;
	import com.flashtoolbox.messenger.commands.*;
	import com.flashtoolbox.messenger.events.*;

	public class MessengerController extends FrontController
	{
		public function MessengerController()
		{
			super();
			
			this.addCommand(LoginEvent.LOGIN, LoginCommand);
			this.addCommand(LogoutEvent.LOGOUT, LogoutCommand);
			this.addCommand(AddNewContactEvent.ADD_CONTACT, AddNewContactCommand);
			this.addCommand(ContactActionEvent.REMOVE_CONTACT, RemoveContactCommand);
			this.addCommand(ContactActionEvent.OPEN_CONVERSATION, OpenConversationCommand);
			this.addCommand(ContactActionEvent.GET_PROFILE, GetProfileCommand);
		}
	}
}