include("src/Models.jl")
include("src/InputHandler.jl")
include("src/InitialPlan.jl")
include("src/Optimizer.jl")

using .Models
using .InitialPlan
using .Optimizer

costs = [5.0 4.0 3.0; 8.0 4.0 3.0; 9.0 7.0 5.0]
supply = [100.0, 200.0, 300.0]
demand = [150.0, 150.0, 150.0]
data = TransportData(costs, supply, demand, false, 3, 3)

data = InputHandler.balance_problem(data)
sol = InitialPlan.least_cost(data)
opt_sol = Optimizer.optimize_plan(data, sol, verbose=false)
println("Optimal cost: ", opt_sol.total_cost)
