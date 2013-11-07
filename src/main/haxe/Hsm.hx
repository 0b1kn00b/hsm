package;

import Type;

using Hsm;

using Std;

import stx.plus.Equal;
import stx.Prelude;
import stx.Eventual;
import stx.ifs.Reply;
import stx.Log.*;
import stx.utl.Selector;

using stx.Bools;
using stx.ds.Zipper;
using stx.ds.List;
using stx.Arrow;
using stx.Prelude;
using stx.Compose;
using stx.Functions;
using stx.Option;
using stx.Tuples;
using stx.Transformers;
using stx.Iterables;
using stx.Arrays;
using stx.Strings;
using stx.Log;
using stx.Eventual;
using stx.Objects;

import hx.rct.Dispatcher;

import kwv.Locator;

using hx.Reactor;
import hx.rct.DefaultReactor;

@doc("Hoare logic primitive.")
enum Signal<T>{
  Enter;
  Leave;
  Update(v:T);
}
class Signals{
  @:noUsing static public function onEnter<A>(fn:CodeBlock):Signal<A> -> Void{
    return function(sg){
      switch (sg) {
        case Enter  : fn();
        default     :
      }
    };
  }
  @:noUsing static public function onLeave<A>(fn:CodeBlock):Signal<A> -> Void{
    return function(sg){
      switch (sg) {
        case Leave  : fn();
        default     :
      }
    };
  }
}
@doc("Path to value or unique ")
enum Location{
  Path(v:Locator);
  Id(v:String);
}
@doc("Cache of globally unique strings, should perhaps rely on ")
class UniqueStrings{
  static public var cache : Array<String>;
  static function __init__(){
    cache = [];
  }
}
@doc("Checks for global uniqueness of a String")
abstract UniqueString(String) from String{
  public function new(v){
    this = v;
  }
  static public function alloc(s:String){
    if(UniqueStrings.cache.remove(s)){
      throw 'key "$s" already used';
    }
    UniqueStrings.cache.push(s);
    return new UniqueString(s);  
  }
  public function native(){
    return this;
  }
}
@doc("do nothing marker")
abstract Name(String) from String to String{
  public function new(v){
    this = v;
  }
}
typedef IdentifierType = Tuple2<Name,Option<UniqueString>>;

abstract Identifier(IdentifierType) from IdentifierType to IdentifierType{
  public function new(v){
    this = v;
  }
  @:from static public function fromString(s:String):Identifier{
    var u : UniqueString = Strings.uuid();
    return tuple2(s,Some(u));
  }
  @:from static public function fromName(n:Name):Identifier{
    var un : UniqueString = Strings.uuid();
    return tuple2(n,Some(un));
  }
  @:from static public function fromTuple2(tp:Tuple2<String,String>):Identifier{
    var a : Name          = tp.fst();
    var b : UniqueString  = UniqueString.alloc(tp.snd());
    return new Identifier(tuple2(a,Options.create(b).orElseConst(Some(Strings.uuid()))));
  }
  public function equals(id:Identifier):Bool{
    return (this.fst() == id.fst() || (this.snd() == id.snd() && this.snd() != None));
  }
  public var name(get,never) : Name;
  private function get_name():Name{
    return this.fst();
  }
  public var unique(get,never) : Option<UniqueString>;
  private function get_unique(): Option<UniqueString>{
    return this.snd();
  }
}
@doc("Primitives for building machines directly")
class Hsm{
  static public function group<T>(id:Identifier,segs:Ref<Array<Segment<T>>>,?crs:Cursor,?rct:Reactive<Signal<T>>):Group<T>{
    return Group.create(id,segs,crs,rct);
  }
  static public function segment<T>(id:Identifier,?grps:Ref<Array<Group<T>>>,?rct:Reactive<Signal<T>>):Segment<T>{
    return Segment.create(id,grps,rct);
  }
}

