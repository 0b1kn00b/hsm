package hsm;

import tink.core.Signal;

@doc("Type that lifts functions to a Reactor, used for dsl")
abstract Reactive<T>(SignalTrigger<T>) from SignalTrigger<T> to SignalTrigger<T>{
  public function new(v){
    this = v;
  }
  public function native(){
    return this;
  }
  @:from static public function fromFn(fn:T->Void):Reactive<T>{
    var trg = new SignalTrigger();
        trg.asSignal().handle(fn);
        return trg;
  }
}