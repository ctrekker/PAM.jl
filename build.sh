mkdir -p build

# download PAM source for headers
if [ ! -d linux-pam ]
then
    echo "Downloading PAM header files"
    curl -L https://github.com/linux-pam/linux-pam/archive/refs/tags/v1.5.2.tar.gz --output linux-pam.tar.gz
    mkdir linux-pam
    tar -xf linux-pam.tar.gz -C linux-pam --strip-components=1
    rm linux-pam.tar.gz
fi

# build PAM libraries from source
cd linux-pam
./ci/install-dependencies.sh
./autogen.sh
./configure
make

cd ..
gcc -c -fPIC -Wall -Werror -Ilinux-pam/libpam/include -Ilinux-pam/libpam_misc/include -Ilinux-pam/libpamc/include -o build/pam.o lib/*.cc
gcc -Wall -shared -Wl,-soname,libpam.so -Wl,-soname,libpam_misc.so -Wl,--no-undefined -o build/libpamjl.so build/pam.o -lpam -lpam_misc
rm build/*.o
