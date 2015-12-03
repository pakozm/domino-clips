#include "C_defs.h"
#include "SDL.h"

extern int leyendo, modo_traza;

/* Fichas del jugador */
extern int jugador[7], n;
extern Tficha fichas[28];

/* Superficies */
extern SDL_Surface *screen, *mesa, *msg, *num_fichas;
extern int msg_time;

void C_flip(void *environment)
{
  SDL_Surface *ficha;
  SDL_Rect rect;
  int i, x;
  rect.x = NUM_FICHAS_X;
  rect.y = NUM_FICHAS_Y;
  rect.w = NUM_FICHAS_W;
  rect.h = NUM_FICHAS_H;
  SDL_BlitSurface (num_fichas, NULL, mesa, &rect);
  do {
    SDL_BlitSurface (mesa, NULL, screen, NULL);
    if (msg_time!=0) {
      if (msg_time > 0) --msg_time;
      rect.x = MSG_X;
      rect.y = MSG_Y;
      SDL_BlitSurface (msg, NULL, screen, &rect);
    }
    else if (msg!=NULL) {
      SDL_FreeSurface (msg);
      msg=NULL;
    }
    for (i=0; i<n; ++i) {
      ficha = fichas[jugador[i]].bmpV[1];
      x = 30 + (ficha->w+10)*i;
      rect.w = ficha->w;
      rect.h = ficha->h;
      rect.x = x;
      rect.y = FICHAS_Y;
      SDL_BlitSurface (ficha, NULL, screen, &rect);
    }
    SDL_Flip (screen);
    if (!leyendo && !modo_traza && msg_time<=0) SDL_Delay (DELAY);
    else SDL_Delay(25);
  } while(msg_time > 0 && !modo_traza);
}
