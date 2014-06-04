package hsm;

import stx.Path;

@doc("Path to value or unique ")
enum Location{
  Route(v:Path);
  Id(v:String);
}