-module(nova_admin_router).
-behaviour(nova_router).

-export([routes/1]).

routes(_Environment) ->
    Prefix = application:get_env(nova_admin, prefix, "/admin"),
    [
        #{
            prefix => Prefix,
            security => false,
            routes => [
                {"/assets/css/admin.css", fun nova_admin_css_controller:index/1, #{
                    methods => [get]
                }},
                {"/", fun nova_admin_dashboard_controller:index/1, #{methods => [get]}},
                {"/processes", fun nova_admin_processes_controller:index/1, #{methods => [get]}},
                {"/processes/:pid", fun nova_admin_processes_controller:show/1, #{methods => [get]}},
                {"/ets", fun nova_admin_ets_controller:index/1, #{methods => [get]}},
                {"/ets/:table", fun nova_admin_ets_controller:show/1, #{methods => [get]}},
                {"/ports", fun nova_admin_ports_controller:index/1, #{methods => [get]}},
                {"/applications", fun nova_admin_applications_controller:index/1, #{
                    methods => [get]
                }},
                {"/applications/:app", fun nova_admin_applications_controller:show/1, #{
                    methods => [get]
                }},
                {"/routes", fun nova_admin_routes_controller:index/1, #{methods => [get]}}
            ]
        }
    ].
