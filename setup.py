from Cython.Build import cythonize
from setuptools import setup, Extension

NAME = 'dartsclone'
VERSION = '0.1'
EXTENSIONS = [
    Extension(
        '{0}._{0}'.format(NAME),
        language='c++',
        sources=[
            '{0}/_{0}.pyx'.format(NAME),
            'csrc/src/darts.cc'
        ],
        include_dirs=['./csrc/include']
    )
]

if __name__ == '__main__':
    import os
    import glob

    [os.remove(f) for f in glob.glob('%s/*cpp' % NAME)]
    setup(
        packages=[NAME],
        name=NAME,
        version=VERSION,
        description='Python binding of Darts Clone',
        author='@rixwew',
        author_email='rixwew@gmail.com',
        url='https://github.com/rixwew/darts-clone-python',
        ext_modules=cythonize(EXTENSIONS),
        zip_safe=False,
        classifiers=[
            'License :: OSI Approved :: Apache Software License',
            'Programming Language :: Cython',
            'Programming Language :: Python :: 2',
            'Programming Language :: Python :: 3'
        ]
    )
