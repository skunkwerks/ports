-module(static_probe).
-on_load(init/0).
-export([init/0, answer/0, main/0]).

%% No shared library exists at this path. Success proves static dispatch.
init() -> erlang:load_nif("/does/not/exist/static_probe", 0).
answer() -> erlang:nif_error(not_loaded).
main() ->
    42 = answer(),
    io:format("static nif: 42~n"),
    halt(0).
