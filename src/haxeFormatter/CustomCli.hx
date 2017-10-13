package haxeFormatter;

import haxeFormatter.util.CliMacro;
import sys.FileSystem;
import sys.io.File;
using StringTools;

/**
 * ...
 * @author Christoph Otter
 */
class CustomCli 
{
	static function main() {
        new CustomCli();
    }

	var config:Config;

    function new() {
		config = {
			imports: {},
			padding: {
				colon: {},
				binaryOperator: {},
				insideBrackets: {},
				comma: {},
				questionMark: {},
				//TODO: finish
			},
			indent: {},
			braces: {newlineBeforeOpening: {}}
		}
		
        var args = Sys.args();
        var paths = [];
		
        var argHandler = CliMacro.getArgs();
		
        argHandler.parse(args);
        if (args.length == 0) {
            Sys.println("Haxe Formatter");
            Sys.println(argHandler.getDoc());
            Sys.exit(0);
        }
		
		try {
			var code = readAll(Sys.stdin()).toString();
			formatCode(code);
		} catch (e : Any) {
			trace(e);
		}
		
    }
	
	inline function readAll(input:haxe.io.Input) {
		var bufsize = (1 << 14); // 16 Ko

		var buf = haxe.io.Bytes.alloc(bufsize);
		var total = new haxe.io.BytesBuffer();
		try {
			while( true ) {
				var len = input.readBytes(buf, 0, bufsize);
				if( len == 0 )
					throw haxe.io.Eof;
				total.addBytes(buf,0,len);
			}
		} catch( e : Any ) { }
		return total.getBytes();
	}

	function formatCode(code:String) {
		var formatted = Formatter.formatSource(code, config);
        switch (formatted) {
            case Success(data):
                Sys.print(data);
            case Failure(reason):
                error(reason);
        }
	}

    function error(reason:String) {
        Sys.stderr().writeString('Could not format code: $reason\n');
    }
	
}