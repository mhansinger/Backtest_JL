# dynamic backtest engine

#TODO: 
# include exit factor
# include BOLLINGER Bands

module backtester

include("./backtest_tools.jl")
using .backtest_tools, DataFrames, Statistics, CSV

export backtest_engine, loop_portfolios, loop_portfolios_threads

function backtest_engine(df_in::DataFrame, investment_::Float64,long::Int64,short::Int64)
    df = deepcopy(df_in);           # seemed to solve the probelm
    df.Portfolio = ones(length(df.Price)) * investment_;  # set the portfolio vector, initialize with start portfolio
    df.Market_pos = zeros(length(df.Price));  # 0 means we are not in the market, 1 we are in
    df.Shares = zeros(length(df.Price));      # number of shares

    # Transaction fee is hard coded (does not change usually)
    fee = 0.0026;

    # compute the long and short SMA
    SMA_long = sma(df,long);
    SMA_short = sma(df,short);

    STD_long = smstd(df,long);

    # upper bollinger band
    bollinger_up = SMA_long + STD_long;

    # if positiv we should be in the market!
    SMA_diff = SMA_short - SMA_long; 

    df.Signals = get_crossovers(SMA_diff); 

    # # define exit factor
    # exit_factor = 0;#0.972;
    # println("exit factor ",exit_factor);
    # last_buy = 1000;

    # set this flag to ture if emergency sell has been issued
    #exit_flag = false;

    # loop over the time series
    for i in 2:length(df.Signals)
        if df.Signals[i] == 1 && df.Market_pos[i-1] == 0 #&& (df.Price[i] > bollinger_up[i])#&& exit_flag==false
            #println("BUY");
            #BUY: if Signal says yes and we are not in yet
            df.Portfolio[i] = df.Portfolio[i-1]*(1-fee);
            df.Shares[i] = df.Portfolio[i] / df.Price[i];
            
            # update Market_pos
            df.Market_pos[i] = 1; # we are in

            # last buy price at
            last_buy = df.Price[i];
            #println("Last buy: ",last_buy);

        elseif df.Signals[i] == -1 && df.Market_pos[i-1] == 1
            #println("SELL");
            #SELL: if Signal says sell your shares and we're still in
            df.Portfolio[i] = (df.Shares[i-1] * df.Price[i])*(1-fee);
            df.Shares[i] = 0;
            # update Market_pos
            df.Market_pos[i] = 0; # we are out

        elseif df.Signals[i] == 0 && df.Market_pos[i-1] == 0
            # we are not in the Market, signals say stay out: update Portfolio
            df.Portfolio[i] = df.Portfolio[i-1];
            df.Shares[i] = 0;
            df.Market_pos[i] = 0;   # we are out
            exit_flag = false;      # reset exit flag

            #println("SHORT");

        elseif df.Signals[i] == 0 && df.Market_pos[i-1] == 1
        # we are in the market

            # # emergency sell if the price drops to fast
            # if  last_buy*exit_factor > df.Price[i] 
            #     exit_flag = true;
            #     df.Portfolio[i] = (df.Shares[i-1] * df.Price[i])*(1-fee);
            #     df.Shares[i] = 0;
            #     # update Market_pos
            #     df.Market_pos[i] = 0; # we are out
            #     println("####################");
            #     println("Emergency exit!");
            #     println("####################");
                
            # else
            # we stay in the market
            df.Shares[i] = df.Shares[i-1];
            df.Portfolio[i] = df.Shares[i] * df.Price[i];
            df.Market_pos[i] = 1; # we are in
            #println("LONG");
            #end
        end

    end

    return df

end

# function loop_portfolios(df_in::DataFrame, investment_::Float64,longs_::Array{Int64,1}, shorts_::Array{Int64,1})

#     # store all end_prices to plot a heat map
#     heat_map = zeros((length(longs_), length(shorts_)));

#     for (l_id, l) in enumerate(longs_)
#         for (s_id,s) in enumerate(shorts_)
#             df_new = backtest_engine(df_in,investment_,l,s,0.005);
#             println(df_new.Portfolio[end])
#             heat_map[l_id,s_id] = df_new.Portfolio[end];
#         end
#     end

#     return heat_map

# end

function loop_portfolios(df_in::DataFrame, investment_::Float64,longs_::Array{Int64,1}, shorts_::Array{Int64,1})
    # parallel version of the loop
    # Threads.@threads has problems with enumerate... different formulation!

    # store all end_prices to plot a heat map
    heat_map = zeros((length(longs_), length(shorts_)));

    for l_id in 1:length(longs_)
        for s_id in 1:length(shorts_)

            l = longs_[l_id];
            s = shorts_[s_id];

            df_new = backtest_engine(df_in,investment_,l,s);
            println(df_new.Portfolio[end])
            heat_map[l_id,s_id] = df_new.Portfolio[end];

            if df_new.Portfolio[end] == 0.0
                println("######################");
                println("l_id: ",l_id);
                println("s_id: ",s_id);
                println("l: ",l);
                println("s: ",s);
                println("######################");
            end
        end
    end

    return heat_map

end



function loop_portfolios_threads(df_in::DataFrame, investment_::Float64,longs_::Array{Int64,1}, shorts_::Array{Int64,1})
    # parallel version of the loop
    # Threads.@threads has problems with enumerate... different formulation!

    # store all end_prices to plot a heat map
    heat_map = zeros((length(longs_), length(shorts_)));

    Threads.@threads for l_id in 1:length(longs_)
        Threads.@threads for s_id in 1:length(shorts_)

            l = longs_[l_id];
            s = shorts_[s_id];

            df_new = backtest_engine(df_in,investment_,l,s);
            println(df_new.Portfolio[end])
            heat_map[l_id,s_id] = df_new.Portfolio[end];

            if df_new.Portfolio[end] == 0.0
                println("######################");
                println("l_id: ",l_id);
                println("s_id: ",s_id);
                println("l: ",l);
                println("s: ",s);
                println("######################");
            end
        end
    end

    return heat_map

end

end

