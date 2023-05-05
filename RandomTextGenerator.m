% Text comes from Shakespeare's Macbeth ACT 1, scene 5 and ACT 3, scene 1

clc
clear

% Reads lines of training_data.txt in column vector
sentences = readlines("training_data.txt", "EmptyLineRule", "skip");

% Next we need to remove punctuation from each line and lowercase each word
[lines, ~] = size(sentences);
for line = 1:lines
    sentences(line, 1) = replace(sentences(line, 1), "-", " ");
    sentences(line, 1) = erasePunctuation(sentences(line, 1));
    sentences(line, 1) = lower(sentences(line, 1));
end



% Defines probability matrices of first word, second word,
% and subsequent word pairs
initial_words = dictionary(string([]), [],  string([]), []);
second_word = dictionary(string([]), string([]));
transition = dictionary(string([]), string([]));

% After, we must tokenize each word pair and add to their respective
% dictionary
for line = 1:lines
    % Creates a list of token from each line
    token_sentence = string(sentences(line, 1));
    token_list = strsplit(token_sentence, " ");
    token_list = cellstr(token_list);

    % Return size of token_list
    [~, len_list] = size(token_list);
    for word=1:len_list
        token = token_list{word};

        % Populates initial_words dictionary with distribution of first
        % words. First word will be treated in initial distribution
        keyExists = isKey(initial_words, token);
        if ~keyExists && word == 1
            initial_words(token) = 0;
            newValue = initial_words(token);
            initial_words(token) = newValue +1;
        elseif keyExists && word == 1
            currentValue = initial_words(token);
            initial_words(token) =  currentValue + 1;
        else
            previous_token = token_list{word-1};

            % if at second element create 1st-order markov chain with
            % previous and current word
            secondKeyPair = previous_token + " " + token;


            if word == len_list - 1
                transition(secondKeyPair) = 'END';
            end

            if word == 2
                % Check if chain exists
                keyExists = isKey(second_word, previous_token);

                if ~keyExists
                    second_word(previous_token) = {token};
                else

                    val = second_word(previous_token);
                    if val ~= "END"
                        val = val + ' ' + token;
                        second_word(previous_token) = val;
                    end


                end

            else
                % Form a 2nd order markov chain with remainder of words

                % word that came 2 words previously
                second_previous_token = token_list{word-2};
                keyPair = second_previous_token + " " + previous_token;
                keyExists = isKey(transition, keyPair);

                if ~keyExists
                    transition(keyPair) = "";
                    transition(keyPair) = token;

                else
                    val = transition(keyPair);
                    if val ~= "END"
                        val = val + ' ' + token;
                        transition(keyPair) = val;
                    end


                end

            end


        end


    end



end


% With all of the markov chains calculated we now need to find the
% probability distributions

% Initial word probability distribution dictionary
sumInitial = sum(values(initial_words));
key = keys(initial_words);
initial_words(key) = initial_words(key) / sumInitial;


% Goal: populate the probability of a state change occuring and mark it in
% the column of the current state

% Creates a dictionary of transition probabilities for second words
probability2Dict = dictionary;
prev_word = keys(second_word);
valuePairs = values(second_word);
for key = 1:numEntries(second_word)
    % Extract possible words that can follow previous word
    next_word_list = strsplit(valuePairs(key,1));
    probability2Dict(prev_word(key,1)) = transitionDict(next_word_list);
end


% Creates a dictionary of transition probabilities for remaining words of
% second order Markov Chain.
probabilityTransitionDict = dictionary;
prev_word = keys(transition);
valuePairs = values(transition);
for key = 1:numEntries(transition)
    % Extract possible words that can follow previous word
    next_word_list = strsplit(valuePairs(key,1));
    probabilityTransitionDict(prev_word(key,1)) = transitionDict(next_word_list);
    %disp(probabilityTransitionDict(prev_word(key,1)));

end



% Generate text!
num_sentences = input("Enter number of sentences you want to generate: ");

for index = 1:num_sentences
    sentence = "";
    word1 = sample(initial_words);
    sentence = append(sentence, word1);
    word2 = sample(probability2Dict, sentence);
    sentence = append(sentence, " ", word2);

    % Append subsequent words to end
    while true
        prev_words = append(word1, " ", word2);
        word3 = sample(probabilityTransitionDict, prev_words);
        if word3 == "END"
            break
        end
        sentence = append(sentence, " ", word3);
        % Move words up to next two previous states
        word1 = word2;
        word2 = word3;
    end

    fprintf('%s', sentence);
    fprintf('\n')

end
