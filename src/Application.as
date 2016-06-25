package 
{
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import ui.screens.MainScreen;
	import ui.rasterizer.Rasterizer;
	import ui.screens.MainScreen;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public final class Application extends Sprite 
	{
		static public const RASTERIZER:String = "rasterizerNameMain";
		static public const LAYOUT_NAME_MAIN_SCREEN:String = "layoutNameMainScreen";
		
		private var _raster:Rasterizer;
		
		public function Application() 
		{
			super();
			const viewport:Rectangle = Starling.current.viewPort;
			const mainScreenLayout:MainScreenBase = new MainScreenBase();
			
			_raster = new Rasterizer(
				RASTERIZER, viewport, 
				RasterizationComplete
			);
			
			//if (!_raster.isCacheExist) {
				_raster.addLayoutToRaster(mainScreenLayout, LAYOUT_NAME_MAIN_SCREEN);
			//}
			_raster.process(false);
		}
		
		//==================================================================================================
		private function RasterizationComplete():void {
		//==================================================================================================
			var layoutByID:Sprite = _raster.getLayoutByID(LAYOUT_NAME_MAIN_SCREEN);
			layoutByID.addEventListener(Event.TRIGGERED, Handle_ButtonTriggered);
			this.addChild(layoutByID);
		}
		
		private function Handle_ButtonTriggered(e:Event):void 
		{
			trace((e.target as DisplayObject).name);
		}
	}
}
