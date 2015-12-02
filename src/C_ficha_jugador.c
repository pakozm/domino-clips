#include "SDL.h"
#include "clips.h"
#include "C_defs.h"

extern int jugador[7], n;

void C_ficha_jugador (void *environment)
{
  unsigned long int x, f;
  SDL_Rect rect;
  f = EnvRtnLong(environment, 1);
  jugador[n] = f;
  ++n;
}
