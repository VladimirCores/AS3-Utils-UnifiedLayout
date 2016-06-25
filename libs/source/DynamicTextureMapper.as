package 
{
	import flash.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class DynamicTextureMapper  extends EventDispatcher
	{
		private var _vectorItems:Array = new Array();
		
		public function DynamicTextureMapper() 
		{
			
		}
		
		public function addVectorItemToRaster(displayObject:flash.display.DisplayObject):void 
		{
			_vectorItems.push(displayObject);
		}
		
	}

}