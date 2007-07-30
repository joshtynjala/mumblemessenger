package com.flashtoolbox.messenger.views
{
	import mx.controls.listClasses.ListItemRenderer;
	import com.flashtoolbox.mumble.IContact;

	public class ContactListItemRenderer extends ListItemRenderer
	{
		public function ContactListItemRenderer()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.data)
			{
				this.label.enabled = (this.data as IContact).online;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.graphics.lineStyle(0, 0, 0);
			this.graphics.beginFill(0x000000, 0);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
		}
		
	}
}