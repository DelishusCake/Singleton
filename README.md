Singleton
===

A macro-based solution for automatic singleton management in Haxe.

Use
---

Simply implement the Singleton interface!

    class Thing implements Singleton
    {
    	function new() {}
    }

Then use `instance` to grab the instance anywhere!
   
    Thing.instance;
