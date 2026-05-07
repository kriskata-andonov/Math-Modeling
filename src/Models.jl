module Models

export TransportData, Solution

mutable struct TransportData
    costs::Matrix{Float64}
    supply::Vector{Float64}
    demand::Vector{Float64}
    is_balanced::Bool
    original_m::Int
    original_n::Int
end

mutable struct Solution
    allocation::Matrix{Float64}
    basic_cells::Set{Tuple{Int, Int}}
    total_cost::Float64
end

end