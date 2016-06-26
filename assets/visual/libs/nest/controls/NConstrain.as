package nest.controls {  
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class NConstrain extends MovieClip {
		
		static public const TOP		:String = "top";
		static public const BOTTOM	:String = "bottom";
		static public const LEFT	:String = "left";
		static public const RIGHT	:String = "right";
		static public const CENTER	:String = "center";
		static public const NONE	:String = "none";
		
		static public const PROP	:String = "prop";
		static public const DPI		:String = "dpi";
		
		public function NConstrain() {
			super();
		}
		private var _scale:String = PROP;
		private var _constrainY:String = TOP;
		private var _constarinX:String = LEFT;
		
		[Inspectable(enumeration="top,bottom,center,none", defaultValue="top", name="constarainY")]
		public function get constrainY():String {
			return _constrainY;
		}		
		
		public function set constrainY(value:String):void {
			_constrainY = value;
		}
		
		[Inspectable(enumeration="left,right,center,none", defaultValue="left", name="constarainX")]
		public function get constrainX():String {
			return _constarinX;
		}		
		
		public function set constrainX(value:String):void {
			_constarinX = value;
		}
		
		[Inspectable(enumeration="prop,dpi", defaultValue="prop", name="scale")]
		public function get scale():String {
			return _scale;
		}		
		
		public function set scale(value:String):void {
			_scale = value;
		}
	}
}
