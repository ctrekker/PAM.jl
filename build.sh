mkdir -p build
gcc -c -fPIC -Wall -Werror -o build/pam.o lib/*.cc -lpam -lpam_misc
gcc -Wall -shared -Wl,-soname,libpam.so -Wl,-soname,libpam_misc.so -Wl,--no-undefined -o build/libpamjl.so build/pam.o -lpam -lpam_misc
rm build/*.o
