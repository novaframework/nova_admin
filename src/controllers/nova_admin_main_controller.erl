-module(nova_admin_main_controller).
-export([
         index/1,
         route_table/1
        ]).

-include_lib("routing_tree/include/routing_tree.hrl").
-include_lib("nova/include/nova_router.hrl").

index(_Req) ->
    SysInfo = observer_backend:sys_info(),
    Uptime = observer_lib:to_str({time_ms, proplists:get_value(uptime, SysInfo)}),
    {ok, [{sys_info, SysInfo}, {uptime, Uptime}]}.


route_table(_Req) ->
    #host_tree{hosts = Hosts} = persistent_term:get(nova_dispatch),
    [Routes|_] = lists:map(fun({Host, #routing_tree{tree = Tree}}) ->
                                   #{"text" => to_string(Host), "children" => flatten_routes(Tree, <<"">>)}
                           end, Hosts),
    logger:info("Routes: ~p", [Routes]),
    {ok, [{routes, thoas:encode(Routes)}], #{view => nova_admin_routes}}.


flatten_routes([], _) -> [];
flatten_routes([#node{segment = <<>>}|Tl], Prefix) -> flatten_routes(Tl, Prefix);
flatten_routes([#node{segment = Segment, value = Values, children = Children, is_binding = IsBinding, is_wildcard = IsWildcard}|Tl], Prefix) ->
    HTMLClass = case IsWildcard of
                    true ->
                        <<"wildcard">>;
                    _ ->
                        case IsBinding of
                            true ->
                                logger:info("Children: ~p", [Children]),
                                <<"binding">>;
                            _ ->
                                case Values of
                                    [] ->
                                        <<"">>;
                                    _ ->
                                        <<"endpoint">>
                                end
                        end
                end,

    Methods = lists:foldl(fun(#node_comp{comparator = Comparator, value = #nova_handler_value{module = Module,
                                                                                            function = Function,
                                                                                            secure = Secure,
                                                                                            app = App}}, Ack) ->
                                  [#{<<"method">> => to_string(Comparator),
                                     <<"module">> => to_string(Module),
                                     <<"function">> => to_string(Function),
                                     <<"secure">> => Secure,
                                     <<"app">> => to_string(App)}|Ack];
                             (_, Ack) -> Ack
                          end, [], Values),
    MethodsEncoded = thoas:encode(Methods),

    Segment0 = to_string(Segment),
    logger:info("Segment: ~p", [Segment0]),
    logger:info("Prefix: ~p", [Prefix]),
    FullPath = << Prefix/binary, <<"/">>/binary, Segment0/binary >>,
    case Values of
        [] ->
            [#{"HTMLclass" => HTMLClass, "text" => #{"route" => to_string(Segment), "data-path" => FullPath }, "children" => flatten_routes(Children, FullPath)}|flatten_routes(Tl, Prefix)];
        _Values ->
            [#{"HTMLclass" => HTMLClass, "text" => #{"route" => to_string(Segment), "data-methods" => MethodsEncoded, "data-path" => FullPath}, "children" => flatten_routes(Children, FullPath)}|flatten_routes(Tl, Prefix)]
    end.


to_string('_') -> <<"ALL">>;
to_string(S) when is_list(S) -> erlang:list_to_binary(S);
to_string(I) when is_integer(I) ->
    SCode = erlang:integer_to_binary(I),
    << <<"StatusCode: ">>/binary,
       SCode/binary >>;
to_string(A) when is_atom(A) -> erlang:atom_to_binary(A, utf8);
to_string(B) -> B.
