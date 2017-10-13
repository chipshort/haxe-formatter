package format;

import Type as TypeCl;

class FormatterFile
{
	public var Command: String;
	public var Language: String;
	public var Categories = new Array<Category>();
	public var Code: String;
	public var AdditionalArgs: Array<String>;
	
	public function new(type: String, language: String)
	{
		this.Command = type;
		this.Language = language;
	}
}

class Category
{
	public var Name: String;
	public var Code: String;
	public var Options = new Array<FormatOption>();
	
	public function new(name: String)
	{
		this.Name = name;
	}
}

class FormatOption
{
	public var Id: String;
	public var Name: String;
	public var Type: String;
	public var CheckData: Check;
	public var SelectData : Select;
	public var NumberData : Number;
	
	public function new(name: String, data: Dynamic)
	{
		this.Name = name;
		this.Id = camelCasify(name);
		
		if (Std.is(data, Select)) {
			this.SelectData = data;
			this.Type = "select";
		}
		else if (Std.is(data, Check))
			this.CheckData = data;
		else if (Std.is(data, Number))
			this.NumberData = data;
		else
			throw "Invalid type for data";
		
		if (this.Type == null) {
			var split = TypeCl.getClassName(TypeCl.typeof(data).getParameters()[0]).split(".");
			this.Type = split[split.length-1].toLowerCase();
		}
	}
	
	static function camelCasify(s : String) : String
	{
		var res = "";
		
		var nextUpper = false;
		var i = 0;
		while (i < s.length) {
			var c = s.charAt(i);
			
			if (c == ":") {
				i++;
				continue;
			}
			if (c == " ") {
				nextUpper = true;
			}
			else if (nextUpper) {
				res += c.toUpperCase();
				nextUpper = false;
			}
			else {
				res += c.toLowerCase();
				nextUpper = false;
			}
			
			i++;
		}
		
		return res;
	}
}

class Number
{
	public var Min: Int;
	public var Max: Int;
	public var DefaultValue: Int;
	public var Arg: String;
	
	public function new(min: Int, max: Int, defaultVal: Int)
	{
		this.Min = min;
		this.Max = max;
		this.DefaultValue = defaultVal;
	}
}

class Check
{
	public var Unchecks: Array<String>;
	//public var checks: Array<String>; // maybe?
	public var ArgChecked: String;
	public var ArgUnchecked: String;
	public var DefaultValue: Bool;
	
	public var Suboptions: Array<FormatOption>;
	
	public function new(arg_enabled: String)
	{
		this.ArgChecked = arg_enabled;
	}
}

typedef Select = Array<SelectData>;

class SelectData
{
	public var Name: String;
	public var Value: String;
	public var Arg: String;
	public var Disables: Array<String>;
	
	public function new() {}
}