# run the backtester

using Pkg, Plots 
pyplot()    # plotting backend
Plots.default(overwrite_figure=false)

Pkg.activate(".")
#using Benchmarks
include("./backtester.jl")
include("./backtest_tools.jl")

using .backtest_tools, .backtester


#mypath = "/Users/Maxi/Projects/Julia/backtest/XXBTZEUR_Series.csv";
mypath = "./XXBTZEUR_Series.csv";

df = get_dataframe(mypath);

@time df = backtest_engine(df,1000,10000,1000,0.005);
#Signals = get_crossovers(df.Price)

plot(df.Portfolio/df.Portfolio[1],label="Portfolio")
plot!(df.Price/df.Price[1],label="Price")


longs=collect(1000:100:5000);
shorts = collect(100:20:1000);

longs=convert(Array{Int64}, longs)

df_new = copy(df);

let         # put the loop into a global scope
best_portfolio=0.0;
best_s = 0;
best_l = 0;

# store all end_prices to plot a heat map
global heat_map = zeros((length(longs), length(shorts)));

investment = 1000;

println("Initial investment: ",investment);
println("With BUY and HODL you have: ",df.Price[end]*investment/df.Price[1]);
println(" ");
sleep(3);

a=1;

println("best_portfolio: ",best_portfolio);

for (l_id, l) in enumerate(longs)
    for (s_id,s) in enumerate(shorts)
        df_new = backtest_engine(df,investment,l,s,0.005);
        println(df_new.Portfolio[end])
        global heat_map[l_id,s_id] = df_new.Portfolio[end];
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

# plot the best portfolio
plot(df_new.Portfolio/df_new.Portfolio[1],label="Portfolio",title="Best Portfolio development")
plot!(df_new.Price/df_new.Price[1],label="Price")


heatmap(shorts, longs, heat_map,title="best price heat map",xlabel="short",ylabel="long");

end     # end let
