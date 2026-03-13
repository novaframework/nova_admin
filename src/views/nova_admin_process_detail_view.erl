-module(nova_admin_process_detail_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(#{pid_bin := PidBin}, _Req) ->
    PidStr = "<" ++ binary_to_list(PidBin) ++ ">",
    Pid = list_to_pid(PidStr),
    Info = erlang:process_info(Pid, [
        registered_name, initial_call, current_function, status,
        message_queue_len, memory, heap_size, stack_size,
        reductions, links, trap_exit
    ]),
    Name = case proplists:get_value(registered_name, Info) of
        [] -> <<"(unnamed)">>;
        N -> atom_to_binary(N)
    end,
    {M, F, A} = proplists:get_value(initial_call, Info),
    {CM, CF, CA} = proplists:get_value(current_function, Info),
    Links = [nova_admin_helpers:pid_to_bin(L) || L <- proplists:get_value(links, Info), is_pid(L)],
    Bindings = #{
        id => ~"process-detail",
        pid => list_to_binary(PidStr),
        name => Name,
        initial_call => iolist_to_binary(io_lib:format("~s:~s/~B", [M, F, A])),
        current_function => iolist_to_binary(io_lib:format("~s:~s/~B", [CM, CF, CA])),
        status => atom_to_binary(proplists:get_value(status, Info)),
        memory => nova_admin_helpers:format_bytes(proplists:get_value(memory, Info)),
        heap_size => integer_to_binary(proplists:get_value(heap_size, Info)),
        stack_size => integer_to_binary(proplists:get_value(stack_size, Info)),
        reductions => integer_to_binary(proplists:get_value(reductions, Info)),
        message_queue_len => integer_to_binary(proplists:get_value(message_queue_len, Info)),
        trap_exit => atom_to_binary(proplists:get_value(trap_exit, Info)),
        links => Links,
        links_count => integer_to_binary(length(Links))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    Prefix = list_to_binary(application:get_env(nova_admin, prefix, "/admin")),
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <p><a href="{arizona_html:to_html(<<Prefix/binary, "/processes">>)}">← Back to processes</a></p>
        <h1>Process {arizona_template:get_binding(pid, Bindings)}</h1>

        <div class="card">
            <h2>Identity</h2>
            <table>
                <tr><th style="width:200px">PID</th><td>{arizona_template:get_binding(pid, Bindings)}</td></tr>
                <tr><th>Name</th><td>{arizona_template:get_binding(name, Bindings)}</td></tr>
                <tr><th>Initial Call</th><td><code>{arizona_template:get_binding(initial_call, Bindings)}</code></td></tr>
                <tr><th>Current Function</th><td><code>{arizona_template:get_binding(current_function, Bindings)}</code></td></tr>
                <tr><th>Status</th><td><span class="badge badge-green">{arizona_template:get_binding(status, Bindings)}</span></td></tr>
                <tr><th>Trap Exit</th><td>{arizona_template:get_binding(trap_exit, Bindings)}</td></tr>
            </table>
        </div>

        <div class="card">
            <h2>Resources</h2>
            <table>
                <tr><th style="width:200px">Memory</th><td>{arizona_template:get_binding(memory, Bindings)}</td></tr>
                <tr><th>Heap Size</th><td>{arizona_template:get_binding(heap_size, Bindings)} words</td></tr>
                <tr><th>Stack Size</th><td>{arizona_template:get_binding(stack_size, Bindings)} words</td></tr>
                <tr><th>Reductions</th><td>{arizona_template:get_binding(reductions, Bindings)}</td></tr>
                <tr><th>Message Queue</th><td>{arizona_template:get_binding(message_queue_len, Bindings)}</td></tr>
            </table>
        </div>

        <div class="card">
            <h2>Links ({arizona_template:get_binding(links_count, Bindings)})</h2>
            {arizona_template:render_list(fun(LinkPid) ->
                arizona_template:from_html(~"""
                <span class="badge badge-blue" style="margin: 0.2rem;">{arizona_html:to_html(LinkPid)}</span>
                """)
            end, arizona_template:get_binding(links, Bindings))}
        </div>
    </div>
    """").
