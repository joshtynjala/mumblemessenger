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
	
		public function MessengerServiceErrorEvent(type:String, message:String, screenName:String, time:Date=null)
		{
			super(type, screenName, time);
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
			return new MessengerServiceErrorEvent(type, message, screenName, time);
		}
	}
}