%%%-------------------------------------------------------------------
%% @doc nova_admin public API
%% @end
%%%-------------------------------------------------------------------

-module(nova_admin_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    logger:set_primary_config(level, debug),
    mnesia:create_schema([node()]),
    mnesia:start(),
    nova_sup:start_link(),
    nova_admin_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
