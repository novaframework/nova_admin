-module(nova_admin_dashboard_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(_MountArg, _Req) ->
    Memory = erlang:memory(),
    {Uptime, _} = erlang:statistics(wall_clock),
    SchedulerCount = erlang:system_info(schedulers),
    SchedulerOnline = erlang:system_info(schedulers_online),
    ProcessCount = erlang:system_info(process_count),
    ProcessLimit = erlang:system_info(process_limit),
    PortCount = erlang:system_info(port_count),
    PortLimit = erlang:system_info(port_limit),
    EtsCount = length(ets:all()),
    EtsLimit = erlang:system_info(ets_limit),
    AtomCount = erlang:system_info(atom_count),
    AtomLimit = erlang:system_info(atom_limit),

    Bindings = #{
        id => ~"dashboard",
        otp_release => list_to_binary(erlang:system_info(otp_release)),
        erts_version => list_to_binary(erlang:system_info(version)),
        node_name => atom_to_binary(node()),
        uptime => nova_admin_helpers:format_uptime(Uptime),
        total_memory => nova_admin_helpers:format_bytes(proplists:get_value(total, Memory)),
        process_memory => nova_admin_helpers:format_bytes(proplists:get_value(processes_used, Memory)),
        ets_memory => nova_admin_helpers:format_bytes(proplists:get_value(ets, Memory)),
        binary_memory => nova_admin_helpers:format_bytes(proplists:get_value(binary, Memory)),
        atom_memory => nova_admin_helpers:format_bytes(proplists:get_value(atom, Memory)),
        code_memory => nova_admin_helpers:format_bytes(proplists:get_value(code, Memory)),
        system_memory => nova_admin_helpers:format_bytes(proplists:get_value(system, Memory)),
        scheduler_count => integer_to_binary(SchedulerCount),
        scheduler_online => integer_to_binary(SchedulerOnline),
        process_count => integer_to_binary(ProcessCount),
        process_limit => integer_to_binary(ProcessLimit),
        port_count => integer_to_binary(PortCount),
        port_limit => integer_to_binary(PortLimit),
        ets_count => integer_to_binary(EtsCount),
        ets_limit => integer_to_binary(EtsLimit),
        atom_count => integer_to_binary(AtomCount),
        atom_limit => integer_to_binary(AtomLimit)
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    arizona_template:from_html(~"""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <h1>System Dashboard</h1>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">OTP Release</div>
                <div class="stat-value">{arizona_template:get_binding(otp_release, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">ERTS Version</div>
                <div class="stat-value">{arizona_template:get_binding(erts_version, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Uptime</div>
                <div class="stat-value">{arizona_template:get_binding(uptime, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Node</div>
                <div class="stat-value" style="font-size: 0.9rem;">{arizona_template:get_binding(node_name, Bindings)}</div>
            </div>
        </div>

        <h2>Schedulers</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total</div>
                <div class="stat-value">{arizona_template:get_binding(scheduler_count, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Online</div>
                <div class="stat-value">{arizona_template:get_binding(scheduler_online, Bindings)}</div>
            </div>
        </div>

        <h2>Resource Usage</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Processes</div>
                <div class="stat-value">{arizona_template:get_binding(process_count, Bindings)} <span class="stat-label">/ {arizona_template:get_binding(process_limit, Bindings)}</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Ports</div>
                <div class="stat-value">{arizona_template:get_binding(port_count, Bindings)} <span class="stat-label">/ {arizona_template:get_binding(port_limit, Bindings)}</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">ETS Tables</div>
                <div class="stat-value">{arizona_template:get_binding(ets_count, Bindings)} <span class="stat-label">/ {arizona_template:get_binding(ets_limit, Bindings)}</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Atoms</div>
                <div class="stat-value">{arizona_template:get_binding(atom_count, Bindings)} <span class="stat-label">/ {arizona_template:get_binding(atom_limit, Bindings)}</span></div>
            </div>
        </div>

        <h2>Memory</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total</div>
                <div class="stat-value">{arizona_template:get_binding(total_memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Processes</div>
                <div class="stat-value">{arizona_template:get_binding(process_memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">ETS</div>
                <div class="stat-value">{arizona_template:get_binding(ets_memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Binary</div>
                <div class="stat-value">{arizona_template:get_binding(binary_memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Atoms</div>
                <div class="stat-value">{arizona_template:get_binding(atom_memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Code</div>
                <div class="stat-value">{arizona_template:get_binding(code_memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">System</div>
                <div class="stat-value">{arizona_template:get_binding(system_memory, Bindings)}</div>
            </div>
        </div>
    </div>
    """).
