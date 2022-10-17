function month = month_lkup(month_num)
% Returns abbreviation of month for inputted number
lkup = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
month = lkup(month_num,:);
end
