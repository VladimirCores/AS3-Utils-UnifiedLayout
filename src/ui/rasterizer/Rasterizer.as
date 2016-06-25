package ui.rasterizer 
{
	import flash.data.EncryptedLocalStore;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import nest.controls.NConstrain;
	
	import org.villekoskela.utils.RectanglePacker;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
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
		private var _name:Array = ["name", "ver", "number"];
		private var _cacheVersion:String;
		
		private var _packer:RectanglePacker;
		
		private var _isCacheExist:Boolean;
		private var _atlasTexture:TextureAtlas;
		private var _atlasXML:XML;
		
		public function Rasterizer(
			name			: String,
			viewPort		: Rectangle,
			readyCallback	: Function, 
			cacheVersion	: String = "1"
		) {
			this._viewPort = viewPort;
			this._readyCallback = readyCallback;
			this._cacheVersion = cacheVersion;
			
			_name[0] = name;
			_name[2] = cacheVersion;
			
			var ba:ByteArray = EncryptedLocalStore.getItem(name);
			var latestVersion:String = ba ? ba.readUTFBytes(ba.length) : null;
			
			_isCacheExist = latestVersion == cacheVersion;
		}
		
		public function addLayoutToRaster(
			layout:DisplayObjectContainer, layoutID:String = "", 
			layoutWidth:uint = 0, layoutHeight:uint = 0, proportion:Number = 0
		):void {
			var doc:DisplayObjectContainer;
			var constrain:NConstrain;
			var child:DisplayObject = layout.getChildByName("background");
			var numChildren:uint = layout.numChildren;
			
			const w:uint = _viewPort.width;
			const h:uint = _viewPort.height;
			
			var lt:Point;
			var rb:Point;
			
			var 
				cW		:uint, 
				cH		:uint,
				childID	:uint
			;

			layoutWidth = layoutWidth > 0 ? layoutWidth : layout.width;
			layoutHeight = layoutHeight > 0 ? layoutHeight : layout.height;
			
			trace("layoutWidth, layoutHeight:", layoutWidth, layoutHeight);
			
			if (layoutID == "") layoutID = layout.name;
			if (child) {
				layout.removeChild(child);
				numChildren--;
			}
			
			const prop:Number = proportion > 0 ? proportion : Math.ceil((w < h ? h / layoutHeight : w / layoutWidth) * 1000) / 1000;
			//const prop:Number = proportion > 0 ? proportion : (w < h ? h / layoutHeight : w / layoutWidth);
			
			trace("prop", prop)
			
			while(numChildren--)
			{
				child = layout.getChildAt(numChildren);
				
				cW = child.width;
				cH = child.height;
				
				lt = new Point(Math.floor((child.x / layoutWidth) * 100) / 100, Math.floor((child.y / layoutHeight) * 100) / 100);
				rb = new Point(Math.floor(((child.x + cW) / layoutWidth) * 100) / 100, Math.floor(((child.y + cH) / layoutHeight) * 100) / 100);
				
				if (child is SimpleButton)
				{
					SimpleButton(child).upState.scaleX = prop; 
					SimpleButton(child).upState.scaleY = prop; 
					
					SimpleButton(child).overState.scaleX = prop; 
					SimpleButton(child).overState.scaleY = prop; 
					
					SimpleButton(child).downState.scaleX = prop; 
					SimpleButton(child).downState.scaleY = prop;
					
					SimpleButton(child).hitTestState.scaleX = prop; 
					SimpleButton(child).hitTestState.scaleY = prop;
				} 
				else 
				{
					//child.width *= prop;//
					//child.width = (rb.x - lt.x) * w;
					//child.height *= prop;
					//child.height = (rb.y - lt.y) * h;
					
					child.scaleX = prop;
					child.scaleY = prop;
				}
				
				doc = child is SimpleButton ? (SimpleButton(child).upState as DisplayObjectContainer) : (child as DisplayObjectContainer);
				trace(doc, doc.numChildren, typeof child)
				if ( doc && (constrain = NConstrain(doc.getChildByName("constrain")))) {
					
					trace("constrainX", constrain.constarainX);
					trace("constrainY", constrain.constarainY);
					
					switch (constrain.constarainX) 
					{
						case NConstrain.LEFT:
							child.x *= prop;
						break;
						case NConstrain.RIGHT:
							child.x = w - (layoutWidth - child.x) * prop;
						break;
					}
					
					switch (constrain.constarainY) 
					{
						case NConstrain.TOP:
							child.y *= prop;
						break;
						case NConstrain.BOTTOM:
							child.y *= prop;
						break;
					}
				
					
				} else {
					child.x = lt.x * w;
					child.y = lt.y * h;
					
					//child.x = Math.ceil(rb.x * w - child.width);
					//child.y = Math.ceil(rb.y * h - child.height);
				}
				
				//trace(child.name, "> ", child.height / cH, child.width / cW);
				
				if (child is SimpleButton) 
				{
					childID = _itemsToRaster.length;
					BTN_NAME_DOWN[0] = child.name;
					_itemsToRaster.push(new RasterItem(
						childID, layoutID, RasterTypes.BUTTON, BTN_NAME_DOWN.join(""), 
						SimpleButton(child).downState, new Point(child.x, child.y))
					);
					
					childID = _itemsToRaster.length;
					BTN_NAME_UP[0] = child.name;
					_itemsToRaster.push(new RasterItem(
						childID, layoutID, RasterTypes.BUTTON, BTN_NAME_UP.join(""), 
						SimpleButton(child).upState, new Point(child.x, child.y))
					);
				} 
				else 
				{
					childID = _itemsToRaster.length;
					_itemsToRaster.push(new RasterItem(childID, layoutID, RasterTypes.IMAGE, child.name, child));
				}
			}
		}
		
		public function process(usecache:Boolean = true):void 
		{
			if (_isCacheExist && usecache) {
				ProcessFromLoad();
			} else {
				ProcessAndSave();
			}
		}
		
		public function getLayoutByID(lid:String):Sprite {
			var result			: Sprite = new Sprite();
			var subTextures		: XMLList = _atlasXML.SubTexture.(@lid==lid);
			var subTexture		: Texture;
			var subTextureName	: String;
			var displayObject	: starling.display.DisplayObject;
			
			for each (var subTextureXML:XML in subTextures) 
			{ 
				subTextureName = subTextureXML.@name;
				subTexture = _atlasTexture.getTexture(subTextureName);
				switch(int(subTextureXML.@type))
				{
					case RasterTypes.IMAGE:	 displayObject = new Image(subTexture); 
					break;
					case RasterTypes.BUTTON:	
						if (displayObject is Button) {
							Button(displayObject).downState = subTexture;
							Button(displayObject).scaleWhenDown = 1;
						} else {
							displayObject = new Button(subTexture); 
						}
					break;
					case RasterTypes.MOVIECLIP:
					break;
					default: displayObject = new Sprite(); break;
				}
				
				displayObject.x = int(subTextureXML.@px);
				displayObject.y = int(subTextureXML.@py);
				displayObject.name = subTextureName;
				
				result.addChild(displayObject);
			}
			return result;
		}
		
		private function ProcessAndSave():void {
			
			_packer = new RectanglePacker(1024, 1024, 2);
			_atlasXML = new XML("<TextureAtlas imagePath='" + _name.join("_") +"'/>");
			
			_itemsToRaster.forEach(function(item:RasterItem, index:int, vec:Vector.<RasterItem>):void {
				_packer.insertRectangle(item.width, item.height, item.id);
			});
			_packer.packRectangles(true);
			
			var atlasRect	: Rectangle = new Rectangle();
			var rasterBMD	: BitmapData;
			var rasterRect	: Rectangle;
			var rasterItem	: RasterItem;
			var rasterPos	: Point;
			
			var atlasBMD	: BitmapData = new BitmapData(_packer.packedWidth, _packer.packedHeight);
			
			var subTextureXML:XML;
			for (var j:int = 0, index:int; j < _packer.rectangleCount; j++)
			{
				index = _packer.getRectangleId(j);
				
				rasterItem 	= _itemsToRaster[index];
				rasterBMD 	= rasterItem	.bmd;
				rasterRect 	= rasterBMD		.rect;
				rasterPos 	= rasterItem	.pos;
				
				_packer.getRectangle(j, atlasRect);
				 
				subTextureXML = <SubTexture 
					name 	= { rasterItem.name } 
					type	= { rasterItem.type } 
					lid		= { rasterItem.lid } 
					px 		= { rasterPos.x } 
					py 		= { rasterPos.y } 
					x 		= { atlasRect.x } 
					y 		= { atlasRect.y } 
					width 	= { atlasRect.width } 
					height 	= { atlasRect.height }
				/>
				_atlasXML.appendChild(subTextureXML);
				
				atlasBMD.copyPixels(rasterBMD, rasterRect, atlasRect.topLeft, rasterBMD, rasterRect.topLeft, false);
			}
			
			_atlasTexture = new TextureAtlas(Texture.fromBitmapData(atlasBMD), _atlasXML);
			
			var ba:ByteArray = EncryptedLocalStore.getItem(name);
			var latestVersion:String = ba ? ba.readUTFBytes(ba.length) : null;
			
			var fileXML:File;
			var fileAtlas:File;
			var fileStream:FileStream = new FileStream();
			
			var fileName:String;
			
			// Delete previous created files
			// C:\Users\Vladimir Minkin\AppData\Local\Temp
			if (latestVersion) 
			{
				_name[2] = latestVersion;
				fileName = _name.join("_");
				fileXML = File.cacheDirectory.resolvePath(String(fileName + ".xml"));
				if (fileXML.exists) fileXML.deleteFile();
				fileAtlas = File.cacheDirectory.resolvePath(String(fileName + ".png"));
				if (fileAtlas.exists) fileAtlas.deleteFile();
				_name[2] = _cacheVersion;
			} 
			
			fileName = _name.join("_");
			fileXML = File.cacheDirectory.resolvePath(String(fileName + ".xml"));
			fileStream.open(fileXML, FileMode.WRITE);
			fileStream.writeUTFBytes(_atlasXML.toXMLString());
			fileStream.close();
			
			fileAtlas = File.cacheDirectory.resolvePath(String(fileName + ".png"));
			fileStream.open(fileAtlas, FileMode.WRITE);
			
			if(ba) {
				ba.clear();
				ba.position = 0;
			} else ba = new ByteArray();
			atlasBMD.encode(new Rectangle(0, 0, atlasBMD.width, atlasBMD.height), new PNGEncoderOptions(true), ba);
			fileStream.writeBytes(ba);
			fileStream.close();
			
			ba.clear();
			ba.position = 0;
			ba.writeUTFBytes(_cacheVersion);
			EncryptedLocalStore.setItem(name, ba);
			
			_readyCallback();
		}
		
		private function ProcessFromLoad():void {
			var fileXML:File;
			var fileStream:FileStream = new FileStream();
			var fileName:String = _name.join("_") + ".xml";
			
			fileXML = File.cacheDirectory.resolvePath(fileName);
			if (fileXML.exists) {
				fileStream.addEventListener(Event.COMPLETE, Handler_ReadXMLFileComplete);
				fileStream.openAsync(fileXML, FileMode.READ);
			}
		}
		
		private function Handler_ReadXMLFileComplete(e:Event):void {
			var fileAtlas:File;
			var fileStream:FileStream = FileStream(e.currentTarget);
			var fileName:String = _name.join("_") + ".png";
			
			fileStream.removeEventListener(Event.COMPLETE, Handler_ReadXMLFileComplete);
			_atlasXML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			
			fileAtlas = File.cacheDirectory.resolvePath(fileName);
			if(fileAtlas.exists) {
				fileStream.addEventListener(Event.COMPLETE, Handler_ReadAtlasFileComplete);
				fileStream.openAsync(fileAtlas, FileMode.READ);
			}
		}
		
		private function Handler_ReadAtlasFileComplete(e:Event):void {
			var ba:ByteArray = new ByteArray();
			var loader:Loader = new Loader();
			var handleLoad:Function = function(evt:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handleLoad);
				_atlasTexture = new TextureAtlas(Texture.fromBitmap(Bitmap(loader.content)), _atlasXML);
				_readyCallback();
				loader.unloadAndStop(true);
				ba.clear();
				loader = null;
			}
			var fileStream:FileStream = FileStream(e.currentTarget);
			fileStream.removeEventListener(Event.COMPLETE, Handler_ReadAtlasFileComplete);
			fileStream.readBytes(ba);
			fileStream.close();
			fileStream = null;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoad);
			loader.loadBytes(ba);
		}
		
		public function get isCacheExist():Boolean { return _isCacheExist; }
		public function get cacheVersion():String  { return _cacheVersion; }
		public function get name():String { return _name[0]; }
	}
}