package nest.utils 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public final class DebugUtils 
	{
		static private const _markers:Dictionary = new Dictionary();
		
		static public function addDebugMarkerToLayer(layer:uint, color:uint):void {
			const marker:DisplayObject = new Quad(10, 10, color);
			Starling.current.stage.addChild(marker);
			if (_markers[layer] == undefined) _markers[layer] = [];
			_markers[layer].push(marker);
		}
		
		static public function moveDebugMarker(layer:uint, index:int, location:Point):void {
			if (_markers[layer] == null) return;
			const marker:DisplayObject = _markers[layer][index];
			marker.x = location.x;
			marker.y = location.y;
		}
		
		static public function removeDebugMarker(layer:uint, index:uint):void {
			Starling.current.stage.removeChild((_markers[layer] as Array).removeAt(index));
		}
	}
}