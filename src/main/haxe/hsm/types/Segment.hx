package hsm.types;

import stx.types.Tuple3;
import hsm.*;

typedef Segment<T> = Tuple3<hsm.Identifier,hsm.Ref<Array<hsm.Group<T>>>,Reactive<State<T>>>;