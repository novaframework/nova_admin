-module(nova_admin_processes_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(_MountArg, _Req) ->
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    Processes = lists:filtermap(fun(Pid) ->
        case erlang:process_info(Pid, [registered_name, initial_call, memory, message_queue_len, reductions, status]) of
            undefined ->
                false;
            Info ->
                Name = case proplists:get_value(registered_name, Info) of
                    [] -> <<>>;
                    N -> atom_to_binary(N)
                end,
                {M, F, A} = proplists:get_value(initial_call, Info),
                {true, #{
                    pid => nova_admin_helpers:pid_to_bin(Pid),
                    name => Name,
                    initial_call => iolist_to_binary(io_lib:format("~s:~s/~B", [M, F, A])),
                    memory => nova_admin_helpers:format_bytes(proplists:get_value(memory, Info)),
                    msg_queue => integer_to_binary(proplists:get_value(message_queue_len, Info)),
                    reductions => integer_to_binary(proplists:get_value(reductions, Info)),
                    status => atom_to_binary(proplists:get_value(status, Info))
                }}
        end
    end, erlang:processes()),
    Bindings = #{
        id => ~"processes",
        prefix => list_to_binary(Prefix),
        processes => Processes,
        count => integer_to_binary(length(Processes))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    Prefix = arizona_template:get_binding(prefix, Bindings),
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <h1>Processes ({arizona_template:get_binding(count, Bindings)})</h1>
        <table>
            <thead>
                <tr>
                    <th>PID</th>
                    <th>Name / Initial Call</th>
                    <th>Memory</th>
                    <th>MsgQ</th>
                    <th>Reductions</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                {arizona_template:render_list(fun(P) ->
                    PidBin = maps:get(pid, P),
                    PidEncoded = binary:replace(binary:replace(PidBin, <<"<">>, <<"">>), <<">">>, <<"">>),
                    arizona_template:from_html(~"""
                    <tr>
                        <td><a href="{arizona_html:to_html(<<Prefix/binary, "/processes/", PidEncoded/binary>>)}">{arizona_html:to_html(PidBin)}</a></td>
                        <td>
                            {case maps:get(name, P) of
                                <<>> -> arizona_html:to_html(maps:get(initial_call, P));
                                Name -> arizona_html:to_html(Name)
                            end}
                        </td>
                        <td>{arizona_html:to_html(maps:get(memory, P))}</td>
                        <td>{arizona_html:to_html(maps:get(msg_queue, P))}</td>
                        <td>{arizona_html:to_html(maps:get(reductions, P))}</td>
                        <td><span class="{case maps:get(status, P) of
                            <<"waiting">> -> ~"badge badge-green";
                            <<"running">> -> ~"badge badge-blue";
                            <<"suspended">> -> ~"badge badge-yellow";
                            _ -> ~"badge"
                        end}">{arizona_html:to_html(maps:get(status, P))}</span></td>
                    </tr>
                    """)
                end, arizona_template:get_binding(processes, Bindings))}
            </tbody>
        </table>
    </div>
    """").
