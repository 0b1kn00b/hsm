package hsm;

using stx.Options;
using stx.Tuples;
import stx.Strings;
import haxe.ds.Option;
import stx.types.Tuple2;
import hsm.types.Identifier in CIdentifier;

abstract Identifier(CIdentifier) from CIdentifier to CIdentifier{
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