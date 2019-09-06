#{prefix => "",
  security => false,
  routes => [
             {"/login", {nova_admin_auth_controller, login}}
            ]
 }.
#{prefix => "",
  security => {nova_admin_auth_controller, is_authed},
  routes => [
             {"/", {nova_admin_main_controller, dashboard}, #{admin => true,
                                                              page_name => <<"Dashboard">>}},
             {"/users", {nova_admin_main_controller, users}, #{admin => true,
                                                               page_name => <<"Users">>}}
           ],
  statics => [
              {"/assets/[...]", "assets"}
             ]
 }.
