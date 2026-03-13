-module(nova_admin_routes_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(_MountArg, _Req) ->
    Routes = collect_routes(),
    Bindings = #{
        id => ~"routes",
        routes => Routes,
        count => integer_to_binary(length(Routes))
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    arizona_template:from_html(~""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <h1>Routes ({arizona_template:get_binding(count, Bindings)})</h1>
        <table>
            <thead>
                <tr>
                    <th>Method</th>
                    <th>Path</th>
                    <th>Controller</th>
                    <th>Function</th>
                </tr>
            </thead>
            <tbody>
                {arizona_template:render_list(fun(R) ->
                    arizona_template:from_html(~"""
                    <tr>
                        <td><span class="{maps:get(method_class, R)}">{arizona_html:to_html(maps:get(method, R))}</span></td>
                        <td><code>{arizona_html:to_html(maps:get(path, R))}</code></td>
                        <td>{arizona_html:to_html(maps:get(controller, R))}</td>
                        <td>{arizona_html:to_html(maps:get(function, R))}</td>
                    </tr>
                    """)
                end, arizona_template:get_binding(routes, Bindings))}
            </tbody>
        </table>
    </div>
    """").

collect_routes() ->
    CompiledApps = nova_router:compiled_apps(),
    Env = nova:get_environment(),
    lists:flatmap(fun({App, _Prefix}) ->
        Router = list_to_atom(atom_to_list(App) ++ "_router"),
        try
            Routes = Router:routes(Env),
            lists:flatmap(fun(Group) ->
                GroupPrefix = maps:get(prefix, Group, ""),
                GroupRoutes = maps:get(routes, Group, []),
                lists:filtermap(fun(Route) ->
                    try
                        {true, format_route(GroupPrefix, Route, false)}
                    catch
                        _:_ -> false
                    end
                end, GroupRoutes)
            end, Routes)
        catch
            _:_ -> []
        end
    end, CompiledApps).

format_route(Prefix, {Path, _Mod, #{protocol := ws}}, _Security) ->
    format_route_entry(Prefix, Path, <<"(websocket)">>, <<"-">>, <<"WS">>);
format_route(Prefix, {Path, Callback, #{methods := Methods}}, _Security) when is_function(Callback) ->
    {Mod, Fun} = extract_fun_info(Callback),
    MethodBins = [method_to_bin(M) || M <- Methods],
    MethodStr = iolist_to_binary(lists:join(<<", ">>, MethodBins)),
    format_route_entry(Prefix, Path, Mod, Fun, MethodStr);
format_route(Prefix, {Path, Callback, _Opts}, _Security) when is_function(Callback) ->
    {Mod, Fun} = extract_fun_info(Callback),
    format_route_entry(Prefix, Path, Mod, Fun, <<"GET">>);
format_route(Prefix, {Path, Callback}, _Security) when is_function(Callback) ->
    {Mod, Fun} = extract_fun_info(Callback),
    format_route_entry(Prefix, Path, Mod, Fun, <<"GET">>);
format_route(Prefix, {Path, LocalPath}, _Security) when is_list(Path), is_list(LocalPath) ->
    format_route_entry(Prefix, Path, <<"(static)">>, list_to_binary(LocalPath), <<"GET">>);
format_route(Prefix, {Path, LocalPath, _Opts}, _Security) when is_list(Path), is_list(LocalPath) ->
    format_route_entry(Prefix, Path, <<"(static)">>, list_to_binary(LocalPath), <<"GET">>);
format_route(_Prefix, _Route, _Security) ->
    #{
        method => <<"?">>,
        method_class => ~"badge",
        path => <<"unknown">>,
        controller => <<>>,
        function => <<>>
    }.

extract_fun_info(Fun) when is_function(Fun) ->
    Info = erlang:fun_info(Fun),
    Mod = atom_to_binary(proplists:get_value(module, Info)),
    Name = atom_to_binary(proplists:get_value(name, Info)),
    {Mod, Name}.

format_route_entry(Prefix, Path, Controller, Fun, Method) ->
    FullPath = iolist_to_binary([Prefix, Path]),
    #{
        method => Method,
        method_class => method_badge_class(Method),
        path => FullPath,
        controller => Controller,
        function => Fun
    }.

method_to_bin(get) -> <<"GET">>;
method_to_bin(post) -> <<"POST">>;
method_to_bin(put) -> <<"PUT">>;
method_to_bin(delete) -> <<"DELETE">>;
method_to_bin(patch) -> <<"PATCH">>;
method_to_bin(M) when is_atom(M) -> atom_to_binary(M);
method_to_bin(M) when is_binary(M) -> M.

method_badge_class(<<"GET">>) -> ~"badge badge-green";
method_badge_class(<<"POST">>) -> ~"badge badge-blue";
method_badge_class(<<"PUT">>) -> ~"badge badge-yellow";
method_badge_class(<<"DELETE">>) -> ~"badge badge-red";
method_badge_class(<<"PATCH">>) -> ~"badge badge-yellow";
method_badge_class(<<"WS">>) -> ~"badge badge-blue";
method_badge_class(_) -> ~"badge".
