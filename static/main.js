// "use strict";

/* Editor Stuff */
var filename = "scratch";
var editor = setup();

function setup() {
  let editor = new EpicEditor({
    container: $("#input")[0],
    basePath: "epiceditor-0.2.2",
    clientSideStorage: false,
    button: false
  }).load();

  editor.on("update", update);

  return editor;
}

function update() {
  var output = $("#output");
  output.empty();
  output.html(editor.exportFile(null, 'html'));
  MathJax.Hub.Queue(["Typeset", MathJax.Hub, output[0]]);
}

function reset() {
  var proforma = $("#proforma");
  editor.importFile(null, proforma[0].value);
}

/* Store Stuff */
loadHash();

function loadHash(){
    if (window.location.hash !== '') {
        let sid = window.location.hash.slice(1);
        $.getJSON('/load/' + sid).done((data) =>
            editor.importFile(null, data.snippetContent))
    } else {
        reset();
    }
}

let clipboard = new Clipboard('#copy', { text: () => window.location.href })
    .on('success', function(e) {
        $(e.trigger).tooltip('show');
        setTimeout(() => {
            $(e.trigger).tooltip('hide');
        }, 1000);
    });

$('[data-toggle="tooltip"]').tooltip();

$(window).on('popstate', function(ev){
    loadHash();
});

$('#save').on('click', (ev) => {
    // show tooltip
    let $btn = $(ev.target);
    $btn.button('loading');

    // post to get hash, and set it as History
    let data = {'snippetContent': editor.exportFile()};
    $.ajax({
        url: '/save',
        type: 'POST',
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: 'json',
    }).done((sid) => {
        window.location.hash = sid.snippetId;

        $btn.tooltip('show');
        setTimeout(() => {
            $btn.tooltip('hide');
        }, 1000);
    }).fail((err) => {
        console.log(err);
    }).always(() => $btn.button('reset'));
});
