from setuptools import setup, Extension

NAME = 'dartsclone'
VERSION = '0.8.0'
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
    from os import path
    import glob

    [os.remove(f) for f in glob.glob('%s/*cpp' % NAME)]

    with open(path.join(path.dirname(__file__), 'README.md'), encoding='utf-8') as f:
        readme = f.read()

    setup(
        packages=[NAME],
        name=NAME,
        version=VERSION,
        description='Python binding of Darts Clone',
        author='@rixwew',
        author_email='rixwew@gmail.com',
        url='https://github.com/rixwew/darts-clone-python',
        setup_requires=[
            'cython>=0.28',
        ],
        ext_modules=EXTENSIONS,
        zip_safe=False,
        long_description=readme,
        long_description_content_type='text/markdown',
        classifiers=[
            'License :: OSI Approved :: Apache Software License',
            'Programming Language :: Cython',
            'Programming Language :: Python :: 2',
            'Programming Language :: Python :: 3',
            'Topic :: Text Processing :: Linguistic'
        ],
        install_requires=['Cython']
    )

