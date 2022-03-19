-module(nova_admin_utils).
-export([
         to_json/1
        ]).


to_json([Hd|Tl]) ->
    [to_json(Hd)|to_json(Tl)];
to_json(Tuple) when is_tuple(Tuple) ->
    to_json(erlang:tuple_to_list(Tuple));
to_json(Map) when is_map(Map) ->
    %% What should we do here? Nothing?
    maps:map(fun(Key, Value) ->
                     to_json(Value)
             end, Map);
to_json(Pid) when is_pid(Pid) ->
    erlang:list_to_binary(erlang:pid_to_list(Pid));
to_json(Port) when is_port(Port) ->
    erlang:list_to_binary(erlang:port_to_list(Port));
to_json(Ref) when is_reference(Ref) ->
    erlang:list_to_binary(erlang:ref_to_list(Ref));
to_json(Element) ->
    Element.
