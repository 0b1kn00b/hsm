package hsm;

import stx.io.Logs.*;
import tink.core.Signal;

using stx.Arrays;
using stx.Tuples;
using stx.Options;

import hsm.types.Segment in CSegment;
import hsm.types.Sector in CSector;



@doc("
  State partial, can either be a terminal or contain Groups. Either way, the Reactor will emit Enter/Leave/Update events when required
")
abstract Segment<T>(CSegment<T>) from CSegment<T> to CSegment<T>{
  @:noUsing static public function create<T>(id:Identifier,?grps:Ref<Array<Group<T>>>,rct:Reactive<State<T>>):Segment<T>{
    grps  = grps  == null ? []                    : grps;
    var _rct : Reactive<State<T>> = new SignalTrigger();
        (_rct).native().asSignal().handle(
          function(x){
            trace(debug('$x at $id'));
          }
        );
    rct   = rct   == null ?  _rct : rct;
    return new Segment(tuple3(id,grps,rct));
  }
  @:to public function toSector():CSector<T>{
    return Seg(this);
  }
  public function new(v){
    this = v;
  }
  public function copy(?id:Identifier,?grps:Ref<Array<Group<T>>>,?rct:Reactive<State<T>>){
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