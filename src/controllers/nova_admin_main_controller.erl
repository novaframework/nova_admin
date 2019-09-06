-module(nova_admin_main_controller).
-export([
         dashboard/1,
         users/1
        ]).

-include_lib("nova_admin/include/nova_admin.hrl").

dashboard(#{method := <<"GET">>} = _Req) ->
    {ok, AppRoutes} = nova_router:get_routes(),
    [RouteList] =
        lists:map(fun({Host, Routes}) ->
                          lists:map(fun({Route, _Handler, #{app := App, func := Func, methods := Methods,
                                                            mod := Mod, protocol := Protocol, secure := Secure}}) ->
                                            [underscore_to_all(Host), Route, App, Mod, Func, underscore_to_all(Methods), Protocol, Secure];
                                       ({Route, _Handler, {Func, App, Dir}}) ->
                                            [underscore_to_all(Host), Route, App, Func, <<"">>, <<"all">>, http, false]
                                    end, Routes)
                  end, AppRoutes),
    PagedTable = #paged_table{
                    columns = [<<"Host">>, <<"Route">>, <<"App">>, <<"Module">>, <<"Function">>, <<"Methods">>, <<"Protocol">>, <<"Secure">>],
                    rows = RouteList
                   },
    Container = #container{title = <<"Routing table">>, body = PagedTable},

    {external_handler, nova_admin_handler, Container}.

users(#{method := <<"GET">>}) ->
    {ok, Users} = nova_admin_db:get_users(),
    UserList =
        lists:map(fun({_, Username, Password}) ->
                          [Username, Password]
                  end, Users),
    PagedTable = #paged_table{
                    columns = [<<"Username">>, <<"Password">>],
                    rows = UserList},
    Container = #container{title = <<"Nova Admin users">>, body = PagedTable},

    AddUser = #container{
                 title = <<"Add new user...">>,
                 body = #form{
                           method = <<"POST">>,
                           action = <<"/user">>,
                           body = [
                                   #input{type = <<"input">>, name = <<"email">>, label = <<"Email">>, placeholder = <<"Email">>},
                                   #input{type = <<"input">>, name = <<"password">>, label = <<"Password">>, placeholder = << "Password...">>},
                                   #button{type = <<"submit">>, text = <<"Create user">>, class = <<"btn btn-primary btn-block">>}
                                  ]
                          }
                },

    {external_handler, nova_admin_handler, [Container, AddUser]};

users(#{method := <<"POST">>} = Req) ->
    case cowboy_req:has_body(Req) of
        true ->
            {ok, S, Req0} = cowboy_req:read_urlencoded_body(Req),
            Email = proplists:get_value(<<"email">>),
            Password = proplists:get_value(<<"password">>),
            case nova_admin_db:new_user(#nova_admin_user{username = Email,
                                                         password = Password}) of
                true ->
                    {redirect, "/users"};
                _ ->
                    {external_handler, nova_admin_handler, {ok, [{error, "Could not create user"}]}}
            end;
        _ ->
            {external_handler, nova_admin_handler, {ok, [{error, "Something went wrong :O"}]}}
    end.

%%%%%%%%%%%%%%%%%%%%%%
% Private functions  %
%%%%%%%%%%%%%%%%%%%%%%

underscore_to_all('_') -> <<"all">>;
underscore_to_all(Other) -> Other.
