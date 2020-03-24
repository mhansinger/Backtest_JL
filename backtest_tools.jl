module backtest_tools

#using Missing
using DataFrames, CSV, Gadfly, Statistics


export get_dataframe, sma, ema, get_crossovers, smstd

# reads the data csv file
function get_dataframe(path)
    df = CSV.read(path) 
    rename!(df,[:x,:Date,:Price])
    select!(df, Not(:x)) #delete!(df,:x)
    return df[2:end,:]  #return from 2nd row on
end


function sma(df::DataFrame, window::Int64)
    # sliding moving average
    # return: Array

    X = df.Price[:]
    if window < 1 || length(X) < window
        return X
    end

    Y::Array{Union{Float64},1} = zeros(window-1)#missings(window-1)

    for i in window:length(X)
        push!(Y, mean(X[i-window+1:i]))
    end

    return Y
end

function ema(X, window::Int64)
    if window < 1 || length(X) < window
        return X
    end

    L::Array{Union{Float64},1} = zeros(window-1)
    alpha = 2.0 / (window + 1)

    push!(L, X[window])

    for i in window+1:length(X)
        push!(L, alpha*X[i] + (1-alpha)*L[end])
    end

    return L
end

function get_crossovers(SMA_diff)

    Signals = zeros(length(SMA_diff)); # vector with zeros for BUY and SELL signals

    for i in 2:size(Signals, 1)
        
        # if SMA_diff[i] == missing
        #     continue
        if SMA_diff[i] > 0 && SMA_diff[i-1] < 0
            Signals[i] = 1      # BUY signal: short surpasses long
        elseif SMA_diff[i] < 0 && SMA_diff[i-1] > 0
            Signals[i] = -1     # SELL signal: short goes below long

        end
    end

    return Signals
end

function smstd(df::DataFrame, window::Int64)
    # sliding moving standard deviation
    # return: Array
    
    X = df.Price[:]
    if window < 1 || length(X) < window
        return X
    end

    Y::Array{Union{Float64},1} = zeros(window-1)#missings(window-1)

    for i in window:length(X)
        push!(Y, std(X[i-window+1:i]))
    end

    return Y
end




# function makerunningstd(::Type{T} = Float64) where T
#     ∑x = ∑x² = zero(T)
#     n = 0
#     function runningstd(x)
#         ∑x  += x
#         ∑x² += x ^ 2
#         n   += 1
#         s   = ∑x² / n - (∑x / n) ^ 2
#         return s
#     end
#     return runningstd
# end

end
