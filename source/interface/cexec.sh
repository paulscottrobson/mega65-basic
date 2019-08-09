pushd ../../emulator
sh build.sh
popd
64tass -q -c -D TARGET=2 -b interface_test.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../../emulator/em4510 rom.bin go
fi
