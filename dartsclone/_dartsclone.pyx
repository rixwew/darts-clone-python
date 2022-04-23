from libc.stdlib cimport calloc, free

cdef extern from "Python.h":
    ctypedef struct PyObject
    int PyObject_GetBuffer(PyObject *exporter, Py_buffer *view, int flags)
    void PyBuffer_Release(Py_buffer *view)
    const int PyBUF_C_CONTIGUOUS


cdef class DoubleArray:
    def __cinit__(self):
        self.wrapped = new CppDoubleArray()
        self._strides[0] = 1

    def __dealloc__(self):
        if <PyObject *>self._buf.obj != NULL:
            PyBuffer_Release(&self._buf)
        del self.wrapped

    def __getstate__(self):
        return bytes(self.array())

    def __setstate__(self, array):
        self.set_array(array)

    def __getbuffer__(self, Py_buffer *buffer, int flags):
        buffer.buf = <char *>self.wrapped.array()
        buffer.obj = self
        buffer.len = self._shape[0] = self.wrapped.total_size()
        buffer.readonly = True
        buffer.itemsize = 1
        buffer.format = 'B'
        buffer.ndim = 1
        buffer.shape = self._shape
        buffer.strides = self._strides
        buffer.suboffsets = NULL
        buffer.internal = NULL

    def __releasebuffer__(self, Py_buffer *buffer):
        pass

    def array(self):
        return memoryview(self)

    def set_array(self, array, size_t size=0):
        cdef Py_buffer _buf
        if PyObject_GetBuffer(<PyObject *>array, &_buf, PyBUF_C_CONTIGUOUS) < 0:
            return
        if _buf.buf == self.wrapped.array():
            PyBuffer_Release(&_buf)
            raise ValueError("passed buffer refers to itself")
        if <PyObject *>self._buf.obj != NULL:
            PyBuffer_Release(&self._buf)
        self._buf = _buf
        self.wrapped.set_array(_buf.buf, size)

    def clear(self):
        self.wrapped.clear()

    def unit_size(self):
        return self.wrapped.unit_size()

    def size(self):
        return self.wrapped.size()

    def total_size(self):
        return self.wrapped.total_size()

    def nonzero_size(self):
        return self.wrapped.nonzero_size()

    def build(self, keys,
              lengths = None,
              values = None):
        cdef size_t num_keys = len(keys)
        cdef const char** _keys = NULL
        cdef Py_buffer* _buf = NULL
        cdef size_t *_lengths = NULL
        cdef int *_values = NULL

        try:
            _keys = <const char**> calloc(num_keys, sizeof(char*))
            if _keys == NULL:
                raise MemoryError("failed to allocate memory for key array")
            _buf = <Py_buffer *> calloc(num_keys, sizeof(Py_buffer))
            if _buf == NULL:
                raise MemoryError("failed to allocate memory for buffer")
            for i, key in enumerate(keys):
                if PyObject_GetBuffer(<PyObject *>key, &_buf[i], PyBUF_C_CONTIGUOUS) < 0:
                    return
                _keys[i] = <const char *> _buf[i].buf
            if lengths is not None:
                _lengths = <size_t *> calloc(num_keys, sizeof(size_t))
                if _lengths == NULL:
                    raise MemoryError("failed to allocate memory for length array")
                for i, length in enumerate(lengths):
                    _lengths[i] = length
            if values is not None:
                _values = <int *> calloc(num_keys, sizeof(int))
                if _values == NULL:
                    raise MemoryError("failed to allocate memory for value array")
                for i, value in enumerate(values):
                    _values[i] = value
            self.wrapped.build(num_keys, _keys, <const size_t*> _lengths, <const int*> _values, NULL)
        finally:
            if _keys != NULL:
                free(_keys)
            if _buf != NULL:
                for i in range(num_keys):
                    PyBuffer_Release(&_buf[i])
                free(_buf)
            if _lengths != NULL:
                free(_lengths)
            if _values != NULL:
                free(_values)

    def open(self, file_name,
             mode = 'rb',
             size_t offset = 0,
             size_t size = 0):
        file_name = file_name.encode('utf-8')
        cdef const char *_file_name = file_name
        mode = mode.encode('utf-8')
        cdef const char *_mode = mode
        with nogil:
            self.wrapped.open(_file_name, _mode, offset, size)

    def save(self, file_name,
             mode = 'wb',
             size_t offset = 0):
        file_name = file_name.encode('utf-8')
        cdef const char *_file_name = file_name
        mode = mode.encode('utf-8')
        cdef const char *_mode = mode
        with nogil:
            self.wrapped.save(_file_name, _mode, offset)

    def exact_match_search(self, key,
                           size_t length = 0,
                           size_t node_pos = 0,
                           pair_type=True):
        cdef Py_buffer buf
        if PyObject_GetBuffer(<PyObject *>key, &buf, PyBUF_C_CONTIGUOUS) < 0:
            return
        try:
            if length == 0:
                if buf.len == 0:
                    raise ValueError("buffer cannot be empty")
                length = buf.len
            if pair_type:
                return self.__exact_match_search_pair_type(<const char *>buf.buf, length, node_pos)
            else:
                return self.__exact_match_search(<const char *>buf.buf, length, node_pos)
        finally:
            PyBuffer_Release(&buf)

    def common_prefix_search(self, key,
                             size_t max_num_results = 0,
                             size_t length = 0,
                             size_t node_pos = 0,
                             pair_type=True):
        cdef Py_buffer buf
        if PyObject_GetBuffer(<PyObject *>key, &buf, PyBUF_C_CONTIGUOUS) < 0:
            return
        try:
            if length == 0:
                if buf.len == 0:
                    raise ValueError("buffer cannot be empty")
                length = buf.len
            if max_num_results == 0:
                max_num_results = len(key)
            if pair_type:
                return self.__common_prefix_search_pair_type(<const char *>buf.buf, max_num_results, length, node_pos)
            else:
                return self.__common_prefix_search(<const char *>buf.buf, max_num_results, length, node_pos)
        finally:
            PyBuffer_Release(&buf)

    def traverse(self, key,
                 size_t node_pos,
                 size_t key_pos,
                 size_t length = 0):
        cdef Py_buffer buf
        cdef int result
        if PyObject_GetBuffer(<PyObject *>key, &buf, PyBUF_C_CONTIGUOUS) < 0:
            return
        try:
            if length == 0:
                if buf.len == 0:
                    raise ValueError("buffer cannot be empty")
                length = buf.len
            with nogil:
                result = self.wrapped.traverse(<const char *>buf.buf, node_pos, key_pos, length)
            return result
        finally:
            PyBuffer_Release(&buf)

    def __exact_match_search(self, const char *key,
                             size_t length = 0,
                             size_t node_pos = 0):
        cdef int result = 0
        with nogil:
            self.wrapped.exact_match_search(key, result, length, node_pos)
        return result

    def __exact_match_search_pair_type(self, const char *key,
                                            size_t length = 0,
                                            size_t node_pos = 0):
        cdef result_pair_type result
        with nogil:
            self.wrapped.exact_match_search(key, result, length, node_pos)
        return result.value, result.length

    def __common_prefix_search(self, const char *key,
                               size_t max_num_results,
                               size_t length,
                               size_t node_pos):
        cdef int *results = <int *> calloc(max_num_results, sizeof(int))
        cdef int result_len
        try:
            with nogil:
                result_len = self.wrapped.common_prefix_search(key, results, max_num_results, length, node_pos)
            values = list()
            for i in range(result_len):
                values.append(results[i])
        finally:
            free(results)
        return values

    def __common_prefix_search_pair_type(self, const char *key,
                                              size_t max_num_results,
                                              size_t length,
                                              size_t node_pos):
        cdef result_pair_type *results = <result_pair_type *> calloc(max_num_results, sizeof(result_pair_type))
        cdef result_pair_type result
        cdef int result_len
        try:
            with nogil:
                result_len = self.wrapped.common_prefix_search(key, results, max_num_results, length, node_pos)
            values = list()
            for i in range(result_len):
                result = results[i]
                values.append((result.value, result.length))
        finally:
            free(results)
        return values
