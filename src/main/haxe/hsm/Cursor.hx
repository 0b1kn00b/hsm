package hsm;

import hsm.types.Cursor in CCursor;
@doc("
  for modifying execution path in state hierarchy. 
  Do not edit manually as it is required by the algorithm.
  This is a major confounding factor for full functional support atm
")
@:test('test reuse of cursors and their effects')
abstract Cursor(CCursor) from CCursor to CCursor{
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