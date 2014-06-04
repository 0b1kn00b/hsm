package hsm;

@doc("do nothing marker")
abstract Name(String) from String to String{
  public function new(v){
    this = v;
  }
}