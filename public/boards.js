function update() {
    $('.dynamic').each(function(){
        url="view/"+this.id.replace("_","/");
        $(this).load(url)});
}
function displayBoard(id) {
    $('#main').load("view/board/"+id)
}
    

$(function() {
    $("input[type=submit], button" ).livequery(function(){$(this).button()});
    // $('button#create_board').on("click",function() {
    //     $.post('boards/create_empty');
    //     update()});
    $('button#reload').on("click",update);
    $('#boards_list')
        .on("click",".board-selector",function(e) {displayBoard(e.target.dataset.boardId)})
        // .on("click","#create_board",function() {$.post('boards/create_empty'); update()})
        .on("click","button.trash",function(e) {$.post('delete/board/'+e.target.dataset.boardId);
                                                update()})
    ;
    $('button.trash').livequery(function(){
        $(this).button({icons: { primary: "ui-icon-trash"}, text: false})});
    $('button#create_board').livequery(function(){
        $(this).button({icons: { primary: "ui-icon-plusthick"}, text: false})
            .click(function(){$.post('boards/create_empty'); update()})});
    update();
});
