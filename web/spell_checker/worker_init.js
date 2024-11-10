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
    // // When Web Worker got a return value, send the result to Flutter
    // window.workerResult = event.data;
    // Dispatch an event with the result map
    const result = event.data;
    const customEvent = new CustomEvent('newResult', { detail: result });
    window.resultEmitter.dispatchEvent(customEvent);
    // console.log('Event dispatched with result:', result);
};

// Expose postMessage function in Web Worker to Flutter
window.postMessageToFindMistakesWorker = function (text, dictionary, checkedWords) {
    worker.postMessage({ text: text, dictionary: dictionary, checkedWords: checkedWords });
};
