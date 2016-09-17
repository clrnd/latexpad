"use strict";


let $share = $('#share-link');
let $output = $('#output');

/* Editor Stuff */
let update = _.debounce(function(){
    $share.empty();

    $output.empty();
    $output.html(editor.exportFile(null, 'html'));

    MathJax.Hub.Queue(['Typeset', MathJax.Hub, output[0]]);
}, 800, { 'leading': false, 'trailing': true });

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

/* Store Stuff */
loadHash();

function loadHash(){
    if (window.location.hash !== '') {
        let sid = window.location.hash.slice(1);
        $.getJSON('/api/load/' + sid).done((data) =>
            editor.importFile(null, data.snippetContent))
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

    // post to get hash, and set it as History
    let data = {'snippetContent': editor.exportFile()};
    $.ajax({
        url: '/api/save',
        type: 'POST',
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: 'json',
    }).done((sid) => {
        window.location.hash = sid.snippetId;
        $share.html(`<a class="share" href="${window.location}">
                         Saved! Share using this link.</a>`);
    }).fail((err) => {
        console.log(err);
    }).always(() => $btn.button('reset'));
});
