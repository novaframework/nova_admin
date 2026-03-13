-module(nova_admin_applications_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(_MountArg, _Req) ->
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    Apps = lists:map(fun({App, Desc, Vsn}) ->
        #{
            name => atom_to_binary(App),
            description => unicode:characters_to_binary(Desc),
            version => unicode:characters_to_binary(Vsn)
        }
    end, lists:sort(application:which_applications())),
    Bindings = #{
        id => ~"applications",
        prefix => list_to_binary(Prefix),
        apps => Apps,
        count => integer_to_binary(length(Apps))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    Prefix = arizona_template:get_binding(prefix, Bindings),
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <h1>Applications ({arizona_template:get_binding(count, Bindings)})</h1>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Version</th>
                </tr>
            </thead>
            <tbody>
                {arizona_template:render_list(fun(A) ->
                    AppName = maps:get(name, A),
                    arizona_template:from_html(~"""
                    <tr>
                        <td><a href="{arizona_html:to_html(<<Prefix/binary, "/applications/", AppName/binary>>)}">{arizona_html:to_html(AppName)}</a></td>
                        <td>{arizona_html:to_html(maps:get(description, A))}</td>
                        <td><span class="badge badge-blue">{arizona_html:to_html(maps:get(version, A))}</span></td>
                    </tr>
                    """)
                end, arizona_template:get_binding(apps, Bindings))}
            </tbody>
        </table>
    </div>
    """").
