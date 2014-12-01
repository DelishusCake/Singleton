Singleton
===

A macro-based solution for automatic singleton management in Haxe.

Use
---

Simply extend the Singleton class!

    class Thing extends Singleton
    {
    	function new() {}
    }

Then use `getInstance()` to grab the instance anywhere!
   
    Thing.getInstance();
