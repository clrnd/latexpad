"use strict"

let Preview = {
    delay: 500,        // delay after keystroke before updating
    preview: null,     // filled in by Init below
    buffer: null,      // filled in by Init below
    editor: null,      // filled in by caller
    timeout: null,     // store setTimout id
    mjRunning: false,  // true when MathJax is processing
    mjPending: false,  // true when a typeset has been queued
    oldText: null,     // used to check if an update is needed
    //
    //  Get the preview and buffer DIV's
    //
    Init: function (editor) {
        this.preview = document.getElementById("math-preview");
        this.buffer = document.getElementById("math-buffer");
        this.editor = editor;
    },
    //
    //  Switch the buffer and preview, and display the right one.
    //  (We use visibility:hidden rather than display:none since
    //  the results of running MathJax are more accurate that way.)
    //
    SwapBuffers: function () {
        let buffer = this.preview;
        let preview = this.buffer;

        this.buffer = buffer;
        buffer.style.visibility = "hidden";
        buffer.style.position = "absolute";

        this.preview = preview;
        preview.style.position = "";
        preview.style.visibility = "";
    },
    //
    //  This gets called when a key is pressed in the textarea.
    //  We check if there is already a pending update and clear it if so.
    //  Then set up an update to occur after a small delay (so if more keys
    //    are pressed, the update won't occur until after there has been
    //    a pause in the typing).
    //  The callback function is set up below, after the Preview object is set up.
    //
    Update: function () {
        if (this.timeout) {clearTimeout(this.timeout)}
        this.timeout = setTimeout(this.callback, this.delay);
    },
    //
    //  Creates the preview and runs MathJax on it.
    //  If MathJax is already trying to render the code, return
    //  If the text hasn't changed, return
    //  Otherwise, indicate that MathJax is running, and start the
    //    typesetting.  After it is done, call PreviewDone.
    //
    CreatePreview: function () {
        this.timeout = null;

        if (this.mjPending) return;

        let text = this.editor.exportFile();
        if (text === this.oldtext) return;

        if (this.mjRunning) {
            this.mjPending = true;
            MathJax.Hub.Queue(["CreatePreview", this]);
        } else {
            this.buffer.innerHTML = this.Escape(text);
            this.oldtext = text;
            this.mjRunning = true;
            MathJax.Hub.Queue(
                ["Typeset", MathJax.Hub, this.buffer],
                ["PreviewDone", this]
            );
        }
    },
    //
    //  Indicate that MathJax is no longer running,
    //  and swap the buffers to show the results.
    //
    PreviewDone: function () {
        this.mjRunning = this.mjPending = false;
        let tmp = this.buffer.innerHTML.replace(/^&gt;/mg, '>');
        this.buffer.innerHTML = marked(tmp);
        this.SwapBuffers();
    },

    Escape: function (html, encode) {
        return html
            .replace(!encode ? /&(?!#?\w+;)/g : /&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    },
};
//
//  Cache a callback to the CreatePreview action
//
Preview.callback = MathJax.Callback(["CreatePreview", Preview]);
Preview.callback.autoReset = true; // make sure it can run more than once
