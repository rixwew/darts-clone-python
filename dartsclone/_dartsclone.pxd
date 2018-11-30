cdef extern from "darts.h":
    cdef struct result_pair_type "Darts::DoubleArray::result_pair_type":
        int value
        size_t length

    cdef cppclass CppDoubleArray "Darts::DoubleArray":
        void set_array(const void *ptr, size_t size)
        const void *array()
        void clear() nogil
        size_t unit_size() nogil
        size_t size() nogil
        size_t total_size() nogil
        size_t nonzero_size() nogil
        int build(size_t num_keys,
                  const char ** keys,
                  const size_t *lengths,
                  const int *values,
                  int (*progress_func)(size_t, size_t)) nogil except +
        int open(const char *file_name,
                 const char *mode,
                 size_t offset,
                 size_t size) nogil except +
        int save(const char *file_name,
                 const char *mode,
                 size_t offset) nogil except +
        void exact_match_search "exactMatchSearch"(const char *key,
                                                   int & result,
                                                   size_t length,
                                                   size_t node_pos) nogil except +
        void exact_match_search "exactMatchSearch"(const char *key,
                                                   result_pair_type & result,
                                                   size_t length,
                                                   size_t node_pos) nogil except +
        size_t common_prefix_search "commonPrefixSearch"(const char *key,
                                                         int *results,
                                                         size_t max_num_results,
                                                         size_t length,
                                                         size_t node_pos) nogil except +
        size_t common_prefix_search "commonPrefixSearch"(const char *key,
                                                         result_pair_type *results,
                                                         size_t max_num_results,
                                                         size_t length,
                                                         size_t node_pos) nogil except +
        int traverse(const char *key,
                     size_t & node_pos,
                     size_t & key_pos,
                     size_t length) nogil except +




cdef class DoubleArray:
    cdef CppDoubleArray *wrapped
