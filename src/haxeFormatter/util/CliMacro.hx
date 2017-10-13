package haxeFormatter.util;

import format.FormatterFile;
import format.FormatterFile.Category;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxeFormatter.util.CliMacro.FieldTree;

using StringTools;
using Lambda;

/**
 * ...
 * @author Christoph Otter
 */
class CliMacro {
	
	macro public static function getArgs() : Expr {
		var leaves = getOptions();
		var argExprs = new Array<Expr>();
		
		
		for (l in leaves) {
			var path = l.toPath();
			
			var arg = "--" + path.join("-").substr("config-".length);
			var expr = macro @doc($v{l.doc == null ? "" : l.doc}) [$v{arg}] => function(arg) ${Context.parse(path.join("."), Context.currentPos())} = arg;
			argExprs.push(expr);
		}
		
		return haxeFormatter.util.ArgsHelper.generate(macro $a{argExprs});
		
		return macro {};
	}
	
	#if macro
	
	static function getOptions() : Array<FieldTree> {
		var configType = Context.follow(Context.getType("haxeFormatter.Config"));
		var tree = getFieldTree(configType, "config");
		var leaves = tree.getAllSubFields().filter(function (f) return f.isLeaf());
		
		return leaves;
	}
	
	static function getFieldTree(type : Type, name : String) : FieldTree {
		var tree = new FieldTree(null, "config", type);
		
		switch (type) {
			case TAnonymous(type):
				var t = type.get();
				for (field in t.fields) {
					tree.addSubField(field);
				}
			default:
				Context.error("type should be TAnonymous", Context.currentPos());
		}
		
		return tree;
	}
	#end
}

#if macro

class FieldTree {
	
	public var subFields = new Array<FieldTree>();
	public var parent : FieldTree;
	public var name : String;
	public var doc : String;
	public var type : Type;
	
	public function new(p : FieldTree, n : String, t : Type) {
		parent = p;
		name = n;
		type = t;
	}
	
	public function addSubField(field : ClassField) {
		var fieldTree = new FieldTree(this, field.name, field.type);
		fieldTree.doc = field.doc;
		subFields.push(fieldTree);
		
		var fieldType = Context.follow(field.type);
		
		switch (fieldType) {
			case TAnonymous(type):
				for (field in type.get().fields)
					fieldTree.addSubField(field); //add all subFields recursively
			default:
				//fieldType has no subfields
		}
	}
	
	public function toPath() : Array<String> {
		if (parent == null)
			return [name];
		
		var path = parent.toPath();
		path.push(name);
		return path;
	}
	
	/**
	 * Gets subFields and subsubFields, ...
	 * @return
	 */
	public function getAllSubFields() : Array<FieldTree> {
		var array = subFields;
		
		for (sub in subFields) {
			array = array.concat(sub.getAllSubFields());
		}
		
		return array;
	}
	
	public function isLeaf() : Bool {
		return subFields.length == 0;
	}
}

#end