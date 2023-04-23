function probabilityStruct = transitionDict(list_states)
% Takes a list of future words the previous word can go to.
% returns a structure with the probabilities normalized of each word
[~, list_length] = size(list_states);
[uniqueWords, ~, index] = unique(list_states, 'stable');
frequency = accumarray(index, ones(size(index)));
probabilityStruct.words = uniqueWords; 
probabilityStruct.frequency = frequency' / list_length; 

end