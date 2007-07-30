package com.flashtoolbox.mumble
{
	import flash.events.Event;
	
	public class MessengerServiceErrorEvent extends MessengerServiceEvent
	{
		
	//--------------------------------------
	//  Constants
	//--------------------------------------
		
		public static const ERROR:String = "error";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function MessengerServiceErrorEvent(type:String, message:String, time:Date=null)
		{
			super(type, time);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		public var message:String;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		override public function clone():Event
		{
			return new MessengerServiceErrorEvent(type, message, time);
		}
	}
}