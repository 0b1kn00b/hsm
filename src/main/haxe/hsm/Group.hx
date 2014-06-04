package hsm;

using stx.Arrays;
using stx.Tuples;
using stx.Options;

import hsm.types.Sector;

import stx.types.Tuple4;
import tink.core.Signal;
import haxe.ds.Option;
import hsm.types.Group in CGroup;

@doc("Groups select amongst Segments. If the Cursor is null, the first value in segs is used. Requires at least one Segment")
abstract Group<T>(CGroup<T>) from CGroup<T> to CGroup<T>{
  @:noUsing static public function create<T>(id:Identifier,?segs:Ref<Array<Segment<T>>>,?crs:Cursor,?rct:Reactive<State<T>>):Group<T>{
    segs  = segs  == null ? []                    : segs;
    rct   = rct   == null ? new SignalTrigger()   : rct;
    crs   = crs   == null ? Cursor.unit()         : crs;
    return new Group(tuple4(id,segs,crs,rct));
  }
  @:to public function toSector():Sector<T>{
    return Grp(this);
  }
  public function new(v){
    this = v;
  }
  public function copy(?id:Identifier,?segs:Ref<Array<Segment<T>>>,?crs:Cursor,?rct:Reactive<State<T>>){
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