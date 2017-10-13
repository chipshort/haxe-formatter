package format;
import format.FormatterFile;
import haxe.Json;
import haxeFormatter.Config;

using format.util.Lambda;

/**
 * ...
 * @author Christoph Otter
 */
class Generator 
{
	static var additionalArgs : Array<String>;
	
	static function main() : Void {
		additionalArgs = ["haxe-formatter.js"];
		
		var formatter = new FormatterFile("node", "haxe");
		
		formatter.Categories.push(basic());
		
		formatter.AdditionalArgs = additionalArgs;
		
		Sys.println(Json.stringify(formatter, null, "    "));
	}
	
	static function basic() {
		var basic = new Category("Basic");
		basic.Code = "";
		
		var select = [new SelectData()];
		
		basic.Options.push(new FormatOption("Base config:", createSelect([
			"Noop" => BaseConfig.Noop,
			"Default" => BaseConfig.Default
		])));
		additionalArgs.push("--baseConfig ${baseConfig}");
		
		basic.Options.push(new FormatOption("Field Modifier Order:", createSelect([
			"Default" => BaseConfig.Default,
			"Noop" => BaseConfig.Noop
		])));
		additionalArgs.push("--fieldModifierOrder ${fieldModifierOrder}");
		
		return basic;
	}
	
	static function createSelect(options : Map<String, String>) {
		var select : Select = options.keys().map(function (k) {
			var data = new SelectData();
			data.Value = options[k];
			data.Name = k;
			return data;
		});
		
		return select;
	}
	
}