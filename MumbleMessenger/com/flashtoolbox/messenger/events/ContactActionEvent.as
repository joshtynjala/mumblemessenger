package com.flashtoolbox.messenger.events
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.flashtoolbox.mumble.ContactEvent;
	import com.flashtoolbox.mumble.IContact;

	public class ContactActionEvent extends CairngormEvent
	{
		public static const OPEN_CONVERSATION:String = "openConversation";
		public static const GET_PROFILE:String = "getProfile";
		public static const REMOVE_CONTACT:String = "removeContact"
		
		public function ContactActionEvent(type:String, contact:IContact)
		{
			super(type, false, false);
			this.contact = contact;
		}
		
		public var contact:IContact;
		
		override public function clone():Event
		{
			return new ContactActionEvent(this.type, this.contact);
		}
		
	}
}