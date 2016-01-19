package ui.base {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	public class Layout extends LayoutBase {
		
		public var layout:Sprite;
		
		public function Layout(name:String, w:uint, h:uint, translate:Boolean = true) {
			// constructor code
			layout = this.getChildByName(name) as Sprite;
			var x:uint = this.x
			,	y:uint = this.y
			,	xpers:Number = 0.0
			, 	ypers:Number = 0.0
			,	tw:uint = background.width
			,	th:uint = background.height
			,	propX:Number = w / tw
			,	propY:Number = h / th
			,	prop:Number = propX < propY ? propY : propX
			;
			
			var child:DisplayObject;
			for each (child in layout) 
			{
				x = child.x;
				y = child.y;
				
				xpers = x > 0 ? x / tw : 0;
				ypers = y > 0 ? y / th : 0;
				
				x = w * xpers;
				y = h * ypers;
				
				if (child is SimpleButton) {
					SimpleButton(child).upState.scaleX *= prop; 
					SimpleButton(child).upState.scaleY *= prop; 
					
					SimpleButton(child).downState.scaleX *= prop; 
					SimpleButton(child).downState.scaleY *= prop;
				} else {
					child.scaleX *= prop;
					child.scaleY *= prop;
				}
				
				child.x = x;
				child.y = y;
			}
		}
	}
	
}
