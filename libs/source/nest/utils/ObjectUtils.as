package nest.utils
{
	import flash.utils.describeType;

	public class ObjectUtils
	{
		public static function _new(A:Class, param:*):Object
		{
			if (A.prototype.extend)
			{
				trace("params:", param);
				
				var O:Object = new A();
				var E:Object = new A.prototype.extend(); 
				var xml:XML = describeType(E);          
				
				O = copy(O, E, xml.method);
				O = copy(O, E, xml.variable);
				O = copy(O, E, xml.constant);
				O = copy(O, E, xml.accessor);
				
				O.prototype = { }; O.prototype.extend = E;
				return O;
			}
			else return new A(); //->
		}
		
		public static function extend(A:Object, B:Object):Object
		{
			var xml:XML = describeType(B);
			
			A.prototype.extend = B;
			A = copy(A, B, xml.constant);
			A = copy(A, B, xml.variable);
			A = copy(A, B, xml.method);
			A = copy(A, B, xml.accessor);
			
			return A;
		}
		
		public static function copy(A:Object, B:Object, xml:XMLList):Object   
		{
			var node:XML
			
			for each(node in xml)
			{
				try { A[node.@name] = B[node.@name] } catch (e:Error) { trace('fail: '+node.@name) };
			}
			
			return A;
		}
		
		
	}
	
}