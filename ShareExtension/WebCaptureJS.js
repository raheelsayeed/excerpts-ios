var WebCaptureJavaScriptClass = function() {};

WebCaptureJavaScriptClass.prototype = {

run: function(arguments) {
    arguments.completionFunction({"URL": document.URL, "title": document.title, "selection": window.getSelection().toString()});
},
    
    // Note that the finalize function is only available in iOS.
finalize: function(arguments) {
    // arguments contains the value the extension provides in [NSExtensionContext completeRequestReturningItems:completion:].
    // In this example, the extension provides a color as a returning item.
    document.body.style.backgroundColor = arguments["bgColor"];
}
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new WebCaptureJavaScriptClass;