#ifndef __C_DEFS
#define __C_DEFS

#include "SDL.h"
#include "clips.h"

#define FICHAS_Y 510
#define HEAD 0
#define TAIL 1
#define DERECHA 0
#define IZQUIERDA 1
#define MSG_X 0
#define MSG_Y 480
#define MSG_TIME 100
#define DELAY 250
#define NUM_FICHAS_X 670
#define NUM_FICHAS_Y 510
#define NUM_FICHAS_W 100
#define NUM_FICHAS_H 80

typedef struct Tficha {
  unsigned short int x, y;
  SDL_Surface *bmpV[2], *bmpH[2];
} Tficha;

void C_leer_ficha(void *environment,DATA_OBJECT_PTR returnValuePtr);
void C_sdl_init(void *environment);
void C_ficha_jugador(void *environment);
void C_flip(void *environment);
void C_ficha_mesa(void *environment);
void C_mostrar_mesa(void *environment);
void C_sdl_cerrar(void *environment);
int  C_time(void *environment);
void C_msg(void *environment);
void C_traza(void *environment);
void C_fichas(void *environment);
void C_elige_jugadores(void *environment,DATA_OBJECT_PTR returnValuePtr);

#endif
