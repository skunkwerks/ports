#define STATIC_ERLANG_NIF_LIBNAME greet
#include "erl_nif.h"
#include <string.h>

static ERL_NIF_TERM greet(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    char name[256];

    if (argc != 1 || !enif_get_string(env, argv[0], name, sizeof(name), ERL_NIF_LATIN1))
        return enif_make_badarg(env);

    char greeting[512];
    snprintf(greeting, sizeof(greeting), "hello, %s!", name);

    return enif_make_string(env, greeting, ERL_NIF_LATIN1);
}

static ErlNifFunc functions[] = {
    {"greet", 1, greet, 0}
};

ERL_NIF_INIT(greet, functions, NULL, NULL, NULL, NULL)
