#include "SDL.h"
#include "C_defs.h"

extern int leyendo;
extern SDL_Surface *screen, *mesa;

void C_mostrar_mesa(void *environment)
{
  SDL_BlitSurface (mesa, NULL, screen, NULL);
  SDL_Flip (screen);
  leyendo=0;
}
