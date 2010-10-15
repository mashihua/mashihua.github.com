#!/usr/bin/env python
import zlib
import sys
import os
  
CHUNKSIZE=1024
dec = zlib.decompressobj(16+zlib.MAX_WBITS)
#dec = zlib.decompressobj(-15)

def printFile(f):
  f=open(f,'rb')
  buffer=f.read(CHUNKSIZE)
  
  while buffer:
    outstr = dec.decompress(buffer,1) +  dec.flush()
    print(outstr);
    buffer = f.read(CHUNKSIZE)
   
  f.close()

    
if __name__ == "__main__":
  if len(sys.argv) < 2:
    print('Usage: python deflate.py inputfile')
  else:
    printFile(sys.argv[1]) 
