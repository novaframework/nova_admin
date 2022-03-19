-module(nova_admin_ports_controller).
-export([
         index/1
        ]).


index(_Req) ->
    Ports = [ maps:from_list(X) || X <- observer_backend:get_port_list()],
    Ports0 = lists:map(fun(A = #{port_id := PortId, connected := Connected}) ->
                               A#{port_id => port_to_list(PortId), connected => erlang:pid_to_list(Connected)}
                       end, Ports),
    {ok, [{ports, Ports0}]}.
