import haxe.macro.Context;
import haxe.macro.Expr;

#if !macro

@:autoBuild(Singleton.build())
interface Singleton {}

#else

class Singleton {
	public static macro function build():Array<Field> {
		var pos = Context.currentPos();
		var pack = Context.getLocalClass().get().pack;
		var className = Context.getLocalClass().get().name;
		var typePath = { pack: pack , name: className };
		var type = TPath( typePath );
		
		var fields = Context.getBuildFields();
		fields.push( { name: "instance", pos: pos, access: [AStatic, APublic], kind: FProp("get", "null", type) } );
		fields.push( { name: "get_instance", pos: pos, access: [AStatic, APrivate],
			meta: [ { name: ":noCompletion", pos: pos } ],
			kind: FFun( {
				args: [], ret: type,
				expr: macro return instance == null ? instance = new $typePath() : instance
			} )
		} );
		fields.push( { name: "getInstance", pos: pos, access: [AStatic, APublic, AInline],
			meta: [ { name: ":noCompletion", pos: pos } ],
			kind: FFun( { args: [], ret: type, expr: macro return get_instance() } )
		} );
		
		var constructorExists = false;
		for( field in fields ) {
			if( field.name == "new" ) {
				constructorExists = true;
				break;
			}
		}
		
		if( !constructorExists ) {
			var constructorExpr = macro {};
			
			if( Context.getLocalClass().get().superClass != null ) {
				constructorExpr = macro super();
			}
			
			fields.push( { name: "new", pos: pos, access: [APrivate],
				kind: FFun( { args: [], ret: null, expr: constructorExpr } )
			} );
		}
		
		return fields;
	}
}

#end
