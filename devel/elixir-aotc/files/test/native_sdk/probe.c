#define STATIC_ERLANG_NIF_LIBNAME static_probe
#include "erl_nif.h"

static ERL_NIF_TERM answer(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    return enif_make_int(env, 42);
}

static ErlNifFunc functions[] = {
    {"answer", 0, answer, 0}
};

ERL_NIF_INIT(static_probe, functions, NULL, NULL, NULL, NULL)
