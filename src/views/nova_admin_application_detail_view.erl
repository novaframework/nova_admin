-module(nova_admin_application_detail_view).
-behaviour(arizona_view).
-compile({parse_transform, arizona_parse_transform}).

-export([mount/2, render/1]).

mount(#{app := AppBin}, _Req) ->
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    AppAtom = binary_to_existing_atom(AppBin),
    {ok, Keys} = application:get_all_key(AppAtom),
    Desc = list_to_binary(proplists:get_value(description, Keys, "")),
    Vsn = list_to_binary(proplists:get_value(vsn, Keys, "")),
    Modules = [#{name => atom_to_binary(M)} || M <- proplists:get_value(modules, Keys, [])],
    Deps = [#{name => atom_to_binary(D)} || D <- proplists:get_value(applications, Keys, [])],
    SupTree = case application_controller:get_master(AppAtom) of
        undefined -> [];
        Master ->
            case application_master:get_child(Master) of
                {Pid, _} when is_pid(Pid) -> flatten_sup_tree(Pid, 0);
                _ -> []
            end
    end,
    Bindings = #{
        id => ~"app-detail",
        prefix => list_to_binary(Prefix),
        name => AppBin,
        description => Desc,
        version => Vsn,
        modules => Modules,
        module_count => integer_to_binary(length(Modules)),
        deps => Deps,
        dep_count => integer_to_binary(length(Deps)),
        sup_tree => SupTree
    },
    arizona_view:new(?MODULE, Bindings,
        {nova_admin_layout, render, inner_content, #{}}).

render(Bindings) ->
    Prefix = arizona_template:get_binding(prefix, Bindings),
    arizona_template:from_html(~"""""
    <div id="{arizona_template:get_binding(id, Bindings)}">
        <p><a href="{arizona_html:to_html(<<Prefix/binary, "/applications">>)}">← Back to applications</a></p>
        <h1>{arizona_template:get_binding(name, Bindings)}</h1>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Version</div>
                <div class="stat-value">{arizona_template:get_binding(version, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Modules</div>
                <div class="stat-value">{arizona_template:get_binding(module_count, Bindings)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Dependencies</div>
                <div class="stat-value">{arizona_template:get_binding(dep_count, Bindings)}</div>
            </div>
        </div>

        <div class="card">
            <h2>Description</h2>
            <p>{arizona_template:get_binding(description, Bindings)}</p>
        </div>

        <div class="card">
            <h2>Supervision Tree</h2>
            {arizona_template:render_list(fun(Node) ->
                arizona_template:from_html(~""""
                <div style="margin-left: {arizona_html:to_html(maps:get(indent, Node))}px; padding: 0.3rem 0;">
                    <span class="{maps:get(type_class, Node)}">{arizona_html:to_html(maps:get(type_label, Node))}</span>
                    <code>{arizona_html:to_html(maps:get(name, Node))}</code>
                    <span style="color: #94a3b8;">{arizona_html:to_html(maps:get(pid, Node))}</span>
                </div>
                """")
            end, arizona_template:get_binding(sup_tree, Bindings))}
        </div>

        <div class="card">
            <h2>Dependencies</h2>
            {arizona_template:render_list(fun(Dep) ->
                arizona_template:from_html(~""""
                <a href="{arizona_html:to_html(<<Prefix/binary, "/applications/", (maps:get(name, Dep))/binary>>)}"><span class="badge badge-blue" style="margin: 0.2rem;">{arizona_html:to_html(maps:get(name, Dep))}</span></a>
                """")
            end, arizona_template:get_binding(deps, Bindings))}
        </div>

        <div class="card">
            <h2>Modules</h2>
            {arizona_template:render_list(fun(Mod) ->
                arizona_template:from_html(~""""
                <span class="badge badge-green" style="margin: 0.2rem;">{arizona_html:to_html(maps:get(name, Mod))}</span>
                """")
            end, arizona_template:get_binding(modules, Bindings))}
        </div>
    </div>
    """"").

flatten_sup_tree(Pid, Depth) ->
    try
        case supervisor:which_children(Pid) of
            Children when is_list(Children) ->
                lists:flatmap(fun({Id, ChildPid, Type, _Mods}) ->
                    case ChildPid of
                        undefined -> [];
                        _ ->
                            Name = case Id of
                                N when is_atom(N) -> atom_to_binary(N);
                                _ -> nova_admin_helpers:term_to_bin(Id)
                            end,
                            TypeClass = case Type of
                                supervisor -> ~"badge badge-yellow";
                                _ -> ~"badge badge-green"
                            end,
                            Node = #{
                                name => Name,
                                pid => nova_admin_helpers:pid_to_bin(ChildPid),
                                type_label => atom_to_binary(Type),
                                type_class => TypeClass,
                                indent => integer_to_binary(Depth * 24)
                            },
                            SubChildren = case Type of
                                supervisor -> flatten_sup_tree(ChildPid, Depth + 1);
                                _ -> []
                            end,
                            [Node | SubChildren]
                    end
                end, Children);
            _ ->
                []
        end
    catch
        _:_ -> []
    end.
