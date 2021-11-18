import haxe.macro.Context;
import haxe.macro.Expr;

#if !macro

@:autoBuild(Singleton.build())
interface Singleton {}

#else

class Singleton {
	public static macro function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		//Interfaces can extend this, but no changes are needed.
		if(Context.getLocalClass().get().isInterface) {
			return fields;
		}
		
		var typePath:TypePath = {
			pack: Context.getLocalClass().get().pack,
			name: Context.getLocalClass().get().name
		};
		var type:ComplexType = TPath(typePath);
		
		/**
		 * Extracts the fields from the given `macro class XYZ {}`
		 * expression, and adds them to `fields`.
		 * 
		 * This function mainly exists for readability.
		 */
		function addClassFields(classDef:TypeDefinition):Void {
			fields = fields.concat(classDef.fields);
		}
		
		#if display
			addClassFields(macro class Singleton {
				public static var instance:$typePath;
			});
			return fields;
		#end
		
		//Define the `instance` field and its getters.
		addClassFields(macro class Singleton {
			public static var instance(get, null):$type;
			
			@:noCompletion private static function get_instance():$type {
				return instance != null ? instance : new $typePath();
			}
			
			//For backwards compatibility.
			@:noCompletion public static inline function getInstance():$type {
				return instance;
			}
		});
		
		//`instance = this` must be the first line of the
		//constructor. Otherwise, the constructor could set
		//off an infinite loop by calling `get_instance()`.
		
		//First, check if a constructor exists.
		for(field in fields) {
			if(field.name == "new") {
				//If so, insert the line and return.
				switch(field.kind) {
					case FFun({ expr: { expr: EBlock(exprs) } }):
						exprs.unshift(macro instance = this);
					case FFun(f):
						f.expr = macro {
							instance = this;
							${f.expr};
						};
					default:
						Context.error("Constructor is not a function.", field.pos);
				}
				
				return fields;
			}
		}
		
		//If not, create one.
		var superClass = Context.getLocalClass().get().superClass;
		if(superClass != null && Lambda.exists(superClass.t.get().fields.get(),
				function(field) return field.name == "new")) {
			addClassFields(macro class Singleton {
				private function new() {
					instance = this;
					super();
				}
			});
		} else {
			addClassFields(macro class Singleton {
				private inline function new() {
					instance = this;
				}
			});
		}
		
		return fields;
	}
}

#end

