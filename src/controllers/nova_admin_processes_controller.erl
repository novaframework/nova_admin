-module(nova_admin_processes_controller).

-export([index/1, show/1]).

index(Req) ->
    nova_admin_helpers:render_view(nova_admin_processes_view, #{req => Req}).

show(#{bindings := #{<<"pid">> := PidBin}}) ->
    nova_admin_helpers:render_view(nova_admin_process_detail_view, #{pid_bin => PidBin}).
