package hsm;
@doc("Cache of globally unique strings, should perhaps rely on ")
class UniqueStrings{
  static public var cache : Array<String>;
  static function __init__(){
    cache = [];
  }
}