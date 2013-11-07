package hsm;

import stx.Eventual;
import hx.ifs.Scheduler;
import hx.sch.Timer;

import stx.ioc.Inject.*;


import Stax.*;
import stx.Compare.*;
import stx.Log.*;

using stx.UnitTest;

using stx.Maths;
using stx.Enums;
using stx.Strings;

using Hsm;

import Hsm.*;
import stx.rct.*;

import hx.rct.DefaultReactor;
using hx.Reactor;

class HsmTest extends TestCase{
  public function testNietcheActionPhilosopherFigurine(u:UnitArrow):UnitArrow{
    var evt       = Eventual.unit();
    var count     = 0;
    var mcn : Machine<String> = null;
    var thinking = new DefaultReactor();
        thinking.on(Reactors.any(),
          function(x:Signal<String>){
            switch (x){
              case Enter  : 
                count++;
                trace(debug('hmmm....'));
                if(count == 3){
                  trace(info('buggr t-i-oh, iss-er wossits!'));
                  Timer.wait(3,
                    function(){
                      trace(info('mah gerd, tham wossats Moffet!'));
                      evt.deliver(isTrue(true));
                    }
                  );
                  return;
                }
                Timer.wait(2,
                  function(){
                    var activity = Activities.act();
                    mcn.go(Path('root/group/$activity'));
                    mcn.update(activity);
                  }
                );
              case Leave  :
                trace(debug('ok'));
              default     :
            }
          }
        );
    var other = new DefaultReactor();
        other.on(Reactors.any(),
          function(x:Signal<String>){
            switch (x){
              case Enter      : 
                Timer.wait(4,mcn.go.bind(Path('root/group/thinking')));
              case Update(v)  :
                trace(debug(v));
              case Leave      :
                trace(debug('but...'));
            } 
          }
        );
    var st = segment('root',
      [
        group('group',
          [
            segment('thinking',[],thinking),
            segment(tuple2('walking',"#a03fe"),[],other),
            segment('jumping',[],other),
            segment('sitting',[],other),
          ]
        )
      ]
    );
    mcn = st;
    mcn.update('hello');
    //mcn.go(Id('#a03fe'));
    //mcn.go(Path('root/group/thinking'));

    inject(Scheduler).latch();
    return u.add(evt.flatten());
  }
  private function prt(s:String):Signal<String>->Void{ return function(x:Signal<String>) trace('$x $s'); }
  public function testDsl(u:UnitArrow):UnitArrow{
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
    s0.go(Path('0/0_0/0_0_0/0_0_0_1/0_0_0_1_1'));
    ////trace(s0.paths().map(function(x) return x.id.name));3
    //trace("________________________________________");
    s0.go(Path('0/0_0/0_0_1'));
    ////trace(s0.paths().map(function(x) return x.id.name));
    //trace("________________________________________");
    s0.go(Path('0/0_0/0_0_0/0_0_0_0/0_0_0_0_1'));
    ////trace(s0.paths().map(function(x) return x.id.name));
    //trace("________________________________________");
    //'0_0_0_2'
    s0.go(Path('0/0_0/0_0_1/0_0_1_1'));
    //trace("________________________________________");
    s0.go(Id("timbuck-three"));
    s0.go(Id('not'));
    s0.go(Path('not'));
    s0.go(Id("wackawacka"));
    return u;
  }
  public function testPath(u:UnitArrow):UnitArrow{
    var button = group('switch',
      [
        segment('off',[],prt('off')),
        segment('on',[],prt('on'))
      ]
    );
    var mcn : Machine<String> = button;
        mcn.go(Path('#/switch/on'));
        mcn.go(Path('#/switch/off'));
        mcn.go(Path('#/switch/on'));
        mcn.update('hello all');

    return u;
  }
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