function newdat=mergedata2(d1,d2)
% MERGEDATA - Function to merge datasets d1, and d2 with unrepeated labels.
% d1 and d2 are matrices where labels are in the first
% column and d1 and d2 can be of different size. Empty entries are padded
% with "0".

% Returns newdat, merged matrix.
e=0.01; %error (in mergedata the times must match exactly to 15 decimals.  Here they must be the same to 0.001 which is several fractions of a second.)
newdat=[d1,zeros(length(d1(:,1)),length(d2(1,2:end)))]; %initialize new matrix with zeros
[m,n]=size(newdat); %get dimensions of new matrix
for i=1:length(d2(:,1)) %loop through data to merge
indx=find(abs(newdat(:,1)-d2(i,1))<=e); %find existing dates/labels
if indx
newdat(indx,[n-length(d2(i,2:end))+1:n])=d2(i,2:end); %if label is matched update the row-
else
newdat(m+1,[n-length(d2(i,2:end))+1:n])=d2(i,2:end); %if the label is new, create new row
newdat(m+1,1)=d2(i,1); %insert new label in first column
m = m+1; %update the dimension of the new matrix
end
end
newdat=sortrows(newdat); %sort the new matrix

