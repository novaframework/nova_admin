-module(nova_admin_dashboard_controller).

-export([index/1]).

index(Req) ->
    nova_admin_helpers:render_view(nova_admin_dashboard_view, #{req => Req}).
