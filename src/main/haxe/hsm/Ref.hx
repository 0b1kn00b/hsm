package hsm;

import hsm.types.Ref in CRef;

@doc("Lifts objects to References, useful when building state machines.")
abstract Ref<T>(CRef<T>) from CRef<T> to CRef<T>{
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