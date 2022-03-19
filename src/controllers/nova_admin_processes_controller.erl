-module(nova_admin_processes_controller).
-export([
         index/1,
         process_info/1
        ]).


index(_Req) ->
    Processes = [ maps:put(pid, erlang:pid_to_list(Pid), maps:from_list(erlang:process_info(Pid))) || Pid <- erlang:processes()],
    {ok, [{procs, Processes}]}.


process_info(#{bindings := #{<<"pid">> := Pid}}) ->
    Pid0 = uri_string:percent_decode(Pid),
    Pid1 = erlang:binary_to_list(Pid0),
    Pid2 = erlang:list_to_pid(Pid1),

    ProcInfo = erlang:process_info(Pid2),
    MapInfo = maps:from_list(ProcInfo),
    logger:info("Pid: ~p", [MapInfo]),

    {json, nova_admin_utils:to_json(MapInfo)}.
