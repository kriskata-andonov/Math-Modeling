module Utils

using ..Models

export print_table

function print_table(data::TransportData, sol::Union{Solution, Nothing}=nothing; title="Матрица")
    println("\n=== $title ===")
    m, n = size(data.costs)
    
    # Заглавен ред
    print(rpad("Изт/Потр", 10), " | ")
    for j in 1:n
        print(rpad("D$j", 10), " | ")
    end
    println("Наличности")
    
    # Разделителна линия
    println("-" ^ (13 + 13 * n + 12))
    
    for i in 1:m
        # Оригинални и фиктивни източници
        row_label = (i <= data.original_m) ? "S$i" : "S_fict$(i - data.original_m)"
        print(rpad(row_label, 10), " | ")
        
        for j in 1:n
            cost_str = string(round(data.costs[i, j], digits=2))
            alloc_str = ""
            if !isnothing(sol) && ((i, j) in sol.basic_cells || sol.allocation[i, j] > 0)
                alloc_str = "[$(round(sol.allocation[i, j], digits=2))]"
            end
            cell_str = "$(cost_str)$alloc_str"
            print(rpad(cell_str, 10), " | ")
        end
        println(round(data.supply[i], digits=2))
    end
    
    println("-" ^ (13 + 13 * n + 12))
    
    print(rpad("Потребн.", 10), " | ")
    for j in 1:n
        println_val = round(data.demand[j], digits=2)
        print(rpad(string(println_val), 10), " | ")
    end
    println(round(sum(data.supply), digits=2))
    
    if !isnothing(sol)
        println("\nОбщи транспортни разходи: ", round(sol.total_cost, digits=2))
    end
end

end