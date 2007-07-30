package com.flashtoolbox.messenger.events
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.flashtoolbox.mumble.IMessengerService;

	public class LogoutEvent extends CairngormEvent
	{
		public static const LOGOUT:String = "logout";
		
		public function LogoutEvent(service:IMessengerService)
		{
			super(LogoutEvent.LOGOUT, false, false);
			this.service = service;
		}
		
		public var service:IMessengerService;
		
		override public function clone():Event
		{
			return new LogoutEvent(this.service);
		}
		
	}
}