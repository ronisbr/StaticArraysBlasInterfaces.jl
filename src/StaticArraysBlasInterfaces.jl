module StaticArraysBlasInterfaces

using StaticArrays

import LinearAlgebra: BLAS, LAPACK, libblastrampoline
import StaticArrays: _pinv, SVD, _svd

############################################################################################
#                                         Includes                                         #
############################################################################################

include("svd.jl")

end # module StaticArraysBlasInterfaces
