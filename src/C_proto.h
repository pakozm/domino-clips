#ifndef __C_PROTO_H
#define __C_PROTO_H

#include "clips.h"
#include "C_defs.h"
#include <time.h>

extern int modo_traza;

void C_traza(void *environment)
{
  modo_traza=EnvRtnLong(environment,1);
}

int C_time(void *environment)
{
  return (int)time(NULL);
}

void EnvUserFunctions(void *environment)
{
  EnvDefineFunction(environment, "C_leer_ficha", 'm',
                    PTIEF C_leer_ficha, "C_leer_ficha");
  EnvDefineFunction(environment, "C_sdl_init", 'v',
                    PTIEF C_sdl_init, "C_sdl_init");
  EnvDefineFunction(environment, "C_ficha_jugador", 'v',
                    PTIEF C_ficha_jugador, "C_ficha_jugador");
  EnvDefineFunction(environment, "C_flip", 'v',
                    PTIEF C_flip, "C_flip");
  EnvDefineFunction(environment, "C_ficha_mesa", 'v',
                    PTIEF C_ficha_mesa, "C_ficha_mesa");
  EnvDefineFunction(environment, "C_mostrar_mesa", 'v',
                    PTIEF C_mostrar_mesa, "C_mostrar_mesa");
  EnvDefineFunction(environment, "C_sdl_cerrar", 'v',
                    PTIEF C_sdl_cerrar, "C_sdl_cerrar");
  EnvDefineFunction(environment, "C_time", 'i',
                    PTIEF C_time, "C_time");
  EnvDefineFunction(environment, "C_msg", 'v',
                    PTIEF C_msg, "C_msg");
  EnvDefineFunction(environment, "C_traza", 'v',
                    PTIEF C_traza, "C_traza");
  EnvDefineFunction(environment, "C_fichas", 'v',
                    PTIEF C_fichas, "C_fichas");
  EnvDefineFunction(environment, "C_elige_jugadores", 'm',
                    PTIEF C_elige_jugadores, "C_elige_jugadores");
  EnvDefineFunction(environment, "C_esperar_boton_derecho", 'v',
                    PTIEF C_esperar_boton_derecho, "C_esperar_boton_derecho");
}

#endif
