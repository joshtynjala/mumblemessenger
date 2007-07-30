package com.flashtoolbox.messenger.events
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class LoginEvent extends CairngormEvent
	{
		public static const LOGIN:String = "login";
		
		public function LoginEvent(serviceType:Class, screenName:String, password:String)
		{
			super(LoginEvent.LOGIN, false, false);
			this.serviceType = serviceType;
			this.screenName = screenName;
			this.password = password;
		}
		
		public var serviceType:Class;
		public var screenName:String;
		public var password:String;
		
		override public function clone():Event
		{
			return new LoginEvent(this.serviceType, this.screenName, this.password);
		}
		
	}
}