#include <stdlib.h>
#include "SDL.h"
#include "C_defs.h"

void C_sdl_cerrar(void *environment)
{
  char fin=0;
  SDL_Event evento;
  while (!fin) {
    while (SDL_PollEvent(&evento))
      if (evento.type == SDL_QUIT) fin=1;
    C_flip(environment);
  }
  SDL_Quit();
}
