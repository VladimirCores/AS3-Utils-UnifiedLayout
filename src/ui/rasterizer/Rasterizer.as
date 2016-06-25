package ui.rasterizer 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import org.villekoskela.utils.RectanglePacker;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import ui.screens.MainScreen;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Rasterizer extends EventDispatcher
	{
		static private const BTN_NAME_UP:Array = ["", "up"];
		static private const BTN_NAME_DOWN:Array = ["", "down"];
		
		private var _readyCallback:Function;
		
		private var _itemsToRaster:Vector.<RasterItem> = new Vector.<RasterItem>();
		private var _viewPort:Rectangle;
		private var _stage:Stage;
		
		private var packer:RectanglePacker;
		
		public function Rasterizer(
			stage			: Stage,
			viewPort		: Rectangle,
			readyCallback	: Function, 
			cacheVersion	: String = "1"
		) {
			this._stage = stage;
			this._viewPort = viewPort;
			this._readyCallback = readyCallback;
			
			packer = new RectanglePacker(1024, 1024, 2);
		}
		
		public function addItemToRaster(layout:DisplayObjectContainer, tw:uint = 550, th:uint = 400, id:String = ""):void 
		{
			var child:DisplayObject;
			var numChildren:uint = layout.numChildren;
			
			const w:uint = _viewPort.width;
			const h:uint = _viewPort.height;

			const prop:Number = w < h ? h / th : w / tw;
			
			var 
				xPos:uint, 
				yPos:uint, 
				xPers:Number, 
				yPers:Number,
				cW:Number, 
				cH:Number,
				childID:uint
			;
			for (var i:int = 0; i < numChildren; i++) 
			{
				child = layout.removeChildAt(0);
				
				xPers = child.x / tw;
				yPers = child.y / th;
				
				xPos = w * xPers;
				yPos = h * yPers;
				
				if (child is SimpleButton) {
					SimpleButton(child).upState.scaleX *= prop; 
					SimpleButton(child).upState.scaleY *= prop; 
					
					SimpleButton(child).downState.scaleX *= prop; 
					SimpleButton(child).downState.scaleY *= prop;
				} else {
					child.scaleX *= prop;
					child.scaleY *= prop;
				}
				
				child.x = xPos;
				child.y = yPos;
				
				cW = child.width;
				cH = child.height;
				
				if (child is SimpleButton) {
					childID = _itemsToRaster.length;
					BTN_NAME_UP[0] = child.name;
					_itemsToRaster.push(new RasterItem(childID, BTN_NAME_UP.join(""), SimpleButton(child).upState, new Point(child.x, child.y)));
					packer.insertRectangle(cW, cH, childID);
					
					childID = _itemsToRaster.length;
					BTN_NAME_DOWN[0] = child.name;
					_itemsToRaster.push(new RasterItem(childID, BTN_NAME_DOWN.join(""), SimpleButton(child).downState, new Point(child.x, child.y)));
					packer.insertRectangle(cW, cH, childID);
				} else {
					childID = _itemsToRaster.length;
					
					_itemsToRaster.push(new RasterItem(childID, child.name, child));
					packer.insertRectangle(cW, cH, childID);
				}
			}
					
			packer.packRectangles(true);
			
			var rect:Rectangle = new Rectangle();
			var sourceBMD:BitmapData;
			var sourceRasterItem:RasterItem;
			var mBitmapData:BitmapData = new BitmapData(packer.packedWidth, packer.packedHeight);
			
			_stage.addChild(new Bitmap(mBitmapData));
			
			var xml:XML = new XML("<TextureAtlas imagePath='atlas.png'/>");
			
			for (var j:int = 0; j < packer.rectangleCount; j++)
			{
				var index:int = packer.getRectangleId(j);
				var color:uint = 0xFF171703 + (((18 * ((index + 4) % 13)) << 16) + ((31 * ((index * 3) % 8)) << 8) + 63 * (((index + 1) * 3) % 5));

				sourceRasterItem = _itemsToRaster[index];
				packer.getRectangle(j, rect);
				
				xml.appendChild("<SubTexture name='" + sourceRasterItem.name + "' x='" + rect.x + "' y='" + rect.y + "' width='" + rect.width + "' height='" + rect.height + "'/>");
				
				sourceBMD = sourceRasterItem.bmd;
				
				//mBitmapData.fillRect(new Rectangle(rect.x, rect.y, rect.width, rect.height), 0xFF000000);
				//mBitmapData.fillRect(new Rectangle(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2), color);
				mBitmapData.copyPixels(sourceBMD, sourceBMD.rect, rect.topLeft, null, null, true);
			}
			
			//File.applicationDirectory.browseForSave("FILE");
			
			xml.appendChild("</TextureAtlas>");
			
			//var textureAtlas:TextureAtlas = new TextureAtlas(Texture.fromBitmapData(mBitmapData));
			//var texture:Texture = textureAtlas.getTexture("avatar")
			//var img:Image = new Image(texture);
			//Starling.current.stage.addChild(img);
			//trace(packer.packedHeight, packer.packedWidth);
			
		}
		
		public function process():void 
		{
			
		}
	}
}