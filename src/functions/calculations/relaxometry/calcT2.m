%% Magnetic Resonance Imaging T2 Relaxometry Calculator
% Calculation of T2 in MR imaging using exponential decay:
%
% $$ S(TE)=S_{0}~\textup{e}^{-TE/T2} $$
%
%% Important notice on nomenclature 
% This function is implemented on the basis of a mathematical 
% equation. The coding convention is PEP8 (Python convention)
% with slight modifications to facilitate the understanding of
% mathematical arguments. As such, the notation |ABC__X| has
% been employed, where |ABC| is the name of the variables, and
% |__X| represents the variable name in the mathematical equation.
%
%% Requirements 
% This function requires |stylishPlot.m| to be available in order to plot the
% graph. 
%
%% Inputs
% |echo_time__TE| must be a vector of the echo times (TE), of type |single| or 
% |double|.
%
% |mr_signal__S| must be a vector of the magnetic resonance signals (S), of type
% |single| or |double|. 
%
%% Outputs
% |response|, which is an object of the class |struct|, containing:
% 
% |response.T2_value| which is the estimated T2 value.
%
% |response.S0_value| which is the calculated S0 value. 
%
% |response.fit_equation| which contains the equation for the line of best fit. 
% 
% |response.plot_handle| which is the handle to the graph.
%
%
%% Calculations
% Calculating $\textup{ln}(signal)$.
%
%       log_mr_signal__S = single(log(mr_signal__S));
%
%%
% Storing the size of the data (applies to both signal and time). 
%
%       echo_time_size = uint8(size(echo_time__TE));
%
%% 
% For $n$ measurements of the MR signal $[S_{1} \dots S_{n}]$ , corresponding
% to an $n$ number of $TE$ values $[TE_{1} \dots TE_{n}]$ , it work out as:
% 
% $$ 
% \left[ \matrix {  
%    \textup{ln}(S_{1})     \cr
%    \vdots                 \cr
%    \textup{ln}(S_{n})     \cr
% }  \right]  
% =
% \left[ \matrix {  
%    1        &   TE_{n}    \cr
%    \vdots   &   \vdots    \cr
%    1        &   TE_{nn}   \cr
% }  \right] 
% \left[ \matrix {  
%    \textup{ln}(S_{0})     \cr
%    -1/T_{2}               \cr
% }  \right] 
% $$
%
% therefore:
%
% $$
% \left[ \matrix {  
%    1        &   TE_{n}    \cr
%    \vdots   &   \vdots    \cr
%    1        &   TE_{n}    \cr
% }  \right] 
% $$
%
%       matrix__TE = single([ones(echo_time_size); echo_time__TE]);
%
%%
% As $y=XA$; therefore 
%
% $$ 
% \left[ \matrix {  
%        \textup{ln}(S_{0})     \cr
%        -1/T_{2}               \cr
% }  \right] 
% = \frac{\textup{ln}(S)}{
% \left[ \matrix {  
%        1        &   TE_{n}    \cr
%        \vdots   &   \vdots    \cr
%        1        &   TE_{n}    \cr
% }  \right] 
% } $$
%
%       matrix__S0__T2 = single(log_mr_signal__S / matrix__TE);
%
%% Initial signal intesity, $S_{0}$:
%
%       init_signal__S0 = exp(matrix__S0__T2(INDEX__S0));
%
%% Regression
% Calculating the line of best fit.
% Only takes objects of the class |double| as an input.
%
%       [x_data__T, y_data__S] = prepareCurveData(double([0 echo_time__TE]), ...
%                                                 double([init_signal__S0 mr_signal__S])...
%                                                );
%

