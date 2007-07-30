////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2007 Josh Tynjala
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.flashtoolbox.mumble.aim
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.flashtoolbox.mumble.IMessengerService;
	import com.flashtoolbox.mumble.IContact;
	import com.flashtoolbox.mumble.MessengerServiceEvent;
	import com.flashtoolbox.mumble.ContactEvent;

	public class AIMService extends EventDispatcher implements IMessengerService
	{		
		
	//--------------------------------------
	//  Class Constants
	//--------------------------------------
	
		private static const AUTHORIZATION_SERVER:String = "login.oscar.aol.com";
		private static const AUTHORIZATION_PORT:int = 29999;
		private static const USER_AGENT:String = "\"TIC:TOC\"";
		private static const PROTOCOL_IDENTIFIER:String = "TOC2.0";
		private static const FLAPON:String = "FLAPON\r\n\r\n";
		private static const TIMOUT_DURATION:int = 10000;
		
		private static const HEADER_LENGTH:int = 6;
		
		//TOC2 messages from the client
		private static const CLIENT_INIT_DONE:String = "toc_init_done";
		private static const CLIENT_SIGN_ON:String = "toc2_signon";
		private static const CLIENT_SEND_IM:String = "toc2_send_im";
		private static const CLIENT_GET_INFO:String = "toc_get_info";
		private static const CLIENT_SET_INFO:String = "toc_set_info";
		private static const CLIENT_SET_AWAY:String = "toc_set_away";
		private static const CLIENT_NEW_BUDDIES:String = "toc2_new_buddies";
		private static const CLIENT_REMOVE_BUDDY:String = "toc2_remove_buddy";
		
		//commands from the server
		private static const SERVER_CONFIG:String = "CONFIG2";
		private static const SERVER_SIGN_ON:String = "SIGN_ON";
		private static const SERVER_UPDATE_BUDDY:String = "UPDATE_BUDDY2";
		private static const SERVER_ERROR:String = "ERROR";
		private static const SERVER_IM_IN:String = "IM_IN2";
		private static const SERVER_NICK:String = "NICK";
		private static const SERVER_GOTO_URL:String = "GOTO_URL";
		private static const SERVER_NEW_BUDDY:String = "NEW_BUDDY_REPLY2";
		private static const SERVER_CLIENT_EVENT:String = "CLIENT_EVENT2";
		private static const SERVER_UPDATED:String = "UPDATED2";
		private static const SERVER_INSERTED:String = "INSERTED2";
		private static const SERVER_DELETED:String = "DELETED2";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * @param host		the server in which to connect
		 * @param port		the port on the server in which you are connecting
		 */
		public function AIMService(host:String = "aimexpress.oscar.aol.com", port:int = 5190)
		{
			this.host = host;
			this.port = port;
		}	
		
	//--------------------------------------
	//  Variables and Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The URL of the server to which the protocol connects.
		 */
		private var host:String;
		
		/**
		 * @private
		 * The TCP port on the server.
		 */
		private var port:int;
		
		private var socket:Socket;
		
		private var password:String;
	
		private var loggedIn:Boolean = false;
	
		/**
		 * @storage for the screenName property.
		 */
		private var _screenName:String;
		
		public function get screenName():String
		{
			return this._screenName;
		}
	
		/**
		 * @private
		 * The sequence number ensures that the client and the server stay in sync.
		 */
		private var sequence:int;
		
		/**
		 * @private
		 * Storage for the contacts property.
		 */
		private var _contacts:Array = [];
		
		public function get contacts():Array
		{
			return this._contacts;
		}
		
		public function get connected():Boolean
		{
			return this.socket && this.socket.connected;
		}
		
		/**
		 * @private
		 * The timer used to catch lost connections on login.
		 */
		private var connectionTimer:Timer;
		
		private var nextCommandLength:int = -1;
		
		/**
		 * @private
		 * Loads in profile text.
		 */
		private var _profileLoader:URLLoader;
		
		/**
		 * The last contact whose profile was requested.
		 */
		private var _lastProfileContact:IContact;
		
		/**
		 * @private
		 * Storage for the debugMode property.
		 */
		private var _debugMode:Boolean = false;
		
		/**
		 * If true, an AIMCommandEvent.RECEIVE_COMMAND event will be dispatched
		 * for every command received from the server, whether it is handled or not.
		 */
		public function get debugMode():Boolean
		{
			return this._debugMode;
		}
		
		/**
		 * @private
		 */
		public function set debugMode(value:Boolean):void
		{
			this._debugMode = value;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#connect
		 */
		public function connect(screenName:String, password:String):void
		{
			//close the socket if the connection is already made
			if(this.socket && this.socket.connected)
			{
				this.disconnect();
			}
			
			this._screenName = screenName;
			this.password = password;
			
			this.socket = new Socket();
			this.socket.addEventListener(Event.CONNECT, socketConnectHandler);
			this.socket.addEventListener(Event.CLOSE, socketCloseHandler);
			this.socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler);
			this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler);
			this.socket.connect(this.host, this.port);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#disconnect
		 */
		public function disconnect(message:String = null):void
		{
			this.loggedIn = false;
			
			if(this.socket && this.socket.connected)
			{
				this.socket.close();
			}
			
			var disconnectEvent:MessengerServiceEvent = new MessengerServiceEvent(MessengerServiceEvent.DISCONNECT, message);
			this._screenName = null;
			this.password = null;
			this._contacts = [];
			this.dispatchEvent(disconnectEvent);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#sendMessage
		 */
		public function sendMessage(contact:IContact, message:String):void
		{
			if(!this.connected)
			{
				throw new Error("Must be connected to send a message.");
				return;
			}
			
			var sendImCommand:ByteArray = new ByteArray();
			sendImCommand.writeUTFBytes(CLIENT_SEND_IM + " " + AIMUtil.normalizeScreenName(contact.screenName) + " \"" + message + "\" F");
			this.sendClientCommand(sendImCommand);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#getContactProfile
		 */
		public function getContactProfile(contact:IContact):void
		{
			if(!this.connected)
			{
				throw new Error("Must be connected to retrieve a profile.");
				return;
			}
			
			if(this._profileLoader)
			{
				this._profileLoader.close();
				this._lastProfileContact = null;
			}
			
			this._lastProfileContact = contact;
			
			var getInfoCommand:ByteArray = new ByteArray();
			getInfoCommand.writeUTFBytes(CLIENT_GET_INFO + " " + AIMUtil.normalizeScreenName(contact.screenName));
			this.sendClientCommand(getInfoCommand);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#setUserProfile
		 */
		public function setUserProfile(profile:String):void
		{
			if(!this.connected)
			{
				throw new Error("Must be connected to set profile.");
				return;
			}
			
			var setInfoCommand:ByteArray = new ByteArray();
			setInfoCommand.writeUTFBytes(CLIENT_SET_INFO + " \"" + profile + "\"");
			this.sendClientCommand(setInfoCommand);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#setStatusMessage
		 */
		public function setStatusMessage(message:String):void
		{
			if(!this.connected)
			{
				throw new Error("Must be connected to set status.");
				return;
			}
			
			var setAwayCommand:ByteArray = new ByteArray();
			setAwayCommand.writeUTFBytes(CLIENT_SET_AWAY + " \"" + message + "\"");
			this.sendClientCommand(setAwayCommand);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#addContact
		 */
		public function addContact(screenName:String, groupName:String):void
		{
			if(!this.connected)
			{
				throw new Error("Must be connected to add a contact.");
				return;
			}
			
			var newContact:AIMContact = new AIMContact(screenName);
			newContact.groupName = groupName;
			newContact.service = this;
			this.contacts.push(newContact);
			
			var addContactCommand:ByteArray = new ByteArray();
			addContactCommand.writeUTFBytes(CLIENT_NEW_BUDDIES + " " +  "{g:" + groupName + "\nb:" + AIMUtil.normalizeScreenName(screenName) + "\n}");
			this.sendClientCommand(addContactCommand);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#removeContact
		 */
		public function removeContact(contact:IContact):void
		{
			if(!this.connected)
			{
				throw new Error("Must be connected to remove a contact.");
				return;
			}
			
			var removeContactCommand:ByteArray = new ByteArray();
			removeContactCommand.writeUTFBytes(CLIENT_REMOVE_BUDDY + " " +  AIMUtil.normalizeScreenName(contact.screenName) + " \"" + contact.groupName + "\"");
			this.sendClientCommand(removeContactCommand);
			
			//for some reason, we don't get a response back from the server
			//when we remove a contact.
			//well... we do, but its a weird INSERTED2 command, and I'm not sure I trust it
			var index:int = this.contacts.indexOf(contact);
			this.contacts.splice(index, 1);
			var removeContactEvent:ContactEvent = new ContactEvent(ContactEvent.CONTACT_REMOVED, contact);
			this.dispatchEvent(removeContactEvent);
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#screenNameToContact
		 */
		public function screenNameToContact(contactName:String):IContact
		{
			contactName = contactName.toLowerCase();
			var contactCount:int = this._contacts.length;
			for(var i:int = 0; i < contactCount; i++)
			{
				var contact:AIMContact = this._contacts[i] as AIMContact;
				if(contact.screenName.toLowerCase() == contactName)
				{
					return contact;
				}
			}
			return null;
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Handles the unexpected loss of socket connections.
		 */
		private function socketCloseHandler(event:Event):void
		{
			if(this.loggedIn)
			{
				this.disconnect("Connection lost.");
			}
		}
		
		/**
		 * @private
		 * Once the socket is connected, send the FLAPON message to start the communication with AOL's servers.
		 */
		private function socketConnectHandler(event:Event):void
		{
			this.loggedIn = true;
			
			//there is a chance that the connection will time out without any warning.
			//if we haven't stopped this timer by that point, we're going to disconnect.
			this.connectionTimer = new Timer(TIMOUT_DURATION, 1);
			this.connectionTimer.addEventListener(TimerEvent.TIMER, connectionTimeOutHandler);
			this.connectionTimer.start();
			
			this.socket.removeEventListener(Event.CONNECT, socketConnectHandler);
			this.socket.addEventListener(ProgressEvent.SOCKET_DATA, socketConnectionResponseHandler);
			this.socket.writeUTFBytes(FLAPON);
			this.socket.flush();
		}
		
		/**
		 * @private
		 * Should the connection fail to be completed before a certain timeout
		 * threshold, force a full disconnect.
		 */
		private function connectionTimeOutHandler(event:TimerEvent):void
		{
			this.disconnect("Failed to establish the connection. Please try again later.");
		}
		
		/**
		 * @private
		 * Called when the socket and the server stop communicating. Typically, the server
		 * receives a bad command and drops the connection.
		 */
		private function socketIOErrorHandler(event:IOErrorEvent):void
		{
			this.disconnect("Connection lost. IO Error.");
		}
		
		/**
		 * @private
		 * Called when the Flash Player encounters a sandbox security error.
		 * Disconnects automatically.
		 */
		private function socketSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			this.disconnect("Connection lost. Security Error.");
		}
		
		/**
		 * @private
		 * Confirms an acknowledgement to the FLAPON command, and passes
		 * control to the main message handler.
		 */
		private function socketConnectionResponseHandler(event:ProgressEvent):void
		{
			this.socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketConnectionResponseHandler)
			this.socket.addEventListener(ProgressEvent.SOCKET_DATA, socketReceiveDataHandler);
			this.signOn();
		}
		
		/**
		 * @private
		 * Initialize the sequence number and sign on to the AIM service.
		 */
		private function signOn():void
		{
			//SET UP NEEDED DATA FOR SIGN-IN
			this.sequence = Math.floor(Math.random() * 65536); //create a random sequence number
			var normalizedUserName:String = AIMUtil.normalizeScreenName(this.screenName);
			var roastedPassword:String = AIMUtil.roast(this.password);
			var signOnCode:int = AIMUtil.getSignOnCode(normalizedUserName, this.password);
			
			//TOC FLAP SIGNON FROM CLIENT
			var signOnResponse:ByteArray = new ByteArray();
			signOnResponse.writeInt(1);
			signOnResponse.writeShort(1);
			signOnResponse.writeShort(normalizedUserName.length);
			signOnResponse.writeUTFBytes(normalizedUserName);
			signOnResponse = AIMUtil.createTocMessage(AIMUtil.FLAP_SIGNON, this.sequence, signOnResponse);
			this.socket.writeBytes(signOnResponse);
			this.socket.flush();
			this.sequence++;
			
			//client sends sign on message
			var signOnCommand:ByteArray = new ByteArray();
			signOnCommand.writeUTFBytes(CLIENT_SIGN_ON + " " + AUTHORIZATION_SERVER + " " + AUTHORIZATION_PORT.toString() + " " + normalizedUserName + " " + roastedPassword + " english " + USER_AGENT +  " 160 " + signOnCode.toString());
			this.sendClientCommand(signOnCommand);
		}
		
		private function sendClientCommand(command:ByteArray):void
		{
			var tocMessage:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, command);
			this.socket.writeBytes(tocMessage);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @private
		 * Handles messages that are received from the server.
		 */
		private function socketReceiveDataHandler(event:ProgressEvent):void
		{
			//make sure we've received a message longer than the length of a TOC2 header
			while(this.socket.bytesAvailable >= 0)
			{
				if(this.socket.bytesAvailable >= HEADER_LENGTH && this.nextCommandLength < 0)
				{
					this.socket.readInt(); //skip the header
					this.nextCommandLength = this.socket.readShort();
				}
				
				//we should have messageLength bytes left, but check just in case
				//EOF has been encountered, even though messageLength > 0
				if(this.nextCommandLength > 0 && this.socket.bytesAvailable >= this.nextCommandLength)
				{
					var commandBody:String = this.socket.readUTFBytes(this.nextCommandLength);
					this.nextCommandLength = -1;
					this.parseServerCommand(commandBody);
				}
				else break;
			}
		}
		
		/**
		 * @private
		 * Reads and parses commands sent from the server.
		 * 
		 * @param message		the raw server command
		 */
		private function parseServerCommand(command:String):void
		{
			if(command.indexOf(SERVER_SIGN_ON) == 0)
			{
				this.processSignOnCommand(command);
			}
			else if(command.indexOf(SERVER_CONFIG) == 0)
			{
				this.processConfigCommand(command);
			}
			else if(command.indexOf(SERVER_UPDATE_BUDDY) == 0)
			{
				this.processUpdateBuddyCommand(command);
			}
			else if(command.indexOf(SERVER_ERROR) == 0)
			{
				this.processErrorCommand(command);
			}
			else if(command.indexOf(SERVER_IM_IN) == 0)
			{
				this.processImInCommand(command);
			}
			else if(command.indexOf(SERVER_NICK) == 0)
			{
				var nickMessageParts:Array = command.split(":");
				this._screenName = nickMessageParts[1]; //get the formatted version
			}
			else if(command.indexOf(SERVER_GOTO_URL) == 0)
			{
				this.processGotoURLCommand(command);
			}
			else if(command.indexOf(SERVER_NEW_BUDDY) == 0)
			{
				this.processNewBuddyCommand(command);
			}
			else if(command.indexOf(SERVER_INSERTED) == 0)
			{
				this.processInsertCommand(command);
			}
			else if(command.indexOf(SERVER_DELETED) == 0)
			{
				this.processDeleteCommand(command);
			}
			else if(command.length == 0)
			{
				//Occasionally, we get a blank message from the server.
				//This is a good time to send a keep-alive message back.
				this.sendKeepAlive();
			}
			else
			{
				//Any other messages we get might be interesting to client
				this.handleUnknownCommand(command);
			}
			
			if(this.debugMode)
			{
				var commandEvent:AIMCommandEvent = new AIMCommandEvent(AIMCommandEvent.RECEIVE_COMMAND, command);
				this.dispatchEvent(commandEvent);
			}
		}
		
	//-- Specific server command processing
		
		/**
		 * @private
		 * Reads and parses a SIGN_ON command
		 * 
		 * @param command		the raw server command
		 */
		private function processSignOnCommand(command:String):void
		{
			var commandParts:Array = command.split(":");
			if(commandParts.length >= 2)
			{
				var protocolID:String = String(commandParts[1]);
				if(protocolID != PROTOCOL_IDENTIFIER)
				{
					this.disconnect("Wrong TOC protocol version. Server requested " + protocolID);
				}
			}
		}
		
		/**
		 * @private
		 * Reads and parses a CONFIG2 command. This command gives us a listing of
		 * the groups and contacts stored on the server.
		 * 
		 * @param command		the raw server command
		 */
		private function processConfigCommand(command:String):void
		{
			//we've successfully signed in, so stop the connection timeout handler
			if(this.connectionTimer.running) this.connectionTimer.stop();
			
			//we've received the configuration data, so let's tell aol that we're good to go
			var initDoneCommand:ByteArray = new ByteArray();
			initDoneCommand.writeUTFBytes(CLIENT_INIT_DONE);
			this.sendClientCommand(initDoneCommand);
			
			//configuration appears on multiple lines
			var commandParts:Array = command.split("\n");
			var partCount:int = commandParts.length;
			var currentGroupName:String = "";
			for(var i:int = 0; i < partCount; i++)
			{
				var currentParam:String = String(commandParts[i]);
				//each line can have several items
				var configurationSubParams:Array = currentParam.split(":");
				if(configurationSubParams[0] == "g")
				{
					currentGroupName = configurationSubParams[1];
				}
				else if(configurationSubParams[0] == "b")
				{
					var contact:AIMContact = new AIMContact();
					contact.isSavedContact = true;
					contact.service = this;
					contact.screenName = configurationSubParams[1];
					contact.groupName = currentGroupName;
					this._contacts.push(contact);
				}
				//ignore any others
			}
			
			var connectEvent:MessengerServiceEvent = new MessengerServiceEvent(MessengerServiceEvent.CONNECT);
			this.dispatchEvent(connectEvent);
		}
		
		/**
		 * @private
		 * Reads and parses an ERROR command
		 * 
		 * @param command		the raw server command
		 */
		private function processErrorCommand(command:String):void
		{
			if(this.connectionTimer.running) this.connectionTimer.stop();
				
			var lastDelimiter:int = command.lastIndexOf(":");
			var errorID:int = int(command.substr(lastDelimiter + 1));
				
			var errorEvent:AIMServiceErrorEvent = new AIMServiceErrorEvent(AIMServiceErrorEvent.ERROR, errorID, new Date());
			this.dispatchEvent(errorEvent);
		}
		
		/**
		 * @private
		 * Reads and parses an UPDATE_BUDDY2 command
		 * 
		 * @param command		the raw server command
		 */
		private function processUpdateBuddyCommand(command:String):void
		{
			var commandParts:Array = command.split(":");
			var contactName:String = commandParts[1] as String;
			var updatedContact:AIMContact = this.screenNameToContact(contactName) as AIMContact;
			
			//ignore updates to contacts that aren't in the list
			if(updatedContact)
			{
				updatedContact.screenName = contactName; //formatted
				updatedContact.online = commandParts[2] != "F";
				updatedContact.warningLevel = new int(commandParts[3]);
				updatedContact.loginTime = new int(commandParts[4]);
				updatedContact.idleTime = new int(commandParts[5]);
				
				/*var userClass:String = commandParts[6];
				for(var i:uint = 0; i < userClass.length; i++)
				{
					switch(userClass.charAt(i))
					{
						case "U":
							if(i == 2) this.unavailable = true;
						case "A":
							if(i == 0) this.aolUser = true;
					}
				}*/
				var updateEvent:ContactEvent = new ContactEvent(ContactEvent.UPDATE_STATUS, updatedContact);
				
				updatedContact.dispatchEvent(updateEvent.clone());
				
				this.dispatchEvent(updateEvent);
			}
		}
		
		/** 
		 * @private
		 * Reads and parses an IM_IN2 command
		 * 
		 * @param command		the raw server command
		 */
		private function processImInCommand(command:String):void
		{
			var commandParts:Array = command.split(":");
			var contactName:String = commandParts[1] as String;
			var contact:IContact = this.screenNameToContact(contactName);
			
			//first, let's handle the case where we have an unknown contact
			if(!contact)
			{
				contact = new AIMContact();
				contact.service = this;
				contact.screenName = contactName;
				contact.isSavedContact = false;
				this.contacts.push(contact);
			}
			
			/*if(commandParts[2] == "F") this.auto = false;
			else this.auto = true;*/
			
			//remove the first four entries because we don't need them anymore
			commandParts.splice(0, 4);
			
			//since the message may contain the : character,
			//we should re-join the remaining data to get the full message
			var message:String = commandParts.join(":");
			
			var receivedMessage:ContactEvent = new ContactEvent(ContactEvent.RECEIVE_MESSAGE, contact, message);
			contact.dispatchEvent(receivedMessage.clone());
			
			this.dispatchEvent(receivedMessage);
		}
		
		/**
		 * @private
		 * The goto URL command tells us the location of the contact's profile.
		 */
		private function processGotoURLCommand(command:String):void
		{
			var lastDelimiter:int = command.lastIndexOf(":");
			var url:String = "http://" + this.host + ":" + this.port + "/";
			url += command.substr(lastDelimiter + 1);
			
			this._profileLoader = new URLLoader();
			this._profileLoader.addEventListener(Event.COMPLETE, profileLoaderCompleteHandler, false, 0, true);
			this._profileLoader.addEventListener(IOErrorEvent.IO_ERROR, profileLoaderErrorHandler, false, 0, true);
			
			this._profileLoader.load(new URLRequest(url));
		}
		
		private function processNewBuddyCommand(command:String):void
		{
			var commandParts:Array = command.split(":");
			var screenName:String = commandParts[1];
			var action:String = commandParts[2];
			
			switch(action)
			{
				case "added":
					var contact:AIMContact = this.screenNameToContact(screenName) as AIMContact;
					if(!contact)
					{
						contact = new AIMContact();
						contact.service = this;
						contact.screenName = screenName;
						this.contacts.push(contact);
					}
					contact.isSavedContact = true;
					
					var contactAdded:ContactEvent = new ContactEvent(ContactEvent.CONTACT_ADDED, contact);
					this.dispatchEvent(contactAdded);
					
					break;
				default:
					this.handleUnknownCommand(command);
			}
		}
		
		private function processInsertCommand(command:String):void
		{
			var commandParts:Array = command.split(":");
			var type:String = String(commandParts[1]);
			switch(type)
			{
				default:
					this.handleUnknownCommand(command);
			}
		}
		
		private function processDeleteCommand(command:String):void
		{
			var commandParts:Array = command.split(":");
			var type:String = String(commandParts[1]);
			
			switch(type)
			{
				case "b":
					var screenName:String = commandParts[2];
					var contact:AIMContact = this.screenNameToContact(screenName) as AIMContact;
					if(contact)
					{
						this.contacts.splice(this.contacts.indexOf(contact), 1);
			
						var removeContactEvent:ContactEvent = new ContactEvent(ContactEvent.CONTACT_REMOVED, contact);
						this.dispatchEvent(removeContactEvent);
					}
					break;
				default:
					this.handleUnknownCommand(command);
			}	
		}
		
		private function handleUnknownCommand(command:String):void
		{
			if(this.debugMode)
			{
				var unknownCommand:AIMCommandEvent = new AIMCommandEvent(AIMCommandEvent.UNKNOWN_COMMAND, command);
				this.dispatchEvent(unknownCommand);
			}
		}
		
		/**
		 * @private
		 * Sends a blank message to keep the connection to the server alive.
		 */
		private function sendKeepAlive():void
		{
			var keepAlive:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_KEEP_ALIVE, this.sequence, new ByteArray());
			this.socket.writeBytes(keepAlive);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @private
		 */
		private function profileLoaderCompleteHandler(event:Event):void
		{
			this._profileLoader.removeEventListener(Event.COMPLETE, profileLoaderCompleteHandler);
			this._profileLoader.removeEventListener(IOErrorEvent.IO_ERROR, profileLoaderErrorHandler);
			
			var contact:IContact = this._lastProfileContact;
			var profileText:String = this._profileLoader.data as String;
			
			var startIndex:int = profileText.indexOf("<hr><br>") + 8;
			profileText = profileText.substr(startIndex);
			var endIndex:int = profileText.indexOf("<br><hr>");
			profileText = profileText.substr(0, endIndex);
			
			var receiveProfile:ContactEvent = new ContactEvent(ContactEvent.RECEIVE_PROFILE, contact, profileText);
			contact.dispatchEvent(receiveProfile.clone());
			
			this.dispatchEvent(receiveProfile);
			
			this._profileLoader = null;
			this._lastProfileContact = null;
		}
		
		/**
		 * @private
		 */
		private function profileLoaderErrorHandler(event:IOErrorEvent):void
		{
			this._profileLoader.removeEventListener(Event.COMPLETE, profileLoaderCompleteHandler);
			this._profileLoader.removeEventListener(IOErrorEvent.IO_ERROR, profileLoaderErrorHandler);
			
			var contact:IContact = this._lastProfileContact;
			this._profileLoader = null;
			this._lastProfileContact = null;
			
			trace("Profile could not be loaded for", contact.screenName);
		}
		
	}
}