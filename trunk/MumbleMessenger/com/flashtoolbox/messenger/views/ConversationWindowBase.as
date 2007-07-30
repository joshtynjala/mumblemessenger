package com.flashtoolbox.messenger.views
{
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import mx.core.Application;
	import mx.controls.TextArea;
	import mx.controls.Alert;
	import mx.controls.HTML;
	import mx.managers.SystemManager;
	import com.flashtoolbox.mumble.IContact;
	import com.flashtoolbox.mumble.ContactEvent;
	import mx.core.Window;
	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import com.flashtoolbox.messenger.model.MessageHistoryItem;

	public class ConversationWindowBase extends Window
	{
		
    //----------------------------------
	//  Constants
    //----------------------------------
    
		private static const FONT_SIZE_DIFFERENCE:uint = 8;
		
    //----------------------------------
	//  Constructor
    //----------------------------------
    
		public function ConversationWindowBase()
		{
			super();
		}
		
    //----------------------------------
	//  Properties
    //----------------------------------
		
		[Bindable]
		public var historyDisplay:HTML;
		
		[Bindable]
		public var editor:TextArea;
		
		private var _screenName:String;
		
		[Bindable]
		public function get screenName():String
		{
			return this._screenName;
		}
		
		public function set screenName(value:String):void
		{
			this._screenName = value;
		}
		
		private var _contact:IContact;
		
		protected var contactChanged:Boolean = false;
		
		[Bindable]
		public function get contact():IContact
		{
			return this._contact;
		}
		
		public function set contact(value:IContact):void
		{
			if(this._contact)
			{
				this._contact.removeEventListener(ContactEvent.RECEIVE_MESSAGE, receiveMessageHandler);
			}
			this._contact = value;
			this._contact.addEventListener(ContactEvent.RECEIVE_MESSAGE, receiveMessageHandler, false, 0, true);			
			this.contactChanged = true;
			this.invalidateProperties();
		}
		
		private var _history:ArrayCollection;
		
		protected var historyChanged:Boolean = false;
		
		public function get history():ArrayCollection
		{
			return this._history;
		}
		
		public function set history(value:ArrayCollection):void
		{
			this._history = value;
			this.historyChanged = true;
			this.invalidateProperties();
		}
		
    //----------------------------------
	//  Protected Methods
    //----------------------------------
    
		override protected function createChildren():void
		{
			super.createChildren();
			
			this.editor.addEventListener(KeyboardEvent.KEY_DOWN, checkForEnterKeyOnInput);
		}
		
    //----------------------------------
	//  Private Methods
    //----------------------------------
    
		private function checkForEnterKeyOnInput(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				this.sendMessage();
				setTimeout(clearEditor, 50);
			}
		}
		
		private function clearEditor():void
		{
			this.editor.text = "";
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.contactChanged)
			{
				if(this.contact)
				{
					this.title = this.contact.screenName;
				}
				else this.title = "No Contact";
				this.contactChanged = false;
			}
			
			if(this.historyChanged && this.history)
			{
				var iterator:IViewCursor = this.history.createCursor();
				while(!iterator.afterLast)
				{
					var data:MessageHistoryItem = iterator.current as MessageHistoryItem;
					this.addMessage(data.screenName, data.message);
					iterator.moveNext();
				}
				this.historyChanged = false;
			}
		}
		
		protected function receiveMessageHandler(event:ContactEvent):void
		{
			var fullMessage:String = event.data as String;
			this.addMessage(this.contact.screenName, fullMessage);
			
			this.window.focus();
		}
		

		protected function sendMessage():void
		{
			if(!this.contact.online)
			{
				trace("Cannot send message to " + this.contact.screenName + " because contact is not available.", "Contact is Offline");
				return;
			}
			
			var originalMessage:String = this.editor.text;
			this.editor.text = "";
			this.editor.validateNow();

			//clear line breaks, if any
			var editedMessage:String = "";
			for(var i:int = 0; i < originalMessage.length; i++)
			{
				if(originalMessage.charAt(i) != "\n" && originalMessage.charAt(i) != "\r")
					editedMessage += originalMessage.charAt(i);
			}

			this.addMessage(this.screenName, editedMessage);
			this.contact.sendMessage( editedMessage );
		}

		private function addMessage(screenName:String, message:String):void
		{
			var color:String = "0000ff";
			if(screenName != this.screenName)
			{
				color = "ff0000";
			}
			
			//this makes *very* invalid html, but webkit seems to handle it without too much trouble.
			this.historyDisplay.htmlText += 
				"<p><b><font color=\"#" + color + "\">" + screenName + ":</font></b> " + 
				message + "</p>";
			
			//scroll back to the bottom when we receive a message
			this.historyDisplay.validateNow();
			this.historyDisplay.verticalScrollPosition = this.historyDisplay.maxVerticalScrollPosition;
		}

	}
}