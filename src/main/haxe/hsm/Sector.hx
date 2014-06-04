package hsm;

import stx.test.Assert.*;

import stx.types.Tuple2;

using hsm.Sectors;
using stx.Arrays;
using stx.Bools;
using stx.Options;
using stx.Tuples;

import stx.Path;

import haxe.ds.Option;
import hsm.types.Sector in CSector;

abstract Sector<T>(CSector<T>) from CSector<T> to CSector<T>{
  public function new(v){
    this = v;
  }
  @:static public function fromSegment<T>(v:hsm.types.Segment<T>):Sector<T>{
    return Seg(v);
  }
  @:static public function fromGroup<T>(v:hsm.types.Group<T>):Sector<T>{
    return Grp(v);
  }
  public var id(get,never):Identifier;
  private function get_id(){
    return switch (this) {
      case Seg(v): v.id;
      case Grp(v): v.id;
    }
  }
  public var reactor(get,never):Reactive<State<T>>;
  private function get_reactor(){
    return switch (this) {
      case Seg(v): v.thd();
      case Grp(v): v.frt();
    }
  }
  public function isEmpty():Bool{
    return switch (this) {
      case Seg(v): v.isEmpty();
      case Grp(v): v.isEmpty();
    }
  }
  @doc("Returns the next level of Sectors")
  public function sectors():Array<Sector<T>>{
    return switch (this) {
      case Grp(g) :
        g.segments.get().map(function(s:Segment<T>):Sector<T> return Seg(s));
      case Seg(v) :
        v.groups.get().map(function(g:Group<T>):Sector<T> return Grp(g));
    } 
  }
  @doc("
    Returns a path to location, using the `open` lambda for the next level, typically `Sectors.sectors` for any available path
    or `Sectors.step` for the active path.
  ")
  public function path(location:Location,?open:Sector<T>->Array<Sector<T>>,?stack:Array<Sector<T>>):Option<Array<Sector<T>>>{
    assert(location);
    open  = open  == null ? Sectors.sectors : open;
    stack = stack == null ? [this]          : stack.add(this);
    return switch (location) {
      case Route(lct) :
        var pth = stack.map(function(x) return x.id.name).join('/');
        new Path(pth).equals(lct).ifElse(
          function(){
            return Some(stack);
          },
          function(){
            return open(this).foldLeft(None,
              function(memo,next){
                return switch (memo) {
                  case Some(v)  : Some(v);
                  case None     : next.path(location,open,stack);
                }
              }
            );
          }
        );
      case Id(unq) :
        return Type.enumEq(id.unique,Some(unq)) ? Some(stack) : 
        open(this).foldLeft(None,
          function(memo,next){
            return switch (memo) {
              case Some(v)  : Some(v);
              case None     : next.path(location,open,stack);
            }
          }
        );
    }
  }
  @doc("Returns the route of a unique id.")
  public function route(str:String):Option<Path>{
    var p   = path(Id(str));
    var rt  = p.map(function(p) return p.foldLeft([],function(memo,next) return memo.add(next.id.name)));
    return rt.map(
      function(x):Path{
        return x;
      }
    );
  }
  @doc("Returns either the input Path or a Path relative to this sector.")
  public function relative(l:Location):Option<Path>{
    return switch (l) {
      case Route(v)  : Options.create(v);
      case Id(v)    : route(v);
    }
  }
  @doc("Steps through the active hierarchy from this Sector, dispatching Enter on each Reactor in turn.")
  @:access(hx.rct)
  public function init():Void{
    var all = Sectors.paths(this);
    all.each(
      function(x){
        if(x.reactor!=null){
          x.reactor.native().trigger(Enter);
        }
      }
    );
  }
  @doc("Equality operation.")
  public function equals(s:Sector<T>):Bool{
    return switch (s) {
      case Seg(v) : v.id.equals(s.id);
      case Grp(v) : v.id.equals(s.id);
    }
  }
  @doc("Produces a common set between the currently active paths and the provided location from here.")
  public function common(l:Location):Option<Path>{
    var paths = Sectors.paths(this);
    //trace(paths.map(function(x) return x.id.name));
    var to    = relative(l);
    return to.map(
      function(x){
        return x.foldLeft(
          [],
          function(memo,next){
            return paths.any(
              function(x){
                return x.id.name == next;
              }
            ).ifElse(
              function(){
                return memo.add(next);
              },
              function(){
                return memo;
              }
            );
          }
        );
      }
    ).map(
      function(l):Path{
        return l;
      }
    );
  }
  @doc("Does transition. use this one, really. go-an go-an, it does stuff.")
  @:access(hx.rct)
  public function go(to:Location){
    //trace('current\t: ${Sectors.paths(this).map(function(x) return x.id.name)}');
    //trace('to\t\t: ${to}');
    var pth         = path(to);
    if(pth == null){
      throw 'unkwnown path';
    }
    //trace('to\t\t: ${!Type.enumEq(pth,None)}');
    return pth.flatMap(
      function(pth){
        var cmn         = common(to).flatMap(function(x:Path):Option<Array<Sector<T>>> return path(this,Route(x)));
        //trace('common\t: ${cmn.getOrElseC([]).map(function(x) return x.id.name)}');
        var root        = cmn.map(Arrays.last);
        return root.map(tuple2.bind(pth));
    }).flatMap(
      function(pth:Array<Sector<T>>,root:Sector<T>){
        //trace('root\t: ${root.id.name}');
        var paths       = Sectors.paths(root);
        var into        = pth.dropWhile(
          function(x){
            return !(x.id.equals(root.id));
          }
        );
        var from        = paths.dropWhile(
          function(x){
            return !(x.id.equals(root.id));
          }
        ).reversed();
        //trace('-------------Leave-------------');
        from.each(
          function(x){
            if(x.reactor!=null){
              x.reactor.native().trigger(Leave);
            }
          }
        );
        //trace('-------------Patch------------');
        into.foldLeft1(
          function(memo,next){
            switch (memo) {
              case Grp(v) :
                v.cursor.set(next.id.name);
              default     :
            }
            return next;
          }
        );
        //trace('-------------Enter-------------');
        root.init();
        //trace('-------------Finish-----------');
        return None;
      }.tupled()
    );
  }
}