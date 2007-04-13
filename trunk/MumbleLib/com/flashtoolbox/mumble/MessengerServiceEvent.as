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

	/**
	 * An event used by the <code>IMessengerService</code> type.
	 */
	public class MessengerServiceEvent extends Event
	{
		
	//--------------------------------------
	//  Constants
	//--------------------------------------
	
		/**
		 * The constant associated with a completed connection.
		 */
		public static const CONNECT:String = "connect";
		
		/**
		 * The constant associated with a closed connection.
		 */
		public static const DISCONNECT:String = "disconnect";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param type			The event type.
		 * @param screeName		The screen name associated with the event.
		 * @param time			The time at which the event fired.
		 */
		public function MessengerServiceEvent(type:String, screenName:String, time:Date = null)
		{
			super(type, false, false);
			
			this.screenName = screenName;
			if(time)
			{
				this.time = time;
			}
			else this.time = new Date();
		}
	
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The screen name associated with the event.
		 */
		public var screenName:String;
		
		/**
		 * The time at which the event fired.
		 */
		public var time:Date;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function clone():Event
		{
			var clonedEvent:MessengerServiceEvent = new MessengerServiceEvent(this.type, this.screenName, this.time);
			return clonedEvent;
		}
		
	}
}