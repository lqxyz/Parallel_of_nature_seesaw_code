% This routine finds the breakpoint in the WAIS Divide d18O AIM composite
% using a fit of two polynomials.
%
% [t_break fit_curve] = WDC_breakpoint(t, WDstack, breakvec, minormax, fitorder)
%
% t vector HAS to be -1200:1200;
% WDstack is the stack/composite of the individual events.
% breakvec is a vector of potential t_break values that are investigated
% minormax has values 'min' or 'max'; for NH cooling or warming, respectively
% polynomials are of order 'fitorder'
%
% This function is specifically written for the WDC d18O stacks, and use
% for other purposes is discouraged. One should use the routine BREAKFIT instead.

function [t_break, fit_curve] = WDC_breakpoint(t,WDstack, breakvec,fitorder)

solutions = zeros(length(breakvec),length(t));
RMSD = zeros(size(breakvec));
breakpoints = zeros(size(breakvec));
% the 'mode' parameter is only for quality control purposes
mode = zeros(size(breakvec));

% the routine will not work outside these limits
breakvec = max(min(breakvec,500),-200);

fitorder = min(fitorder,2); % should not be more than 2nd order polynomials

for i = 1:length(breakvec);

    % fit a polynomial to both sides of the break
    dummy = (201:1201)+breakvec(i);
    p1 = polyfit(t(dummy),WDstack(dummy),fitorder);
    dummy = breakvec(i)+(1201:1901);
    p2 = polyfit(t(dummy),WDstack(dummy),fitorder);

    % Find the intercept of the polynomial curves.
    dummy = roots(p1-p2);
    pv1 = polyval(p1,t);
    pv2 = polyval(p2,t);

    % in hypothetical case the solution is not a real number
    if ~isreal(dummy);
        % use linear fit instead:
        % warning('No intercept found; 1st order fit used instead')
        [breakpoints(i), solutions(i,:)] = WDC_breakpoint(t,WDstack, breakvec(i),1);
        mode(i) = 1;
    else

        % Normal case: there is only 1 intercept in time interval
        if sum((dummy>t(1))&(dummy<t(2401)))==1
            % find the intercept that is inside the time interval
            dummy2 = dummy((dummy>t(1))&(dummy<t(2401)));
            % and combine the solutions to a single fitting curve
            solutions(i,t<=dummy2) = pv1(t<=dummy2);
            solutions(i,t>dummy2) = pv2(t>dummy2);
            % the breakpoint equals the intercept.
            breakpoints(i) = dummy2;
            mode(i) = 2;


            % Alternative case: there are 2 intercepts in time interval
        else
            % solutions at the edges are known:
            solutions(i,t<=min(dummy)) = pv1(t<=min(dummy));
            solutions(i,t>max(dummy)) = pv2(t>max(dummy));

            % use intercept closest to breakvec(i)
            [~,dummy2] = min(abs(dummy-breakvec(i)));
            breakpoints(i) = dummy(dummy2);
            mode(i) = 3;


            % inbetween the two breakpoints we use the solution with the best fit:
            dummy = (t>min(dummy))&(t<=max(dummy));
            if sum(abs(pv1(dummy)-WDstack(dummy)))<sum(abs(pv2(dummy)-WDstack(dummy)))
                solutions(i,dummy) = pv1(dummy);
            else
                solutions(i,dummy) = pv2(dummy);
            end

        end

    end

    % Determine the RMSD for the solution

    RMSD(i) = sqrt(mean((WDstack(601:1901)-solutions(i,601:1901)).^2));
end

RMSD = RMSD + 1*((abs(breakvec-breakpoints))>50); % penalize solutions that place the breakpoint too far from the breakvec

[~, dummy2] = min(RMSD);

fit_curve = solutions(dummy2,:);
t_break = breakpoints(dummy2);
