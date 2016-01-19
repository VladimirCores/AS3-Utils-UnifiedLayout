package ui.base 
{
	import com.xtdstudios.DMT.DMTBasic;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LayoutProcessor extends DMTBasic 
	{
		private var _readyCallback:Function;
		public function LayoutProcessor(dataName:String, readyCallback:Function, useCache:Boolean=true, cacheVersion:String="1") 
		{
			super(dataName, useCache, cacheVersion);
			this._readyCallback = readyCallback;
			this.addEventListener(Event.COMPLETE, HandleComplete);
		}
		
		private function HandleComplete(e:Event):void 
		{
			this.removeEventListener(Event.COMPLETE, HandleComplete);
			if (_readyCallback) _readyCallback();
		}
		
	}

}