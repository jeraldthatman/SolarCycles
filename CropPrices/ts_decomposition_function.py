from statsmodels.tsa.seasonal import seasonal_decompose
import matplotlib.pyplot as plt

def ts_analysis(timeSeries, n_periods = 252, show_plots = True, title=None):
    "Return time series decomposition for dataframe. Set Show_plots = False to return data"
    assert n_periods < len(timeSeries), "Number of Periods given is greater than the data given "
    # Additive Decomposition
    additive = seasonal_decompose(timeSeries, model='additive', extrapolate_trend='freq',period=n_periods)
    # Multiplicative Decomposition 
    multiplicative = seasonal_decompose(timeSeries, model='multiplicative', extrapolate_trend='freq', period=n_periods)
    if show_plots != True:
        return additive, multiplicative
    else:
        fig, axes = plt.subplots(4,2, figsize = (15,8))
        axes[0,0].plot(additive.observed, color = 'Black')
        axes[1,0].plot(additive.trend, color = 'orange')
        axes[2,0].plot(additive.seasonal, color = 'green')
        axes[3,0].plot(additive.resid, color = 'red')
        axes[0,1].plot(multiplicative.observed, color = 'Black')
        axes[1,1].plot(multiplicative.trend, color = 'orange')
        axes[2,1].plot(multiplicative.seasonal, color = 'green')
        axes[3,1].plot(multiplicative.resid, color = 'red')

        axes[0,0].set_title("Additive")
        axes[1,0].set_title("Trend")
        axes[2,0].set_title("Seasonality")
        axes[3,0].set_title("Residuals")
        axes[0,1].set_title("Multiplicative")
        axes[1,1].set_title("Trend")
        axes[2,1].set_title("Seasonality")
        axes[3,1].set_title("Residuals")
        if title == None: 
            fig.suptitle('Time Series Decomposition')
        else: 
            fig.suptitle(title)
        fig.autofmt_xdate()
        plt.tight_layout()
        plt.show()