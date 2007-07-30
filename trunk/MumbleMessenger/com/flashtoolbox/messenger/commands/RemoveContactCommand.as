package com.flashtoolbox.messenger.commands
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.flashtoolbox.messenger.events.ContactActionEvent;
	import com.flashtoolbox.mumble.IContact;
	import com.flashtoolbox.mumble.IMessengerService;

	public class RemoveContactCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var removeContact:ContactActionEvent = event as ContactActionEvent;
			
			var contact:IContact = removeContact.contact;
			var service:IMessengerService = contact.service;
			service.removeContact(contact);
		}
		
	}
}