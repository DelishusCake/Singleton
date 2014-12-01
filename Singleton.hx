import haxe.macro.Context;
import haxe.macro.Expr;

#if !macro @:autoBuild(Singleton.build()) #end
class Singleton
{
	macro static public function build():Array<Field>
	{
		var local = Context.getLocalClass().toString().split(".");
		
		var pos = Context.currentPos();
		var pack = local.splice(0, local.length - 1);
		var clazz = local[0];
		var type = TPath( { pack: pack , name: clazz, params: [], sub: null } );
		
		var fields = Context.getBuildFields();
		fields.push( { name: "instance", pos: pos, access: [AStatic, APrivate], kind: FVar(type, null) } );
		fields.push( { name: "getInstance", doc: "Get the instance of this singleton", pos: pos, access: [AStatic, APublic], kind:
			FFun({
				args: [], params: [], ret: type, 
				expr: {
					expr: {
						EBlock([
							{
								expr: EIf(
									{ expr: EBinop(OpEq, { expr: EConst(CIdent("instance")), pos: pos }, { expr: EConst(CIdent("null")), pos: pos } ), pos: pos }, 
									{ expr: EBinop(OpAssign, { expr: EConst(CIdent("instance")), pos: pos }, { expr: ENew( { name: clazz, pack: pack, params: [] }, []), pos: pos } ), pos: pos }, null),
								pos: pos 
							},
							{ expr: EReturn( { expr: EConst(CIdent("instance")), pos: pos } ), pos: pos }
						]);
					},
					pos: pos
				}
			})
		});
		return fields;
	}
}