package com.flashtoolbox.messenger.commands
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.flashtoolbox.messenger.model.MessengerModelLocator;
	import com.flashtoolbox.messenger.model.ContactListStatus;
	import com.flashtoolbox.messenger.events.AddNewContactEvent;
	import com.flashtoolbox.mumble.IMessengerService;
	import com.flashtoolbox.mumble.ContactEvent;

	public class AddNewContactCommand implements ICommand
	{
		protected var service:IMessengerService;
		
		public function execute(event:CairngormEvent):void
		{
			var addNewContact:AddNewContactEvent = event as AddNewContactEvent;
			
			this.service = addNewContact.service;
			this.service.addContact(addNewContact.contactName, addNewContact.groupName);
			this.service.addEventListener(ContactEvent.CONTACT_ADDED, contactAddedHandler);
		}
		
		public function contactAddedHandler(event:ContactEvent):void
		{
			this.service.removeEventListener(ContactEvent.CONTACT_ADDED, contactAddedHandler);
			this.service = null;
			
			var model:MessengerModelLocator = MessengerModelLocator.getInstance();
			model.contactListStatus = ContactListStatus.SUCCESS;
			model.contactListStatusMessage = "Contact added!";
		}
		
		/*public function fault(info:Object):void
		{
			var model:MessengerModelLocator = MessengerModelLocator.getInstance();
			model.contactListStatus = ContactListStatus.ERROR;
			model.contactListStatusMessage = "Error adding contact.";
		}*/
		
	}
}