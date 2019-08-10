#
#		Test interface (EM4510)
#
pushd ../../emulator
sh build.sh
popd
64tass -q -c -D INTERFACE=1 -b interface_test.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../../emulator/em4510 rom.bin go
	rm rom.lst rom.bin
fi
