// JavaScript: Define an EventTarget for streaming results
window.resultEmitter = new EventTarget();

window.postMessageToFindMistakesWorker = async function (text, dictionary, checkedWords) {
    try {
        // Update dictionaryList if a new dictionary is provided
        if (Array.isArray(dictionary) && dictionary.length > 0) {
            window.dictionaryList = dictionary;
        } else if (window.dictionaryList.length === 0) {
            console.warn('Dictionary is empty. Please provide a valid dictionary.');
        }


        // Simulate asynchronous calculation
        // const processedText = await new Promise(resolve => {
        //     setTimeout(() => resolve(`Processed: ${text} with dictionary ${dictionary}`), 5000);
        // });

        // Create a result map that includes the original input values and the processed text
        // const result = {
        //     text: text,
        //     dictionary: dictionary,
        //     checkedWords: checkedWords,
        //     processedText: processedText
        // };
        const result = findMistakes(text, window.dictionaryList, checkedWords);

        // Dispatch an event with the result map
        const event = new CustomEvent('newResult', { detail: result });
        window.resultEmitter.dispatchEvent(event);

    } catch (error) {
        console.error('Error in processing:', error);
    }
};


// Function to calculate Levenshtein distance between two strings
function levenshteinDistance(s, t) {
    s = s.toLowerCase();
    t = t.toLowerCase();
    if (s === t) return 0;
    if (!s.length) return t.length;
    if (!t.length) return s.length;

    const v0 = Array(t.length + 1).fill(0);
    const v1 = Array(t.length + 1).fill(0);

    for (let i = 0; i < v0.length; i++) v0[i] = i;

    for (let i = 0; i < s.length; i++) {
        v1[0] = i + 1;
        for (let j = 0; j < t.length; j++) {
            const cost = s[i] === t[j] ? 0 : 1;
            v1[j + 1] = Math.min(v1[j] + 1, Math.min(v0[j + 1] + 1, v0[j] + cost));
        }
        for (let j = 0; j < v0.length; j++) v0[j] = v1[j];
    }
    return v1[t.length];
}

// Function to find mistakes in text
function findMistakes(text, dictionary, checkedWords) {
    let results = [];
    checkedWords = new Set(checkedWords); // Convert checkedWords to a Set
    let newCheckedWords = new Set(); // Create a new Set to store checked words

    // Split text into sentences based on punctuation
    const sentenceRegex = /[^.!?]+/g;
    const sentences = text.match(sentenceRegex) || [];

    // Loop through sentences
    for (let i = 0; i < sentences.length; i++) {
        let sentence = sentences[i];
        // Match words in each sentence
        const wordRegex = /\b\w+\b/g;
        const wordMatches = [...sentence.matchAll(wordRegex)];

        // Loop through matched words
        for (let j = 0; j < wordMatches.length; j++) {
            const match = wordMatches[j];
            const word = match[0].toLowerCase(); // Convert word to lowercase for case-insensitive comparison

            // Skip last word in last sentence
            if (i === sentences.length - 1 && j === wordMatches.length - 1) continue;

            if (checkedWords.has(word)) continue; // Skip already checked words

            if (!dictionary.includes(word)) {
                // Calculate Levenshtein distance for all suggestions
                const potentialSuggestions = dictionary
                    .map(entry => ({ entry, distance: levenshteinDistance(entry, word) }))
                    .filter(entry => entry.distance <= 2) // Keep suggestions with distance <= 2
                    .sort((a, b) => a.distance - b.distance)
                    .slice(0, 10) // Take top 10 suggestions
                    .map(entry => entry.entry);

                // Add mistake to results
                results.push({
                    offset: text.indexOf(match[0]), // Calculate offset in the original text
                    length: match[0].length,
                    suggestions: potentialSuggestions
                });
            }

            // Add word to newCheckedWords set
            newCheckedWords.add(word);
        }
    }

    return {
        newMistakes: results,
        newCheckedWords: Array.from(newCheckedWords)
    };
}


// // Example usage
// const text = "This is some smple txt for testng the spellcheker.";
// const dictionary = ["this", "is", "some", "sample", "text", "for", "testing", "the", "spellchecker"];
// const checkedWords = new Set(["this", "is"]); // Initialize with some pre-checked words

// const result = findMistakes(text, dictionary, checkedWords);
// console.log(result);
