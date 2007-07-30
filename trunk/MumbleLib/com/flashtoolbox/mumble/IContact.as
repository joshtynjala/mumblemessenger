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
	
	/**
	 * Dispatched when a contact's status changes.
	 *
	 * @eventType com.flashtoolbox.im.ContactEvent.UPDATE_STATUS
	 */
	 [Event(name="updateStatus", type="com.flashtoolbox.im.ContactEvent")]
	
	/**
	 * Dispatched when a contact sends a message.
	 *
	 * @eventType com.flashtoolbox.im.ContactEvent.RECEIVE_MESSAGE
	 */
	[Event(name="receiveMessage", type="com.flashtoolbox.im.ContactEvent")]
	
	public interface IContact extends IEventDispatcher
	{
		function get service():IMessengerService;
		function set service(value:IMessengerService):void;
		
		function get screenName():String;
		function set screenName(value:String):void;
		
		function get groupName():String;
		function set groupName(value:String):void;
		
		function get isSavedContact():Boolean;
		function set isSavedContact(value:Boolean):void;
		
		function get online():Boolean;
		function set online(value:Boolean):void;
		
		function get status():String;
		function set status(value:String):void;
		
		function sendMessage(message:String):void;
		//function getProfile():void;
	}
}