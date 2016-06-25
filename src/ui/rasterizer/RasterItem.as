package ui.rasterizer 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nest.utils.DisplayUtils;
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class RasterItem 
	{
		private var _child:DisplayObject;
		private var _id:uint;
		private var _bmd:BitmapData;
		private var _rect:Rectangle;
		private var _name:String;
		
		public function RasterItem(id:uint, name:String, child:DisplayObject, position:Point = null ) 
		{
			this._name = name;
			this._id = id;
			this._child = child;
			_bmd = DisplayUtils.displayObjectToBitmapData(child);
			_rect = new Rectangle(
				position ? position.x : child.x, 
				position ? position.y : child.y, 
				child.width, child.height);
		}
		
		public function get child():DisplayObject 
		{
			return _child;
		}
		
		public function get id():uint 
		{
			return _id;
		}
		
		public function get bmd():BitmapData 
		{
			return _bmd;
		}
		
		public function get rect():Rectangle 
		{
			return _rect;
		}
		
		public function get name():String 
		{
			return _name;
		}
	}
}