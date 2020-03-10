# run the backtester

using Pkg, Plots 
#Pkg.add("Benchmarks")
#using Benchmarks
include("./backtester.jl")
include("./backtest_tools.jl")

using .backtest_tools, .backtester


mypath = "/Users/Maxi/Projects/Julia/backtest/XXBTZEUR_Series.csv";

df = get_dataframe(mypath);

@time df = backtest_engine(df,1000,10000,1000,0.005);
#Signals = get_crossovers(df.Price)

plot(df.Portfolio/df.Portfolio[1],label="Portfolio")
plot!(df.Price/df.Price[1],label="Price")


longs=collect(1000:20:5000)
shorts = collect(100:10:1000)

longs=convert(Array{Int64}, longs)

df_new = copy(df);

best_portfolio=0.0;
best_s = 0;
best_l = 0;

println(best_portfolio);

for l in longs
    for s in shorts
        df_new = backtest_engine(df,1000,l,s,0.005);
        println(df_new.Portfolio[end])
        if df_new.Portfolio[end] > best_portfolio
            best_portfolio = df_new.Portfolio[end];
            best_s = s;
            best_l = l;
        end
    end
end

println(" ");
println("best_s: ", best_s);
println("best_l: ", best_l);
println("best_portfolio: ", best_portfolio);