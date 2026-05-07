module Optimizer

using ..Models

export optimize_plan

function calculate_uv(costs::Matrix{Float64}, basic_cells::Set{Tuple{Int, Int}}, m::Int, n::Int)
    u = fill(NaN, m)
    v = fill(NaN, n)
    u[1] = 0.0 # Избираме първоначален потенциал u_1 = 0
    
    changed = true
    while changed
        changed = false
        for (i, j) in basic_cells
            if !isnan(u[i]) && isnan(v[j])
                v[j] = costs[i, j] - u[i]
                changed = true
            elseif isnan(u[i]) && !isnan(v[j])
                u[i] = costs[i, j] - v[j]
                changed = true
            end
        end
    end
    
    # Ако системата не е свързана (напр. заради изроденост или грешка в базиса)
    for i in 1:m
        if isnan(u[i]) u[i] = 0.0 end
    end
    for j in 1:n
        if isnan(v[j]) v[j] = 0.0 end
    end
    
    return u, v
end

function get_cycle(nodes::Set{Tuple{Int, Int}}, start_cell::Tuple{Int, Int})
    # Търсене в дълбочина (DFS) за намиране на цикъл с редуващи се посоки
    function dfs(current, path, is_horiz)
        for nxt in nodes
            if nxt == current continue end
            if (is_horiz && nxt[1] == current[1]) || (!is_horiz && nxt[2] == current[2])
                if nxt == start_cell && length(path) >= 3
                    return path
                end
                if !(nxt in path)
                    res = dfs(nxt, push!(copy(path), nxt), !is_horiz)
                    if !isnothing(res) return res end
                end
            end
        end
        return nothing
    end
    
    res = dfs(start_cell, [start_cell], true)
    if isnothing(res)
        res = dfs(start_cell, [start_cell], false)
    end
    return res
end

function optimize_plan(data::TransportData, initial_solution::Solution; verbose=true)
    m, n = size(data.costs)
    sol = Solution(copy(initial_solution.allocation), copy(initial_solution.basic_cells), initial_solution.total_cost)
    iteration = 1
    
    while true
        if verbose println("\n" * "="^15 * " Итерация $iteration " * "="^15) end
        
        # 1. Изчисляване на потенциалите u и v
        u, v = calculate_uv(data.costs, sol.basic_cells, m, n)
        
        if verbose
            println("Потенциали:")
            println("  u (производители): ", round.(u, digits=2))
            println("  v (потребители)  : ", round.(v, digits=2))
        end
        
        # 2. Изчисляване на оценки за всички небазисни клетки: Δ = c_ij - (u_i + v_j)
        min_delta = 0.0
        entering_cell = (-1, -1)
        
        for i in 1:m, j in 1:n
            if !((i, j) in sol.basic_cells)
                delta = data.costs[i, j] - (u[i] + v[j])
                if delta < -1e-7 # Използваме толерантност заради плаваща запетая
                    if delta < min_delta
                        min_delta = delta
                        entering_cell = (i, j)
                    end
                end
            end
        end
        
        # Ако всички оценки са >= 0, текущият план е оптимален
        if entering_cell == (-1, -1)
            if verbose println("\nВсички оценки (Δ) са >= 0. Планът е оптимален!") end
            break
        end
        
        if verbose println("Най-негативна оценка: Δ_$(entering_cell[1]),$(entering_cell[2]) = $(round(min_delta, digits=2)). Клетката влиза в базиса.") end
        
        # 3. Намиране на цикъл за преразпределение
        search_nodes = copy(sol.basic_cells)
        push!(search_nodes, entering_cell)
        
        # Премахваме върхове без съседи по ред и колона (оптимизация преди DFS)
        while true
            changed = false
            for node in search_nodes
                same_row = sum(1 for n in search_nodes if n[1] == node[1])
                same_col = sum(1 for n in search_nodes if n[2] == node[2])
                if same_row <= 1 || same_col <= 1
                    delete!(search_nodes, node)
                    changed = true
                end
            end
            if !changed break end
        end
        
        cycle = get_cycle(search_nodes, entering_cell)
        if isnothing(cycle)
            println("Грешка: Не може да се намери цикъл! Задачата може да е силно изродена.")
            break
        end
        
        if verbose 
            print("Цикъл за преразпределение: ")
            println(join(["($(c[1]),$(c[2]))" for c in cycle], " -> "))
        end
        
        # 4. Преразпределение на количествата по цикъла
        # Клетките на четни позиции получават минус (-), а на нечетни плюс (+)
        minus_cells = [cycle[k] for k in 2:2:length(cycle)]
        plus_cells = [cycle[k] for k in 1:2:length(cycle)]
        
        # Търсим минималното количество сред "минус" клетките
        theta, leaving_idx = findmin([sol.allocation[c[1], c[2]] for c in minus_cells])
        leaving_cell = minus_cells[leaving_idx]
        
        if verbose println("Количество за прехвърляне θ = $theta. Излизаща клетка: $leaving_cell") end
        
        # Прилагане на промените
        for c in plus_cells
            sol.allocation[c[1], c[2]] += theta
        end
        for c in minus_cells
            sol.allocation[c[1], c[2]] -= theta
        end
        
        # Обновяване на базиса
        push!(sol.basic_cells, entering_cell)
        delete!(sol.basic_cells, leaving_cell)
        
        sol.total_cost = sum(data.costs .* sol.allocation)
        if verbose println("Текущи общи разходи: ", round(sol.total_cost, digits=2)) end
        
        iteration += 1
    end
    
    return sol
end

end