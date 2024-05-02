-module(nova_admin_trace_controller).
-export([
         set_trace/1,
         remove_trace/1,
         init/1,
         websocket_init/1,
         websocket_handle/2,
         websocket_info/2,
         terminate/3
        ]).


set_trace(Req) ->
    ok.

remove_trace(Req) ->
    ok.


init(Req) ->
    {ok, Req}.

websocket_init(State) ->
    {ok, #{traces => 0}}.

websocket_handle({text, Msg}, State = #{traces := Traces}) ->
    logger:info("Recevied message: ~p", [Msg]),
    {ok, Data} = thoas:decode(Msg),
    logger:info("Decoded message: ~p", [Data]),
    Path = maps:get(<<"path">>, Data),
    case maps:get(<<"action">>, Data, undefined) of
        undefined ->
            logger:info("Invalid message: ~p", [Msg]);
        <<"register">> ->
            %% We are currently only supporting tracing on all methods
            nova_admin_trace_db:set_mark(self(), '_', Path),
            nova_pubsub:join(Path),
            logger:info("Registering trace: ~p", [Data]);
        <<"deregister">> ->
            nova_admin_trace_db:unset_mark(self(), '_', Path),
            nova_pubsub:leave(maps:get(<<"path">>, Data)),
            logger:info("Deregistering trace: ~p", [Data])
    end,
    {ok, State}.

websocket_info({text, Msg}, State) ->
    {ok, State};
websocket_info({nova_pubsub, Path, _From, "trace", Payload}, State) ->
    logger:info("Received trace message: ~p", [Payload]),
    Payload0 = thoas:encode(Payload),
    {reply, {text, Payload0}, State}.

terminate(_Reason, _PartialReq, _State) ->
    ok.
