package com.flashtoolbox.messenger.commands
{
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.flashtoolbox.messenger.events.ContactActionEvent;
	import com.flashtoolbox.mumble.IContact;
	import com.flashtoolbox.messenger.views.ConversationWindow;
	import com.flashtoolbox.messenger.model.MessengerModelLocator;

	public class OpenConversationCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var model:MessengerModelLocator = MessengerModelLocator.getInstance();
			var openConversation:ContactActionEvent = event as ContactActionEvent;
			var contact:IContact = openConversation.contact;
			
			//if a conversation window has not been opened for this contact, create a new one.
			var conversationWindow:ConversationWindow = model.conversationWindows[contact];
			if(!conversationWindow)
			{
				conversationWindow = new ConversationWindow();
				conversationWindow.screenName = contact.service.screenName;
				conversationWindow.contact = contact;
				model.conversationWindows[contact] = conversationWindow;
				
				var history:ArrayCollection = model.messageHistory[contact];
				conversationWindow.history = history;
				model.messageHistory[contact] = null;
				
				conversationWindow.addEventListener(Event.CLOSING, conversationCloseHandler);
				conversationWindow.open();
			}
		}
		
		private function conversationCloseHandler(event:Event):void
		{
			var model:MessengerModelLocator = MessengerModelLocator.getInstance();
			
			var conversationWindow:ConversationWindow = event.target as ConversationWindow;
			conversationWindow.removeEventListener(Event.CLOSING, conversationCloseHandler);
			
			var contact:IContact = conversationWindow.contact;
			model.conversationWindows[contact] = null;
		}
		
	}
}