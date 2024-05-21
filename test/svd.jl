## Description #############################################################################
#
# Tests related to singular value decomposition (SVD).
#
############################################################################################

@testset "Allocations" verbose = true begin
    for (elty, full) in (
        (:Float32, false),
        (:Float32, true),
        (:Float64, false),
        (:Float64, true),
    )
        @eval begin
            @testset "Type: $($elty), Full: $($full)" begin
                A = @SMatrix randn($elty, 10, 10)
                @test (@allocated svd(A; full = $full)) == 0

                A = @SMatrix randn($elty, 10, 5)
                @test (@allocated svd(A; full = $full)) == 0

                A = @SMatrix randn($elty, 5, 10)
                @test (@allocated svd(A; full = $full)) == 0
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
                A = @SMatrix randn($elty, 10, 10)
                Ur, Sr, Vr = svd(Matrix(A); full = $full)
                U,  S,  V  = svd(A; full = $full)

                @test U isa StaticMatrix
                @test S isa StaticVector
                @test V isa StaticMatrix
                @test length(S) == 10

                @test U ≈ Ur
                @test S ≈ Sr
                @test V ≈ Vr

                A = @SMatrix randn($elty, 10, 5)
                Ur, Sr, Vr = svd(Matrix(A); full = $full)
                U,  S,  V  = svd(A; full = $full)

                @test U isa StaticMatrix
                @test S isa StaticVector
                @test V isa StaticMatrix
                @test length(S) == 5

                @test U ≈ Ur
                @test S ≈ Sr
                @test V ≈ Vr

                A = @SMatrix randn($elty, 5, 10)
                Ur, Sr, Vr = svd(Matrix(A); full = $full)
                U,  S,  V  = svd(A; full = $full)

                @test U isa StaticMatrix
                @test S isa StaticVector
                @test V isa StaticMatrix
                @test length(S) == 5

                @test U ≈ Ur
                @test S ≈ Sr
                @test V ≈ Vr
            end
        end
    end
end
