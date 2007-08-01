package com.flashtoolbox.messenger.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.flashtoolbox.mumble.IMessengerService;
	import com.flashtoolbox.mumble.aim.AIMService;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import mx.collections.IViewCursor;
	import com.flashtoolbox.mumble.IContact;

	[Bindable]
	public class MessengerModelLocator extends EventDispatcher implements IModelLocator
	{
		private static var modelLocator:MessengerModelLocator;
        
		public static function getInstance():MessengerModelLocator
		{
			if(modelLocator == null)
			{
				modelLocator = new MessengerModelLocator(new ModelLocatorEnforcer());
			}
			return modelLocator;
		}
		
		public function MessengerModelLocator(enforcer:ModelLocatorEnforcer) 
		{
			if(modelLocator != null)
			{
				throw new Error( "Only one ModelLocator instance should be instantiated" );    
			}
			
			this.services.addEventListener(CollectionEvent.COLLECTION_CHANGE, servicesCollectionChangeHandler);
		}
		
		[Bindable("servicesChange")]
		public var services:ArrayCollection = new ArrayCollection();
		public var serviceDelegates:Dictionary = new Dictionary();
		
		public var conversationWindows:Dictionary = new Dictionary();
		public var messageHistory:Dictionary = new Dictionary();
		
		public var contactListStatus:String = "";
		public var contactListStatusMessage:String = "";
		
		public var contacts:ArrayCollection = new ArrayCollection();
		
		private function servicesCollectionChangeHandler(event:CollectionEvent):void
		{
			this.rebuildContacts();
			this.dispatchEvent(new Event("servicesChange"));
		}
		
		public function rebuildContacts():void
		{
			var allContacts:Array = [];
			var iterator:IViewCursor = this.services.createCursor();
			while(!iterator.afterLast)
			{
				var service:IMessengerService = iterator.current as IMessengerService;
				allContacts = allContacts.concat(service.contacts);
				iterator.moveNext();
			}
			
			this.contacts = new ArrayCollection(allContacts);
		}
			
		public function serviceToIcon(item:Object):Class
		{
			if(item is IContact) item = IContact(item).service;
			if(item is AIMService)
			{
				return Library.AimIcon;
			}
			return null;
		}
	}
}

class ModelLocatorEnforcer {}