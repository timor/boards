function update() {
    $('#sidebar').load("views/sidebar");
}

$(function() {
    $("input[type=submit], button" ).button();
    $('#sidebar').on("click","button#create_board",function(event) {
        $.post('boards/create_empty');
        update()
    });
    update();
});
