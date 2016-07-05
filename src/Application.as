package 
{
	import adobe.utils.CustomActions;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
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
		static public const LAYOUT_NAME_SETTINGS_SCREEN:String = "layoutNameSettingsScreen";
		
		private var _raster:Rasterizer;
		private var screens:Array = new Array();
		private var start:uint;
		
		public function Application() 
		{
			super();
			const viewport:Rectangle = Starling.current.viewPort;
			
			_raster = new Rasterizer(
				RASTERIZER, viewport, 
				RasterizationComplete
			);
			
			start = getTimer();
			
			var useChache:Boolean = false;
			
			if (!_raster.isCacheExist || !useChache) {
				const mainScreenLayout:MainScreenBase = new MainScreenBase();
				const settingsScreenLayout:SettingScreenBase = new SettingScreenBase();
				_raster.addLayoutToRaster(mainScreenLayout, LAYOUT_NAME_MAIN_SCREEN);
				_raster.addLayoutToRaster(settingsScreenLayout, LAYOUT_NAME_SETTINGS_SCREEN);
			}
			_raster.process(useChache);
			
			var that:Application = this as Application;
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_UP, function (e:KeyboardEvent):void 
			{
				if (e.keyCode == Keyboard.SPACE) {
					screens.push(that.removeChildAt(0));
					that.addChild(screens.shift() as Sprite);
				}
			});
		}
		
		//==================================================================================================
		private function RasterizationComplete():void {
		//==================================================================================================
			var mainLayout:Sprite = _raster.getLayoutByID(LAYOUT_NAME_MAIN_SCREEN);
			mainLayout.addEventListener(Event.TRIGGERED, Handle_ButtonTriggered);
			this.addChild(mainLayout);
			
			var settingsLayout:Sprite = _raster.getLayoutByID(LAYOUT_NAME_SETTINGS_SCREEN);
			screens.push(settingsLayout);
			
			trace((getTimer() - start) + "ms");
		}
		
		private function Handle_ButtonTriggered(e:Event):void 
		{
			trace((e.target as DisplayObject).name);
		}
	}
}
