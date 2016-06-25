package nest.utils
{
	public final class StringUtils
	{
		public static function setCharAt(str:String, char:String, index:int):String {
			return str.substr(0,index) + char + str.substr(index + 1);
		}
		
		public static  function replaceBackslashes($string:String, simbol:String="'"):String {
			return $string.replace(/\\/g, simbol);
		}
		
		public static  function replaceSymbolsWith($string:String, simbol:String, replacer:String):String {
			return $string.replace(new RegExp('/' + simbol + '/g'), simbol);
		}
		
		public static function getStringFromEmptyCharactersInArray(arr:Array, replacer:String = "-"):String {
			return arr.filter(function(item:String, index:uint, arr:Array):Boolean {
				return item == null || item == "";
			}).join(replacer);
		}
	}
}