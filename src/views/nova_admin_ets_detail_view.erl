-module(nova_admin_ets_detail_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(#{table := TableBin}, _Req) ->
    TableAtom = binary_to_existing_atom(TableBin),
    Info = ets:info(TableAtom),
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    Rows = try
        ets:tab2list(TableAtom)
    catch
        _:_ -> []
    end,
    RowsBin = lists:map(fun(Row) ->
        #{value => nova_admin_helpers:term_to_bin(Row)}
    end, lists:sublist(Rows, 100)),
    Bindings = #{
        id => ~"ets-detail",
        prefix => list_to_binary(Prefix),
        name => TableBin,
        type => atom_to_binary(proplists:get_value(type, Info)),
        size => integer_to_binary(proplists:get_value(size, Info)),
        memory => nova_admin_helpers:format_bytes(proplists:get_value(memory, Info) * erlang:system_info(wordsize)),
        owner => nova_admin_helpers:pid_to_bin(proplists:get_value(owner, Info)),
        protection => atom_to_binary(proplists:get_value(protection, Info)),
        rows => RowsBin,
        showing => integer_to_binary(length(RowsBin)),
        total => integer_to_binary(proplists:get_value(size, Info))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    Prefix = arizona_template:get_binding(prefix, Bindings),
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <p><a href="{arizona_html:to_html(<<Prefix/binary, "/ets">>)}">← Back to ETS tables</a></p>
        <h1>ETS: {arizona_template:get_binding(name, Bindings)}</h1>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Type</div>
                <div class="stat-value">{arizona_template:get_binding(type, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Size</div>
                <div class="stat-value">{arizona_template:get_binding(size, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Memory</div>
                <div class="stat-value">{arizona_template:get_binding(memory, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Protection</div>
                <div class="stat-value">{arizona_template:get_binding(protection, Bindings)}</div>
            </div>
        </div>

        <div class="card">
            <h2>Entries (showing {arizona_template:get_binding(showing, Bindings)} of {arizona_template:get_binding(total, Bindings)})</h2>
            <table>
                <thead>
                    <tr><th>Value</th></tr>
                </thead>
                <tbody>
                    {arizona_template:render_list(fun(R) ->
                        arizona_template:from_html(~"""
                        <tr><td><code style="word-break: break-all;">{arizona_html:to_html(maps:get(value, R))}</code></td></tr>
                        """)
                    end, arizona_template:get_binding(rows, Bindings))}
                </tbody>
            </table>
        </div>
    </div>
    """").
