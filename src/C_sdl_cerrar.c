#include <stdlib.h>
#include "SDL.h"
#include "C_defs.h"

void C_sdl_cerrar(void *environment)
{
  SDL_Quit();
}
