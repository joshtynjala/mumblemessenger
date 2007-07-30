package com.flashtoolbox.messenger.views
{
	import flash.display.NativeWindow;
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import com.flashtoolbox.messenger.events.LoginEvent;
	import com.flashtoolbox.messenger.events.LogoutEvent;
	import com.flashtoolbox.messenger.model.MessengerModelLocator;
	import com.flashtoolbox.mumble.ContactEvent;
	import com.flashtoolbox.mumble.IContact;
	import com.flashtoolbox.mumble.aim.AIMService;
	import com.flextoolbox.controls.AdvancedTextInput;
	
	public class LoginFormBase extends VBox
	{
		
    //----------------------------------
	//  Constructor
    //----------------------------------
    
		public function LoginFormBase()
		{
			super();
		}
		
    //----------------------------------
	//  Properties
    //----------------------------------
		
		[Bindable]
		public var screenNameInput:AdvancedTextInput;
		
		[Bindable]
		public var passwordInput:AdvancedTextInput;
		
		[Bindable]
		protected var model:MessengerModelLocator = MessengerModelLocator.getInstance();
		
		private var profileWindow:ContactProfileWindow;
		
		private var conversations:Array = [];
		
		private var contactList:ContactList;
		
		private var contactToFind:IContact;
		private var windowToFind:NativeWindow;
		
		private var lastContact:IContact;
		private var lastContactMessage:String;
		
		private var lastContactProfile:String;
		
		public function set services(value:ArrayCollection):void
		{
			if(value.length > 0)
			{
				if(!this.contactList)
				{
					this.createContactList();
				}
			}
			else if(this.contactList)
			{
				this.contactList.close();
				this.contactList = null;
			}
			else this.stage.window.visible = true;
		}
		
    //----------------------------------
	//  Protected Methods
    //----------------------------------
		
		/**
		 * Begins the connection process.
		 */
		protected function connect():void
		{
			var login:LoginEvent = new LoginEvent(AIMService, this.screenNameInput.text, this.passwordInput.text);
			login.dispatch();
			//this.screenNameInput.text = "";
			this.passwordInput.text = "";
			this.stage.window.visible = false;
		}
		
    //----------------------------------
	//  Private Methods
    //----------------------------------
		
		private function createContactList():void
		{
			this.contactList = new ContactList();
			this.contactList.addEventListener(Event.CLOSING, mainWindowClosingHandler);
			this.contactList.open();
		}
		
		private function receiveMessageHandler(event:ContactEvent):void
		{
			this.contactToFind = event.contact;
			var matches:Array = this.conversations.filter(this.conversationIsWithContact);
			
			if(matches.length == 0)
			{
				this.openConversation(this.contactToFind, event.data as String);
			}
			
			this.contactToFind = null;
		}
		
		private function receiveProfileHandler(event:ContactEvent):void
		{
			var profile:String = event.data as String;
			if(this.profileWindow)
			{
				this.profileWindow.contact = event.contact;
				if(profile)
				{
					this.profileWindow.profile = profile;
				}
				
			}
			else
			{
				this.lastContact = event.contact;
				this.lastContactProfile = profile;
			}
		}
		
		public function openConversation(contact:IContact, message:String = null):void
		{
			var conversation:ConversationWindow = new ConversationWindow();
			conversation.screenName = contact.service.screenName;
			conversation.contact = contact;
			
			this.conversations.push(conversation);
			/*if(message)
			{
				var messageEvent:ContactEvent = new ContactEvent(ContactEvent.RECEIVE_MESSAGE, contact);
				messageEvent.data = message;
				contact.dispatchEvent(messageEvent);
			}*/
			
			conversation.open();
		}
		
		protected function updateProfileWindow(contact:IContact):void
		{
			if(!this.profileWindow)
			{
				this.profileWindow = new ContactProfileWindow();
				this.profileWindow.open();
				this.profileWindow.addEventListener(Event.CLOSE, profileWindowCloseHandler, false, 0, true);
			}
			
			this.profileWindow.contact = contact;
		}
		
		private function profileWindowCloseHandler(event:Event):void
		{
			this.profileWindow = null;
		}
		
		private function mainWindowClosingHandler(event:Event):void
		{
			this.closeConversations();
			this.contactList = null;
			
			var serviceCount:int = this.model.services.length;
			for(var i:int = 0; i < serviceCount; i++)
			{
				var logout:LogoutEvent = new LogoutEvent(this.model.services[i]);
				logout.dispatch();
			}
			this.stage.window.visible = true;
		}
		
		private function closeConversations():void
		{				
			var conversationCount:int = this.conversations.length;
			for(var i:int = conversationCount - 1; i >= 0; i--)
			{
				var conversation:ConversationWindow = this.conversations.pop() as ConversationWindow;
				conversation.close();
			}
		}
		
		private function contactIsOnline(contact:IContact, index:int, array:Array):Boolean
		{
			return contact.online;
		}
		
		private function conversationIsWithContact(conversation:ConversationWindow, index:int, array:Array):Boolean
		{
			return conversation.contact == this.contactToFind;
		}
		
		private function conversationIsInWindow(conversation:ConversationWindow, index:int, array:Array):Boolean
		{
			return conversation.stage.window == this.windowToFind;
		}
		
		private function conversationWindowCloseHandler(event:Event):void
		{
			this.windowToFind = event.target as NativeWindow;
			var matches:Array = this.conversations.filter(this.conversationIsInWindow);
			if(matches.length > 0)
			{
				var index:int = this.conversations.indexOf(matches[0]);
				if(index >= 0) this.conversations.splice(index, 1);
			}
		}
		
	}
}