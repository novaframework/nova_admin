$(document).ready(function() {
    var traces = 0;
    var ws_conn = null;

    var selected_node = null;

    $('#toggle-info').click(function() {
        $('.node.endpoint, .node.binding').removeClass('selected-node');
        $('#route_info').hide();
    });

    $('.route-info-list').on('click', 'a.source_mod', function(x) {
        var module = $(this).data('module');
        $.get(base_url + '/code/' + module, function(data) {
            $('#code_block').removeData('highlighted');
            $('#code_block').html(data);
            $('#code_block').each(function(i, e) {hljs.highlightBlock(e)});
            $('code.hljs').each(function(i, block) {
                hljs.lineNumbersBlock(block);
            });
            $('#source_modal').modal('show');
        });
    });

    $('.node.endpoint, .node.binding').click(function(x) {
        // Remove highlights of all nodes and add it to this particular node
        $('.node.endpoint, .node.bindning').removeClass('selected-node');
        $(this).addClass('selected-node');

        // Show the info bar
        let methods = $(this).data('methods');
        $('.route-info-list').empty();
        let path = $(this).data('path');

        $.each(methods, function(index, method) {
            $('.route-info-list').append(
                '<b>App:</b> ' + method.app + '<br>' +
                    '<b>Path:</b> ' + path + '<br>' +
                    '<b>Method:</b> <span class="method ' + method.method + '">' + method.method + '</span><br>' +
                    '<b>Module:</b> <a class="source_mod" href="#" data-module="' + method.module + '">' + method.module + '</a><br>' +
                    '<b>Function:</b> <a class="source_mod" href="#" data-module="' + method.module + '">' + method.function + '/1</a><br>'
            );
            if(method.secure !== false) {
                $('.route-info-list').append('<b>Secure:</b> Yes<br>');
            } else {
                $('.route-info-list').append('<b>Secure:</b> No<br>');
            }
            $('.route-info-list').append('<hr />');
        });

        $('#route_info').show();
        selected_node = $(this);
    });

    $('#start-trace').click(function(x) {
        var path = $('#route_info_path').text();

        if(selected_node.toggleClass('striped-node').hasClass('striped-node')) {
            traces++;
            if(traces == 1) {
                $('#tracebar').addClass('folded');
                $('#start-trace').text('Stop Trace');
                // Open websocket
                ws_conn = new WebSocket('ws://' + location.host + base_url + '/trace');
                ws_conn.onopen = function() {
                    ws_conn.send('{"action": "register", "path": "' + path + '"}');
                }
                ws_conn.onmessage = function (evt) {
                    $('#trace-entries').prepend(evt.data);
                }
            }
        } else {
            $('#start-trace').text('Start Trace');
            traces--;
            ws_conn.close();
        }

        if(traces == 0) {
            // We need to close the websocket
            $('#tracebar').removeClass('unfolded').removeClass('folded');
        }
    });

    $('#toggle-trace').click(function(x) {
        $('#tracebar').toggleClass('folded');
        $('#tracebar').toggleClass('unfolded');
    });

} );
