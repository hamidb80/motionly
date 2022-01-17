import tables

func merge*[K, V](t1, t2: Table[K, V]): Table[K, V] =
  result = t1
  for k2, v2 in t2:
    result[k2] = v2
