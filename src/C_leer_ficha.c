#include "clips.h"
#include "SDL.h"
#include "C_defs.h"

extern int leyendo;

/* Fichas del jugador */
extern int jugador[7], n;
extern Tficha fichas[28];

/* Cabeza y cola de la mesa */
extern SDL_Rect head, tail;

/* Valores de las fichas y la mesa */
extern int fichaH, fichaW, num_mesa;

char is_head(int x, int y);
char is_tail(int x, int y);

char is_head(int x, int y)
{
  if (num_mesa==0) return 1;
  if (num_mesa > 1) {
    if (x >= head.x && x <= head.x + fichaH &&
	y >= head.y && y <= head.y + fichaW) return 1;
  }
  else {
    if (x >= head.x && x <= head.x + fichaH/2 &&
	y >= head.y && y <= head.y + fichaW) return 1;
  }
  return 0;
}

char is_tail(int x, int y)
{
  if (num_mesa == 0) return 1;
  if (num_mesa > 1) {
    if (x >= tail.x && x <= tail.x + fichaH &&
	y >= tail.y && y <= tail.y + fichaW) return 1;
  }
  else {
    if (x >= tail.x + fichaH/2 && x <= tail.x + fichaH &&
	y >= tail.y && y <= tail.y + fichaW) return 1;
  }
  return 0;
}

void C_leer_ficha(void *environment, DATA_OBJECT_PTR returnValuePtr)
{
  SDL_Event evento;
  int x, y, pos, head_bool=1;
  void *retorno;
  char fin=0, fin2=0;
  if (n == 0) {
    x=-1;
    y=-1;
    fin = 1;
  }
  leyendo=1;
  while (!fin) {
    while (SDL_PollEvent(&evento)) {
      switch (evento.type) {
      case SDL_QUIT:
	SDL_Quit();
	fin = 1;
	break;
      case SDL_MOUSEBUTTONDOWN:
        printf("%d : (%d,%d)\n", evento.button.button, evento.button.x, evento.button.y);
	if (evento.button.button == SDL_BUTTON_RIGHT) {
	  x=-1; y=-1;
	  fin = 1;
	  break;
	}
	if (evento.button.y >= FICHAS_Y &&
	    evento.button.y <= FICHAS_Y + fichaH) {
	  for (pos=0; pos<n; ++pos) {
	    if (evento.button.y >= FICHAS_Y &&
		evento.button.y <= FICHAS_Y + fichaH) {
	      if (evento.button.x >= (30 + pos*(fichaW + 10)) &&
		  evento.button.x <= (30 + pos*(fichaW + 10) + fichaW)) {
		if (evento.button.y > FICHAS_Y + fichaH/2) {
		  x = fichas[jugador[pos]].y;
		  y = fichas[jugador[pos]].x;
		}
		else {
		  x = fichas[jugador[pos]].x;
		  y = fichas[jugador[pos]].y;
		}
		fin2=0;
		while (!fin2) {
		  SDL_PollEvent(&evento);
		  switch (evento.type) {
		  case SDL_MOUSEBUTTONDOWN:
		    if (evento.button.button == SDL_BUTTON_RIGHT) fin2=1;
		    else {
		      if (is_head (evento.button.x, evento.button.y))
			fin=1, fin2=1;
		      else if (is_tail (evento.button.x, evento.button.y)) {
			fin = x;
			x = y;
			y = fin;
			fin = 1;
			head_bool = 0;
			fin2=1;
		      }
		    }
		    break;
		  }
		}
	      }
	    }
	  }
	}
	break;
      }
    }
    C_flip(environment);
  }
  
  retorno = EnvCreateMultifield(environment,3);
  SetMFType(retorno, 1, INTEGER);
  SetMFValue(retorno, 1, EnvAddLong(environment,x));
  SetMFType(retorno, 2, INTEGER);
  SetMFValue(retorno, 2, EnvAddLong(environment,y));
  SetMFType(retorno, 3, INTEGER);
  SetMFValue(retorno, 3, EnvAddLong(environment,head_bool));
  SetpType(returnValuePtr, MULTIFIELD);
  SetpValue(returnValuePtr, retorno);
  SetpDOBegin(returnValuePtr, 1);
  SetpDOEnd(returnValuePtr, 3);
  n=0;
  
  while (SDL_PollEvent(&evento));
}
