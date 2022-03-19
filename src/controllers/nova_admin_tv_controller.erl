-module(nova_admin_tv_controller).
-export([
         index/1
        ]).


index(_Req) ->
    Tables = [ maps:from_list(X) || X <- observer_backend:get_table_list(ets, [{sys_hidden, true}, {unread_hidden, true}]) ],
    Tables0 = lists:map(fun(A = #{id := Id, owner := Owner}) ->
                                Id0 = maybe_convert_id(Id),
                                A#{owner => erlang:pid_to_list(Owner), id => Id0}
                        end, Tables),
    {ok, [{tables, Tables0}]}.


maybe_convert_id(ignore) ->
    "";
maybe_convert_id(Ref) ->
    erlang:ref_to_list(Ref).