typedef RefType<T> = {
  function get():T;
}
@doc("Lifts objects to References, useful when building state machines.")
abstract Ref<T>(RefType<T>) from RefType<T> to RefType<T>{
  @:noUsing static public function create<T>(v:T):Ref<T>{
    return new Ref({
      get : function() return v
    });
  }
  public function new(v){
    this = v;
  }
  @:from static public function fromT<T>(v:Null<T>):Ref<T>{
    return {
      get : function() return v
    }
  }
  public function get():T{
    return this.get();
  }
}
typedef CursorType = {
  function get():Name;
  function set(v:Name):Void;
}
@doc("
  for modifying execution path in state hierarchy. 
  Do not edit manually as it is required by the algorithm.
  This is a major confounding factor for full functional support atm
")
@:test('test reuse of cursors and their effects')
abstract Cursor(CursorType) from CursorType to CursorType{
  @:noUsing static public function create(s:String){
    var val = s;
    return{
      get : function() {return val;},
      set : function(s){ val = s; }
    }
  }
  @:noUsing static public function unit(){
    return create(null);
  }
  public function new(v){
    this = v;
  }
  public function set(v:Name){
    this.set(v);
  }
  public function get():Name{
    return this.get();
  }
}
typedef GroupType<T> = Tuple4<Identifier,Ref<Array<Segment<T>>>,Cursor,Reactive<Signal<T>>>;
@doc("Groups select amongst Segments. If the Cursor is null, the first value in segs is used. Requires at least one Segment")
abstract Group<T>(GroupType<T>) from GroupType<T> to GroupType<T>{
  @:noUsing static public function create<T>(id:Identifier,?segs:Ref<Array<Segment<T>>>,?crs:Cursor,?rct:Reactive<Signal<T>>):Group<T>{
    segs  = segs  == null ? []                    : segs;
    rct   = rct   == null ? new DefaultReactor()  : rct;
    crs   = crs   == null ? Cursor.unit()         : crs;
    return new Group(tuple4(id,segs,crs,rct));
  }
  @:to public function toSector():Sector<T>{
    return Grp(this);
  }
  public function new(v){
    this = v;
  }
  public function copy(?id:Identifier,?segs:Ref<Array<Segment<T>>>,?crs:Cursor,?rct:Reactive<Signal<T>>){
    return tuple4(
      id    == null ? this.fst() : id,
      segs  == null ? this.snd() : segs, 
      crs   == null ? this.thd() : crs,
      rct   == null ? this.frt() : rct
    );
  }
  public function add(s:Segment<T>):Group<T>{
    return copy(null,this.snd().get().add(s));
  }
  public var segments(get,never):Ref<Array<Segment<T>>>;
  private function get_segments(){
    return this.snd();
  }
  public function segment():Option<Segment<T>>{
    var crs = cursor.get();
    return if(crs == null){
      Options.create(segments.get().first());
    }else{
      segments.get().search(function(x:Segment<T>) return x.id.name == crs);
    }
  }
  public function sector():Sector<T>{
    return toSector();
  }
  public var cursor(get,never):Cursor;
  private function get_cursor():Cursor{
    return this.thd();
  }
  public var id(get,never):Identifier;
  private function get_id():Identifier{
    return this.fst();
  }
  public function isEmpty(){
    return segments.get().length == 0;
  }
}
typedef SegmentType<T> = Tuple3<Identifier,Ref<Array<Group<T>>>,Reactive<Signal<T>>>;
@doc("
  State partial, can either be a terminal or contain Groups. Either way, the Reactor will emit Enter/Leave/Update events when required
")
abstract Segment<T>(SegmentType<T>) from SegmentType<T> to SegmentType<T>{
  @:noUsing static public function create<T>(id:Identifier,?grps:Ref<Array<Group<T>>>,rct:Reactive<Signal<T>>):Segment<T>{
    grps  = grps  == null ? []                    : grps;
    var _rct : Reactive<Signal<T>> = new DefaultReactor();
        untyped _rct.on(Reactors.any(),
          function(x){
            printer()(debug('$x at $id'));
          }
        );
    rct   = rct   == null ?  _rct : rct;
    return new Segment(tuple3(id,grps,rct));
  }
  @:to public function toSector():Sector<T>{
    return Seg(this);
  }
  public function new(v){
    this = v;
  }
  public function copy(?id:Identifier,?grps:Ref<Array<Group<T>>>,?rct:Reactive<Signal<T>>){
    return tuple3(
      id    == null ? this.fst() : id,
      grps  == null ? this.snd() : grps, 
      rct   == null ? this.thd() : rct
    );
  }
  public function add(g:Group<T>):Segment<T>{
    return copy(null,this.snd().get().add(g));
  }
  public var groups(get,never):Ref<Array<Group<T>>>;
  private function get_groups(){
    return this.snd();
  }
  public function sector():Sector<T>{
    return toSector();
  }
  public var id(get,never):Identifier;
  private function get_id():Identifier{
    return this.fst();
  }
  public function isEmpty(){
    return groups.get().length == 0;
  }
}
@doc("Type that lifts functions to a Reactor, used for dsl")
abstract Reactive<T>(Reactor<T>) from Reactor<T> to Reactor<T>{
  public function new(v){
    this = v;
  }
  @:from static public function fromFn<T>(fn:T->Void):Reactive<T>{
    var v : Reactor<T> = new DefaultReactor();
        v.on(Reactors.any(),fn);
    return v;
  }
  public function native(){
    return this;
  }
}
abstract Machine<T>(Sector<T>){
  function new(v){
    this = v;
  }
  public function go(to:Location){
    this.go(to);
  }
  @:access(hx.rct)
  public function update(v:T){
    this.paths().foreach(
      function(x){
        x.reactor.native().emit(Update(v));
      }
    );
  }
  @:from static public function fromSegment<T>(s:Segment<T>):Machine<T>{
    var sct = s.sector();
        sct.init();
    return new Machine(sct);
  }
  @doc("Wraps the Group in a base Segment before creating Sector.")
  @:from static public function fromGroup<T>(s:Group<T>):Machine<T>{
    var sct = Hsm.segment('#',[s]).sector();
        sct.init();
    return new Machine(sct);
  }
}
@doc("Unifying type for Group and Segment")
enum SectorType<T>{
  Seg(s:Segment<T>);
  Grp(g:Group<T>);
}
abstract Sector<T>(SectorType<T>) from SectorType<T> to SectorType<T>{
  public function new(v){
    this = v;
  }
  @:static public function fromSegment<T>(v:Segment<T>):Sector<T>{
    return Seg(v);
  }
  @:static public function fromGroup<T>(v:Group<T>):Sector<T>{
    return Grp(v);
  }
  public var id(get,never):Identifier;
  private function get_id(){
    return switch (this) {
      case Seg(v): v.id;
      case Grp(v): v.id;
    }
  }
  public var reactor(get,never):Reactive<Signal<T>>;
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
        g.segments.get().map(function(s:Segment<T>):Sector<T> return s);
      case Seg(v) :
        v.groups.get().map(function(g:Group<T>):Sector<T> return g);
    } 
  }
  @doc("
    Returns a path to location, using the `open` lambda for the next level, typically `Sectors.sectors` for any available path
    or `Sectors.step` for the active path.
  ")
  public function path(location:Location,?open:Sector<T>->Array<Sector<T>>,?stack:Array<Sector<T>>):Option<Array<Sector<T>>>{
    open  = open  == null ? Sectors.sectors : open;
    stack = stack == null ? [this]          : stack.add(this);
    return switch (location) {
      case Path(lct) :
        var pth = stack.map(function(x) return x.id.name);
        new LocatorType(pth).equals(lct).ifElse(
          function(){
            return Some(stack);
          },
          function(){
            return open(this).foldl(None,
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
        open(this).foldl(None,
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
  public function route(str:String):Option<Locator>{
    var p   = path(Id(str));
    var rt  = p.map(function(p) return p.foldl([],function(memo,next) return memo.add(next.id.name)));
    return rt.map(
      function(x){
        return new LocatorType(x);
      }
    );
  }
  @doc("Returns either the input Locator or a Locator relative to this sector.")
  public function relative(l:Location):Option<Locator>{
    return switch (l) {
      case Path(v)  : Options.create(v);
      case Id(v)    : route(v);
    }
  }
  @doc("Steps through the active hierarchy from this Sector, dispatching Enter on each Reactor in turn.")
  @:access(hx.rct)
  public function init():Void{
    var all = Sectors.paths(this);
    all.foreach(
      function(x){
        //trace(x.id);
        x.reactor.native().emit(Enter);
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
  public function common(l:Location):Option<Locator>{
    var paths = Sectors.paths(this);
    //trace(paths.map(function(x) return x.id.name));
    var to    = relative(l);
    return to.map(
      function(x){
        return x.foldl(
          [],
          function(memo,next){
            return paths.forAny(
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
      function(l){
        return new LocatorType(l);
      }
    );
  }
  @doc("Does transition. use this one, really. go-an go-an, it does stuff.")
  @:access(hx.rct)
  public function go(to:Location){
    //trace('current\t: ${Sectors.paths(this).map(function(x) return x.id.name)}');
    //trace('to\t\t: ${to}');
    var pth         = path(to);
    //trace('to\t\t: ${!Type.enumEq(pth,None)}');
    return pth.flatMap(
      function(pth){
        var cmn         = common(to).flatMap(function(x:Locator) return path(Path(x)));
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
        from.foreach(
          function(x){
            x.reactor.native().emit(Leave);
          }
        );
        //trace('-------------Patch------------');
        into.foldl1(
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
class Sectors{
  @doc("Produces all children of Sector.")
  static public function sectors<T>(s:Sector<T>):Array<Sector<T>>{
    return switch (s) {
      case Grp(g) :
        g.segments.get().map(function(s:Segment<T>):Sector<T> return s);
      case Seg(v) :
        v.groups.get().map(function(g:Group<T>):Sector<T> return g);
    } 
  }
  @doc("Produces the active children of Sector")
  static public function step<T>(s:Sector<T>):Array<Sector<T>>{
    return switch (s) {
      case Grp(g) :
        var crs = g.cursor.get();
        (if(crs == null){
          [g.segments.get().first()];
        }else{
          g.segments.get().search(function(x) return x.id.name == crs).map(Arrays.one).getOrElseC([]);
        }).map(function(s:Segment<T>):Sector<T> return s);
      case Seg(v) : 
        v.groups.get().map(function(g:Group<T>):Sector<T> return g);
    }
  }
  @doc("Returns all active paths for Sector.")
  static public function paths<T>(s:Sector<T>):Array<Sector<T>>{
    return [s].append(SArrays.flatMap(step(s),paths));
  }
}