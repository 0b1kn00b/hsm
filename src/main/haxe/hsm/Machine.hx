package hsm;

import hsm.State;
using stx.Arrays;

using hsm.Sectors;

abstract Machine<T>(Sector<T>){
  function new(v){
    this = v;
  }
  public function go(to:Location){
    this.go(to);
  }
  @:access(hx.rct)
  public function update(v:T){

    this.paths().each(
      function(x){
        x.reactor.native().trigger(Update(v));
      }
    );
  }
  @:from static public function fromSegment<T>(s:Segment<T>):Machine<T>{
    var sct = s.sector();
    return new Machine(sct);
  }
  @doc("Wraps the Group in a base Segment before creating Sector.")
  @:from static public function fromGroup<T>(s:Group<T>):Machine<T>{
    var sct = Hsm.segment('#',[s]).sector();
    return new Machine(sct);
  }
  public function init(){
    this.init();
  }
}