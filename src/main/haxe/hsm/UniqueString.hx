package hsm;

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