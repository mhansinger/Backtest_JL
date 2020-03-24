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
mypath = "./XETHZEUR_Series.csv";

println(mypath);

investment = 1000.0;

df = get_dataframe(mypath);

# only for test
#df = df[20000:end,:];

#@time df = backtest_engine(df,investment,10000,1000,0.0026);
#Signals = get_crossovers(df.Price)

# plot(df.Portfolio/df.Portfolio[1],label="Portfolio")
# plot!(df.Price/df.Price[1],label="Price")


longs=collect(1000:50:7000);
shorts = collect(100:20:600);

longs=convert(Array{Int64}, longs)

#df_new = copy(df);

#let         # set the loop into a global scope

# println("Length of the time series: ", length(df));
# println("");
println("Initial investment: ",investment);
println("With BUY and HODL you have: ",df.Price[end]*investment/df.Price[1]);
println(" ");
sleep(3);

# # loop over the different short/long window combinations
# @time heat_map = loop_portfolios(df,investment,longs,shorts);

println(" ");
println("##########################################################");
println(" ");
@time heat_map_t = loop_portfolios_threads(df,investment,longs,shorts);


# max_heatmap = findmax(heat_map);

# best_portfolio = max_heatmap[1];
# best_short = shorts[max_heatmap[2][2]];
# best_long = longs[max_heatmap[2][1]];

# println("\nbest portfolio is: ",best_portfolio);
# println("best short window is: ",best_short);
# println("best long window is: ",best_long);


max_heatmap_t = findmax(heat_map_t);

best_portfolio_t = max_heatmap_t[1];
best_short_t = shorts[max_heatmap_t[2][2]];
best_long_t = longs[max_heatmap_t[2][1]];

println("\nbest portfolio parallel is: ",best_portfolio_t);
println("best short window is: ",best_short_t);
println("best long window is: ",best_long_t);

#end     # end let

# # # plot the heatmap
# display(heatmap(shorts, longs, heat_map,title="best price heat map",xlabel="short",ylabel="long"))

# plot the heatmap
display(heatmap(shorts, longs, heat_map_t,title="best price heat map parallel",xlabel="short",ylabel="long"))

