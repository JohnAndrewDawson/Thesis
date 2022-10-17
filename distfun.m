function d = distfun(XI,XJ)
% Calculates great circle distance called by other functions
        a = sind((XI(1)-XJ(:,1))/2).^2 + cosd(XI(1)).*cosd(XJ(:,1)).*sind((XI(2)-XJ(:,2))/2).^2;
        d = 6371.009*2*atan2(sqrt(a), sqrt(1-a));
end