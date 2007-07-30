package com.flashtoolbox.messenger.views
{
	import mx.core.Window;
	import com.flashtoolbox.mumble.IContact;

	public class ContactProfileWindowBase extends Window
	{
		
    //----------------------------------
	//  Constructor
    //----------------------------------
    
		public function ContactProfileWindowBase()
		{
			super();
		}
		
    //----------------------------------
	//  Properties
    //----------------------------------
		
		private var _contact:IContact;
		
		[Bindable]
		public function get contact():IContact
		{
			return this._contact;
		}
		
		public function set contact(value:IContact):void
		{
			this._contact = value;
			if(this._contact && this.stage)
			{
				this.stage.window.title = "Profile for " + this._contact.screenName;
			}
		}
		
		private var _profile:String = "";
		
		[Bindable]
		public function get profile():String
		{
			return this._profile;
		}
		
		public function set profile(value:String):void
		{
			this._profile = value;
		}
		
	}
}