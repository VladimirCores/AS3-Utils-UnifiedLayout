package ui.rasterizer 
{
	import flash.data.EncryptedLocalStore;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
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
	import flash.utils.Dictionary;
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
	 * @author Vladimir Minkin
	 */
	public class Rasterizer extends EventDispatcher
	{
		static private const BTN_NAME_UP:Array = ["", "up"];
		static private const BTN_NAME_DOWN:Array = ["", ""];
		
		private var _readyCallback:Function;
		
		private var _itemsToRaster:Vector.<RasterItem> = new Vector.<RasterItem>();
		private var _viewPort:Rectangle;
		private var _name:Array = ["name", "ver", "number"];
		private var _cacheVersion:String;
		
		private var _packer:RectanglePacker;
		
		private var _isCacheExist:Boolean;
		private var _atlasTexture:TextureAtlas;
		private var _atlasXML:XML;
		
		private var _minAtlasSize:uint;
		private var _maxAtlasSize:uint;
		private var _currentAtlasSize:uint;
		
		private const _isObjectAlreadyExist:Dictionary = new Dictionary(true);
		
		public function Rasterizer(
			name			: String,
			viewPort		: Rectangle,
			readyCallback	: Function, 
			cacheVersion	: String = "1",
			minAtlasSize	: uint = 1024,
			maxAtlasSize	: uint = 4096
		) {
			this._viewPort = viewPort;
			this._readyCallback = readyCallback;
			this._cacheVersion = cacheVersion;
			
			_minAtlasSize = minAtlasSize;
			_maxAtlasSize = maxAtlasSize;
			_currentAtlasSize = 0;
			
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
			var doc			:DisplayObjectContainer;
			var mc			:MovieClip;
			var frame		:DisplayObject;
			var child		:DisplayObject = layout.getChildByName("background");
			var childName	:String;
			var numChildren	:uint = layout.numChildren;
			var constrain	:NConstrain;
			var rasterItem	:RasterItem;
			
			var w:uint = _viewPort.width;
			var h:uint = _viewPort.height;
			
			var lt:Point;
			var rb:Point;
			
			var
				i		:int,
				cW		:uint, 
				cH		:uint
			;

			layoutWidth = layoutWidth > 0 ? layoutWidth : layout.width;
			layoutHeight = layoutHeight > 0 ? layoutHeight : layout.height;
			
			trace("layoutWidth, layoutHeight:", w, layoutWidth, h, layoutHeight);
			
			if (layoutID == "") layoutID = layout.name;
			if (child) {
				layout.removeChild(child);
				numChildren--;
			}
			
			const prop:Number = proportion > 0 ? proportion : Math.ceil((w < h ? h / layoutHeight : w / layoutWidth) * 1000) / 1000;
			
			trace("prop", prop)
			
			while(numChildren--)
			{
				child = layout.getChildAt(numChildren);
				childName = child.name;
				
				mc = null;
				doc = null;
				
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
					mc = child as MovieClip;
					child.scaleX = prop; //child.width *= prop;//child.width = (rb.x - lt.x) * w;
					child.scaleY = prop; //child.height *= prop;//child.height = (rb.y - lt.y) * h;
				}
				
				doc = child is SimpleButton ?  (SimpleButton(child).upState as DisplayObjectContainer) : (child as DisplayObjectContainer);
				if ( doc &&  (constrain = GetConstrainFromChild(doc)))  
				{
					switch (constrain.constrainX) {
						case NConstrain.LEFT: 	child.x *= prop; break;
						case NConstrain.RIGHT: 	child.x = w - Math.floor((layoutWidth - child.x) * prop); /*Math.ceil(rb.x * w - child.width);*/ break;
						case NConstrain.CENTER: child.x = (w - child.width) * 0.5 - Math.floor((child.x - (layoutWidth - cW) * 0.5) * prop); break;
						case NConstrain.NONE: 	child.x = lt.x * w; break;
					}
					
					switch (constrain.constrainY)  {
						case NConstrain.TOP: 	child.y *= prop; break;
						case NConstrain.BOTTOM: child.y = h - Math.floor((layoutHeight - child.y) * prop); /* Math.ceil(rb.y * h - child.height);// */ break;
						case NConstrain.CENTER: child.y = (h - child.height) * 0.5 - Math.floor((child.y - (layoutHeight - cH) * 0.5) * prop); break;
						case NConstrain.NONE: 	child.y = lt.y * h; break;
					}
				} 
				else { // From Top Left
					child.x = lt.x * w;
					child.y = lt.y * h;
				}
				
				if (child is SimpleButton) 
				{
					BTN_NAME_UP[0] = child.name;
					RegisterRasterItem(_itemsToRaster.length, layoutID, RasterTypes.BUTTON, BTN_NAME_UP.join(""), SimpleButton(child).upState, new Point(child.x, child.y))
					RegisterRasterItem(_itemsToRaster.length, layoutID, RasterTypes.BUTTON, childName, SimpleButton(child).downState, new Point(child.x, child.y))
				} 
				else if (mc != null && mc.totalFrames > 1) 
				{
					mc.gotoAndStop(0);
					RegisterRasterItem(_itemsToRaster.length, layoutID, RasterTypes.MOVIECLIP, childName, mc);
					var objectsToRaster:Array = _isObjectAlreadyExist[childName];
					if(objectsToRaster.length == 0)
					{
						for (i = 2; i <= mc.totalFrames; i++) {
							mc.gotoAndStop(i);
							RegisterRasterItem(_itemsToRaster.length, childName, RasterTypes.MOVIECLIP, childName+"_"+i, mc);
							mc.nextFrame();
						}
						mc.gotoAndStop(0);
					}
				}
				else
				{
					RegisterRasterItem(_itemsToRaster.length, layoutID, RasterTypes.IMAGE, child.name, child);
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
		
		public function getLayoutByID(lid:String, playMC:Boolean = false, fps:uint = 30 ):Sprite {
			var result			: Sprite = new Sprite();
			var subTextures		: XMLList = _atlasXML.SubTexture.(@lid==lid);
			var subTexture		: Texture;
			var subTextureName	: String;
			var displayObject	: starling.display.DisplayObject;
			
			for each (var subTextureXML:XML in subTextures) 
			{ 
				subTextureName = subTextureXML.@name;
				//trace(subTextureName, "subTextureXML.@type", subTextureXML.@type);
				switch(int(subTextureXML.@type))
				{
					case RasterTypes.IMAGE:	 
						subTexture = _atlasTexture.getTexture(subTextureName);
						displayObject = new Image(subTexture); 
					break;
					case RasterTypes.BUTTON:	
						subTexture = _atlasTexture.getTexture(subTextureName);
						if (displayObject is Button) {
							Button(displayObject).downState = subTexture;
							Button(displayObject).scaleWhenDown = 1;
						} else {
							displayObject = new Button(subTexture); 
						}
					break;
				case RasterTypes.MOVIECLIP:
					displayObject = new starling.display.MovieClip(_atlasTexture.getTextures(subTextureName));
					if (playMC) {
						starling.display.MovieClip(displayObject).fps = fps;
						Starling.juggler.add(starling.display.MovieClip(displayObject));
					}
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
			trace("Atlas expected size:", _currentAtlasSize, _minAtlasSize * _minAtlasSize);
			
			var atlasMinSize:uint = _minAtlasSize * _minAtlasSize;
			var atlasMaxSize:uint = _maxAtlasSize * _maxAtlasSize;
			
			if (_currentAtlasSize > atlasMinSize && _currentAtlasSize < atlasMaxSize) _minAtlasSize *= 2;
			
			_packer = new RectanglePacker(_minAtlasSize, _minAtlasSize, 0);
			_atlasXML = new XML("<TextureAtlas imagePath='" + _name.join("_") +"'/>");
			
			_itemsToRaster.forEach(function(item:RasterItem, index:int, vec:Vector.<RasterItem>):void {
				_packer.insertRectangle(item.width, item.height, item.id);
			});
			_packer.packRectangles(true);

			var duplicates:Array;
			var duplicatesCount:uint;
			
			var atlasRect	: Rectangle = new Rectangle();
			var rasterBMD	: BitmapData;
			var rasterRect	: Rectangle;
			var rasterItem	: RasterItem;
			var rasterPos	: Point;
			var rasterName	: String;
			
			var atlasBMD	: BitmapData = new BitmapData(_packer.packedWidth, _packer.packedHeight);
			
			var subTextureXML:XML;
			for (var j:int = 0, index:int; j < _packer.rectangleCount; j++)
			{
				index = _packer.getRectangleId(j);
				
				rasterItem 	= _itemsToRaster[index];
				rasterBMD 	= rasterItem	.bmd;
				rasterRect 	= rasterBMD		.rect;
				rasterPos 	= rasterItem	.pos;
				rasterName	= rasterItem	.name;
				
				_packer.getRectangle(j, atlasRect);
				 
				subTextureXML = <SubTexture 
					name 	= { rasterName } 
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
				
				duplicates = _isObjectAlreadyExist[rasterName];
				duplicatesCount = duplicates.length;
				if (duplicatesCount > 0) {
					while (duplicatesCount--) {
						rasterItem = duplicates.shift();
						rasterPos = rasterItem.pos;
						subTextureXML = subTextureXML.copy();
						subTextureXML.@lid = rasterItem.lid;
						subTextureXML.@px = rasterPos.x;
						subTextureXML.@py = rasterPos.y;
						_atlasXML.appendChild(subTextureXML);
					}
					delete _isObjectAlreadyExist[rasterName];
				} 
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
		
		private function GetConstrainFromChild(doc:DisplayObjectContainer):NConstrain {
			var child:DisplayObject = NConstrain(doc.getChildByName("constrain"));
			var counter:uint = doc.numChildren;
			if(child == null) while (counter--) {
				child = doc.getChildAt(counter);
				if (child is NConstrain) break;
			} 
			return child as NConstrain;
		}
		
		private function RegisterRasterItem(
			childID		:int, 
			layoutID	:String, 
			type		:int, 
			name		:String,
			entity		:DisplayObject,
			position	:Point = null
		):void {
			const rasterItem:RasterItem = new RasterItem(
				childID, layoutID, type, name, 
				entity, position
			);
			var duplicates:Array = _isObjectAlreadyExist[name];
			if (!duplicates) {
				_itemsToRaster.push(rasterItem);
				_isObjectAlreadyExist[name] = new Array();
				_currentAtlasSize += rasterItem.getSize();
			} else {
				duplicates.push(rasterItem);
			}
		}
		
		public function get isCacheExist():Boolean { return _isCacheExist; }
		public function get cacheVersion():String  { return _cacheVersion; }
		public function get name():String { return _name[0]; }
	}
}