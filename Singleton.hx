import haxe.macro.Context;
import haxe.macro.Expr;

#if !macro @:autoBuild(SingletonBuilder.build()) #end
interface Singleton {}

@:noCompletion
class SingletonBuilder {
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
		return fields;
	}
}
