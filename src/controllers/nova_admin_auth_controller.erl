-module(nova_admin_auth_controller).
-export([
         is_authed/1,
         login/1
        ]).


is_authed(Req) ->
    {Session, Req1} = nova_session:get_session(Req),
    case maps:get(logged_in, Session, false) of
        false ->
            {redirect, "/login"};
        _ ->
            true
    end.

login(#{method := <<"GET">> = _Req}) ->
    {ok, [], #{view => "login"}};
login(#{method := <<"POST">>} = Req) ->
    case cowboy_req:has_body(Req) of
        true ->
            {ok, S, Req0} = cowboy_req:read_urlencoded_body(Req),
            Password = proplists:get_value(<<"password">>, S),
            case nova_admin_db:get_user(proplists:get_value(<<"email">>, S)) of
                {ok, {_, _, Password}} ->
                    nova_session:put(logged_in, true, Req0),
                    {redirect, "/"};
                _ ->
                    {ok, [{error, "Wrong username/password"}], #{view => "login"}}
            end;
        _ ->
            {ok, [], #{view => "login"}}
    end.
