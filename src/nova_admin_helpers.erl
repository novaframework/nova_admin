-module(nova_admin_helpers).

-export([
    render_view/2,
    format_bytes/1,
    format_uptime/1,
    pid_to_bin/1,
    port_to_bin/1,
    term_to_bin/1
]).

render_view(ViewModule, MountArg) ->
    ArizonaReq = arizona_request:new(arizona_cowboy_request, undefined, #{
        method => <<"GET">>,
        path => <<"/">>
    }),
    View = ViewModule:mount(MountArg, ArizonaReq),
    {Html, _View} = arizona_renderer:render_layout(View),
    {status, 200, #{<<"content-type">> => <<"text/html; charset=utf-8">>}, iolist_to_binary(Html)}.

format_bytes(Bytes) when Bytes < 1024 ->
    iolist_to_binary([integer_to_binary(Bytes), " B"]);
format_bytes(Bytes) when Bytes < 1024 * 1024 ->
    iolist_to_binary(io_lib:format("~.1f KB", [Bytes / 1024]));
format_bytes(Bytes) when Bytes < 1024 * 1024 * 1024 ->
    iolist_to_binary(io_lib:format("~.1f MB", [Bytes / (1024 * 1024)]));
format_bytes(Bytes) ->
    iolist_to_binary(io_lib:format("~.1f GB", [Bytes / (1024 * 1024 * 1024)])).

format_uptime(MilliSeconds) ->
    Seconds = MilliSeconds div 1000,
    Days = Seconds div 86400,
    Hours = (Seconds rem 86400) div 3600,
    Minutes = (Seconds rem 3600) div 60,
    Secs = Seconds rem 60,
    iolist_to_binary(
        io_lib:format(
            "~Bd ~2..0Bh ~2..0Bm ~2..0Bs",
            [Days, Hours, Minutes, Secs]
        )
    ).

pid_to_bin(Pid) when is_pid(Pid) ->
    list_to_binary(pid_to_list(Pid)).

port_to_bin(Port) when is_port(Port) ->
    list_to_binary(erlang:port_to_list(Port)).

term_to_bin(Term) ->
    iolist_to_binary(io_lib:format("~p", [Term])).
