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

package com.flashtoolbox.mumble
{
	import flash.events.IEventDispatcher;
		
	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Dispatched when the socket connects to the remote server and the user is
	 * signed in.
	 *
	 * @eventType com.flashtoolbox.mumble.MessengerServiceEvent.CONNECT
	 */
	[Event(name="connect", type="com.flashtoolbox.mumble.MessengerServiceEvent")]

	/**
	 * Dispatched when the socket disconnects from the remote server or the
	 * connection detects that the server has dropped the connection without
	 * warning.
	 *
	 * @eventType com.flashtoolbox.mumble.MessengerServiceEvent.DISCONNECT
	 */
	[Event(name="disconnect", type="com.flashtoolbox.mumble.MessengerServiceEvent")]

	/**
	 * Dispatched when the remote sever returns an error message.
	 *
	 * @eventType com.flashtoolbox.mumble.MessengerServiceErrorEvent.ERROR
	 */
	[Event(name="disconnect", type="com.flashtoolbox.mumble.MessengerServiceErrorEvent")]

	/**
	 * Dispatched when a contact's status changes.
	 *
	 * @eventType com.flashtoolbox.mumble.ContactEvent.UPDATE_STATUS
	 */
	[Event(name="updateStatus", type="com.flashtoolbox.mumble.ContactEvent")]

	/**
	 * Dispatched when a message is received from a contact.
	 *
	 * @eventType com.flashtoolbox.mumble.ContactEvent.RECEIVE_MESSAGE
	 */
	[Event(name="receiveMessage", type="com.flashtoolbox.mumble.ContactEvent")]

	/**
	 * Dispatched when a profile is received from a contact.
	 *
	 * @eventType com.flashtoolbox.mumble.ContactEvent.RECEIVE_PROFILE
	 */
	[Event(name="receiveProfile", type="com.flashtoolbox.mumble.ContactEvent")]
	
	/**
	 * A common interface for connections to instant messenger services.
	 */
	public interface IMessengerService extends IEventDispatcher
	{
		/**
		 * The screen name of the currently logged-in user.
		 */
		function get screenName():String;
		
		/**
		 * An Array of <code>IContact</code> objects that are in the user's contact list.
		 */
		function get contacts():Array;
		
		/**
		 * True if the user is connected, and false if he or she is not.
		 */
		function get connected():Boolean;
		
		/**
		 * Connects to the messenger server, and logs into the specified account.
		 */
		function connect(screenName:String, password:String):void;
		
		/**
		 * Logs out of the connected account and disconnects from the server.
		 */
		function disconnect(message:String = null):void;
		
		/**
		 * Sends an instant message to the specified contact.
		 */
		function sendMessage(contact:IContact, message:String):void;
		
		/**
		 * Requests the profile for the specified contact. The result is returned
		 * in a <code>ContactEvent.RECEIVE_PROFILE</code> event.
		 */
		function getContactProfile(contact:IContact):void;
		
		/**
		 * Changes the profile for the connected user.
		 * 
		 * @param profile		The content to display in the user's profile.
		 */
		function setUserProfile(profile:String):void;
		
		/**
		 * Sets a status message for the connected user.
		 * 
		 * <p>Note: Some clients may only allow certain hard-coded statuses.
		 * Please check for STATUS_* constants.</p>
		 * 
		 * @param message		The text to show for your status.
		 */
		function setStatusMessage(message:String):void;
		
		/**
		 * Adds a contact to the user's contact list.
		 */
		function addContact(screenName:String, groupName:String):void;
		
		/**
		 * Removes a contact from the user's contact list.
		 */
		function removeContact(contact:IContact):void;
		
		/**
		 * Converts a string-based screen name to the corresponding
		 * <code>IContact</code> object. If the contact does not exist,
		 * returns <code>null</code>.
		 */
		function screenNameToContact(contactName:String):IContact;
	}
}