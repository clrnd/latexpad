// "use strict";

/* Editor Stuff */
var editor;
var filename = "scratch";

function setup() {
  editor = new EpicEditor({
    container: $("#input")[0],
    basePath: "epiceditor-0.2.2",
    clientSideStorage: false,
    button: false
  }).load();
  editor.on("update", update);
  editor.open(filename);
  if (editor.exportFile().trim() == "") {
    reset();
  }
  update();
}

function update() {
  var output = $("#output");
  output.empty();
  output.html(editor.exportFile(null, 'html'));
  MathJax.Hub.Queue(["Typeset", MathJax.Hub, output[0]]);
}

function reset() {
  var proforma = $("#proforma");
  editor.importFile(filename, proforma[0].value);
}

setup();

/* Store Stuff */
loadHash();

function loadHash(){
    if (window.location.hash !== '') {
        //$.getJSON('/get', 
        //editor.importFile
    }
}

let clipboard = new Clipboard('#copy', { text: () => window.location.href });

$('[data-toggle="tooltip"]').tooltip();

$(window).on('popstate', function(ev){
    console.log(ev);
});

$('body').on('click', '#save', function(ev){
    // show tooltip
    $(ev.target).tooltip('show');
    setTimeout(() => {
        $(ev.target).tooltip('hide');
    }, 1000);

    // post to get hash, and set it as History
    let data = {'snippetContent': editor.exportFile()};
    $.ajax({
        url: '/save',
        type: 'POST',
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: 'json',
    }).done(saveDone).error(saveError);
});

function saveDone(sid){
    // set hash
    window.location.hash = sid.snippetId;

    // enable copy
    $('#copy').attr('disabled', false)
}

function saveError(err){
    console.log(err);
}
