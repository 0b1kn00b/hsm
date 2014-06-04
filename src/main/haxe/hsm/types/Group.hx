package hsm.types;

import stx.types.Tuple4;

typedef Group<T> = Tuple4<hsm.Identifier,hsm.Ref<Array<hsm.Segment<T>>>,hsm.Cursor,Reactive<State<T>>>;