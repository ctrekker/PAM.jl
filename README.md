# PAM.jl
A minimal interface to PAM authentication. Meant to mimic the behavior of Python's Pamela.

## Installation
First make sure you're on a system with PAM installed. Next, ensure your system has the necessary header files for compiling PAM modules such as the one included in this package. [This article](https://mariadb.com/kb/en/installing-correct-libraries-for-pam-and-readline/) contains installation commands for several common Linux distributions.

Next install this package in the Julia REPL
```julia-repl
julia> add https://github.com/ctrekker/PAM.jl#master
```
