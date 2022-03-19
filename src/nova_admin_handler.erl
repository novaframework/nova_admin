-module(nova_admin_handler).
-export([
         debug_toolbar/3
        ]).

debug_toolbar({ok, Variables}, MF, Req) ->
    debug_toolbar({ok, Variables, #{}}, MF, Req);
debug_toolbar({ok, Variables, _Options}, {Mod, Func}, Req = #{parsed_qs := #{<<"d">> := <<"1">>}}) ->
    %% Fetches the regular view
    nova_basic_handler:handle_ok({ok, Variables}, {Mod, Func}, Req);
debug_toolbar({ok, Variables, Options}, {Mod, _Func}, Req) ->
    io:format("~p~n", [Req]),
    {ok, DebugToolbarVars} = nova_admin_debug_toolbar_controller:overlay(Req),
    nova_basic_handler:handle_ok({ok, DebugToolbarVars#{}, #{view => nova_admin_debug_toolbar}},
                                 {nova_admin_debug_toolbar, overlay}, Req).




get_view_name(Mod) when is_atom(Mod) ->
    StrName = get_view_name(erlang:atom_to_list(Mod)),
    erlang:list_to_atom(StrName);
get_view_name([$_, $c, $o, $n, $t, $r, $o, $l, $l, $e, $r]) ->
    "_dtl";
get_view_name([H|T]) ->
    [H|get_view_name(T)].
