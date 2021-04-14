module PAM

using Base.Libc
import Libdl


struct PamException <: Exception
    message::String
end


PAM_PROMPT_ECHO_OFF = 1
PAM_PROMPT_ECHO_ON = 2
PAM_ERROR_MSG = 3
PAM_TEXT_INFO = 4

PAM_REINITIALIZE_CRED = 0x0008  # This constant is libpam-specific.

mutable struct PamHandle
    handle::Ptr{Cvoid}
end
PamHandle() = PamHandle(0)

mutable struct PamConv
    conv::Ptr{Cvoid}
    appdata_ptr::Ptr{Cvoid}
end
mutable struct PamMessage
    msg_style::Cint
    msg::Ptr{Cchar}
end
mutable struct PamResponse
    resp::Ptr{Cchar}
    resp_retcode::Cint
end

function get_pam_fn(fn_name::Symbol)
    pam_lib = Libdl.dlopen("/lib/x86_64-linux-gnu/libpam.so.0")
    Libdl.dlsym(pam_lib, fn_name)
end

function pam_start(service::AbstractString, username::AbstractString, conversation::PamConv, handle::PamHandle)::Cint
    #                         service    user       conversation  handle
    ccall(get_pam_fn(:pam_start), Cint, (Ptr{Cchar}, Ptr{Cchar}, Ptr{PamConv}, Ptr{PamHandle}), Ptr{Cchar}(pointer(service)), Ptr{Cchar}(pointer(username)), Base.pointer_from_objref(conversation), Base.pointer_from_objref(handle))
end

function pam_end(handle::PamHandle, status::Int=0)
    ccall(get_pam_fn(:pam_end), Cint, (Ptr{PamHandle}, Cint), Base.pointer_from_objref(handle), Cint(status))
end

function pam_authenticate(handle::PamHandle, flags::Int)::Cint
    pam_lib = Libdl.dlopen("/lib/x86_64-linux-gnu/libpam.so.0")
    pam_authenticate_c = Libdl.dlsym(pam_lib, :pam_authenticate)

    ccall(pam_authenticate_c, Cint, (Ptr{PamHandle}, Cint), Base.pointer_from_objref(handle), Cint(flags))
end


Base.@ccallable function my_conv(num_msg::Cint, msg::Ptr{Ptr{PamMessage}}, resp::Ptr{Ptr{PamResponse}}, appdata_ptr::Ptr{Cvoid})::Cint    
    println("hello world")
    # addr = calloc(num_msg, sizeof(PamResponse))

    # for i ∈ Cint(0):(num_msg - Cint(1))
    #     if Ref(msg, i)[].contents.msg_style == PAM_PROMPT_ECHO_OFF
    #         pw_copy = ccall(:strdup, Ptr{Cchar}, (Ptr{Cchar},), password)
    #         Ref(resp, i)[].contents.resp = pw_copy
    #         Ref(resp, i)[].contents.resp_retcode = 0
    #     end
    # end

    return Cint(0)
end


function authenticate(username, password; service="login", encoding="utf-8", resetcred=true)
    my_conv_c = @cfunction(my_conv, Cint, (Cint, Ptr{Ptr{PamMessage}}, Ptr{Ptr{PamResponse}}, Ptr{Cvoid}))

    handle = PamHandle()
    conv = PamConv(my_conv_c, 0)
    
    pam_start_response = pam_start(service, username, conv, handle)
    if pam_start_response != 0
        throw(PamException("Error starting PAM: Received non-0 startup code ($pam_start_response)"))
    end

    pam_auth_response = pam_authenticate(handle, 0)
    println(pam_auth_response)

    println(pam_end(handle))

    # auth_success = (pam_auth_response == 0)
end

greet() = print("Hello World!")

end # module
