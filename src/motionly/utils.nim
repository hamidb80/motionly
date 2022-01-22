import tables, sequtils

func merge*[K, V](main: Table[K, V], ts: varargs[Table[K, V]]): Table[K, V] =
  result = main
  for t in ts:
    for k, v in t:
      result[k] = v

func containsAll*[K, _](t: Table[K, _], keys: openArray[K]): bool =
  keys.allIt it in t
