module TransportationSolver

include("Models.jl")
include("InputHandler.jl")
include("InitialPlan.jl")
include("Optimizer.jl")
include("Utils.jl")

using .Models
using .InputHandler
using .InitialPlan
using .Optimizer
using .Utils

export run_app

function run_app()
    println("="^60)
    println(" Транспортна Задача ")
    println("="^60)
    
    data = InputHandler.read_from_cli()
    
    Utils.print_table(data, title="Входни Данни и Ценова Матрица (Разходи)")
    
    println("\nИзберете метод за намиране на начален опорен план:")
    println("1. Метод на северозападния ъгъл")
    println("2. Метод на минималния елемент (Least Cost)")
    print("Вашият избор (1/2): ")
    
    choice = readline()
    initial_sol = nothing
    
    if choice == "1"
        println("\n--- Метод на северозападния ъгъл ---")
        initial_sol = InitialPlan.northwest_corner(data)
    else
        println("\n--- Метод на минималния елемент ---")
        initial_sol = InitialPlan.least_cost(data)
    end
    
    Utils.print_table(data, initial_sol, title="Начален Опорен План")
    
    println("\n" * "="^60)
    println(" Стартиране на Оптимизация (MODI Метод на потенциалите) ")
    println("="^60)
    
    optimal_sol = Optimizer.optimize_plan(data, initial_sol, verbose=true)
    
    Utils.print_table(data, optimal_sol, title="Оптимален Транспортен План")
    println("\nПрограмата приключи успешно!")
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    TransportationSolver.run_app()
end
