## Description #############################################################################
#
# Functions to compute the singular value decomposition of a static matrix.
#
############################################################################################

# We are implementing here the following functions:
#
#   StaticArrays._svd(A::StaticMatrix{M, N, Float64}, full::Val{false}) where {M, N}
#   StaticArrays._svd(A::StaticMatrix{M, N, Float64}, full::Val{true}) where {M, N}
#   StaticArrays._svd(A::StaticMatrix{M, N, Float32}, full::Val{false}) where {M, N}
#   StaticArrays._svd(A::StaticMatrix{M, N, Float32}, full::Val{true}) where {M, N}
#
for (gesvd, elty, full) in (
    (:dgesvd_, :Float64, false),
    (:dgesvd_, :Float64, true),
    (:sgesvd_, :Float32, false),
    (:sgesvd_, :Float32, true)
)
    @eval begin
        function _svd(A::StaticMatrix{M, N, $elty}, full::Val{$full}) where {M, N}
            K = min(M, N)

            # Convert the input to a `MMatrix` and allocate the required arrays.
            Am    = MMatrix{M, N, $elty}(A)
            Um    = MMatrix{M, $(full ? :M : :K), $elty}(undef)
            Sm    = MVector{K, $elty}(undef)
            Vtm   = MMatrix{$(full ? :N : :K), N, $elty}(undef)
            lwork = max(3min(M, N) + max(M, N), 5min(M, N))
            work  = MVector{lwork, $elty}(undef)
            info  = Ref(1)

            ccall(
                (BLAS.@blasfunc($gesvd), libblastrampoline),
                Cvoid,
                (
                    Ref{UInt8},
                    Ref{UInt8},
                    Ref{BLAS.BlasInt},
                    Ref{BLAS.BlasInt},
                    Ptr{$elty},
                    Ref{BLAS.BlasInt},
                    Ptr{$elty},
                    Ptr{$elty},
                    Ref{BLAS.BlasInt},
                    Ptr{$elty},
                    Ref{BLAS.BlasInt},
                    Ptr{$elty},
                    Ref{BLAS.BlasInt},
                    Ref{BLAS.BlasInt},
                    Clong,
                    Clong
                ),
                $(full ? 'A' : 'S'),
                $(full ? 'A' : 'S'),
                M,
                N,
                Am,
                M,
                Sm,
                Um,
                M,
                Vtm,
                $(full ? :N : :K),
                work,
                lwork,
                info,
                1,
                1
            )

            # Check if the return result of the function.
            LAPACK.chklapackerror(info.x)

            # Convert the matrices to static arrays and return.
            U  = SMatrix{M, $(full ? :M : :K), $elty}(Um)
            S  = SVector{K, $elty}(Sm)
            Vt = SMatrix{$(full ? :N : :K), N, $elty}(Vtm)

            return StaticArrays.SVD(U, S, Vt)
        end
    end
end
