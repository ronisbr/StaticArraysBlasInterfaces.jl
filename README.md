# StaticArraysBlasInterface.jl

[![CI](https://github.com/ronisbr/StaticArraysBlasInterfaces.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/ronisbr/StaticArraysBlasInterfaces.jl/actions/workflows/ci.yml)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package implements a direct interface between BLAS library and some types of
[StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl). The purpose of this
approach is to avoid allocations in those situations that
[StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl) converts static arrays
into Julia's `Array` to call functions in `Base`.

The package uses the following approach to call BLAS functions without allocating when the
input is a `StaticMatrix`:

1. Convert the input to `MMatrix`.
2. Create all the required data for the BLAS function using `MMatrix`.
3. Call the BLAS function.
4. Convert the result back to `StaticMatrix`.

Since the `MMatrix` does not go outside the scope of the function and we make sure that the
function is type-stable, Julia compiler is clever enough to perform all the required
computations in the stack, avoiding allocations.

We currently implemented the direct interface to BLAS in the following situations:

1. Single value decomposition of `StaticMatrix` (`Float32` and `Float64`) using the full and
   thin algorithms. This support also provided an allocation free pseudo-inverse `pinv` when
   using the supported types.

## Installation

TBD

## Usage

We just need to load the package to start using the direct interfaces:

```julia-repl
julia> using LinearAlgebra, StaticArrays, BenchmarkTools

julia> A = @SMatrix randn(10, 5)
10×5 SMatrix{10, 5, Float64, 50} with indices SOneTo(10)×SOneTo(5):
  0.589018   -1.30493     1.58617     -0.77411    -0.253593
 -2.42969    -0.345914   -0.00199176   0.0574487   0.11044
 -0.517858   -0.0884028  -0.637852    -0.0408755   1.01884
 -0.647127   -1.04393    -0.125752     0.363352   -0.449963
  0.0387125  -0.406111   -2.04058     -0.354635   -1.11105
  1.57486    -0.763223    1.16045      0.494147    0.956333
 -0.225419   -1.1004     -0.10753     -0.0707382   0.631543
 -1.0148     -0.65741     0.694031    -0.576483   -1.14052
  0.451196   -0.910734    0.501836    -0.847353    1.60741
  0.710597    1.83357    -0.161693     1.26412    -0.182749

julia> @btime pinv($A)
  3.302 μs (8 allocations: 5.12 KiB)
5×10 SMatrix{5, 10, Float64, 50} with indices SOneTo(5)×SOneTo(10):
  0.0621573  -0.254943   -0.0609774   -0.033726   …  -0.0116428  -0.0741739    0.0214788   0.0242452
 -0.0643493  -0.0248774  -0.00199032  -0.294715      -0.200383    0.00371128   0.0335571   0.103725
  0.149186    0.0564734  -0.100303    -0.0381501     -0.0749295   0.12711     -0.0217453   0.0397455
 -0.121202    0.130855   -0.0118042    0.401804       0.176801   -0.108218    -0.265761    0.230577
 -0.11008     0.0739689   0.179732    -0.0809152      0.0753345  -0.162967     0.208302   -0.0216201

julia> using StaticArraysBlasInterface

julia> @btime pinv($A)
  2.634 μs (0 allocations: 0 bytes)
5×10 SMatrix{5, 10, Float64, 50} with indices SOneTo(5)×SOneTo(10):
  0.0621573  -0.254943   -0.0609774   -0.033726   …  -0.0116428  -0.0741739    0.0214788   0.0242452
 -0.0643493  -0.0248774  -0.00199032  -0.294715      -0.200383    0.00371128   0.0335571   0.103725
  0.149186    0.0564734  -0.100303    -0.0381501     -0.0749295   0.12711     -0.0217453   0.0397455
 -0.121202    0.130855   -0.0118042    0.401804       0.176801   -0.108218    -0.265761    0.230577
 -0.11008     0.0739689   0.179732    -0.0809152      0.0753345  -0.162967     0.208302   -0.0216201
```

## Performance Comparison

The benchmarks are available [here](./benchmarks.md).
