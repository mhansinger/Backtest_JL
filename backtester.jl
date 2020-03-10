# dynamic backtest engine

module backtester

include("./backtest_tools.jl")
using .backtest_tools, DataFrames, Statistics, CSV

export backtest_engine

function backtest_engine(df_in::DataFrame, portfolio::Int64,long::Int64,short::Int64,fee::Float64)
    df = df_in;
    df.Portfolio = ones(length(df.Price)) * portfolio;  # set the portfolio vector, initialize with start portfolio
    df.Market_pos = zeros(length(df.Price));  # 0 means we are not in the market, 1 we are in
    df.Shares = zeros(length(df.Price));      # number of shares

    # compute the long and short SMA
    SMA_long = sma(df,long);
    SMA_short = sma(df,short);

    # if positiv we should be in the market!
    SMA_diff = SMA_short - SMA_long; 

    df.Signals = get_crossovers(SMA_diff); 

    # loop over the time series
    for i in 2:length(df.Signals)
        if df.Signals[i] == 1 && df.Market_pos[i-1] == 0
            #println("BUY");
            #BUY: if Signal says yes and we are not in yet
            df.Portfolio[i] = df.Portfolio[i-1]*(1-fee);
            df.Shares[i] = df.Portfolio[i] / df.Price[i];
            
            # update Market_pos
            df.Market_pos[i] = 1; # we are in

        elseif df.Signals[i] == -1 && df.Market_pos[i-1] == 1
            #println("SELL");
            #SELL: if Signal says sell your shares and we're still in
            df.Portfolio[i] = (df.Shares[i-1] * df.Price[i])*(1-fee);
            df.Shares[i] = 0;
            # update Market_pos
            df.Market_pos[i] = 0; # we are out

        elseif df.Signals[i] == 0 && df.Market_pos[i-1] == 0
            # we are not in the Market and stay out: update Portfolio
            df.Portfolio[i] = df.Portfolio[i-1];
            df.Shares[i] = 0;
            df.Market_pos[i] = 0; # we are out
            #println("SHORT");

        elseif df.Signals[i] == 0 && df.Market_pos[i-1] == 1
            # wer are in the Market and stay in
            df.Shares[i] = df.Shares[i-1];
            df.Portfolio[i] = df.Shares[i] * df.Price[i];
            df.Market_pos[i] = 1; # we are in
            #println("LONG");
        end

    end

    return df

end

end

