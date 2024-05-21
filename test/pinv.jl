## Description #############################################################################
#
# Tests related to pseudo-inverse.
#
############################################################################################

# The code in StaticArrays.jl uses `svd` to compute `pinv`. Hence, after implement the BLAS
# interface to `svd`, we should be able to compute `pinv` without allocations.

@testset "Allocations" verbose = true begin
    for (elty, full) in (
        (:Float32, false),
        (:Float32, true),
        (:Float64, false),
        (:Float64, true),
    )
        @eval begin
            @testset "Type: $($elty), Full: $($full)" begin
                A = @SMatrix rand($elty, 10, 10)
                @test (@allocated pinv(A)) == 0

                A = @SMatrix rand($elty, 10, 5)
                @test (@allocated pinv(A)) == 0

                A = @SMatrix rand($elty, 5, 10)
                @test (@allocated pinv(A)) == 0
            end
        end
    end
end

@testset "Correctness" verbose = true begin
    for (elty, full) in (
        (:Float32, false),
        (:Float32, true),
        (:Float64, false),
        (:Float64, true),
    )
        @eval begin
            @testset "Type: $($elty), Full: $($full)" begin
                A      = @SMatrix rand($elty, 10, 10)
                pinvAr = pinv(Matrix(A))
                pinvA  = pinv(A)

                @test pinvA isa StaticMatrix
                @test pinvA ≈ pinvAr

                A      = @SMatrix rand($elty, 10, 5)
                pinvAr = pinv(Matrix(A))
                pinvA  = pinv(A)

                @test pinvA isa StaticMatrix
                @test pinvA ≈ pinvAr

                A      = @SMatrix rand($elty, 5, 10)
                pinvAr = pinv(Matrix(A))
                pinvA  = pinv(A)

                @test pinvA isa StaticMatrix
                @test pinvA ≈ pinvAr
            end
        end
    end
end