function [ response ] = calcT2( echo_time__TE, mr_signal__S, varargin )
%CALCT2 Calculates the MR T2 Relaxometry value, and plots the data.
%       The function takes two vectors, and calculates the T2 relaxometry 
%       value by estimating T2, and subsequently S0 by calculating the 
%       exponential decay. 
%
%       Note: Precision of this function is limited to type |single| 
%             capacity, even if the input vectors are passed as |double|. 
%
%  
%   REQUIRES: |stylishPlot.m|
%
%   INPUT
%   =======================================================================
%   echo_time__TE  Vector of the echo times (TE), of type |single| or 
%                  |double|.
%
%   mr_signal__S   Vector of the magnetic resonance signals (S), of type
%                  |single| or |double|. 
%
%   plotit         
%
%
%   RETURN
%   =======================================================================
%   response       Object of the class |struct|, containing:
%                     |response.T2_value|     estimated T2 value.
%                     |response.S0_value|     calculated S0 value. 
%                     |response.fit_equation| equation for the line of best fit. 
%                     |response.plot_handle|  handle to the graph.
%
%
%==========================================================================
% author            Pouria Hadjibagheri
% last modified     5 Jan 2015
% matlab version    MATLAB R2015b
% Licence           GPLv2.0
% Coding convention PEP8: https://www.python.org/dev/peps/pep-0008/
%==========================================================================
%      

    min_args = uint8(2);            % Min args in.
    max_args = uint8(4);            % Max args in.
    narginchk(min_args, max_args);  % Check number of args in. 

    %% Constants
    % These are held in the memory for as long as the programme is open. This is 
    % for added efficiency upon repeat calculations and optimisation.

    persistent INDEX__S0;           % Matrix index for S0.
    persistent INDEX__T2;           % Matrix index for T2.
    persistent TIME_INIT;           % Initial time = 0.
    persistent TIME_FINAL;          % Maximum time displayed in the graph. 
    persistent MIN_SIGNAL;          % Minimum signal; signal is always >= 0.
    persistent MAX_SIGNAL_DISPLAY;  % Maximum signal displayed in the graph. 

    % If these conditions apply to one constant, they apply to all of them.
    % If either condition is true, the constants need to be initiated. 
    if isempty(INDEX__S0)

        INDEX__S0          = uint8(1);               
        INDEX__T2          = uint8(2);               
        TIME_INIT          = uint8(0);               
        TIME_FINAL         = uint8(150);            
        MIN_SIGNAL         = single(0);              
        MAX_SIGNAL_DISPLAY = uint16(1500);  

    end
        
    varargs_total = length(varargin);
    if varargs_total == 1 && isa(varargin{1}, 'logical')
        plotit = varargin{1};
    elseif varargs_total == 1 && isa(varargin{1}, 'char')
        mode = varargin{1};
    elseif varargs_total == 2
        for var=varargin
            if isa(var{:}, 'char')
                mode = var{:};
            elseif isa(var{:}, 'logical')
                plotit = var{:};
            else
                error('Invalid input to function |calcT2|.')
            end
        end
    elseif varargs_total == 0
        % Default values
        plotit = true;
        mode = 'lsq';
    else
        error('Invalid input to function |calcT2|.')
    end

    if strcmp(mode, 'calc') && plotit
        warning('\nPlots are not generated for the |calc| mode.\n')
        plotit = false;
    end
    
    
    %% Testing the inputs
    % Asserting the validity of the inputs by testing their types. All inputs 
    % must be vectors, and objects of the class |signle| or the class |double|. 
    try

        assert(isa(echo_time__TE, 'single') || ...
            isa(echo_time__TE, 'double'),      ...
            class(echo_time__TE));

        assert(isa(mr_signal__S , 'single') || ...
            isa(mr_signal__S , 'double'),      ...
            class(mr_signal__S));

    catch exception

        error(sprintf(['\n> Type Error\n\n'...
                 'Invalid input. The function expects two inputs as '...
                 'vectors, both of which must be of type |single| or '  ...
                 '|double|.\nInstead, got arguments of type:\n %s\n%s'], ...
                 exception.identifier, exception.message)); %#ok<SPERR>         

    end
    
    
    %% 
    % Preparing data for ploting.
  
    [x_data__T, y_data__S] = prepareCurveData(...
                                                double(echo_time__TE),...
                                                double(mr_signal__S) ...
                                              );
    % Check the mode of estimation? 
    switch mode
        
        case 'lin'   % Linear fit.
            
            %%
            % Setting up the |fittype| and its options.
            polyfit_y__s = polyfit(x_data__T, y_data__S,2);
            fit_axis_x   = 1:double(max(x_data__T));
            fit_y__s     = polyval(polyfit_y__s,fit_axis_x);
            
            T2__S           = polyval(polyfit_y__s, (max(echo_time__TE)/2));
            init_signal__S0 = polyval(polyfit_y__s, 0);
            T2_time         = T2__S/log(init_signal__S0);

            if plotit
                % Plotting a styled graph. 
                stylishPlot(x_data__T, y_data__S, ...
                            fit_axis_x, fit_y__s, ...
                            T2_time, 'Linear fit');

                % Plot axes limits. 

                current_plot      = gca;                              % Taking the current graph.
                current_plot.YLim = [MIN_SIGNAL MAX_SIGNAL_DISPLAY];  % Y-axis.
                current_plot.XLim = [TIME_INIT TIME_FINAL];           % X-axis.
            
            %% Output
            %
            % Return args. See the intro for more info. 
            response = struct('mode',    'Linear fit',      ...
                              'T2_value', T2_time,          ...
                              'S0_value', init_signal__S0);
            else 
                
                response = [T2_value, init_signal__S0];
                return
                
            end % plotit


            return
            
        case 'calc' % Through the exponential decay calculation.

            log_mr_signal__S = single(log(mr_signal__S));
            echo_time_size   = uint8(size(echo_time__TE));
            matrix__TE       = single([                         ...
                                          ones(echo_time_size); ...
                                          echo_time__TE         ...
                                      ]);
                            
            matrix__S0__T2         = single(log_mr_signal__S / matrix__TE);
            init_signal__S0        = exp(matrix__S0__T2(INDEX__S0));

            %% Calculation by exponential decay
            % Intrinsic %T2% value based on the application of the equation of 
            % exponential decay over matrices. 
            intrinsic__T2 = single(-1/matrix__S0__T2(INDEX__T2));
            %% Output
            %
            % Return args. See the intro for more info. 
            response = struct('mode',     'Calculation',    ...
                              'T2_value', intrinsic__T2,    ...
                              'S0_value', init_signal__S0);

            return
            
        case 'lsq'      % Least square curve fit: Default.

            %% Exponential fit
            % Calculating a line of best fit through a non-linear least squares 
            % method. 
            %
            % $$
            % f(x) = a \times{x_{1},\textup{e}^{\times{(x_{2}, time)}}}
            % $$
            curve_func = @(x,xdata)x(1)*exp(x(2)*xdata);

            curve_x0   = [double(max(x_data__T)), -1];

            %% Least square curve fit
            
            options = optimset('Display','off');
            fitted_curve = lsqcurvefit(curve_func, ...
                                       curve_x0,   ...
                                       x_data__T,  ...
                                       y_data__S,  ...
                                       [],[], options);

            fit_x_vals   = linspace(0, echo_time__TE(end));
            fit_y_vals   = curve_func(fitted_curve, fit_x_vals);

            T2__S           = curve_func(fitted_curve, (max(echo_time__TE)/2));
            init_signal__S0 = curve_func(fitted_curve, 0);
            T2_time         = T2__S/log(init_signal__S0);
            
            if plotit
                % Plotting a styled graph. 
                stylishPlot(x_data__T,  y_data__S,   ...
                            fit_x_vals, fit_y_vals,  ...
                            T2_time, 'Least square curve fit');

                % Plot axes limits. 
                current_plot      = gca;                              % Taking the current graph.
                current_plot.YLim = [MIN_SIGNAL MAX_SIGNAL_DISPLAY];  % Y-axis.
                current_plot.XLim = [TIME_INIT TIME_FINAL];           % X-axis.
                
                %% Output
                %
                % Return args. See the intro for more info. 
                response = struct('mode',     'Least square curve fit',   ...
                                  'T2_value',  T2_time,                   ...
                                  'S0_value',  init_signal__S0);
                
            else 
                
                response = [T2_time, init_signal__S0];
                return
                
            end % plotit
            
            
             
            return

            
    end  % switch
                

              
end  % function.

