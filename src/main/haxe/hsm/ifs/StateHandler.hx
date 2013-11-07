package hsm.ifs;

interface StateHandler<T>{
  public function onEnter():Void;
  public function onUpdate(v:T):Void;
  public function onLeave():Void;
}