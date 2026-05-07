module InitialPlan

using ..Models

export northwest_corner, least_cost

function calculate_cost(costs, alloc)
    return sum(costs .* alloc)
end

function northwest_corner(data::TransportData)
    m, n = size(data.costs)
    alloc = zeros(Float64, m, n)
    basic_cells = Set{Tuple{Int, Int}}()
    
    rem_sup = copy(data.supply)
    rem_dem = copy(data.demand)
    
    i, j = 1, 1
    while i <= m && j <= n
        push!(basic_cells, (i, j))
        qty = min(rem_sup[i], rem_dem[j])
        alloc[i, j] = qty
        rem_sup[i] -= qty
        rem_dem[j] -= qty
        
        if rem_sup[i] == 0 && rem_dem[j] == 0
            if i < m
                i += 1
                # Обработка на изроденост: запазване на (m+n-1) базисни клетки
                push!(basic_cells, (i, j))
            elseif j < n
                j += 1
                push!(basic_cells, (i, j))
            else
                break
            end
        elseif rem_sup[i] == 0
            i += 1
        else
            j += 1
        end
    end
    
    return Solution(alloc, basic_cells, calculate_cost(data.costs, alloc))
end

function least_cost(data::TransportData)
    m, n = size(data.costs)
    alloc = zeros(Float64, m, n)
    basic_cells = Set{Tuple{Int, Int}}()
    
    rem_sup = copy(data.supply)
    rem_dem = copy(data.demand)
    
    active_rows = trues(m)
    active_cols = trues(n)
    
    while sum(active_rows) > 0 && sum(active_cols) > 0
        min_c = Inf
        min_i, min_j = -1, -1
        for i in 1:m, j in 1:n
            if active_rows[i] && active_cols[j] && data.costs[i, j] < min_c
                min_c = data.costs[i, j]
                min_i, min_j = i, j
            end
        end
        
        if min_i == -1 break end
        
        push!(basic_cells, (min_i, min_j))
        qty = min(rem_sup[min_i], rem_dem[min_j])
        alloc[min_i, min_j] = qty
        rem_sup[min_i] -= qty
        rem_dem[min_j] -= qty
        
        if rem_sup[min_i] == 0 && rem_dem[min_j] == 0
            if sum(active_rows) > 1
                active_rows[min_i] = false
                # Изроденост се обработва естествено, тъй като не премахваме 
                # колоната, следващата итерация ще й даде количество 0.
            else
                active_cols[min_j] = false
            end
        elseif rem_sup[min_i] == 0
            active_rows[min_i] = false
        else
            active_cols[min_j] = false
        end
    end
    
    return Solution(alloc, basic_cells, calculate_cost(data.costs, alloc))
end

end