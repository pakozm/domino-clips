#include <stdio.h>
#include "SDL.h"
#include "C_defs.h"

extern SDL_Surface *num_fichas;

const char * const fichas_str[]={
  "cantidades/jugador0.bmp",
  "cantidades/jugador1.bmp",
  "cantidades/jugador2.bmp",
  "cantidades/jugador3.bmp",
  "cantidades/cero.bmp", "cantidades/uno.bmp",
  "cantidades/dos.bmp",
  "cantidades/tres.bmp", "cantidades/cuatro.bmp",
  "cantidades/cinco.bmp", "cantidades/seis.bmp",
  "cantidades/siete.bmp"
};

void C_fichas(void *environment)
{
  SDL_Rect rect;
  unsigned long int j=EnvRtnLong(environment, 1),
    n=EnvRtnLong(environment, 2);
  SDL_Surface *tmp, *aux, *num;
  tmp = SDL_LoadBMP(fichas_str[j]);
  if (tmp == NULL) {
    fprintf (stderr, "Error al cargar la imagen: %s\n%s\n", fichas_str[j],
	     SDL_GetError());
  }
  aux=SDL_DisplayFormat(tmp);
  SDL_FreeSurface (tmp);
  tmp=SDL_LoadBMP(fichas_str[n+4]);
  if (tmp == NULL) {
    fprintf (stderr, "Error al cargar la imagen: %s\n%s\n", fichas_str[n+4],
	     SDL_GetError());
  }
  num=SDL_DisplayFormat(tmp);
  SDL_FreeSurface(tmp);
  rect.y=0;
  rect.x=80;
  rect.w=num->w;
  rect.h=num->h;
  SDL_BlitSurface (num, NULL, aux, &rect);
  SDL_FreeSurface (num);
  
  rect.x=0;
  rect.y=aux->h*j;
  rect.w=aux->w;
  rect.h=aux->h;
  SDL_BlitSurface (aux, NULL, num_fichas, &rect);

  SDL_FreeSurface (aux);
}
