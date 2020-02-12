#!/bin/sh

PYTHONS=("cp36-cp36m" "cp37-cp37m" "cp38-cp38")

for PYTHON in ${PYTHONS[@]}; do
    /opt/python/${PYTHON}/bin/pip install --upgrade pip
    /opt/python/${PYTHON}/bin/pip install -U wheel auditwheel
    /opt/python/${PYTHON}/bin/python setup.py bdist_wheel
done

for whl in /github/workspace/dist/*.whl; do
    auditwheel repair $whl
done
