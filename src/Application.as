package 
{
	import com.xtdstudios.DMT.DMTBasic;
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
		private var _raster:Rasterizer;
		
		public function Application() 
		{
			super();
			const viewport:Rectangle = Starling.current.viewPort;
			
			_raster = new Rasterizer(Starling.current.nativeStage, viewport, RasterizationComplete);
			
			const screen:MainScreenBase = new MainScreenBase();
			
			_raster.addItemToRaster(screen);
			//_raster.process():
		}
		
		private function LayoutUI():void {
			//const ns:Stage = Starling.current.nativeStage;
			//const sw:uint = ns.stageWidth;
			//const sh:uint = ns.stageHeight;
			//const mainLayout:MainScreen = new MainScreen(sw, sh);
			//_raster.addItemToRaster(mainLayout, MainScreen.NAME);
			//_raster.process(); // will rasterize the given assets  
		}
		
		//==================================================================================================
		private function RasterizationComplete():void {
		//==================================================================================================
			//starlingUIContainer = _raster.getAssetByUniqueAlias(MainScreen.NAME) as Sprite;
			//starlingUIContainer.addEventListener(Event.TRIGGERED, Handle_ButtonTriggered);
			//addChild(starlingUIContainer);
		}
		
		private function Handle_ButtonTriggered(e:Event):void 
		{
			trace((e.target as DisplayObject).name);
		}
	}
}
