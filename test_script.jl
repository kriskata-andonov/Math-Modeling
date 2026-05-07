include("src/Models.jl")
include("src/InputHandler.jl")
include("src/InitialPlan.jl")
include("src/Optimizer.jl")

using .Models
using .InitialPlan
using .Optimizer

costs = [2.0 3.0 4.0 5.0; 3.0 2.0 5.0 2.0; 4.0 1.0 2.0 3.0]
supply = [20.0, 30.0, 50.0]
demand = [10.0, 20.0, 30.0, 40.0]
data = TransportData(costs, supply, demand, true, 3, 4)

sol1 = InitialPlan.northwest_corner(data)
println("NW cost: ", sol1.total_cost)

opt_sol = Optimizer.optimize_plan(data, sol1, verbose=false)
println("Optimal cost: ", opt_sol.total_cost)

sol2 = InitialPlan.least_cost(data)
println("LC cost: ", sol2.total_cost)
opt_sol2 = Optimizer.optimize_plan(data, sol2, verbose=false)
println("Optimal cost LC: ", opt_sol2.total_cost)
