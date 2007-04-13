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
	import com.flashtoolbox.mumble.Contact;

	/**
	 * A contact from AOL Instant Messenger.
	 */
	public class AIMContact extends Contact
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function AIMContact(screenName:String = null)
		{
			super(screenName);
		}
		
	//--------------------------------------
	//  Variables Properties
	//--------------------------------------
		
		private var _warningLevel:int = 0;
		
		public function get warningLevel():int
		{
			return this._warningLevel;
		}
		
		public function set warningLevel(value:int):void
		{
			this._warningLevel = value;
		}
		
		private var _loginTime:int = 0;
		
		public function get loginTime():int
		{
			return this._loginTime;
		}
		
		public function set loginTime(value:int):void
		{
			this._loginTime = value;
		}
		
		private var _idleTime:int = 0;
		
		public function get idleTime():int
		{
			return this._idleTime;
		}
		
		public function set idleTime(value:int):void
		{
			this._idleTime = value;
		}
		
		
	}
}