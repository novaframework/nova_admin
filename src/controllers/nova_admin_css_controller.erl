-module(nova_admin_css_controller).

-export([index/1]).

index(_Req) ->
    PrivDir = code:priv_dir(nova_admin),
    CssFile = filename:join([PrivDir, "static", "assets", "css", "admin.css"]),
    {ok, Css} = file:read_file(CssFile),
    {status, 200, #{<<"content-type">> => <<"text/css; charset=utf-8">>}, Css}.
