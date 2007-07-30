package com.flashtoolbox.mumble.aim
{
	import flash.events.Event;
	import com.flashtoolbox.mumble.MessengerServiceErrorEvent;
	
	public class AIMServiceErrorEvent extends MessengerServiceErrorEvent
	{
		
	//--------------------------------------
	//  Constants
	//--------------------------------------
		
		public static const ERROR:String = "error";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function AIMServiceErrorEvent(type:String, errorCode:int, time:Date=null)
		{
			super(type, this.errorCodeToMessage(errorCode), time);
			this.errorCode = errorCode;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		public var errorCode:int;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		override public function clone():Event
		{
			return new AIMServiceErrorEvent(this.type, this.errorCode, this.time);
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		protected function errorCodeToMessage(errorCode:int):String
		{
			var message:String = errorCode + ": ";
			message += "Unknown Error";
			
			return message;
		}
		
	}
}