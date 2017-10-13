package format.util;

/**
 * ...
 * @author Christoph Otter
 */
class Lambda 
{

	public function new() 
	{
		
	}
	
	public static function map<T, U>(it : Iterator<T>, convert : T->U) : Array<U>
	{
		var a = new Array<U>();
		
		for (i in it) {
			a.push(convert(i));
		}
		
		return a;
	}
	
}