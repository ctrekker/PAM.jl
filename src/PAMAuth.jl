module PAMAuth

export authenticate


using Base.Libc
import Libdl

struct PamException <: Exception
    message::String
end


"""
    authenticate(username::AbstractString, password::AbstractString)

Attempts to authenticate a user with the local system via PAM under the given username and password.

# Examples
```julia
using PAM

print("Username: ")
username = readline()
password = read(Base.getpass("Password"), String)

valid = authenticate(username, password)
# Valid is true if authentication was successful
```
"""
function authenticate(username::AbstractString, password::AbstractString)
    libpamjl = Libdl.dlopen(normpath("$(@__DIR__)/../build/libpamjl.so"))
    pamjl_authenticate = Libdl.dlsym(libpamjl, :pamjl_authenticate)
    ccall(pamjl_authenticate, Cint, (Ptr{Cchar}, Ptr{Cchar}), username, password) == 0
end


end # module
