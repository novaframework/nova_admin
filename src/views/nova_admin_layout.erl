-module(nova_admin_layout).
-compile({parse_transform, arizona_parse_transform}).

-export([render/1]).

render(Bindings) ->
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    PrefixBin = list_to_binary(Prefix),
    arizona_template:from_html(~"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Nova Admin</title>
        <link rel="stylesheet" href="{arizona_html:to_html(<<PrefixBin/binary, "/assets/css/admin.css">>)}" />
    </head>
    <body>
        <div class="admin-container">
            <nav class="sidebar">
                <div class="sidebar-title">Nova Admin</div>
                <a href="{arizona_html:to_html(PrefixBin)}">Dashboard</a>
                <a href="{arizona_html:to_html(<<PrefixBin/binary, "/processes">>)}">Processes</a>
                <a href="{arizona_html:to_html(<<PrefixBin/binary, "/ets">>)}">ETS Tables</a>
                <a href="{arizona_html:to_html(<<PrefixBin/binary, "/ports">>)}">Ports</a>
                <a href="{arizona_html:to_html(<<PrefixBin/binary, "/applications">>)}">Applications</a>
                <a href="{arizona_html:to_html(<<PrefixBin/binary, "/routes">>)}">Routes</a>
                <div class="node-info">
                    Node: {arizona_html:to_html(atom_to_binary(node()))}
                </div>
            </nav>
            <main class="main-content">
                {arizona_template:render_slot(arizona_template:get_binding(inner_content, Bindings))}
            </main>
        </div>
    </body>
    </html>
    """).
