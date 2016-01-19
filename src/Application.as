package 
{
	import com.xtdstudios.DMT.DMTBasic;
	import flash.display.Stage;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import ui.base.Layout;
	import ui.base.LayoutProcessor;
	import ui.MainLayout;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public final class Application extends Sprite 
	{
		private var _layoutProcessor:LayoutProcessor;
		private var starlingUIContainer : Sprite;
		
		public function Application() 
		{
			super();
			
			_layoutProcessor = new LayoutProcessor("UIContainer", LayoutComplete, false);
			if (_layoutProcessor.cacheExist() == true) {
				_layoutProcessor.process(); // will use the existing cache
			}
			else LayoutUI(); // will be done one time per device  
		}
		
		private function LayoutUI():void {
			var ns:Stage = Starling.current.nativeStage;
			var sw:uint = ns.stageWidth;
			var sh:uint = ns.stageHeight;
			var mainLayout:MainLayout = new MainLayout(sw, sh);
			_layoutProcessor.addItemToRaster(mainLayout.layout, MainLayout.NAME);
			_layoutProcessor.process(); // will rasterize the given assets  
		}
		
		//==================================================================================================
		private function LayoutComplete():void {
		//==================================================================================================
			starlingUIContainer = _layoutProcessor.getAssetByUniqueAlias(MainLayout.NAME) as Sprite;
			starlingUIContainer.addEventListener(Event.TRIGGERED, Handle_Button_Triggered);
			addChild(starlingUIContainer);
		}
		
		private function Handle_Button_Triggered(e:Event):void 
		{
			trace((e.target as DisplayObject).name);
		}
	}
}
