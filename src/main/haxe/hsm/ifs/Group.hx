package hsm.ifs;

import hx.Reactor;
import Hsm;

//Tuple4<Identifier,Ref<Array<Segment<T>>>,Cursor,Reactive<Signal<T>>>;
interface Group<T> extends StateHandler<T>{
  public var id(get,null) : String;
  private function get_id():String;

  public var path(get,null):String;
  private function get_path():String;

  private var cursor(default,null):Cursor;

  public function segments():Array<Segment<T>>;
  public function reactor():Reactor<Signal<T>>;
}