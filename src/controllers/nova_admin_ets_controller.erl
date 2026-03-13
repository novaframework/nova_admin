-module(nova_admin_ets_controller).

-export([index/1, show/1]).

index(Req) ->
    nova_admin_helpers:render_view(nova_admin_ets_view, #{req => Req}).

show(#{bindings := #{<<"table">> := TableBin}}) ->
    nova_admin_helpers:render_view(nova_admin_ets_detail_view, #{table => TableBin}).
