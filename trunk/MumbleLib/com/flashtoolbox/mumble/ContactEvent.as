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
	import flash.events.Event;

	public class ContactEvent extends Event
	{
		public static const UPDATE_STATUS:String = "updateStatus";
		public static const RECEIVE_MESSAGE:String = "receiveMessage";
		public static const RECEIVE_PROFILE:String = "receiveProfile";
		public static const CONTACT_ADDED:String = "contactAdded";
		public static const CONTACT_REMOVED:String = "contactRemoved";
		
		public function ContactEvent(type:String, contact:IContact, data:Object = null, time:Date = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.contact = contact;
			this.data = data;
			if(time)
			{
				this.time = time;
			}
			else this.time = new Date();
		}
		
		public var contact:IContact;
		public var time:Date;
		public var data:Object;
		
		override public function clone():Event
		{
			var clonedEvent:ContactEvent = new ContactEvent(this.type, this.contact, this.data, this.time);
			return clonedEvent;
		}
	}
}