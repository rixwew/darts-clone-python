import tempfile
import unittest

from dartsclone import DoubleArray


class DoubleArrayTest(unittest.TestCase):
    """test class of double array
    """
    darts: DoubleArray = None

    @classmethod
    def setUpClass(cls):
        cls.darts = DoubleArray()

    @classmethod
    def tearDownClass(cls):
        del cls.darts

    def tearDown(self):
        self.darts.clear()

    def test_darts_no_values(self):
        keys = ['test', 'テスト', 'テストケース']
        self.darts.build(sorted([key.encode() for key in keys]))
        with tempfile.NamedTemporaryFile() as f:
            self.assertEqual(1, self.darts.exact_match_search('テスト'.encode(), include_length=False))
            self.assertEqual(0, self.darts.common_prefix_search('testcase'.encode(), include_length=False)[0])
            self.darts.save(f.name)
            self.darts.clear()
            self.darts.open(f.name)
            self.assertEqual(0, self.darts.exact_match_search('test'.encode(), include_length=False))
            self.assertEqual(2, self.darts.common_prefix_search('テストケース'.encode(), include_length=False)[1])

    def test_darts_with_values(self):
        keys = ['test', 'テスト', 'テストケース']
        self.darts.build(sorted([key.encode() for key in keys]), values=[3, 5, 1])
        with tempfile.NamedTemporaryFile() as f:
            self.assertEqual(5, self.darts.exact_match_search('テスト'.encode(), include_length=False))
            self.assertEqual(3, self.darts.common_prefix_search('testcase'.encode(), include_length=False)[0])
            self.darts.save(f.name)
            self.darts.clear()
            self.darts.open(f.name)
            self.assertEqual(1, self.darts.exact_match_search('テストケース'.encode(), include_length=False))
            self.assertEqual(1, self.darts.common_prefix_search('テストケース'.encode(), include_length=False)[1])


if __name__ == "__main__":
    unittest.main()
