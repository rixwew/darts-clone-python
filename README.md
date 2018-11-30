# darts-clone-python

[Darts-clone](https://github.com/s-yata/darts-clone) binding for Python 3.x.  
This repository provides Cython-based pip-installable package.

## Installation

    pip install dartsclone


## Usage

darts-clone-python is almost compatible with darts-clone.

```python
import dartsclone

darts = dartsclone.DoubleArray()

# build index
data = [b'apple', b'banana', b'orange']
values = [1, 3, 2]
darts.build(data, values=values)

# exact match search
result = darts.exact_match_search('apple'.encode('utf-8'))
print(result) # [1, 5]

# common prefix search
result = darts.common_prefix_search('apples'.encode('utf-8'), pair_type=False)
print(result) # [1]

# save index
darts.save('sample.dic')

# load index
darts.clear()
darts.open('sample.dic')

# dump array data
array = darts.array()

# load array data
darts.clear()
darts.set_array(array)

```
