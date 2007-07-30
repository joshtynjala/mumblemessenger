package com.flashtoolbox.messenger.events
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.flashtoolbox.mumble.IMessengerService;

	public class AddNewContactEvent extends CairngormEvent
	{
		public static const ADD_CONTACT:String = "addContact"
		
		public function AddNewContactEvent(service:IMessengerService, contactName:String, groupName:String = null)
		{
			super(AddNewContactEvent.ADD_CONTACT, false, false);
			this.service = service;
			this.contactName = contactName;
			this.groupName = groupName;
		}
		
		public var service:IMessengerService;
		public var contactName:String;
		public var groupName:String;
		
		override public function clone():Event
		{
			return new AddNewContactEvent(this.service, this.contactName, this.groupName);
		}
	}
}