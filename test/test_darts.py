import tempfile
import unittest
import pickle

from dartsclone import DoubleArray


class DoubleArrayTest(unittest.TestCase):
    """test class of double array
    """

    def test_darts_no_values(self):
        keys = ['test', 'テスト', 'テストケース']
        darts = DoubleArray()
        darts.build(sorted([key.encode() for key in keys]))
        self.assertEqual(1, darts.exact_match_search('テスト'.encode(), pair_type=False))
        self.assertEqual(0, darts.common_prefix_search('testcase'.encode(), pair_type=False)[0])
        self.assertEqual(0, darts.exact_match_search('test'.encode(), pair_type=False))
        self.assertEqual(2, darts.common_prefix_search('テストケース'.encode(), pair_type=False)[1])

    def test_darts_with_values(self):
        keys = ['test', 'テスト', 'テストケース']
        darts = DoubleArray()
        darts.build(sorted([key.encode() for key in keys]), values=[3, 5, 1])
        self.assertEqual(5, darts.exact_match_search('テスト'.encode(), pair_type=False))
        self.assertEqual(3, darts.common_prefix_search('testcase'.encode(), pair_type=False)[0])
        self.assertEqual(1, darts.exact_match_search('テストケース'.encode(), pair_type=False))
        self.assertEqual(1, darts.common_prefix_search('テストケース'.encode(), pair_type=False)[1])

    def test_darts_save(self):
        keys = ['test', 'テスト', 'テストケース']
        darts = DoubleArray()
        darts.build(sorted([key.encode() for key in keys]), values=[3, 5, 1])
        with tempfile.NamedTemporaryFile('wb') as output_file:
            darts.save(output_file.name)
            output_file.flush()
            darts.clear()
            darts.open(output_file.name)
        self.assertEqual(5, darts.exact_match_search('テスト'.encode(), pair_type=False))
        self.assertEqual(3, darts.common_prefix_search('testcase'.encode(), pair_type=False)[0])

    def test_darts_pickle(self):
        keys = ['test', 'テスト', 'テストケース']
        darts = DoubleArray()
        darts.build(sorted([key.encode() for key in keys]), values=[3, 5, 1])
        with tempfile.NamedTemporaryFile('wb') as output_file:
            pickle.dump(darts, output_file)
            output_file.flush()
            with open(output_file.name, 'rb') as input_file:
                darts = pickle.load(input_file)
        self.assertEqual(5, darts.exact_match_search('テスト'.encode(), pair_type=False))
        self.assertEqual(3, darts.common_prefix_search('testcase'.encode(), pair_type=False)[0])

    def test_darts_array(self):
        keys = ['test', 'テスト', 'テストケース']
        darts = DoubleArray()
        darts.build(sorted([key.encode() for key in keys]), values=[3, 5, 1])
        array = darts.array()
        darts = DoubleArray()
        darts.set_array(array)
        self.assertEqual(5, darts.exact_match_search('テスト'.encode(), pair_type=False))
        self.assertEqual(3, darts.common_prefix_search('testcase'.encode(), pair_type=False)[0])


if __name__ == "__main__":
    unittest.main()
