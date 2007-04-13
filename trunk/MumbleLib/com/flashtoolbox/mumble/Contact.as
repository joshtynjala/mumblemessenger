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
	import flash.events.EventDispatcher;
	
	public class Contact extends EventDispatcher implements IContact
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function Contact(screenName:String = null)
		{
			this.screenName = screenName;
		}
		
	//--------------------------------------
	//  Variables and Properties
	//--------------------------------------
		
		private var _connection:IMessengerService;
		
		public function get connection():IMessengerService
		{
			return this._connection;
		}
		
		public function set connection(value:IMessengerService):void
		{
			this._connection = value;
		}
		
		private var _screenName:String;
		
		public function get screenName():String
		{
			return this._screenName;
		}
		
		public function set screenName(value:String):void
		{
			this._screenName = value;
		}
		
		private var _groupName:String;
		
		public function get groupName():String
		{
			return this._groupName;
		}
		
		public function set groupName(value:String):void
		{
			this._groupName = value;
		}
		
		private var _online:Boolean = false;
		
		public function get online():Boolean
		{
			return this._online;
		}
		
		public function set online(value:Boolean):void
		{
			this._online = value;
		}
		
		private var _status:String = "Offline";
		
		public function get status():String
		{
			return this._status;
		}
		
		public function set status(value:String):void
		{
			this._status = value;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public function sendMessage(messageText:String):void
		{
			this.connection.sendMessage(this, messageText);
		}
		
	}
}