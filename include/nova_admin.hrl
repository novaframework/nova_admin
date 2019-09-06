-record(nova_admin_user, {
                          username,
                          password
                         }).


-record(paged_table, {
                      columns = [] :: [binary()],
                      rows = [] :: [[binary()]],
                      options = #{} :: map()
                     }).

-record(form, {
               method :: binary(),
               action :: binary(),
               body :: [binary()],
               options = #{} :: map()
              }).

-record(button, {
                 type  = <<"submit">>, %% <<"submit">> | <<"cancel">> | <<"button">>,
                 text = <<"Submit">> :: binary(),
                 class = <<"">> :: binary()
                }).

-record(input, {
                type :: binary(), %% <<"input">> | <<"checkbox">>,
                name :: binary(),
                label :: binary() | undefined,
                placeholder :: binary() | undefined,
                value = <<"">> :: binary() | binary
               }).

-record(container, {
                    title :: binary(),
                    body :: binary(),
                    footer = <<"">> :: binary()
                   }).
