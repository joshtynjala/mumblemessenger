package com.flashtoolbox.messenger.business
{
	import com.flashtoolbox.mumble.ContactEvent;
	import com.flashtoolbox.mumble.IMessengerService;
	import com.flashtoolbox.mumble.MessengerServiceEvent;
	import com.flashtoolbox.mumble.MessengerServiceErrorEvent;
	import com.flashtoolbox.messenger.model.MessengerModelLocator;
	import com.flashtoolbox.messenger.views.ConversationWindow;
	import com.flashtoolbox.messenger.events.ContactActionEvent;
	import mx.collections.ArrayCollection;
	import com.flashtoolbox.mumble.IContact;
	import com.flashtoolbox.messenger.model.MessageHistoryItem;
	import com.flashtoolbox.mumble.aim.AIMService;
	import com.flashtoolbox.mumble.aim.AIMCommandEvent;
	
	public class AIMServiceDelegate
	{
		public function AIMServiceDelegate(service:IMessengerService, screenName:String, password:String):void
		{
			this.service = service;
			
			//comment out to stop listening for debug messages
			this.service.debugMode = true;
			
			this.service.addEventListener(MessengerServiceEvent.CONNECT, serviceConnectHandler);
			this.service.addEventListener(MessengerServiceEvent.DISCONNECT, serviceDisconnectHandler);
			this.service.addEventListener(MessengerServiceErrorEvent.ERROR, serviceErrorHandler);
			this.service.addEventListener(AIMCommandEvent.UNKNOWN_COMMAND, serviceUnknownCommandHandler);
			this.service.addEventListener(AIMCommandEvent.RECEIVE_COMMAND, serviceReceiveCommandHandler);
			
			this.service.connect(screenName, password);
		}
		
		protected var service:IMessengerService;
		protected var model:MessengerModelLocator = MessengerModelLocator.getInstance();
		
		protected function serviceConnectHandler(event:MessengerServiceEvent):void
		{
			this.model.serviceDelegates[this.service] = this;
			this.model.services.addItem(this.service);
			
			this.service.removeEventListener(MessengerServiceEvent.CONNECT, serviceConnectHandler);
			this.service.addEventListener(ContactEvent.UPDATE_STATUS, contactStatusUpdateHandler);
			this.service.addEventListener(ContactEvent.RECEIVE_MESSAGE, contactReceiveMessageHandler);
			this.service.addEventListener(ContactEvent.RECEIVE_PROFILE, contactReceiveProfileHandler);
			this.service.addEventListener(ContactEvent.CONTACT_ADDED, contactAddedHandler);
			this.service.addEventListener(ContactEvent.CONTACT_REMOVED, contactRemovedHandler);
		}
		
		protected function serviceDisconnectHandler(event:MessengerServiceEvent):void
		{
			trace("disconnect", event.data);
			//TODO: Watch out for contact references in the message histories
			
			this.service.removeEventListener(MessengerServiceEvent.DISCONNECT, serviceDisconnectHandler);
			this.service.removeEventListener(MessengerServiceErrorEvent.ERROR, serviceErrorHandler);
			this.service.removeEventListener(ContactEvent.UPDATE_STATUS, contactStatusUpdateHandler);
			this.service.removeEventListener(ContactEvent.RECEIVE_MESSAGE, contactReceiveMessageHandler);
			this.service.removeEventListener(ContactEvent.RECEIVE_PROFILE, contactReceiveProfileHandler);
			this.service.removeEventListener(ContactEvent.CONTACT_ADDED, contactAddedHandler);
			this.service.removeEventListener(ContactEvent.CONTACT_REMOVED, contactRemovedHandler);
			this.service.removeEventListener(AIMCommandEvent.UNKNOWN_COMMAND, serviceUnknownCommandHandler);
			this.service.removeEventListener(AIMCommandEvent.RECEIVE_COMMAND, serviceReceiveCommandHandler);
			
			var index:int = model.services.getItemIndex(this.service);
			if(index >= 0)
			{
				this.model.serviceDelegates[this.service] = null;
				this.model.services.removeItemAt(index);
			}
			else
			{
				//force a change event!
				this.model.services.refresh();
			}
		}
		
		protected function serviceErrorHandler(event:MessengerServiceErrorEvent):void
		{
			trace("error: " + event.time);
			if(!this.service.connected)
			{
				var index:int = this.model.services.getItemIndex(this.service);
				if(index >= 0)
				{
					this.model.services.removeItemAt(index);
				}
				else
				{
					this.model.services.refresh();
				}
			}
		}
		
		protected function contactStatusUpdateHandler(event:ContactEvent):void
		{
			//trace("status update:", event.contact.screenName, event.contact.groupName);
			this.model.services.refresh();
		}
		
		protected function contactReceiveMessageHandler(event:ContactEvent):void
		{
			var contact:IContact = event.contact;
			var conversationWindow:ConversationWindow = this.model.conversationWindows[contact] as ConversationWindow;
			if(!conversationWindow)
			{
				var history:ArrayCollection = model.messageHistory[contact];
				if(!history)
				{
					history = model.messageHistory[contact] = new ArrayCollection();
				}
				var messageData:MessageHistoryItem = new MessageHistoryItem(contact.screenName, event.data.toString());
				history.addItem(messageData);
				
				var openConversation:ContactActionEvent = new ContactActionEvent(ContactActionEvent.OPEN_CONVERSATION, event.contact);
				openConversation.dispatch();
			}
		}
		
		protected function contactReceiveProfileHandler(event:ContactEvent):void
		{
			
		}
		
		protected function contactAddedHandler(event:ContactEvent):void
		{
			this.model.rebuildContacts();
		}
		
		protected function contactRemovedHandler(event:ContactEvent):void
		{
			this.model.rebuildContacts();
		}
		
		protected function serviceUnknownCommandHandler(event:AIMCommandEvent):void
		{
			trace("unknown command:", event.command);
		}
		
		protected function serviceReceiveCommandHandler(event:AIMCommandEvent):void
		{
			trace("command: [" + event.command + "]");
		}
	}
}