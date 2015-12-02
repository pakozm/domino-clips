#include "C_defs.h"
#include "SDL.h"

/* Superficies */
extern SDL_Surface *screen, *msg, *mesa;

#define CPU    0
#define HUMANO 1

#define POSX 150
#define POSY 150

SDL_Surface *load(const char *file);

SDL_Surface *load(const char *file)
{
  Uint32 blanco;
  SDL_Surface *tmp=SDL_LoadBMP(file), *aux;
  if (tmp == NULL) {
    fprintf (stderr, "Error al cargar la imagen: mesa.bmp\n%s\n",
             SDL_GetError());
    return NULL;
  }
  aux = SDL_DisplayFormat(tmp);
  SDL_FreeSurface (tmp);
  blanco=SDL_MapRGB (aux->format, 255, 255, 255);
  SDL_SetColorKey (aux, SDL_SRCCOLORKEY, blanco);
  return aux;
}

void C_elige_jugadores(void *environment, DATA_OBJECT_PTR returnValuePtr)
{
  void *retorno;
  int jugadores[4]={0,0,0,0}, mano=0, fin=0;
  SDL_Event evento;
  SDL_Surface *j[4];
  SDL_Surface *mano_negro, *mano_rojo;
  SDL_Surface *cpu_negro, *cpu_rojo;
  SDL_Surface *humano_rojo, *humano_negro;
  SDL_Rect rect;
  int i;
  
  j[0]=load("seleccion/jugador0.bmp");
  j[1]=load("seleccion/jugador1.bmp");
  j[2]=load("seleccion/jugador2.bmp");
  j[3]=load("seleccion/jugador3.bmp");
  
  mano_negro=load("seleccion/mano_negro.bmp");
  mano_rojo=load("seleccion/mano_rojo.bmp");
  humano_negro=load("seleccion/humano_negro.bmp");
  humano_rojo=load("seleccion/humano_rojo.bmp");
  cpu_negro=load("seleccion/cpu_negro.bmp");
  cpu_rojo=load("seleccion/cpu_rojo.bmp");
  
  do {
    rect.x = MSG_X;
    rect.y = MSG_Y;
    SDL_BlitSurface (mesa, NULL, screen, NULL);
    SDL_BlitSurface (msg, NULL, screen, &rect);
    
    rect.y= POSY;
    for (i=0; i<4; ++i) {
      rect.x= POSX;
      rect.w = j[i]->w;
      rect.h = j[i]->h;
      SDL_BlitSurface (j[i], NULL, screen, &rect);
      /* Pintamos la selección */
      rect.x += j[i]->w + 10;
      if (jugadores[i] == CPU)
	SDL_BlitSurface (cpu_rojo, NULL, screen, &rect);
      else SDL_BlitSurface (cpu_negro, NULL, screen, &rect);
      rect.x += cpu_rojo->w + 10;
      if (jugadores[i] == HUMANO)
      	SDL_BlitSurface (humano_rojo, NULL, screen, &rect);
      else SDL_BlitSurface (humano_negro, NULL, screen, &rect);
      rect.x += humano_negro->w + 15;
      if (mano == i)
	SDL_BlitSurface (mano_rojo, NULL, screen, &rect);
      else SDL_BlitSurface (mano_negro, NULL, screen, &rect);
      /* ===================== */
      rect.y += j[i]->h + 5;
    }
    

    SDL_Flip (screen);
    SDL_Delay(25);

    /* Leemos del ratón */
    while (SDL_PollEvent (&evento)) {
      switch(evento.type) {
      case SDL_QUIT:
	SDL_Quit();
	fin=1;
	exit(0);
	break;
      case SDL_MOUSEBUTTONDOWN:
	if (evento.button.button == SDL_BUTTON_RIGHT) {
	  fin=1;
	  break;
	}
	else if (evento.button.button == SDL_BUTTON_LEFT) {
	  i=-1;
	  if (evento.button.y >=  POSY) {
	    if (evento.button.y <  POSY + j[0]->h)
	      i=0;
	    else if (evento.button.y < POSY + j[1]->h*2 + 5)
	      i=1;
	    else if (evento.button.y < POSY + j[2]->h*3 + 10)
	      i=2;
	    else if (evento.button.y < POSY + j[3]->h*4 + 15)
	      i=3;
	  }
	  if (i != -1) {
	    if (evento.button.x >= POSX + j[0]->w + 10) {
	      if (evento.button.x <
		  POSX + j[0]->w + 10 + cpu_rojo->w)
		jugadores[i]=CPU;
	      else if (evento.button.x <
		       POSX + j[0]->w + 20 + cpu_rojo->w + humano_rojo->w)
		jugadores[i]=HUMANO;
	      else if (evento.button.x <
		       POSX + j[0]->w + 35 + cpu_rojo->w + humano_rojo->w + mano_negro->w)
		mano=i;
	    }
	  }
	}
	break;
      }
    }
    
  } while(!fin);
  
  retorno = EnvCreateMultifield(environment,5);
  SetMFType(retorno, 1, INTEGER);
  SetMFValue(retorno, 1, EnvAddLong(environment,jugadores[0]));
  SetMFType(retorno, 2, INTEGER);
  SetMFValue(retorno, 2, EnvAddLong(environment,jugadores[1]));
  SetMFType(retorno, 3, INTEGER);
  SetMFValue(retorno, 3, EnvAddLong(environment,jugadores[2]));
  SetMFType(retorno, 4, INTEGER);
  SetMFValue(retorno, 4, EnvAddLong(environment,jugadores[3]));
  SetMFType(retorno, 5, INTEGER);
  SetMFValue(retorno, 5, EnvAddLong(environment,mano));
  SetpType(returnValuePtr, MULTIFIELD);
  SetpValue(returnValuePtr, retorno);
  SetpDOBegin(returnValuePtr, 1);
  SetpDOEnd(returnValuePtr, 5);

  while (SDL_PollEvent(&evento));
}
