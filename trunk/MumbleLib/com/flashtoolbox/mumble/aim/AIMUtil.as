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
	import flash.utils.ByteArray;
	
	/**
	 * A series of utility functions used for the TOC2 protocol used by AOL
	 * Instant Messenger.
	 */
	public class AIMUtil
	{
		
	//--------------------------------------
	//  Constants
	//--------------------------------------
	
		private static const ROAST_KEY:String = "Tic/Toc";
		
		/**
		 * The constant representing the signon message type in the TOC protocol.
		 */
		public static const FLAP_SIGNON:int = 1;
		
		/**
		 * The constant representing the data message type in the TOC protocol.
		 */
		public static const FLAP_DATA:int = 2;
		
		/**
		 * The constant representing the error message type in the TOC protocol.
		 */
		public static const FLAP_ERROR:int = 3; //not used by TOC
		
		/**
		 * The constant representing the signoff message type in the TOC protocol.
		 */
		public static const FLAP_SIGNOFF:int = 4; //not used by TOC
		
		/**
		 * The constant representing the keep-alive message type in the TOC protocol.
		 */
		public static const FLAP_KEEP_ALIVE:int = 5;
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * Takes a prebuilt message and adds the header to it.
		 *
		 * @param type			a flag that tells AOL what sort of message to expect
		 * @param sequence		the number to identify the order of messages
		 * @param length		the number of bytes in the message
		 * @return				a complete TOC message including a FLAP header in binary form
		 */
		public static function createTocMessage(type:int, sequence:int, message:ByteArray):ByteArray
		{
			//add the null terminator if needed.
			if(type == AIMUtil.FLAP_DATA) message.writeByte(0);
			var tocMessage:ByteArray = AIMUtil.createFlapHeader(type, sequence, message.length);
			tocMessage.writeBytes(message);
			return tocMessage;
		}
		
		/**
		 * Builds a FLAP header for use with the TOC protocol.
		 * 
		 * @param type			a flag that tells AOL what sort of message to expect
		 * @param sequence		the number to identify the order of messages
		 * @param length		the number of bytes in the message
		 * @return				the FLAP header in binary form
		 */
		private static function createFlapHeader(type:int, sequence:int, length:int):ByteArray
		{
			var flapHeader:ByteArray = new ByteArray();
			flapHeader.writeUTFBytes("*");
			flapHeader.writeByte(type);	
			flapHeader.writeShort(sequence);
			flapHeader.writeShort(length);
			return flapHeader;
		}
		
		/**
		 * Converts a formatted screen name to all lowercase and removes any spaces
		 *
		 * @param screenName	The formatted screen name
		 * @return				The normalized screen name
		 */
		public static function normalizeScreenName(screenName:String):String
		{
			var normalizedName:String = "";
			var lowerCaseScreenName:String = screenName.toLowerCase();
			for(var i:Number = 0; i < lowerCaseScreenName.length; i++)
			{
				if(lowerCaseScreenName.charAt(i) != " ")
					normalizedName += lowerCaseScreenName.charAt(i);
			}
			return normalizedName;
		}
		
		/**
		 * Passes the plain-text password through a "roasting key" to obfuscate it.
		 * 
		 * @param password		The plain-text password
		 * @return				The roasted password
		 */
		public static function roast(password:String):String
		{
	        var roastedPassword:String = "0x";
	        for(var i:uint = 0; i < password.length; i++)
	        {
	        	var roastedByte:int = password.charCodeAt(i) ^ ROAST_KEY.charCodeAt(i % ROAST_KEY.length)
	        	var rb:String = roastedByte.toString(16);
	        	if(rb.length < 2) rb = "0" + rb;
	        	roastedPassword += rb;
	        }
	        return roastedPassword;
	    }
	    
	    /**
		 * Generates a magic number that AOL requires for authentication.
		 * 
		 * @param username		a normalized username
		 * @param password		a plain-text password
		 * @return				AOL's authenticating magic number
		 */
	    public static function getSignOnCode(username:String, password:String):int
	    {    	
	    	var usernameID:int = username.charCodeAt(0) - 96
			var passwordID:int = password.charCodeAt(0) - 96;

			var a:int = usernameID * 7696 + 738816;
			var b:int = usernameID * 746512;
			var c:int = passwordID * a;
  
			return c - a + b + 71665152;
	    }
	}
}