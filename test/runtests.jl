using Test

using LinearAlgebra
using StaticArrays
using StaticArraysBlasInterfaces

@testset "Singular Value Decomposition" verbose = true begin
    include("./svd.jl")
end

@testset "Pseudo-Inverse" verbose = true begin
    include("./pinv.jl")
end
