package nest.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;

	public final class FileUtils
	{
		static public function readStringFromFile(path:String):String {
			var result:String = "";
			var localFile:File = File.applicationDirectory.resolvePath(path);
			var fileStream:FileStream = new FileStream();
			fileStream.open(localFile, FileMode.READ);
			result = fileStream.readUTFBytes(fileStream.bytesAvailable);
			
			fileStream.close();
			fileStream = null;
			localFile = null;
			
			return result;
		}
		
		static public function readBytesFromFile(path:String, uncompressed:Boolean = false):ByteArray {
			var file			:File 			= File.applicationDirectory.resolvePath(path);
			var fileStream		:FileStream 	= new FileStream();
			var byteArray		:ByteArray 		= new ByteArray();
			
			if(!file.exists) return byteArray;
			
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(byteArray);
			if(uncompressed)
			try { byteArray.uncompress(CompressionAlgorithm.LZMA); }
			catch ( e:Error ) { trace( "The ByteArray wasn't compressed!" ); }
			
			fileStream.close();
			fileStream = null;
			file = null;
			
			return byteArray;
		}
	}
}