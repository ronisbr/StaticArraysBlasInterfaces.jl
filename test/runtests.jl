using Test

using LinearAlgebra
using StaticArrays
using StaticArraysBlasInterface

@testset "Singular Value Decomposition" verbose = true begin
    include("./svd.jl")
end

@testset "Pseudo-Inverse" verbose = true begin
    include("./pinv.jl")
end
