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
			
			var disconnectEvent:MessengerServiceEvent = new MessengerServiceEvent(MessengerServiceEvent.DISCONNECT, this.screenName);
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
			if(!this.socket.connected)
			{
				this.disconnect();
				return;
			}
			
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_SEND_IM + " " + AIMUtil.normalizeScreenName(contact.screenName) + " \"" + message + "\" F");
			var clientSendMessage:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(clientSendMessage);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#getContactProfile
		 */
		public function getContactProfile(contact:IContact):void
		{
			if(!this.socket.connected)
			{
				this.disconnect();
				return;
			}
			
			if(this._profileLoader)
			{
				this._profileLoader.close();
				this._lastProfileContact = null;
			}
			
			this._lastProfileContact = contact;
			
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_GET_INFO + " " + AIMUtil.normalizeScreenName(contact.screenName));
			var clientGetInfo:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(clientGetInfo);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#setUserProfile
		 */
		public function setUserProfile(profile:String):void
		{
			if(!this.socket.connected)
			{
				this.disconnect();
				return;
			}
			
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_SET_INFO + " \"" + profile + "\"");
			var setInfo:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(setInfo);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#setStatusMessage
		 */
		public function setStatusMessage(message:String):void
		{
			if(!this.socket.connected)
			{
				this.disconnect();
				return;
			}
			
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_SET_AWAY + " \"" + message + "\"");
			var setAway:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(setAway);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#addContact
		 */
		public function addContact(screenName:String, groupName:String):void
		{
			if(!this.socket.connected)
			{
				this.disconnect();
				return;
			}
			
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_NEW_BUDDIES + " " +  "g:" + groupName + "\nb:" + screenName + "\n");
			var addContact:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(addContact);
			this.socket.flush();
			this.sequence++;
		}
		
		/**
		 * @copy com.flashtoolbox.im.IConnection#removeContact
		 */
		public function removeContact(contact:IContact):void
		{
			if(!this.socket.connected)
			{
				this.disconnect();
				return;
			}
			
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_REMOVE_BUDDY + " " +  contact.screenName + " " + contact.groupName);
			var removeContact:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(removeContact);
			this.socket.flush();
			this.sequence++;
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
	//  Protected Methods
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
			this.connectionTimer = new Timer(5000, 1);
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
			this.disconnect();
		}
		
		/**
		 * @private
		 * Called when the Flash Player encounters a sandbox security error.
		 * Disconnects automatically.
		 */
		private function socketSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			this.disconnect();
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
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeInt(1);
			clientCommand.writeShort(1);
			clientCommand.writeShort(normalizedUserName.length);
			clientCommand.writeUTFBytes(normalizedUserName);
			var clientSignonResponse:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_SIGNON, this.sequence, clientCommand);
			this.socket.writeBytes(clientSignonResponse);
			this.socket.flush();
			this.sequence++;
			
			//client sends sign on message
			clientCommand = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_SIGN_ON + " " + AUTHORIZATION_SERVER + " " + AUTHORIZATION_PORT.toString() + " " + normalizedUserName + " " + roastedPassword + " english " + USER_AGENT +  " 160 " + signOnCode.toString());
			var loginRequest:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(loginRequest);
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
			else if(command.length == 0)
			{
				//Occasionally, we get a blank message from the server.
				//This is a good time to send a keep-alive message back.
				this.sendKeepAlive();
			}
			else trace("Unknown command:", command); //Any other messages we get might be interesting to look at
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
				var protocolID:String = commandParts[1];
				if(protocolID != PROTOCOL_IDENTIFIER)
				{
					this.disconnect("Wrong TOC protocol version. Server requested " + protocolID);
				}
			}
		}
		
		/**
		 * @private
		 * Reads and parses a CONFIG2 command
		 * 
		 * @param command		the raw server command
		 */
		private function processConfigCommand(command:String):void
		{
			//we've successfully signed in, so stop the connection timeout handler
			if(this.connectionTimer.running) this.connectionTimer.stop();
			
			//we've received the configuration data, so let's tell aol that we're good to go
			var clientCommand:ByteArray = new ByteArray();
			clientCommand.writeUTFBytes(CLIENT_INIT_DONE);
			var initDone:ByteArray = AIMUtil.createTocMessage(AIMUtil.FLAP_DATA, this.sequence, clientCommand);
			this.socket.writeBytes(initDone);
			this.socket.flush();
			this.sequence++;
			
			//configuration appears on multiple lines
			var commandParts:Array = command.split("\n");
			var partCount:int = commandParts.length;
			var currentGroupName:String = "";
			for(var i:int = 0; i < partCount; i++)
			{
				var currentParam:String = commandParts[i] as String;
				//each line can have several items
				var configurationSubParams:Array = currentParam.split(":");
				if(configurationSubParams[0] == "g")
				{
					currentGroupName = configurationSubParams[1];
				}
				else if(configurationSubParams[0] == "b")
				{
					var contact:AIMContact = new AIMContact();
					contact.connection = this;
					contact.screenName = configurationSubParams[1];
					contact.groupName = currentGroupName;
					this._contacts.push(contact);
				}
				//ignore any others
			}
			
			//this client has some default info
			//this.setUserInfo(TocConnection.DEFAULT_INFO);
			
			var connectEvent:MessengerServiceEvent = new MessengerServiceEvent(MessengerServiceEvent.CONNECT, this.screenName);
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
				
			var errorEvent:AIMServiceErrorEvent = new AIMServiceErrorEvent(AIMServiceErrorEvent.ERROR, errorID, this.screenName, new Date());
			this.dispatchEvent(errorEvent);
			trace("Error:", errorID);
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
			
			//if the contact isn't in the user's buddy list, add it.
			//TODO: this should be updated to ask the user what to do.
			if(!contact)
			{
				contact = new AIMContact(contactName);
				this.contacts.push(contact);
			}
			
			/*if(commandParts[2] == "F") this.auto = false;
			else this.auto = true;*/
			
			//remove the first four entries because we don't need them anymore
			commandParts.splice(0, 4);
			
			//since the message may contain the : character, we should re-join the remaining data
			var message:String = commandParts.join(":");
			
			var receivedMessage:ContactEvent = new ContactEvent(ContactEvent.RECEIVE_MESSAGE, contact, message);
			contact.dispatchEvent(receivedMessage.clone());
			
			this.dispatchEvent(receivedMessage);
		}
		
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