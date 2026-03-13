-module(nova_admin_routes_controller).

-export([index/1]).

index(Req) ->
    nova_admin_helpers:render_view(nova_admin_routes_view, #{req => Req}).
