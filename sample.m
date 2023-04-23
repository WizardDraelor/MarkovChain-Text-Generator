function sampleWord = sample(transitionDict, prev_words)

probability = rand;
cumulative_prob = 0;
key = keys(transitionDict);
valuePairs = values(transitionDict);


% Sampling from initial_words assumes there is no previous word
if nargin < 2

    for word = 1:numEntries(transitionDict)
        cumulative_prob = cumulative_prob + valuePairs(word);
        if probability < cumulative_prob
            sampleWord = key(word, 1);
            break; 
        end
    end


    % If we are sampling from dictionaries other than initial_words
else
    %if valueType == "struct"
    next_word_list = transitionDict(prev_words).words; 
    [~, length_list] = size(transitionDict(prev_words).words);
    for word = 1:length_list
        %disp(valuePairs(word).frequency);
        next_word_freq = transitionDict(prev_words).frequency;
        cumulative_prob = cumulative_prob + next_word_freq(1, word);
        if probability < cumulative_prob
            sampleWord = next_word_list(1, word);
            break;
        end
    end

end

end