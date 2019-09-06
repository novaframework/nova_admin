-module(nova_admin_forms).
-export([
         format/1
        ]).

-include_lib("nova_admin/include/nova_admin.hrl").



format(#paged_table{columns = Columns, rows = Rows, options = Options}) ->
    Variables = [{columns, Columns}, {rows, Rows}],
    {ok, HTML} = paged_table_dtl:render(Variables),
    HTML;
format(#container{title = Title, body = Body, footer = Footer}) ->
    FBody = format(Body),
    [<<"<div class=\"card mb-3\"><div class=\"card-header\"><i class=\"fas fa-table\"></i> ">>,
     Title,
     <<"</div><div class=\"card-body\"><div class=\"table-responsive\">">>,
     FBody,
     <<"</div></div><div class=\"card-footer small text-muted\">">>, Footer, <<"</div></div>">>];
format(#form{method = Method, action = Action, body = Body, options = Options}) ->
    FBody = format(Body),
    [<<"<form method=\"">>, Method, <<"\" action=\"">>, Action, <<"\">">>,
     FBody,
     <<"</form>">>];
format(#button{type = Type, text = Text, class = Class}) ->
    [<<"<button type=\"">>, Type, <<"\" class=\"">>, Class, <<"\">">>, Text, <<"</button>">>];
format(#input{type = Type, name = Name, label = Label, placeholder = Placeholder, value = Value}) ->
    HLabel = case Label of
                 undefined ->
                     <<"">>;
                 L ->
                     [<<"<label>">>, L, <<"</label>">>]
             end,
    [HLabel, <<"<input type=\"">>, Type, <<"\" name=\"">>, Name, <<"\" placeholder=\"">>, Placeholder, <<"\" value=\"">>, Value, <<"\">">>];
format(List) when is_list(List) ->
    [ format(X) || X <- List ];
format(_) ->
    [].
