package com.flashtoolbox.messenger.views
{
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import mx.core.Application;
	import mx.controls.List;
	import mx.events.ListEvent;
	import mx.managers.SystemManager;
	import com.flashtoolbox.mumble.IContact;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import flash.display.DisplayObject;
	import mx.controls.listClasses.IListItemRenderer;
	import flash.geom.Point;
	import mx.core.ClassFactory;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.controls.MenuBar;
	import mx.events.MenuEvent;
	import mx.controls.TextInput;
	import mx.controls.Button;
	import mx.managers.SystemManager;
	import mx.core.Window;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import mx.collections.IViewCursor;
	import mx.collections.ArrayCollection;
	import com.flashtoolbox.mumble.IMessengerService;
	import com.flashtoolbox.messenger.events.AddNewContactEvent;
	import com.flashtoolbox.messenger.events.ContactActionEvent;
	import com.flashtoolbox.messenger.model.MessengerModelLocator;
	import com.flashtoolbox.messenger.model.ContactListStatus;
	import mx.collections.ICollectionView;

	public class ContactListBase extends Window
	{
		
    //----------------------------------
	//  Class Methods
    //----------------------------------
    
		/**
		 * @private
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ContactList");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.paddingLeft = 0;
				this.paddingRight = 0;
				this.paddingTop = 0;
				this.paddingBottom = 0;
				this.verticalGap = 0;
			}
			
			StyleManager.setStyleDeclaration("ContactList", selector, false);
		}
		
		//initialize the default styles
		initializeStyles();
		
    //----------------------------------
	//  Constructor
    //----------------------------------
    
    	/**
    	 * Constructor.
    	 */
		public function ContactListBase()
		{
			super();
		}
		
    //----------------------------------
	//  Properties
    //----------------------------------
		
		[Bindable]
		public var mainMenu:MenuBar;
		
		[Bindable]
		public var list:List;
		
		[Bindable]
		public var contactNameInput:TextInput;
		
		[Bindable]
		public var addButton:Button;
		
		[Bindable]
		protected var model:MessengerModelLocator = MessengerModelLocator.getInstance();
		
		private var _lastContact:IContact;
		
		private var _dataProvider:ICollectionView;
		
		public function get dataProvider():ICollectionView
		{
			return this._dataProvider;
		}
		
		public function set dataProvider(value:ICollectionView):void
		{
			this._dataProvider = value;
			this.invalidateProperties();
		}
		
		public function set messageStatus(value:String):void
		{
			switch(value)
			{
				case ContactListStatus.ERROR:
					this.currentState = "ShowError";
					break;
				case ContactListStatus.SUCCESS:
					this.currentState = "ShowSuccess";
					break;
				case ContactListStatus.NOTIFICATION:
					this.currentState = "ShowNotify";
					break;
				default:
					this.currentState = "";
			}
		}
		
    //----------------------------------
	//  Protected Methods
    //----------------------------------
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			var listMenu:ContextMenu = new ContextMenu();
			listMenu.hideBuiltInItems();
			listMenu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelectHandler);
			
			var sendMessageItem:ContextMenuItem = new ContextMenuItem("Send Message");
			sendMessageItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, sendMessageSelectHandler);
			
			var getProfileItem:ContextMenuItem = new ContextMenuItem("Get Profile");
			getProfileItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, getProfileSelectHandler);
			
			listMenu.customItems = [sendMessageItem, getProfileItem];
			
			this.list.contextMenu = listMenu;
			
			var itemRendererFactory:ClassFactory = new ClassFactory(ContactListItemRenderer);
			itemRendererFactory.properties = {mouseChildren: false};
			this.list.itemRenderer = itemRendererFactory;
			
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(this.list)
			{
				this.list.dataProvider = this._dataProvider;	
			}
		}
		
		protected function addContactClickHandler(event:MouseEvent):void
		{
			this.currentState = "AddContact";
		}
		
		protected function removeContactClickHandler(event:MouseEvent):void
		{
			var contact:IContact = this.list.selectedItem as IContact;
			if(contact)
			{
				var removeContact:ContactActionEvent = new ContactActionEvent(ContactActionEvent.REMOVE_CONTACT, contact);
				removeContact.dispatch();
			}
			else
			{
				trace("TODO: Implement message to user that says you must select a contact");
			}
		}
		
		protected function sendMessageClickHandler(event:MouseEvent):void
		{
			var contact:IContact = this.list.selectedItem as IContact;
			if(contact)
			{
				var openConversation:ContactActionEvent = new ContactActionEvent(ContactActionEvent.OPEN_CONVERSATION, contact)
				openConversation.dispatch();
			}
			else
			{
				trace("TODO: Implement message to user that says you must select a contact");
			}
		}
		
		protected function getServiceIcon(item:Object):Class
		{
			return Library.AimIcon;
		}
		
		protected function listDoubleClickHandler(event:ListEvent):void
		{
			var contact:IContact = event.itemRenderer.data as IContact;
			if(contact)
			{
				var openConversation:ContactActionEvent = new ContactActionEvent(ContactActionEvent.OPEN_CONVERSATION, contact)
				openConversation.dispatch();
			}
		}
		
		protected function addNewContact():void
		{
			var screenName:String = this.contactNameInput.text;
			this.contactNameInput.text = "";
			
			var addContactEvent:AddNewContactEvent = new AddNewContactEvent(this.model.services[0], screenName, "The Usual Suspects");
			addContactEvent.dispatch();
		}
		
    //----------------------------------
	//  Private Methods
    //----------------------------------
		
		private function getContactUnderMouse():IContact
		{
			var mousePosition:Point = new Point(this.mouseX, this.mouseY);
			mousePosition = this.localToGlobal(mousePosition);
			var objects:Array = this.list.getObjectsUnderPoint(mousePosition);
			
			var enableItems:Boolean = false;
			var objectCount:int = objects.length;
			for(var i:int = 0; i < objectCount; i++)
			{
				var listItem:IListItemRenderer = objects[i] as IListItemRenderer;
				if(listItem)
				{
					var contact:IContact = listItem.data as IContact;
					return contact;
				}
			}
			return null;
		}
		
		private function menuSelectHandler(event:ContextMenuEvent):void
		{
			var menu:ContextMenu = event.target as ContextMenu;
			
			var mousePosition:Point = new Point(this.mouseX, this.mouseY);
			mousePosition = this.localToGlobal(mousePosition);
			var objects:Array = this.list.getObjectsUnderPoint(mousePosition);
			
			this._lastContact = this.getContactUnderMouse();
			var enableItems:Boolean = this._lastContact != null;
			
			var menuItems:Array = menu.customItems;
			var itemCount:int = menuItems.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var menuItem:ContextMenuItem = menuItems[i];
				menuItem.enabled = enableItems;
			}
		}
		
		private function sendMessageSelectHandler(event:ContextMenuEvent):void
		{
			var openConversation:ContactActionEvent = new ContactActionEvent(ContactActionEvent.OPEN_CONVERSATION, this._lastContact)
			openConversation.dispatch();
		}
		
		private function getProfileSelectHandler(event:ContextMenuEvent):void
		{
			var getProfile:ContactActionEvent = new ContactActionEvent(ContactActionEvent.GET_PROFILE, this._lastContact)
			getProfile.dispatch();
		}
		
	}
}