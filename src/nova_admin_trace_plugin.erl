-module(nova_admin_trace_plugin).
-behaviour(nova_plugin).

-export([
         pre_request/2,
         post_request/2,
         plugin_info/0
        ]).

pre_request(Req = #{path := Path}, _Options) ->
    case nova_admin_trace_db:get_mark('_', Path) of
        true ->
            Self = self(),
            spawn(fun() -> broadcast_trace(Self, Path, [all]) end);
        _false ->
            ok
    end,
    {ok, Req}.

post_request(Req, _Options) ->
    {ok, Req}.


%%--------------------------------------------------------------------
%% @doc
%% nova_plugin callback. Returns information about the plugin.
%% @end
%%--------------------------------------------------------------------
-spec plugin_info() -> {Title :: binary(), Version :: binary(), Author :: binary(), Description :: binary(),
                       [{Key :: atom(), OptionDescription :: atom()}]}.
plugin_info() ->
    {<<" plugin">>,
     <<"0.0.1">>,
     <<"User <user@email.com">>,
     <<"Descriptive text">>,
     []}.


broadcast_trace(Pid, Path, Pattern) ->
    erlang:trace(Pid, true, Pattern),
    broadcast_trace(Path).

broadcast_trace(Path) ->
    receive
	X ->
            X0 = format_trace(X),
	    nova_pubsub:broadcast(Path, "trace", X0),
	    broadcast_trace(Path)
    end.

format_trace({trace_ts, _Pid, Type, Info, _, Timestamp}) ->
    {{Y,M,D},{ H,MM,SS}} = calendar:now_to_datetime(Timestamp),
    Timestamp0 = lists:flatten(io_lib:format("~B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:~2.10.0B", [Y, M, D,H,MM,SS])),
    Info0 = erlang:list_to_binary(io_lib:format("~p", [Info])),
    #{type => erlang:atom_to_binary(Type),
      info => Info0,
      timestamp => Timestamp0}.
