#
#		Test interface (FPGA)
#
64tass -q --m4510 -D INTERFACE=2 -b interface_test.asm  -L rom.lst -o rom.bin
truncate rom.bin -s 131072
if [ $? -eq 0 ]
then
	../../../mega65-core/src/tools/monitor_load -b ../../documents/nexys4ddr.bit -p -R rom.bin -k ../../documents/hickup.m65 
	rm rom.lst rom.bin
fi
