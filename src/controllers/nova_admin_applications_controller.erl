-module(nova_admin_applications_controller).

-export([index/1, show/1]).

index(Req) ->
    nova_admin_helpers:render_view(nova_admin_applications_view, #{req => Req}).

show(#{bindings := #{<<"app">> := AppBin}}) ->
    nova_admin_helpers:render_view(nova_admin_application_detail_view, #{app => AppBin}).
