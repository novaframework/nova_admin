-module(nova_admin_main_controller).
-export([
         index/1,
         route_table/1
        ]).

-include_lib("routing_tree/include/routing_tree.hrl").


index(_Req) ->
    SysInfo = observer_backend:sys_info(),
    Uptime = observer_lib:to_str({time_ms, proplists:get_value(uptime, SysInfo)}),
    {ok, [{sys_info, SysInfo}, {uptime, Uptime}]}.


route_table(_Req) ->
    #host_tree{hosts = Hosts} = persistent_term:get(nova_dispatch),
    [Routes|_] = lists:map(fun({Host, #routing_tree{tree = Tree}}) ->
                                   #{"text" => to_string(Host), "children" => flatten_routes(Tree)}
                           end, Hosts),
    logger:info("Routes: ~p", [Routes]),
    {ok, [{routes, thoas:encode(Routes)}], #{view => nova_admin_routes}}.


flatten_routes([]) -> [];
flatten_routes([#node{segment = <<>>}|Tl]) -> flatten_routes(Tl);
flatten_routes([#node{segment = Segment, value = Values, children = Children, is_binding = IsBinding, is_wildcard = IsWildcard}|Tl]) ->
    HTMLClass = case IsWildcard of
                    true ->
                        <<"wildcard">>;
                    _ ->
                        case IsBinding of
                            true ->
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
    case Values of
        [] ->
            [#{"HTMLclass" => HTMLClass, "text" => #{"route" => to_string(Segment)}, "children" => flatten_routes(Children)}|flatten_routes(Tl)];
        _Values ->
            [#{"HTMLclass" => HTMLClass, "text" => #{"route" => to_string(Segment)}, "children" => flatten_routes(Children)}|flatten_routes(Tl)]
    end.


to_string('_') -> <<"/">>;
to_string(S) when is_list(S) -> S;
to_string(I) when is_integer(I) ->
    SCode = erlang:integer_to_binary(I),
    << <<"StatusCode: ">>/binary,
       SCode/binary >>;
to_string(B) -> B.
