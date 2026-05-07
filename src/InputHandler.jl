module InputHandler

using ..Models

export read_from_cli, balance_problem

function read_vector(prompt::String, n::Int)
    while true
        print(prompt)
        input = readline()
        vals = tryparse.(Float64, split(input))
        if length(vals) == n && all(!isnothing, vals) && all(x -> x >= 0, vals)
            return [v for v in vals]
        else
            println("Грешка: Невалиден вход. Моля, въведете точно $n неотрицателни числа, разделени с интервал.")
        end
    end
end

function read_from_cli()
    println("=== Въвеждане на данни за Транспортна Задача ===")
    
    m, n = 0, 0
    while true
        print("Въведете брой производители (източници): ")
        try
            m = parse(Int, readline())
            if m > 0
                break
            else
                println("Броят трябва да е по-голям от 0.")
            end
        catch
            println("Грешка: Невалидно цяло число.")
        end
    end
    
    while true
        print("Въведете брой потребители (дестинации): ")
        try
            n = parse(Int, readline())
            if n > 0
                break
            else
                println("Броят трябва да е по-голям от 0.")
            end
        catch
            println("Грешка: Невалидно цяло число.")
        end
    end
    
    supply = read_vector("Въведете наличностите на $m производителя (разделени с интервал): ", m)
    demand = read_vector("Въведете потребностите на $n потребителя (разделени с интервал): ", n)
    
    costs = zeros(Float64, m, n)
    println("Въведете матрицата на транспортните разходи (по един ред наведнъж, разделени с интервал):")
    for i in 1:m
        costs[i, :] = read_vector("Ред $i ($n стойности): ", n)
    end
    
    return balance_problem(TransportData(costs, supply, demand, true, m, n))
end

function balance_problem(data::TransportData)
    total_supply = sum(data.supply)
    total_demand = sum(data.demand)
    
    if total_supply == total_demand
        println("\n[Инфо] Задачата е затворена (балансирана).")
        data.is_balanced = true
        return data
    end
    
    println("\n[Инфо] Задачата е отворена (небалансирана). Балансиране...")
    data.is_balanced = false
    
    m, n = size(data.costs)
    new_costs = copy(data.costs)
    new_supply = copy(data.supply)
    new_demand = copy(data.demand)
    
    if total_supply > total_demand
        diff = total_supply - total_demand
        println("[Инфо] Добавяне на фиктивен потребител с потребност $diff и нулеви транспортни разходи.")
        new_costs = hcat(new_costs, zeros(Float64, m))
        push!(new_demand, diff)
    else
        diff = total_demand - total_supply
        println("[Инфо] Добавяне на фиктивен производител с наличност $diff и нулеви транспортни разходи.")
        new_costs = vcat(new_costs, zeros(Float64, 1, n))
        push!(new_supply, diff)
    end
    
    return TransportData(new_costs, new_supply, new_demand, false, m, n)
end

end