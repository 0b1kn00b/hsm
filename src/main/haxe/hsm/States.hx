package hsm;
class States{
  @:noUsing static public function onEnter<A>(fn:CodeBlock):State<A> -> Void{
    return function(sg){
      switch (sg) {
        case Enter  : fn();
        default     :
      }
    };
  }
  @:noUsing static public function onLeave<A>(fn:CodeBlock):State<A> -> Void{
    return function(sg){
      switch (sg) {
        case Leave  : fn();
        default     :
      }
    };
  }
}