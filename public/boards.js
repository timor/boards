// takes a jquery object
function updateElt(e) {
    url="view/"+e.id.replace("_","/");
    $.ajax({url: url,
            ifModified: true,
            context: e,
            success: function(data){
                $(this).html(data)}});
};
function updateAll() {
    $('.dynamic').each(function(e){
        updateElt(e)})};
function displayBoard(id) {
    $('#main').load("view/board/"+id)
};

$(function() {
    $(document).ajaxError(function(evt,xhr) {
        $("div.log").append($('<p>',{class: 'error'}).text(xhr.responseText))});
    $("input[type=submit], button" ).livequery(function(){$(this).button()});
    // $('button#create_board').on("click",function() {
    //     $.post('boards/create_empty');
    //     update()});
    $('button#reload').on("click",updateAll);
    $('#boards_list')
    // thanks IE for not supporting dataset!
        .on("click",".board-selector",function(e) {displayBoard(e.target.getAttribute('data-board-id'));return false;})
    // .on("click","#create_board",function() {$.post('boards/create_empty'); update()})
        .on("click","button.trash",function(e) {$.post('delete/board/'+$(e.target).closest('.board')[0].getAttribute('data-id'),{},update)});
//    $('#main')
//        .on("click",".add-card",function(e) {$.post('columns/'+e.target.getAttribute('data-column-id')+'/create_card',{},update)});
    $('button.trash').livequery(function(){
        $(this).button({icons: { primary: "ui-icon-trash"}, text: false})});
    $('button#create_board').livequery(function(){
        $(this).button({icons: { primary: "ui-icon-plusthick"}, text: false})
            .click(function(){$.post('boards/create_empty',{},updateAll)})});
    updateAll();
});
