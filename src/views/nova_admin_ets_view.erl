-module(nova_admin_ets_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(_MountArg, _Req) ->
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    Tables = lists:filtermap(fun(Tab) ->
        try
            Info = ets:info(Tab),
            case Info of
                undefined ->
                    false;
                _ ->
                    Name = proplists:get_value(name, Info),
                    {true, #{
                        name => atom_to_binary(Name),
                        id => nova_admin_helpers:term_to_bin(proplists:get_value(id, Info)),
                        type => atom_to_binary(proplists:get_value(type, Info)),
                        size => integer_to_binary(proplists:get_value(size, Info)),
                        memory => nova_admin_helpers:format_bytes(proplists:get_value(memory, Info) * erlang:system_info(wordsize)),
                        owner => nova_admin_helpers:pid_to_bin(proplists:get_value(owner, Info)),
                        protection => atom_to_binary(proplists:get_value(protection, Info))
                    }}
            end
        catch
            _:_ -> false
        end
    end, ets:all()),
    Bindings = #{
        id => ~"ets",
        prefix => list_to_binary(Prefix),
        tables => Tables,
        count => integer_to_binary(length(Tables))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    Prefix = arizona_template:get_binding(prefix, Bindings),
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <h1>ETS Tables ({arizona_template:get_binding(count, Bindings)})</h1>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Size</th>
                    <th>Memory</th>
                    <th>Owner</th>
                    <th>Protection</th>
                </tr>
            </thead>
            <tbody>
                {arizona_template:render_list(fun(T) ->
                    TabName = maps:get(name, T),
                    arizona_template:from_html(~"""
                    <tr>
                        <td><a href="{arizona_html:to_html(<<Prefix/binary, "/ets/", TabName/binary>>)}">{arizona_html:to_html(TabName)}</a></td>
                        <td><span class="badge badge-blue">{arizona_html:to_html(maps:get(type, T))}</span></td>
                        <td>{arizona_html:to_html(maps:get(size, T))}</td>
                        <td>{arizona_html:to_html(maps:get(memory, T))}</td>
                        <td><code>{arizona_html:to_html(maps:get(owner, T))}</code></td>
                        <td>{arizona_html:to_html(maps:get(protection, T))}</td>
                    </tr>
                    """)
                end, arizona_template:get_binding(tables, Bindings))}
            </tbody>
        </table>
    </div>
    """").
