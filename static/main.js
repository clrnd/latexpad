"use strict";

let $msg = $('#message');
let $output = $('#output');
let default_error = "Something went ups";

/* Editor Stuff */
function update(){
    $msg.empty();

    Preview.Update();
}

let editor = new EpicEditor({
        container: $('#input').get(0),
        basePath: 'epiceditor-0.2.2',
        clientSideStorage: false,
        button: false,
        autogrow: true
    })
    .load()
    .on("update", update);

function reset(){
    let proforma = $("#proforma").val();
    editor.importFile(null, proforma);
}

Preview.Init(editor);

/* Store Stuff */

let showError = (err) => $msg.html(`<span class="text-danger">
    Error: ${err.responseText || err.statusText || default_error}</span>`);

function loadHash(){
    if (window.location.hash !== '') {
        let sid = window.location.hash.slice(1);

        NProgress.start();
        $.getJSON(`/api/load/${sid}`)
            .done((data) =>
                editor.importFile(null, data.snippetContent))
            .fail(showError)
            .always(() => NProgress.done());
    } else {
        reset();
    }
}

$(window).on('popstate', function(ev){
    loadHash();
});

$('#save').on('click', (ev) => {
    let $btn = $(ev.target);
    $btn.button('loading');
    $msg.empty();

    // post to get hash, and set it as History
    let data = {'snippetContent': editor.exportFile()};
    NProgress.start();
    $.ajax({
        url: '/api/save',
        type: 'POST',
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: 'json',
    }).done((sid) => {
        history.pushState({}, document.title, '#' + sid.snippetId);
        $msg.html(`<a href="${window.location}">
                         Saved! Share using this link.</a>`);
    }).fail(
        showError
    ).always(() => {
        $btn.button('reset');
        NProgress.done();
    });
});

loadHash();
