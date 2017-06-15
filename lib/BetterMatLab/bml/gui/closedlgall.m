function closedlgall
% Close all figures and dialog boxes.

delete(findobj(findall(groot), 'Type', 'Figure'));