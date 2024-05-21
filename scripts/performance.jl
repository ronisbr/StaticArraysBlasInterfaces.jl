## Description #############################################################################
#
# Test the performance of the package.
#
## Note ####################################################################################
#
# This script **must** be run in a new Julia session!
#
############################################################################################

using BenchmarkTools
using LinearAlgebra
using PrettyTables
using StaticArrays

############################################################################################
#                                        Variables                                         #
############################################################################################

# Matrix dimensions to be tested.
matrix_dims = 2:1:10

# Array with the matrices:
Av_f32 = [
    @SMatrix randn(Float32, n, n) for n in matrix_dims
]

Av_f64 = [
    @SMatrix randn(Float64, n, n) for n in matrix_dims
]

# Time vectors.
alloc_svd_thin_f32_wo_sabi = zeros(length(matrix_dims))
time_svd_thin_f32_wo_sabi  = zeros(length(matrix_dims))
alloc_svd_full_f32_wo_sabi = zeros(length(matrix_dims))
time_svd_full_f32_wo_sabi  = zeros(length(matrix_dims))
alloc_pinv_f32_wo_sabi     = zeros(length(matrix_dims))
time_pinv_f32_wo_sabi      = zeros(length(matrix_dims))

alloc_svd_thin_f32_w_sabi  = zeros(length(matrix_dims))
time_svd_thin_f32_w_sabi   = zeros(length(matrix_dims))
alloc_svd_full_f32_w_sabi  = zeros(length(matrix_dims))
time_svd_full_f32_w_sabi   = zeros(length(matrix_dims))
alloc_pinv_f32_w_sabi      = zeros(length(matrix_dims))
time_pinv_f32_w_sabi       = zeros(length(matrix_dims))

alloc_svd_thin_f64_wo_sabi = zeros(length(matrix_dims))
time_svd_thin_f64_wo_sabi  = zeros(length(matrix_dims))
alloc_svd_full_f64_wo_sabi = zeros(length(matrix_dims))
time_svd_full_f64_wo_sabi  = zeros(length(matrix_dims))
alloc_pinv_f64_wo_sabi     = zeros(length(matrix_dims))
time_pinv_f64_wo_sabi      = zeros(length(matrix_dims))

alloc_svd_thin_f64_w_sabi  = zeros(length(matrix_dims))
time_svd_thin_f64_w_sabi   = zeros(length(matrix_dims))
alloc_svd_full_f64_w_sabi  = zeros(length(matrix_dims))
time_svd_full_f64_w_sabi   = zeros(length(matrix_dims))
alloc_pinv_f64_w_sabi      = zeros(length(matrix_dims))
time_pinv_f64_w_sabi       = zeros(length(matrix_dims))

############################################################################################
#                                      Test Functions                                      #
############################################################################################

# This functions must return the number of allocated bytes and the elapsed execution time.
function test_svd_thin(A::SMatrix{N, M, T}) where {N, M, T}
    return (@allocated svd(A)), (@belapsed svd($A))
end

function test_svd_full(A::SMatrix{N, M, T}) where {N, M, T}
    return (@allocated svd(A; full = true)), (@belapsed svd($A; full = true))
end

function test_pinv(A::SMatrix{N, M, T}) where {N, M, T}
    return (@allocated pinv(A)), (@belapsed pinv($A))
end

############################################################################################
#                                        Algorithm                                         #
############################################################################################

for load_sabi in (false, true)
    @info "Testing $(load_sabi ? "with" : "without") StaticArraysBlasInterface..."

    for T in (Float32, Float64)
        load_sabi && using StaticArraysBlasInterface

        for (test_prefix, func) in (
            ("svd_thin", test_svd_thin),
            ("svd_full", test_svd_full),
            ("pinv",     test_pinv)
        )
            @info "  Benchmark of $test_prefix [$T]"

            T_prefix    = T === Float64 ? "f64" : "f32"
            sabi_prefix = load_sabi ? "w_sabi" : "wo_sabi"

            Av    = @eval $(Symbol("Av_" * T_prefix))
            alloc = @eval $(Symbol("alloc_" * test_prefix * "_" * T_prefix * "_" * sabi_prefix))
            time  = @eval $(Symbol("time_"  * test_prefix * "_" * T_prefix * "_" * sabi_prefix))

            for k in eachindex(Av)
                A = Av[k]
                alloc_k, time_k = func(A)
                alloc[k] = alloc_k / 1024
                time[k]  = 1e6 * time_k
            end
        end
    end
end

############################################################################################
#                                         Results                                          #
############################################################################################

output_file = "benchmarks.md"
f = open(output_file, "w")

println(f, "# Benchmarks of StaticArraysBlasInterface.jl")

header = [
    "Matrix Dimension",
    "Time Before [ms]",
    "Allocations Before [kB]",
    "Time After [ms]",
    "Allocations After [kB]",
    "Gain [%]"
]

ft_dim(v, i, j) = j == 1 ? "$v × $v" : v

for (test_prefix, desc, T) in (
    ("svd_thin", "Singular Value Decomposition (Thin)", Float64),
    ("svd_thin", "Singular Value Decomposition (Thin)", Float32),
    ("svd_full", "Singular Value Decomposition (Full)", Float64),
    ("svd_full", "Singular Value Decomposition (Full)", Float32),
    ("pinv",     "Pseudo-Inverse",                      Float64),
    ("pinv",     "Pseudo-Inverse",                      Float32),
)
    T_prefix = T === Float64 ? "f64" : "f32"

    alloc_wo_sabi = @eval $(Symbol("alloc_" * test_prefix * "_" * T_prefix * "_wo_sabi"))
    time_wo_sabi  = @eval $(Symbol("time_"  * test_prefix * "_" * T_prefix * "_wo_sabi"))
    alloc_w_sabi  = @eval $(Symbol("alloc_" * test_prefix * "_" * T_prefix * "_w_sabi"))
    time_w_sabi   = @eval $(Symbol("time_"  * test_prefix * "_" * T_prefix * "_w_sabi"))

    gain = @. round((1 - time_w_sabi / time_wo_sabi) * 100, digits = 1)

    println(f)
    println(f, "## $desc (`$T`)")
    println(f)

    pretty_table(
        f,
        Any[matrix_dims time_wo_sabi alloc_wo_sabi time_w_sabi alloc_w_sabi gain];
        backend = Val(:markdown),
        formatters = ft_dim,
        header = header
    )
end

close(f)
