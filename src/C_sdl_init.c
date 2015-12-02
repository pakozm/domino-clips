#include <time.h>
#include <stdlib.h>
#include "SDL.h"
#include "C_defs.h"

SDL_Surface *screen, *mesa, *msg, *num_fichas;
SDL_Rect head, tail;
int msg_time=0, leyendo=0, modo_traza=0;
int fichaW, fichaH, num_mesa=0;
int sentido_head, sentido_tail;
int jugador[7], n=0;
Tficha fichas[28];

/*
  Posiciones de los puntos
  en una ficha vertical
*/
static int p[7][2]= {
  {5,4},   /* 0 */
  {29,4},  /* 1 */
  {5,17},  /* 2 */
  {17,17}, /* 3 */
  {29,17}, /* 4 */
  {5,28},  /* 5 */
  {29,28}  /* 6 */
};

static void PonerCirculo (SDL_Surface *circulo, SDL_Surface *ficha,
			  int valor, char pos)
{
  SDL_Rect dest;
  int poner[6], i, offset=0;;
  switch (valor) {
  case 0: default: break;
  case 1: poner[0] = 3; break;
  case 2: poner[0] = 0; poner[1] = 6; break;
  case 3: poner[0] = 0; poner[1] = 3; poner[2] = 6; break;
  case 4: poner[0] = 0; poner[1] = 1; poner[2] = 5; poner[3] = 6; break;
  case 5:
    poner[0] = 0; poner[1] = 1; poner[2] = 3;
    poner[3] = 5; poner[4] = 6;
    break;
  case 6:
    poner[0] = 0; poner[1] = 1; poner[2] = 2;
    poner[3] = 4; poner[4] = 5; poner[5] = 6;
    break;
  }
  if (pos == 1 || pos == 3) offset = 41;
  dest.w = circulo->w;
  dest.h = circulo->h;
  for (i=0; i<valor; ++i) {
    if (pos < 2) {
      dest.x = p[poner[i]][0];
      dest.y = p[poner[i]][1] + offset;
    }
    else {
      dest.x = p[poner[i]][1] + offset;
      dest.y = p[poner[i]][0];
    }
    SDL_BlitSurface (circulo, NULL, ficha, &dest);
  }
}

static void GenerarFichas()
{
  Uint32 color;
  SDL_Surface *circulo, *tmp;
  int i, j, f=0;
  tmp = SDL_LoadBMP ("circulo.bmp");
  if (tmp == NULL) {
    fprintf (stderr, "Error al cargar la imagen: circulo.bmp\n%s\n",
	     SDL_GetError());
  }
  circulo = SDL_DisplayFormat (tmp);
  SDL_FreeSurface (tmp);
  color = SDL_MapRGB(circulo->format, 255, 255, 255);
  SDL_SetColorKey (circulo, SDL_SRCCOLORKEY, color);
  for (i=0; i<7; ++i)
    for (j=i; j<7; ++j, ++f) {
      fichas[f].x = i;
      fichas[f].y = j;
      tmp=SDL_LoadBMP("fichaV.bmp");
      if (tmp == NULL) {
	fprintf (stderr, "Error al cargar la imagen: fichaV.bmp\n%s\n",
		 SDL_GetError());
      }
      fichas[f].bmpV[1] = SDL_DisplayFormat (tmp);
      SDL_FreeSurface(tmp);
      PonerCirculo (circulo, fichas[f].bmpV[1], j, 0);
      PonerCirculo (circulo, fichas[f].bmpV[1], i, 1);
      tmp=SDL_LoadBMP("fichaV.bmp");
      if (tmp == NULL) {
	fprintf (stderr, "Error al cargar la imagen: fichaV.bmp\n%s\n",
		 SDL_GetError());
      }
      fichas[f].bmpV[0] = SDL_DisplayFormat (tmp);
      SDL_FreeSurface(tmp);
      PonerCirculo (circulo, fichas[f].bmpV[0], i, 0);
      PonerCirculo (circulo, fichas[f].bmpV[0], j, 1);
      tmp=SDL_LoadBMP("fichaH.bmp");
      if (tmp == NULL) {
	fprintf (stderr, "Error al cargar la imagen: fichaH.bmp\n%s\n",
		 SDL_GetError());
      }
      fichas[f].bmpH[1] = SDL_DisplayFormat (tmp);
      SDL_FreeSurface(tmp);
      PonerCirculo (circulo, fichas[f].bmpH[1], j, 2);
      PonerCirculo (circulo, fichas[f].bmpH[1], i, 3);
      tmp=SDL_LoadBMP("fichaH.bmp");
      if (tmp == NULL) {
	fprintf (stderr, "Error al cargar la imagen: fichaH.bmp\n%s\n",
		 SDL_GetError());
      }
      fichas[f].bmpH[0] = SDL_DisplayFormat (tmp);
      SDL_FreeSurface(tmp);
      PonerCirculo (circulo, fichas[f].bmpH[0], i, 2);
      PonerCirculo (circulo, fichas[f].bmpH[0], j, 3);
    }
   fichaW = fichas[0].bmpV[1]->w;
   fichaH = fichas[0].bmpV[1]->h;
  SDL_FreeSurface (circulo);
}

void C_sdl_init(void *environment)
{
  Uint32 rmask, gmask, bmask, amask, negro;
  SDL_Surface *tmp;
  msg=NULL;
  srand (time(NULL));
  /* inicializamos SDL */
  if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
    fprintf(stderr, "No se puede iniciar SDL: %s\n", SDL_GetError());
    exit(1);
  }
  atexit(SDL_Quit);
  
  /* dibujamos la ventana */
  
  screen = SDL_SetVideoMode(800, 600, 16, SDL_DOUBLEBUF);
  if (screen == NULL) {
    fprintf(stderr, "No se puede establecer el modo \
                de video 800x600: %s\n", SDL_GetError());
    exit(1);
  }
  GenerarFichas();
  sentido_head = IZQUIERDA;
  sentido_tail = DERECHA;
  //  head.x = 375; head.y = 280;
  head.x=385; head.y = 240;
  head.w = fichaW; head.h = fichaH;
  tail = head;
  tail.x -= fichaH;
  tmp = SDL_LoadBMP ("mesa.bmp");
  if (tmp == NULL) {
    fprintf (stderr, "Error al cargar la imagen: mesa.bmp\n%s\n",
	     SDL_GetError());
  }
  mesa = SDL_DisplayFormat (tmp);
  SDL_FreeSurface (tmp);
  n=0;
  
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
  rmask = 0xff000000;
  gmask = 0x00ff0000;
  bmask = 0x0000ff00;
  amask = 0x000000ff;
#else
  rmask = 0x000000ff;
  gmask = 0x0000ff00;
  bmask = 0x00ff0000;
  amask = 0xff000000;
#endif
  
  tmp = SDL_CreateRGBSurface (0, NUM_FICHAS_W, NUM_FICHAS_H,
			      16, rmask, gmask, bmask, amask);
  if (tmp == NULL) {
    fprintf (stderr, "Error al generar una superficie\n%s\n",
	     SDL_GetError());
  }
  num_fichas = SDL_DisplayFormat (tmp);
  SDL_FreeSurface (tmp);
  negro = SDL_MapRGB (num_fichas->format, 0, 0, 0);
  SDL_FillRect (num_fichas, NULL, negro);
  
  C_flip(environment);
}
