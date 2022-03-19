-module(nova_admin_router).
-behaviour(nova_router).

-export([
         routes/1
        ]).

%% The Environment-variable is defined in your sys.config in {nova, [{environment, Value}]}
routes(_Environment) ->
    [#{prefix => "",
       security => false,
       plugins => [{pre_request, nova_request_plugin, #{parse_bindings => true, parse_qs => true}}],
       routes => [
                  {"/", { nova_admin_main_controller, index}, #{methods => [get]}},
                  {"/route_table", { nova_admin_main_controller, route_table }, #{methods => [get]}},
                  {"/processes", { nova_admin_processes_controller, index }, #{methods => [get]}},
                  {"/processes/:pid", { nova_admin_processes_controller, process_info }, #{methods => [get]}},
                  {"/ports", { nova_admin_ports_controller, index }, #{methods => [get]}},
                  {"/tables", { nova_admin_tv_controller, index }, #{methods => [get]}},
                  {"/assets/[...]", "assets"}
                 ]
      }].
