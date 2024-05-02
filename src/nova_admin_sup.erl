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
    SupFlags = #{strategy => one_for_one,
                 intensity => 1,
                 period => 5},

    {ok, { SupFlags, [child(nova_admin_trace_db, worker)]} }.

%%====================================================================
%% Internal functions
%%====================================================================
child(SupModule, Type) ->
    #{id => SupModule,
      start => {SupModule, start_link, []},
      restart => permanent,
      shutdown => 5000,
      type => Type,
      modules => [SupModule]}.

child(SupModule) ->
    child(SupModule, supervisor).
