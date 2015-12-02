#include <stdio.h>
#include "SDL.h"
#include "C_defs.h"

extern SDL_Surface *msg;
extern int msg_time;

enum {
  MSG_BASE=0,
  MSG_COLOCAR, MSG_PONER, MSG_ESCOGE,
  MSG_GANA0, MSG_GANA1, MSG_GANA2, MSG_GANA3,
  MSG_NADIE,
  MSG_PASA0, MSG_PASA1, MSG_PASA2, MSG_PASA3,
  MSG_TIPO,
  MSG_TURNO0, MSG_TURNO1, MSG_TURNO2, MSG_TURNO3
} msg_e;

const char * const msg_str[]={
"msg_bmp/base.bmp", "msg_bmp/ecolocar.bmp",
"msg_bmp/eponer.bmp", "msg_bmp/escoge.bmp",
"msg_bmp/gana0.bmp", "msg_bmp/gana1.bmp",
"msg_bmp/gana2.bmp", "msg_bmp/gana3.bmp",
"msg_bmp/nadie_puede_poner_mas_fichas.bmp",
"msg_bmp/pasa0.bmp", "msg_bmp/pasa1.bmp",
"msg_bmp/pasa2.bmp", "msg_bmp/pasa3.bmp",
"msg_bmp/tipojugador.bmp",
"msg_bmp/turno0.bmp", "msg_bmp/turno1.bmp",
"msg_bmp/turno2.bmp", "msg_bmp/turno3.bmp"
};

void C_msg(void *environment)
{
  SDL_Surface *tmp;
  unsigned long int m = EnvRtnLong(environment, 1);
  if (msg != NULL) {
    SDL_FreeSurface(msg);
    msg=NULL;
  }
  if (EnvRtnArgCount(environment)>1)
    msg_time=EnvRtnLong(environment, 2);
  else msg_time=-1;
  tmp=SDL_LoadBMP(msg_str[m]);
  if (tmp == NULL) {
    fprintf (stderr, "Error al cargar la imagen: %s\n%s\n", msg_str[m],
	     SDL_GetError());
  }
  msg=SDL_DisplayFormat (tmp);
  SDL_FreeSurface (tmp);
}
