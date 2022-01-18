import tables, sequtils

func merge*[K, V](t1, t2: Table[K, V]): Table[K, V] =
  result = t1
  for k2, v2 in t2:
    result[k2] = v2

func containsAll*[K, _](t: Table[K, _], keys: openArray[K]): bool =
  keys.allIt it in t
