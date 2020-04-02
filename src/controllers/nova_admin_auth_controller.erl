-module(nova_admin_auth_controller).
-export([
         is_authed/1,
         login/1
        ]).

-include_lib("nova_admin/include/nova_admin.hrl").
-include_lib("nova/include/nova.hrl").

is_authed(Req) ->
    case nova_session:get(Req, is_logged_in) of
        {ok, _} ->
            true;
        _ ->
            {redirect, "/login"}
    end.




login(#{method := <<"GET">>}) ->
    {ok, [], #{view => "login"}};

login(#{method := <<"POST">>} = Req) ->
    case cowboy_req:has_body(Req) of
        true ->
            {ok, S, Req0} = cowboy_req:read_urlencoded_body(Req),
            Password = proplists:get_value(<<"password">>, S),
            case nova_admin_db:get_user(proplists:get_value(<<"email">>, S)) of
                {ok, #nova_admin_user{password = Password}} ->
                    nova_session:set(Req, is_logged_in, true),
                    {redirect, "/"};
                _ ->
                    {ok, [{error, "Wrong username/password"}], #{view => "login"}}
            end;
        _ ->
            {ok, [{error, "Could not find body"}], #{view => "login"}}
    end.
