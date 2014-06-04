package hsm.types;

@doc("Unifying type for Group and Segment")
enum Sector<T>{
  Seg(s:hsm.Segment<T>);
  Grp(g:hsm.Group<T>);
}