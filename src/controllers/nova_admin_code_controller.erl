-module(nova_admin_code_controller).
-export([
         get_code/1
        ]).


get_code(Req = #{bindings := #{<<"module">> := ModuleBin}}) ->
    Module = binary_to_atom(ModuleBin),
    CompileInfo = Module:module_info(compile),
    case proplists:get_value(source, CompileInfo) of
        undefined ->
            {status, 404};
        SourceFile ->
            {ok, Source} = file:read_file(SourceFile),
            {status, 200, #{"content-type" => "text/html"}, Source}
    end.
