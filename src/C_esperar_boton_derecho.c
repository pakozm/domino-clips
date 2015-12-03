#include "C_defs.h"
#include "SDL.h"

void C_esperar_boton_derecho(void *environment)
{
  SDL_Event evento;
  int fin=0;
  while (!fin) {
    while (SDL_PollEvent(&evento)) {
      switch (evento.type) {
      case SDL_KEYDOWN:
        if (evento.key.keysym.sym == SDLK_ESCAPE ||
            evento.key.keysym.sym == SDLK_q) fin = 1;
        break;
      case SDL_QUIT:
	SDL_Quit();
	fin = 1;
	break;
      case SDL_MOUSEBUTTONDOWN:
	if (evento.button.button == SDL_BUTTON_RIGHT) {
	  fin = 1;
	  break;
	}
      }
    }
  }
}
