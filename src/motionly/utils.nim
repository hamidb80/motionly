import tables

func merge*[K, V](t1, t2: Table[K, V]): Table[K, V] =
  for k1, v1 in t1:
    result[k1] = v1

  for k2, v2 in t2:
    result[k2] = v2
