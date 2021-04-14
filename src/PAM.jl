module PAM

export authenticate


using Base.Libc
import Libdl

struct PamException <: Exception
    message::String
end


function authenticate(username::AbstractString, password::AbstractString)
    libpamjl = Libdl.dlopen("build/libpamjl.so")
    pamjl_authenticate = Libdl.dlsym(libpamjl, :pamjl_authenticate)
    ccall(pamjl_authenticate, Cint, (Ptr{Cchar}, Ptr{Cchar}), username, password) == 0
end


end # module
