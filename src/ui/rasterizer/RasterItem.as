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
		
		private var _type:int;
		private var _lid:String;
		
		public function RasterItem( 
			id			: uint, 
			lid			: String,
			type		: int, 
			name		: String, 
			child		: DisplayObject, 
			position	: Point = null 
		) {
			this._name = name;
			this._lid = lid;
			this._id = id;
			this._child = child;
			this._type = type;
			
			_bmd = DisplayUtils.displayObjectToBitmapData(child);
			_rect = new Rectangle (
				position ? position.x : child.x, 
				position ? position.y : child.y, 
				child.width, child.height
			);
		}
		
		public function getSize(offset:uint = 0):uint 
		{
			return (_rect.height + offset) * (_rect.width + offset);
		}
		
		public function get width():uint 
		{
			return _rect.width;
		}
		
		public function get height():uint 
		{
			return _rect.height;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function get pos():Point
		{
			return _rect.topLeft;
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
		
		public function get lid():String 
		{
			return _lid;
		}
	}
}