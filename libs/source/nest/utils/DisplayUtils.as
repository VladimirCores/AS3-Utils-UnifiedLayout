package nest.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	
	import starling.display.Button;
	import starling.textures.Texture;

	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class DisplayUtils 
	{
		
		/**
		 * Method for convert String to Bitmap. Use them for optimize Static Text. 
		 * It's optimized for use with Blur and Bevel Filters. Please use HTML formatted text with "\n" sign for line break
		 * For Testing purposes you can trace something like this:
			 * " TF Size: " + Math.round((getSize(tf)/1024)*1000) * 0.001 + "Kb"
			 * " BMP Size: " + Math.round((getSize(bmp.bitmapData) / 1024) * 1000) * 0.001 + "Kb"
		 * @param	text			- string of text
		 * @param	textFormat		- Text Field Format
		 * @param	filters			- filters from original text field object
		 * @param	qualityFactor	- antialising quality (2 - default, 4 - best)
		 * @param	cache			- some optimization (cache a TextFormat)
		 * @param	letterSpacing	- space inbetween letters 
		 * @param	w				- specify exact width of the final image
		 * @param	h				- specify exact height of the final image
		 * @param	smooth			- is Smooth Final Pixels
		 * @return Bitmap
		 */
		// DECLARATION FOR - stringToBITMAP
		private static var 	
			tf				:TextField = new TextField()
		,	frmt			:TextFormat
		,	bmd				:BitmapData
		,	bmp				:Bitmap = new Bitmap()
		,	mtr				:Matrix = new Matrix()
		,	filter			:Object = { }
		,	filterDescr		:XML
		;
		private static const
			BLUR_X:String = "blurX"
		,	BLUR_Y:String = "blurY"
		,	DISTANCE:String = "distance"
		,	STRENGTH:String = "strength"
		;
		//==================================================================================================	
		public static function stringToBITMAP(text:String, textFormat:TextFormat = null, filters:Array = null, qualityFactor:Number = 2, cache:Boolean = false, letterSpacing:uint = 2, w:Number = 0, h:Number = 0, smooth:Boolean = true):Bitmap {
		//==================================================================================================	
			if (cache == false || frmt == null) 
				frmt = (textFormat == null ? new TextFormat('Verdana, Arial, Calibri, Monaco', 30, 0xffcc00, true) : textFormat); frmt.letterSpacing = letterSpacing;
			
			tf.width 					= w > 0 ? w : tf.textWidth + 10;
			tf.height 					= h > 0 ? h : tf.textHeight + 2;
			tf.htmlText 				= text;
			tf.antiAliasType 			= AntiAliasType.ADVANCED;
			tf.autoSize 				= TextFieldAutoSize.LEFT;
			tf.setTextFormat(frmt);
			
			if(filters != null) {
				for (var i:int = filters.length-1; i > -1 ; i--) {
					filter = Object(filters[i]);
					filterDescr = describeType(filter);
					filter[BLUR_X] *= qualityFactor;
					filter[BLUR_Y] *= qualityFactor;
					if (filter.hasOwnProperty(DISTANCE)) filter[DISTANCE] *= qualityFactor;
					if (filter.hasOwnProperty(STRENGTH) && String(filterDescr.@name).split("::")[1] != "BevelFilter") filter[STRENGTH] *= qualityFactor;
				}
				tf.filters = filters;
			}
			tf.gridFitType = GridFitType.SUBPIXEL;
			
			filter 			= null;
			filterDescr 	= null;
			if (cache == false || mtr == null) 
			mtr				= new Matrix();
			mtr				.scale( tf.scaleX * qualityFactor, tf.scaleY * qualityFactor);
			bmd				= new BitmapData(tf.width * qualityFactor, tf.height * qualityFactor, true, 0x00000000)
			bmd				.drawWithQuality( tf, mtr, null, null, null, smooth, StageQuality.BEST);
			bmp				.bitmapData = bmd;
			bmp				.smoothing = smooth;
			
			if (cache == false) frmt = null;
			
			bmp.scaleX = bmp.scaleY = 1 / qualityFactor;
			return bmp;
		}
		
		/**
		* @TODO Описать метод
		*
		* Parameters:
		* @TODO Описать аргументы или стереть
		*
		* Return:
		* @TODO Описать что возвращает метод или стереть
		*/
		//==================================================================================================	
		public static function displayObjectToBITMAP(displayObject:flash.display.DisplayObject, scaleFactor:Number = 0, smooth:Boolean = true):Bitmap {
		//==================================================================================================	
			if(scaleFactor > 0) {
				displayObject.scaleX *= scaleFactor;
				displayObject.scaleY *= scaleFactor;
			}	
			mtr				= new Matrix();
			bmd				= new BitmapData(displayObject.width, displayObject.height, true, 0x00000000)
			bmd				.draw(displayObject, mtr, null, null, null, smooth);
			bmp 			= new Bitmap(bmd);
			bmp				.smoothing = smooth;
			return bmp;
		}
		
		//==================================================================================================	
		public static function displayObjectToBitmapData(displayObject:flash.display.DisplayObject, scaleFactor:Number = 0, smooth:Boolean = true):BitmapData {
		//==================================================================================================	
			if(scaleFactor > 0) {
				displayObject.scaleX *= scaleFactor;
				displayObject.scaleY *= scaleFactor;
			}	
			mtr				= new Matrix();
			mtr.scale(displayObject.scaleX, displayObject.scaleY);
			bmd				= new BitmapData(displayObject.width, displayObject.height, true, 0x00000000)
			bmd				.draw(displayObject, mtr, null, null, null, smooth);
			return bmd;
		}
		
		//==================================================================================================	
		public static function getStarlingButtonFromSimpleButtonClass(classRef:Class, sf:Number = 1):Button { 
		//==================================================================================================	
			const buttonGraphics:* = new classRef();
			const buttonUpTexture:Texture = Texture.fromBitmapData(displayObjectToBitmapData(buttonGraphics.upState, sf));
			const buttonDownTexture:Texture = Texture.fromBitmapData(displayObjectToBitmapData(buttonGraphics.downState, sf));
			return new Button(buttonUpTexture, "", buttonDownTexture);
		}
		//==================================================================================================	
		public static function textureFromClass(classRef:Class, sf:Number):Texture {
		//==================================================================================================	
//			trace("CREATE imageFromClassRef for: ", classRef, sf);
			const displayObject:DisplayObject = new classRef() as DisplayObject;
			mtr = displayObject.transform.matrix;
			displayObject.scaleX = displayObject.scaleY = sf;
			mtr.scale(sf, sf);
			bmd = new BitmapData(displayObject.width, displayObject.height, true, 0x00000000);
			bmd.draw(displayObject, mtr);
			return Texture.fromBitmapData(bmd, false, false);
		}
		
	}

}
