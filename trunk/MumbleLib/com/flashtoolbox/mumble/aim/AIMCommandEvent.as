package com.flashtoolbox.mumble.aim
{
	import com.flashtoolbox.mumble.MessengerServiceEvent;
	import flash.events.Event;

	public class AIMCommandEvent extends MessengerServiceEvent
	{
		public static const RECEIVE_COMMAND:String = "receiveCommand";
		public static const UNKNOWN_COMMAND:String = "unknownCommand";
		
		public function AIMCommandEvent(type:String, command:String, time:Date=null)
		{
			super(type, time);
			this.command = command;
		}
		
		public var command:String;
		
		override public function clone():Event
		{
			return new AIMCommandEvent(this.type, this.command, this.time);
		}
	}
}