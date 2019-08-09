64tass -q --m4510 -D TARGET=1 -b interface_test.asm  -L rom.lst -o rom.bin
truncate rom.bin -s 131072
if [ $? -eq 0 ]
then
	../../../mega65-core/src/tools/monitor_load -b ../../documents/nexys4ddr.bit -p -R rom.bin -k ../../documents/hickup.m65 
fi
