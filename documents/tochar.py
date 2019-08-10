#
#		Convert first 1k of pet font to 'C' source.
#
src = [x for x in open("pet-font.bin","rb").read(-1)]
src = src[:1024]
data = ",".join([str(x) for x in src])
hdr = "static const BYTE8 character_rom[] = {"
print(hdr+data+"};\n")