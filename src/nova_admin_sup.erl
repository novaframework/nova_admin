%%%-------------------------------------------------------------------
%% @doc nova_admin top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(nova_admin_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    %% Let's tell Nova that we want to overwrite the regular handler for view
    %%nova_handlers:unregister_handler(ok),
    %%nova_handlers:register_handler(ok, fun nova_admin_handler:debug_toolbar/3),
    {ok, { {one_for_all, 0, 1}, []} }.

%%====================================================================
%% Internal functions
%%====================================================================
