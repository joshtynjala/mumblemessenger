package com.flashtoolbox.messenger.commands
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.flashtoolbox.messenger.events.ContactActionEvent;
	import com.flashtoolbox.mumble.IContact;

	public class GetProfileCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var getProfile:ContactActionEvent = event as ContactActionEvent;
			var contact:IContact = getProfile.contact;
		}
		
	}
}