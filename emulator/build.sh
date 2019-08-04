pushd processor
python process.py >cpu_opcodes.h
popd
make -f makefile.linux


