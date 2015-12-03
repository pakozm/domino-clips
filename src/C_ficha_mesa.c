#include "SDL.h"
#include "C_defs.h"
#include "clips.h"

extern SDL_Surface *mesa;
extern int num_mesa;
extern SDL_Rect head, tail;
extern Tficha fichas[28];
extern int sentido_head, sentido_tail;

void C_ficha_mesa(void *environment)
{
  /*
    int posH[][2]={
    {}
    }
    int posT[][2]=
  */
  SDL_Surface *s;
  unsigned long int ficha, sentido, pos;
  ficha = EnvRtnLong(environment, 1);
  sentido = EnvRtnLong(environment, 2);
  pos = EnvRtnLong (environment, 3);
  
  s = fichas[ficha].bmpH[!sentido];
  if (pos == HEAD) {
    if (sentido_head == DERECHA) {
      if (head.x >= 500) {
	s = fichas[ficha].bmpV[!sentido];
	head.x += s->w;
	head.y -= s->h;
	SDL_BlitSurface (s, NULL, mesa, &head);
	sentido_head = IZQUIERDA;
      }
      else
	{	    
	    s = fichas[ficha].bmpH[sentido];
	    head.x += s->w;
	    // sentido_head = sentido_head;   
	    SDL_BlitSurface (s, NULL, mesa, &head);
	  }
    }
    else 
      /* sentido == IZQUIERDA*/
      {
	if (head.x <= 70) {
	  s = fichas [ficha].bmpV[!sentido];
	  head.y -= s->h ;
	  //head.x = 540; 
	  SDL_BlitSurface (s, NULL, mesa, &head);
	  head.x -= s->w;
	  sentido_head = DERECHA;
	}
	else
	  {
	    s = fichas [ficha].bmpH[!sentido];
	    head.x -= s->w;   
	    SDL_BlitSurface (s, NULL, mesa, &head);
	  }
	
      }
  } 
  if (pos == TAIL) {
    if (sentido_tail == DERECHA) {
      if (tail.x >= 500) {
	s = fichas[ficha].bmpV[!sentido];
	tail.x += s->w;
	tail.y += s->w;
	SDL_BlitSurface (s, NULL, mesa, &tail);	
	tail.y += s->w;
	sentido_tail = IZQUIERDA;
      }
      else
	{	    
	    s = fichas[ficha].bmpH[!sentido];
	    tail.x += s->w;	    
	    // sentido_tail = sentido_tail;
	    SDL_BlitSurface (s, NULL, mesa, &tail);
	  }
    }
    else 
      /* sentido == IZQUIERDA*/
      {
	if (tail.x <= 60) {
	  s = fichas [ficha].bmpV[!sentido];
	  tail.y += s->w ;	   
	  SDL_BlitSurface (s, NULL, mesa, &tail);
	  tail.y += s->h - s->w;
	  tail.x -= s->w;
	  sentido_tail = DERECHA;
	}
	else 
	  {
	    s = fichas [ficha].bmpH[sentido];
	    tail.x -= s->w;
	    SDL_BlitSurface (s, NULL, mesa, &tail);
	  }
	
      }
  }
  /*
  if (pos == TAIL) {
    if (tail.x >= 500) {
      tail.x = 50;
      tail.y += s->h + 10;
    }
    else tail.x += s->w;
    SDL_BlitSurface (s, NULL, mesa, &tail);
  }
  */
  ++num_mesa; 

  /*
    // original 
    if (pos == HEAD) {
    if (head.x <= 60) {
    head.y -= s->h + 10;
    head.x = 540;
    }
    else head.x -= s->w;
    SDL_BlitSurface (s, NULL, mesa, &head);
  }
  if (pos == TAIL) {
    if (tail.x >= 500) {
      tail.x = 50;
      tail.y += s->h + 10;
    }
    else tail.x += s->w;
    SDL_BlitSurface (s, NULL, mesa, &tail);
  }
  ++num_mesa;
  */
}
