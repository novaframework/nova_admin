-module(nova_admin_handler).
-export([
         handle/2
        ]).

-include_lib("nova_admin/include/nova_admin.hrl").

handle({ok, Variables}, Req) ->
    {ok, MainApp} = nova_router:get_main_app(),
    Apps = application:get_env(MainApp, nova_applications, []),
    AppsWithPages =
        lists:map(fun(#{name := App, routes_file := RoutesFile}) ->
                          #{name => App, pages => get_subpages(RoutesFile)}
                  end, Apps),
    {ok, Variables ++ [{menu_apps, AppsWithPages}], #{view => "blank"}};

handle(Formats, Req) when is_list(Formats) ->
    ConcatHTML =
        lists:foldl(fun(Format, Aux) ->
                            HTML = nova_admin_forms:format(Format),
                            [HTML|Aux]
                    end, [], Formats),
    logger:info("Concat: ~p", [ConcatHTML]),
    handle({ok, [{html, lists:reverse(ConcatHTML)}]}, Req);

handle(Format, Req) ->
    HTML = nova_admin_forms:format(Format),
    handle({ok, [{html, HTML}]}, Req);

handle(Payload, Req) ->
    logger:error("Unsupported payload in nova_admin_handler; ~p", [Payload]),
    {status, 500}.

get_subpages(Routefile) ->
    case file:consult(Routefile) of
        {ok, Terms} ->
            get_subpages_route(Terms);
        _ ->
            []
    end.

get_subpages_route([]) -> [];
get_subpages_route([#{prefix := Prefix, routes := AdminRoutes}|Tl]) ->
    format_routes(Prefix, AdminRoutes) ++ get_subpages_route(Tl).

format_routes(_, []) -> [];
format_routes(Prefix, [{Route, _Callback, Options = #{admin := true,
                                                      page_name := PageName}}|Tl]) ->
    [#{route => Prefix ++ Route,
       name => PageName}|format_routes(Prefix, Tl)];
format_routes(Prefix, [_|Tl]) ->
    format_routes(Prefix, Tl).
