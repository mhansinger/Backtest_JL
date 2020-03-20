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

investment = 1000.0;

df = get_dataframe(mypath);

@time df = backtest_engine(df,investment,10000,1000,0.005);
#Signals = get_crossovers(df.Price)

# plot(df.Portfolio/df.Portfolio[1],label="Portfolio")
# plot!(df.Price/df.Price[1],label="Price")


longs=collect(3000:500:7000);
shorts = collect(300:100:800);

longs=convert(Array{Int64}, longs)

df_new = copy(df);

#let         # set the loop into a global scope


println("Initial investment: ",investment);
println("With BUY and HODL you have: ",df.Price[end]*investment/df.Price[1]);
println(" ");
sleep(3);

# loop over the different short/long window combinations
heat_map = loop_portfolios(df,investment,longs,shorts);

# plot the heatmap
heatmap(shorts, longs, heat_map,title="best price heat map",xlabel="short",ylabel="long");

max_heatmap = findmax(heat_map);

best_portfolio = max_heatmap[1];
best_short = shorts[max_heatmap[2][2]];
best_long = longs[max_heatmap[2][1]];


println("\nbest portfolio is: ",best_portfolio);
println("best short window is: ",best_short);
println("best long window is: ",best_long);

#end     # end let


