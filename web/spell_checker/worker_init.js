// worker_init.js
window.resultEmitter = new EventTarget();

// Check if Trusted Types are supported and create a Trusted Type Policy
if (window.trustedTypes) {
    window.policy = trustedTypes.createPolicy('default', {
        createScriptURL: (url) => url
    });
}

const workerUrl = 'spell_checker/worker.js';
const trustedWorkerUrl = window.policy ? window.policy.createScriptURL(workerUrl) : workerUrl;

// Create the Web Worker with the trusted URL
const worker = new Worker(trustedWorkerUrl);

worker.onmessage = function (event) {
    const { id, newMistakes, newCheckedWords } = event.data;
    const customEvent = new CustomEvent(`newResult_${id}`, {
        detail: {
            newMistakes,
            newCheckedWords,
        }
    });
    window.resultEmitter.dispatchEvent(customEvent);
};

// Expose postMessage function in Web Worker to Flutter
window.postMessageToFindMistakesWorker = function (id, text, dictionary, checkedWords) {
    worker.postMessage({ id: id, text: text, dictionary: dictionary, checkedWords: checkedWords });
};
