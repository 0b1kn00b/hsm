package hsm;

using stx.Options;
using stx.Arrays;

import hsm.types.Sector;
import hsm.Sector in ASector;



class Sectors{
  @doc("Produces all children of Sector.")
  static public function sectors<T>(s:ASector<T>):Array<ASector<T>>{
    return switch (s) {
      case Grp(g) :
        g.segments.get().map(function(s:Segment<T>):ASector<T> return Seg(s));
      case Seg(v) :
        v.groups.get().map(function(g:Group<T>):ASector<T> return Grp(g));
    } 
  }
  @doc("Produces the active children of Sector")
  static public function step<T>(s:ASector<T>):Array<ASector<T>>{
    return switch (s) {
      case Grp(g) :
        var crs = g.cursor.get();
        (if(crs == null){
          [g.segments.get().first()];
        }else{
          g.segments.get().search(function(x) return x.id.name == crs).map(Arrays.one).valOrC([]);
        }).map(function(s:Segment<T>):ASector<T> return Seg(s));
      case Seg(v) : 
        v.groups.get().map(function(g:Group<T>):ASector<T> return Grp(g));
    }
  }
  @doc("Returns all active paths for Sector.")
  static public function paths<T>(s:ASector<T>):Array<ASector<T>>{
    return [s].append(Arrays.flatMap(step(s),paths));
  }
}