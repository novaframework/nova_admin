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
    nova_admin_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
