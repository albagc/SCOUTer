function [Ahat, Asv, Acumsv] = predncomp(S, cumss, svthres, mode, Amax)
arguments
    S double
    cumss (1,1)double = 0.8
    svthres (1,1)double = 1
    mode char = 'manual'
    Amax (1,1)double = size(S,1)
end
disp("Sugested number of PCs:")
[~,ss1] = svd(S);
Asv = sum(diag(ss1) > svthres);
disp(strcat(" - Singular values of covariance matrix > ", string(svthres),...
    " = ", string(Asv)))
Acumsv = sum((cumsum(diag(ss1))/sum(diag(ss1))) < cumss) + 1;
disp(strcat(" - Minimum PCs to reach cummulative variance > ", string(cumss*100),...
    " % = ", string(Acumsv)))

switch mode
    case 'auto'
        Ahat = min([Amax,Acumsv,Asv]);
    case 'manual'
        afig = figure;
        subplot(211), plot(diag(ss1),'o-','HandleVisibility','off'), 
        grid on, hold on, 
        line([Asv + 0.5 Asv + 0.5], [0 max(diag(ss1))],'Color','red','LineStyle','--',...
            'DisplayName',"\sigma > 1")
        legend('location','best'),xlabel('PCs')
        title('Singular values of Covariance matrix'),
        subplot(212), plot(cumsum(diag(ss1))/sum(diag(ss1))*100,'o-'), grid on,
        xlabel('PCs'), ylabel('Variance (%)'),ylim([0,100])
        title('Cummulative variance'),
        Ahat = input("Select the number of PCs: ");
        close(afig)
end

end