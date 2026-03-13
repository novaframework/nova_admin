-module(nova_admin_ports_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(_MountArg, _Req) ->
    Ports = lists:filtermap(fun(Port) ->
        try
            Info = erlang:port_info(Port),
            case Info of
                undefined ->
                    false;
                _ ->
                    {true, #{
                        port => nova_admin_helpers:port_to_bin(Port),
                        name => list_to_binary(proplists:get_value(name, Info, "")),
                        connected => nova_admin_helpers:pid_to_bin(proplists:get_value(connected, Info)),
                        input => nova_admin_helpers:format_bytes(proplists:get_value(input, Info, 0)),
                        output => nova_admin_helpers:format_bytes(proplists:get_value(output, Info, 0))
                    }}
            end
        catch
            _:_ -> false
        end
    end, erlang:ports()),
    Bindings = #{
        id => ~"ports",
        ports => Ports,
        count => integer_to_binary(length(Ports))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <h1>Ports ({arizona_template:get_binding(count, Bindings)})</h1>
        <table>
            <thead>
                <tr>
                    <th>Port</th>
                    <th>Name</th>
                    <th>Connected</th>
                    <th>Input</th>
                    <th>Output</th>
                </tr>
            </thead>
            <tbody>
                {arizona_template:render_list(fun(P) ->
                    arizona_template:from_html(~"""
                    <tr>
                        <td><code>{arizona_html:to_html(maps:get(port, P))}</code></td>
                        <td>{arizona_html:to_html(maps:get(name, P))}</td>
                        <td><code>{arizona_html:to_html(maps:get(connected, P))}</code></td>
                        <td>{arizona_html:to_html(maps:get(input, P))}</td>
                        <td>{arizona_html:to_html(maps:get(output, P))}</td>
                    </tr>
                    """)
                end, arizona_template:get_binding(ports, Bindings))}
            </tbody>
        </table>
    </div>
    """").
