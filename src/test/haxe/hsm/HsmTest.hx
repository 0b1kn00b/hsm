package hsm;

import stx.types.Tuple2;
import stx.io.Logs.*;

import tink.core.Signal;

import stx.Compare.*;

using stx.Maths;
using stx.Enums;
using stx.Strings;

using Hsm;

import Hsm.*;
import stx.rct.*;


class HsmTest{
  public function new(){}
  public function testNietcheActionPhilosopherFigurine(){
    var count     = 0;
    var mcn : Machine<String> = null;
    var thinking = (function(x:State<String>){
            switch (x){
              case Enter  : 
                count++;
                trace(debug('hmmm....'));
                if(count == 3){
                  trace(info('buggr t-i-oh, iss-er wossits!'));
                  trace(info('mah gerd, tham wossats Moffet!'));
                  return;
                }else{
                  var activity = Activities.act();
                    mcn.go(Route('root/group/$activity'));
                    mcn.update(activity);
                }
              case Leave  :
                trace(debug('ok'));
              default     :
            }
          });
    var other = (function(x:State<String>){
            switch (x){
              case Enter      : 
                mcn.go(Route('root/group/thinking'));
              case Update(v)  :
                trace(debug(v));
              case Leave      :
                trace(debug('but...'));
            } 
          });
    var st = segment('root',
      [
        group('group',
          [
            segment('jumping',[],other),
            segment('thinking',[],thinking),
            segment(tuple2('walking',"#a03fe"),[],other),
            
            segment('sitting',[],other),
          ]
        )
      ]
    );
    mcn = st;
    mcn.init();
    //mcn.update('hello');
    //mcn.go(Id('#a03fe'));
    //mcn.go(Path('root/group/thinking'));
  }
  private function prt(s:String):State<String>->Void{ return function(x:State<String>) trace('$x $s'); }
  /*public function testDsl(){
    var hsm  = 
      segment('0',
        [
          group('0_0',
            [
              segment('0_0_0',
                [
                  group('0_0_0_0',[
                      segment(tuple2('0_0_0_0_0','wackawacka'),[],prt('0_0_0_0_0')),
                      segment(tuple2('0_0_0_0_1','timbuck-three'),[],prt('0_0_0_0_1'))
                    ],prt('0_0_0_0')
                  ),
                  group('0_0_0_1',[
                      segment('0_0_0_1_0',[],prt('0_0_0_1_0')),
                      segment('0_0_0_1_1',[],prt('0_0_0_1_1'))
                    ],prt('0_0_0_1')
                  ),
                  group('0_0_0_2',[
                    segment('0_0_0_2_0',[],prt('0_0_0_2_0'))
                  ],prt('0_0_0_2'))
                ],
                prt('0_0_0')
              ),
              segment('0_0_1',[
                group('0_0_1_0',[segment('0_0_1_0_0',[],prt('0_0_1_0_0'))],prt('0_0_1_0')),
                group('0_0_1_1',[segment('0_0_1_1_0',[],prt('0_0_1_1_0'))],prt('0_0_1_1'))
              ],prt('0_0_1'))
            ],
            prt('0_0')
          )
        ],
        prt('0')
      );
    var s0 : Machine<String> = hsm;
    //trace("________________________________________");
    s0.go(Route('0/0_0/0_0_0/0_0_0_1/0_0_0_1_1'));
    ////trace(s0.paths().map(function(x) return x.id.name));3
    //trace("________________________________________");
    s0.go(Route('0/0_0/0_0_1'));
    ////trace(s0.paths().map(function(x) return x.id.name));
    //trace("________________________________________");
    s0.go(Route('0/0_0/0_0_0/0_0_0_0/0_0_0_0_1'));
    ////trace(s0.paths().map(function(x) return x.id.name));
    //trace("________________________________________");
    //'0_0_0_2'
    s0.go(Route('0/0_0/0_0_1/0_0_1_1'));
    //trace("________________________________________");
    s0.go(Id("timbuck-three"));
    s0.go(Id('not'));
    s0.go(Route('not'));
    s0.go(Id("wackawacka"));
  }
  public function testRoute(){
    var button = group('switch',
      [
        segment('off',[],prt('off')),
        segment('on',[],prt('on'))
      ]
    );
    var mcn : Machine<String> = button;
        mcn.go(Route('#/switch/on'));
        mcn.go(Route('#/switch/off'));
        mcn.go(Route('#/switch/on'));
        mcn.update('hello all');

  }*/
}

private enum Activity{
  Thinking;
  Walking;
  Jumping;
  Sitting;
  Nothing;
}
class Activities{
  static public function fromInt(i:Int){
    return switch (i) {
      case 1  : Walking;
      case 2  : Jumping;
      case 3  : Sitting;
      default : Nothing;
    }
  }
  static public function toString(act:Activity){
    return act.constructor().toLowerCase();
  }
  static public function random(){
    return fromInt(Maths.random(4,1).toInt());
  }
  static public function act(){
    return toString(random());
  }
}