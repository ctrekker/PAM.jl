import Pkg
Pkg.activate(".")


using PAM
print("Username: ")
username = readline()
password = read(Base.getpass("Password"), String)
println(authenticate(username, password))
