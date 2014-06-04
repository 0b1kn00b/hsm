package;

import hsm.*;

@doc("Primitives for building machines directly")
class Hsm{
  static public function group<T>(id:Identifier,segs:Ref<Array<Segment<T>>>,?crs:Cursor,?rct:Reactive<State<T>>):Group<T>{
    return Group.create(id,segs,crs,rct);
  }
  static public function segment<T>(id:Identifier,?grps:Ref<Array<Group<T>>>,?rct:Reactive<State<T>>):Segment<T>{
    return Segment.create(id,grps,rct);
  }
}