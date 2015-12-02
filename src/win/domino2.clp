;; TODO: Al inferir las fichas que puede tener un jugador
;; hay que comprobar que el jugador que juega en ese momento
;; no tiene dobles, pues si tiene un doble, el conteo no para
;; cierre no es correcto :P

;; En la mesa, si sentido es 1, está al derecho,
;; si no al revés

(defglobal ?*texto* = 0)
(defglobal ?*numj* = 4)
(defglobal ?*MSG_BASE* = 0)
(defglobal ?*MSG_COLOCAR* = 1)
(defglobal ?*MSG_PONER*  = 2)
(defglobal ?*MSG_ESCOGE* = 3)
(defglobal ?*MSG_GANA0*  = 4)
(defglobal ?*MSG_GANA1*  = 5)
(defglobal ?*MSG_GANA2*  = 6)
(defglobal ?*MSG_GANA3*  = 7)
(defglobal ?*MSG_NADIE*  = 8)
(defglobal ?*MSG_PASA0*  = 9)
(defglobal ?*MSG_PASA1*  = 10)
(defglobal ?*MSG_PASA2*  = 11)
(defglobal ?*MSG_PASA3*  = 12)
(defglobal ?*MSG_TIPO*   = 13)
(defglobal ?*MSG_TURNO0* = 14)
(defglobal ?*MSG_TURNO1* = 15)
(defglobal ?*MSG_TURNO2* = 16)
(defglobal ?*MSG_TURNO3* = 17)
	

(deffunction acabar()
  (halt)
  )

;; Template para definir los atributos de cada jugador
;; Vendría a ser nuestra representación del frame :)
(deftemplate
  jugador
  (slot n (type INTEGER)) ;; Id del jugador
  (slot tipo (type SYMBOL)) ;; Tipo de jugador
  (multislot fichas (type INTEGER)) ;; Fichas que tiene
  (multislot tiene (type INTEGER)) ;; Palos que puede tener
  (multislot pasa (type INTEGER)) ;; Palos que ha pasado
  (multislot puso (type INTEGER)) ;; Palos que ha puesto en mesa
  (multislot abre (type INTEGER)) ;; Palo que deja abierto
  (multislot palos (type INTEGER)) ;; Palos que tiene
  )

;; Valores herísticos que le damos a cada ficha
;; (valor *num_ficha *valor_head *valor_tail)
;; *valor_head: indica el beneficio de ponerla en la cabeza
;; *valor_tail: indica el beneficio de ponerla en la cola
(deffacts valores
  (valor 0 0 0)
  (valor 1 0 0)
  (valor 2 0 0)
  (valor 3 0 0)
  (valor 4 0 0)
  (valor 5 0 0)
  (valor 6 0 0)
  (valor 7 0 0)
  (valor 8 0 0)
  (valor 9 0 0)
  (valor 10 0 0)
  (valor 11 0 0)
  (valor 12 0 0)
  (valor 13 0 0)
  (valor 14 0 0)
  (valor 15 0 0)
  (valor 16 0 0)
  (valor 17 0 0)
  (valor 18 0 0)
  (valor 19 0 0)
  (valor 20 0 0)
  (valor 21 0 0)
  (valor 22 0 0)
  (valor 23 0 0)
  (valor 24 0 0)
  (valor 25 0 0)
  (valor 26 0 0)
  (valor 27 0 0)
  )

;; Fichas, ordenadas de menor a mayor valor
(deffacts fichas
  ;; Parar repartir las fichas al principio
  (repartir 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
	    20 21 22 23 24 25 26 27)
  (ficha 0 0 0)
  (ficha 1 0 1)
  (ficha 2 0 2)
  (ficha 3 0 3)
  (ficha 4 0 4)
  (ficha 5 0 5)
  (ficha 6 0 6)
  (ficha 7 1 1)
  (ficha 8 1 2)
  (ficha 9 1 3)
  (ficha 10 1 4)
  (ficha 11 1 5)
  (ficha 12 1 6)
  (ficha 13 2 2)
  (ficha 14 2 3)
  (ficha 15 2 4)
  (ficha 16 2 5)
  (ficha 17 2 6)
  (ficha 18 3 3)
  (ficha 19 3 4)
  (ficha 20 3 5)
  (ficha 21 3 6)
  (ficha 22 4 4)
  (ficha 23 4 5)
  (ficha 24 4 6)
  (ficha 25 5 5)
  (ficha 26 5 6)
  (ficha 27 6 6)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Indica si un jugador es rival de otro ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffunction es_rival(?jugador ?otro)
  (bind ?ret
	(or
	 (= ?otro (mod (+ ?jugador 1) 4))
	 (= ?otro (mod (+ ?jugador 3) 4))
	 )
	)
  ?ret
  )

;; Estado del juego en el comienzo
(deffacts juego
  ;;  (estado REPARTIR)
;;  (mano 0)
  ;;  (mesa)
  (tirada 0)
  ;; Indica cuantas veces seguidas han pasado
  ;; los jugadores
  (han_pasado 0)
  (dobles_mesa 0 0 0 0 0 0 0)
  ;;  (cierre 0 0 0 0 0 0 0)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Regla para repartir las fichas a cada jugador ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Repartimos las fichas al azar
(defrule repartir_fichas
  (declare (salience 50))
  ?r<-	(repartir $?resto)
  ?j<-	(jugador
	 (n ?n)
	 (tipo ?tipo)
	 (fichas $?fichas)
	 (tiene)
	 (pasa)
	 (puso)
	 (abre)
	 (palos $?palos)
	 )
  ?e<-	(estado REPARTIR)
  ?rand<-	(MI_RANDOM ?una)
  (test (< (length$ $?fichas) 7))
  (ficha ?f ?x ?y)
  (test (= ?f (nth$ ?una $?resto)))
  =>
  (bind $?palos (replace$ $?palos (+ ?x 1) (+ ?x 1)
			  (+ (nth$ (+ ?x 1) $?palos) 1)))
  (bind $?palos (replace$ $?palos (+ ?y 1) (+ ?y 1)
			  (+ (nth$ (+ ?y 1) $?palos) 1)))
  (retract ?j ?r ?rand)
  (assert
   (jugador
    (n ?n)
    (tipo ?tipo)
    (fichas $?fichas (nth$ ?una $?resto))
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos $?palos)
    )
   (repartir (delete$ $?resto ?una ?una))
   )
  )

(defrule mi_random
  (declare (salience 55))
  ?r <-	(repartir $?resto)
  (test (> (length$ $?resto) 0))
  (estado REPARTIR)
  =>
  (assert (MI_RANDOM (random 1 (length$ $?resto))))
  )

(defrule repartir_cambio_estado
  (declare (salience 40))
  (repartir)
  (mano ?mano)
  ?e <-	(estado REPARTIR)
 =>
  (retract ?e)
  (assert (estado TURNO ?mano))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;; FINAL DE LA PARTIDA ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule 4pasos_seguidos
  (declare (salience 4000))
  (han_pasado 4)
  (jugador (n ?yo)(palos $?palos1))
  (jugador (n ?uno)(palos $?palos2))
  (jugador (n ?compi)(palos $?palos3))
  (jugador (n ?otro)(palos $?palos4))
  (test (and
	 (es_rival ?uno ?yo)
	 (es_rival ?otro ?yo)
	 (<> ?uno ?otro ?yo)
	 (not (es_rival ?compi ?yo))
	 (<> ?yo ?compi)
	 )
	)
  =>
  (C_msg ?*MSG_NADIE*)
  (printout t "Ningún jugador puede poner más fichas!!" crlf)
  (printout t "Puntos de cada jugador: " crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos1)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos1) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?yo ": " ?puntos
	    " " $?palos1 crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos2)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos2) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?uno ": " ?puntos
	    " " $?palos2 crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos3)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos3) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?compi ": " ?puntos
	    " " $?palos3 crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos4)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos4) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?otro ": " ?puntos
	    " " $?palos4 crlf)
  (C_mostrar_mesa)
  (C_flip)
  (C_sdl_cerrar)
  (acabar)
  )

(defrule gana_jugador
  (declare (salience 4000))
  (not (exists (estado REPARTIR)))
  (jugador (n ?yo)(tipo ?tipo)(fichas)(palos $?palos1))
  (jugador (n ?uno)(palos $?palos2))
  (jugador (n ?compi)(palos $?palos3))
  (jugador (n ?otro)(palos $?palos4))
  (test (and
	 (es_rival ?uno ?yo)
	 (es_rival ?otro ?yo)
	 (<> ?uno ?otro ?yo)
	 (not (es_rival ?compi ?yo))
	 (<> ?yo ?compi)
	 )
	)
  =>
  (C_msg (+ ?*MSG_GANA0* ?yo))
  (printout t "Ha ganado el jugador: " ?yo crlf)
  (printout t "Puntos de cada jugador: " crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos1)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos1) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?yo ": " ?puntos
	    " " $?palos1 crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos2)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos2) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?uno ": " ?puntos
	    " " $?palos2 crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos3)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos3) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?compi ": " ?puntos
	    " " $?palos3 crlf)
  (bind ?i 1)
  (bind ?puntos 0)
  (while (<= ?i (length$ $?palos4)) do
	 (bind ?puntos (+ ?puntos (* (nth$ ?i $?palos4) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (printout t tab "Jugador " ?otro ": " ?puntos
	    " " $?palos4 crlf)
  
  (C_mostrar_mesa)
  (C_flip)
  (C_sdl_cerrar)
  (acabar)
  )
;;;;;;;;;;;;;;;;;;;;;;;;

;; Eliminamos los hechos que limitan poner la ficha
;; en la cabeza o la cola de la mesa
(defrule eliminar_purga
  (declare (salience 10000))
  (estado TURNO ?jugador)
  ?p <-	(purga ?WOP)
  =>
  (retract ?p)
  )

;; Paso al siguiente jugador
(defrule sig_jugador
  (declare (salience 100))
  ?e <-	(estado SIG_JUGADOR ?jugador)
  =>
  (retract ?e)
  (assert (estado TURNO (mod (+ ?jugador 1) ?*numj*)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mostramos las fichas de la mesa
(defrule turno
  (declare (salience 6000))
  (estado TURNO ?jugador)
  =>
  (C_msg (+ ?*MSG_TURNO0* ?jugador) 50)
  (printout t "=> Turno para el jugador '" ?jugador "'" crlf)
  (printout t "Estado de la mesa: ")
  (C_flip)
  (C_msg (+ ?*MSG_TURNO0* ?jugador) -1)
  )

(defrule mostrar_tablero
  (declare (salience 5500))
  (estado TURNO ?jugador)
  (mesa $?fichas1 ?ficha ?sentido $?fichas2)
  (test (= (mod (length$ $?fichas1) 2) 0))
  (ficha ?ficha ?x ?y)
  =>
  (if (= ?sentido 1) then
    (printout t ?x "·" ?y " ")
    else (printout t ?y "·" ?x " ")
    )
  )

(defrule mostrar_tablero_crlf
  (declare (salience 5250))
  (estado TURNO ?jugador)
  (mesa $?fichas)
  (jugador (n ?jugador) (tipo ?tipo))
  =>
;;;;	(C_dibujar_mesa)
  (printout t crlf)
  (C_mostrar_mesa)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Regla para ceder el control o tomarlo ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Control para la CPU
(defrule control_cpu
  (declare (salience 5000))
  ?e<-	(estado TURNO ?jugador)
  (jugador (n ?jugador) (tipo CPU))
  =>
  (retract ?e)
  (assert (estado CPU ?jugador))
  (C_flip)
  )

;; Control para el usuario
(defrule ceder_control
  (declare (salience 5000))
  ?e<-	(estado TURNO ?jugador)
  (jugador (n ?jugador) (tipo HUMANO))
  =>
  (retract ?e)
  (assert (estado USUARIO ?jugador))
  (printout t "Tus fichas: ")
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mostramos las fichas del usuario ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule mostrar_fichas_crlf
  (declare (salience 4000))
  (estado USUARIO ?jugador)
  =>
  (printout t crlf)
  (C_flip)
  )

(defrule mostrar_fichas
  (declare (salience 5000))
  (estado USUARIO ?jugador)
  (jugador (n ?jugador) (fichas $?dummy1 ?ficha $?dummy2))
  (ficha ?ficha ?x ?y)
  =>
  (printout t ?x "·" ?y " | ")
  (C_ficha_jugador ?ficha)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; El jugador ha pasado ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Si un jugador pasa, se anota en su atributo
;; los valores de las puertas para los cuales
;; no ha podido poner ficha.
;; También incrementamos en 1 (han_pasado ?n)
(defrule pasar_tirada
  (declare (salience 1000))
  ?e <-	(estado ?WOP ?jugador)
  ?p <-	(pasar ?jugador)
  ?h <-	(han_pasado ?pasan)
  (mesa ?head ?sh $?dummy ?tail ?st)
  (ficha ?head ?fhx ?fhy)
  (ficha ?tail ?ftx ?fty)
  ?j <-	(jugador
	 (n ?jugador) (tipo ?tipo)
	 (fichas $?fichas)
	 (tiene $?tiene)
	 (pasa $?pasa)
	 (puso $?puso)
	 (abre $?abre)
	 (palos $?palos)
	 )
  ?t <-	(tirada ?tirada)
  =>
  (bind ?ph ?fhx)
  (bind ?pt ?fty)
  (if (= ?sh 0) then (bind ?ph ?fhy))
  (if (= ?st 0) then (bind ?pt ?ftx))

  (retract ?e ?p ?j ?t ?h)
  (assert
   (han_pasado (+ ?pasan 1))
   (tirada (+ ?tirada 1))
   (estado SIG_JUGADOR ?jugador)
   (jugador
    (n ?jugador) (tipo ?tipo)
    (fichas $?fichas)
    (tiene $?tiene)
    (pasa $?pasa ?ph ?pt)
    (puso $?puso)
    (abre $?abre)
    (palos $?palos)
    )
   )
  (C_msg (+ ?*MSG_PASA0* ?jugador) 75)
  (printout t "El jugador '" ?jugador "' ha pasado!!" crlf)
  (C_flip)
  )

;; Si pasa en la segunda tirada, tendrá un tratamiento
;; especial para que el LHS se cumpla
(defrule pasar_tirada_segunda
  (declare (salience 1100))
  ?e <-	(estado $?WOP)
  ?p <-	(pasar ?jugador)
  (mesa ?head ?sh)
  (ficha ?head ?fhx ?fhy)
  ?j <-	(jugador
	 (n ?jugador) (tipo ?tipo)
	 (fichas $?fichas)
	 (tiene $?tiene)
	 (pasa $?pasa)
	 (puso $?puso)
	 (abre $?abre)
	 (palos $?palos)
	 )
  ?t <-	(tirada ?tirada)
  ?h <-	(han_pasado ?pasan)
  =>
  (retract ?e ?p ?j ?t ?h)
  (assert
   (han_pasado (+ ?pasan 1))
   (tirada (+ ?tirada 1))
   (estado SIG_JUGADOR ?jugador)
   (jugador
    (n ?jugador) (tipo ?tipo)
    (fichas $?fichas)
    (tiene $?tiene)
    (pasa $?pasa ?fhx ?fhy)
    (puso $?puso)
    (abre $?abre)
    (palos $?palos)
    )
   )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ponemos la ficha elegida ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indica que ficha es la que se va a poner, y la posición
(defrule voy_a_poner
  (declare (salience 300))
  (estado PONER_FICHA ?jugador)
  (poner ?x ?y)
  =>
  (printout t "El jugador '" ?jugador "' va a poner: "
	    ?x "·" ?y crlf)
  )

;; La ficha no se ha podido colocar
(defrule error_colocar_ficha
  (declare (salience 100))
  ?e <-	(estado PONER_FICHA ?jugador)
  ?p <-	(poner ?x ?y)
  =>
  (C_msg ?*MSG_COLOCAR* 75)
  (printout t "Error al colocar la ficha!!!: "
	    ?x "·" ?y crlf)
  (retract ?e ?p)
  (assert (estado TURNO ?jugador))
  (C_flip)
  )

;; Si es la primera ficha, necesita un tratamiento
;; especial para que el LHS se cumpla
(defrule poner_primera_ficha
  (declare (salience 250))
  ?t <-	(tirada 0)
  ?e <-	(estado PONER_FICHA ?jugador)
  ?p <-	(poner ?x ?y)
  ?c <-	(cierre $?cierre)
  (ficha ?ficha ?fx ?fy)
  (test (or
	 (and (= ?x ?fx) (= ?y ?fy))
	 (and (= ?x ?fy) (= ?y ?fx))
	 ))
  ?m <-	(mesa)
  ?j <-	(jugador (n ?jugador) (tipo ?tipo)
		 (fichas $?fichas1 ?ficha $?fichas2)
		 (tiene $?tiene) (pasa $?pasa) (puso $?puso)
		 (abre $?abre)
		 (palos $?palos)
		 )
  ?h <-	(han_pasado ?pasan)
  ?d <- (dobles_mesa $?dobles)
  =>
  (C_fichas ?jugador (+ (length$ $?fichas1) (length$ $?fichas2)))
  (bind ?s 1)
  (if (= ?y ?fx) then (bind ?s 0))
  (retract ?t ?e ?p ?m ?j ?h ?c ?d)
  (bind $?cierre (replace$ $?cierre (+ ?x 1) (+ ?x 1)
			   (+ (nth$ (+ ?x 1) $?cierre) 1)))
  (if (<> ?x ?y) then
    (bind $?cierre (replace$ $?cierre (+ ?y 1) (+ ?y 1)
			     (+ (nth$ (+ ?y 1) $?cierre) 1)))
    )
  
  (bind $?palos (replace$ $?palos (+ ?x 1) (+ ?x 1)
			  (- (nth$ (+ ?x 1) $?palos) 1)))
  (bind $?palos (replace$ $?palos (+ ?y 1) (+ ?y 1)
			  (- (nth$ (+ ?y 1) $?palos) 1)))
  
  (if (= ?x ?y) then
    (bind $?dobles (replace$ $?dobles (+ ?x 1) (+ ?x 1) 1))
    )
  
  (assert
   (dobles_mesa $?dobles)
   (han_pasado 0)
   (tirada 1)
   (estado SIG_JUGADOR ?jugador)
   (mesa ?ficha ?s)
   (cierre $?cierre)
   (jugador
    (n ?jugador) (tipo ?tipo)
    (fichas $?fichas1 $?fichas2)
    (tiene $?tiene)
    (pasa $?pasa)
    (puso $?puso ?ficha)
    (abre $?abre ?x ?y)
    (palos $?palos)
    )
   )
  (C_ficha_mesa ?ficha ?s 0)
  )

;; Ponemos una ficha en la cabeza de la mesa
;; si no se ha bloqueado esta acción con una purga
(defrule poner_ficha_elegida_HEAD
  (declare (salience 200))
  ?t <-	(tirada ?tirada)
  ?e <-	(estado PONER_FICHA ?jugador)
  ?p <-	(poner ?x ?y)
  (ficha ?ficha ?fx ?fy)
  ?c <-	(cierre $?cierre)
  ;; La ficha debe existir
  (test (or
	 (and (= ?x ?fx) (= ?y ?fy))
	 (and (= ?x ?fy) (= ?y ?fx))
	 ))
  ?m <-	(mesa ?head ?sentido $?fichas)
  (ficha ?head ?hx ?hy)
  ;; Según el sentido de la primera ficha en la mesa
  ;; indicaremos si se puede o no poner la ficha
  (test (or
	 (and (= ?sentido 1) (= ?hx ?y))
	 (and (= ?sentido 0) (= ?hy ?y))
	 ))
  ;; Fichas del jugador, debemos eliminar la que ponemos
  ?j <-	(jugador (n ?jugador) (tipo ?tipo)
		 (fichas $?fichas1 ?ficha $?fichas2)
		 (tiene $?tiene) (pasa $?pasa)
		 (puso $?puso) (abre $?abre)
		 (palos $?palos)
		 )
  ;; no exists Purga
  (not (exists (purga HEAD)))
  ?h <-	(han_pasado ?pasan)
  ?d <- (dobles_mesa $?dobles)
  =>
  (C_fichas ?jugador (+ (length$ $?fichas1) (length$ $?fichas2)))
  (bind ?abrio ?fx)
  (bind ?s 1)
  (if (= ?y ?fx) then (bind ?s 0) (bind ?abrio ?fy))
  (retract ?t ?e ?p ?m ?j ?h ?c ?d)
  (bind $?cierre (replace$ $?cierre (+ ?x 1) (+ ?x 1)
			   (+ (nth$ (+ ?x 1) $?cierre) 1)))
  (if (<> ?x ?y) then
    (bind $?cierre (replace$ $?cierre (+ ?y 1) (+ ?y 1)
			     (+ (nth$ (+ ?y 1) $?cierre) 1)))
    )
  (bind $?palos (replace$ $?palos (+ ?x 1) (+ ?x 1)
			  (- (nth$ (+ ?x 1) $?palos) 1)))
  (bind $?palos (replace$ $?palos (+ ?y 1) (+ ?y 1)
			  (- (nth$ (+ ?y 1) $?palos) 1)))

  (if (= ?x ?y) then
    (bind $?dobles (replace$ $?dobles (+ ?x 1) (+ ?x 1) 1))
    )
  
  (assert
   (dobles_mesa $?dobles)
   (han_pasado 0)
   (tirada (+ ?tirada 1))
   (estado SIG_JUGADOR ?jugador)
   (mesa ?ficha ?s ?head ?sentido $?fichas)
   (cierre $?cierre)
   (jugador
    (n ?jugador) (tipo ?tipo)
    (fichas $?fichas1 $?fichas2)
    (tiene $?tiene)
    (pasa $?pasa)
    (puso $?puso ?ficha)
    (abre $?abre ?abrio)
    (palos $?palos)
    )
   )
  (C_ficha_mesa ?ficha ?s 0)
  )

;; Igual pero para la cola de la mesa
(defrule poner_ficha_elegida_TAIL
  (declare (salience 200))
  ?t <-	(tirada ?tirada)
  ?e <-	(estado PONER_FICHA ?jugador)
  ?p <-	(poner ?x ?y)
  (ficha ?ficha ?fx ?fy)
  ?c <-	(cierre $?cierre)
  (test (or
	 (and (= ?x ?fx) (= ?y ?fy))
	 (and (= ?x ?fy) (= ?y ?fx))
	 ))
  ?m <-	(mesa $?fichas ?tail ?sentido)
  (ficha ?tail ?tx ?ty)
  (test (or
	 (and (= ?sentido 1) (= ?ty ?x))
	 (and (= ?sentido 0) (= ?tx ?x))
	 ))
  ?j <-	(jugador (n ?jugador) (tipo ?tipo)
		 (fichas $?fichas1 ?ficha $?fichas2)
		 (tiene $?tiene) (pasa $?pasa) (puso $?puso)
		 (abre $?abre)
		 (palos $?palos)
		 )
  (not (exists (purga TAIL)))
  ?h <-	(han_pasado ?pasan)
  ?d <- (dobles_mesa $?dobles)
  =>
  (C_fichas ?jugador (+ (length$ $?fichas1) (length$ $?fichas2)))
  (bind ?abrio ?fy)
  (bind ?s 1)
  (if (= ?y ?fx) then (bind ?s 0) (bind ?abrio ?fx))
  (retract ?t ?e ?p ?m ?j ?h ?c ?d)
  (bind $?cierre (replace$ $?cierre (+ ?x 1) (+ ?x 1)
			   (+ (nth$ (+ ?x 1) $?cierre) 1)))
  (if (<> ?x ?y) then
    (bind $?cierre (replace$ $?cierre (+ ?y 1) (+ ?y 1)
			     (+ (nth$ (+ ?y 1) $?cierre) 1)))
    )
  (bind $?palos (replace$ $?palos (+ ?x 1) (+ ?x 1)
			  (- (nth$ (+ ?x 1) $?palos) 1)))
  (bind $?palos (replace$ $?palos (+ ?y 1) (+ ?y 1)
			  (- (nth$ (+ ?y 1) $?palos) 1)))

  (if (= ?x ?y) then
    (bind $?dobles (replace$ $?dobles (+ ?x 1) (+ ?x 1) 1))
    )
  
  (assert
   (dobles_mesa $?dobles)
   (han_pasado 0)
   (tirada (+ ?tirada 1))
   (estado SIG_JUGADOR ?jugador)
   (mesa $?fichas ?tail ?sentido ?ficha ?s)
   (cierre $?cierre)
   (jugador
    (n ?jugador) (tipo ?tipo)
    (fichas $?fichas1 $?fichas2)
    (tiene $?tiene)
    (pasa $?pasa)
    (puso $?puso ?ficha)
    (abre $?abre ?abrio)
    (palos $?palos)
    )
   )
  (C_ficha_mesa ?ficha ?s 1)
  )

;; Si resulta que la ficha se puede poner de 2 formas distintas
;; se indicará y se preguntará en que posición se quiere poner
(defrule preguntar_lugar
  (declare (salience 500))
  ?e <-	(estado PONER_FICHA ?jugador)
  ?p <-	(poner ?x ?y)
  (ficha ?ficha ?fx ?fy)
  (test (or
	 (and (= ?x ?fx) (= ?y ?fy))
	 (and (= ?x ?fy) (= ?y ?fx))
	 ))
  ?m <-	(mesa ?head ?sentido $?fichas ?tail ?sentido)
  (test (<> ?head ?tail))
  (ficha ?tail ?tx ?ty)
  (ficha ?head ?hx ?hy)
  (test (or
	 (and (= ?sentido 1) (= ?ty ?x))
	 (and (= ?sentido 0) (= ?tx ?x))
	 ))
  (test (or
	 (and (= ?sentido 1) (= ?hx ?y))
	 (and (= ?sentido 0) (= ?hy ?y))
	 ))
  (not (exists (purga ?WOP)))
  ?j <-	(jugador (n ?jugador) (tipo ?tipo)
		 (fichas $?fichas1 ?ficha $?fichas2)
		 (tiene $?tiene) (pasa $?pasa) (puso $?puso))
  =>
  (printout t "Ey, la ficha se puede poner de 2 formas,"
	    "¿cual quieres (head tail)?: ")
  (bind ?l (read))
  (if (eq ?l head) then (assert (purga TAIL))
      else (assert (purga HEAD))
      )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Control para el usuario ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; El usuario ha puesto una ficha
(defrule poner_ficha_usuario
  (declare (salience 100))
  ?p <-	(poner ?x ?y)
  ?e <-	(estado USUARIO ?jugador)
  =>
  (retract ?e)
  (assert (estado PONER_FICHA ?jugador))
  )

;;;;;;;;;;;;;
;; ERRORES ;;
;;;;;;;;;;;;;

;; La ficha no se puede poner
(defrule error
  (declare (salience 10))
  ?p <-	(poner ?x ?y)
  ?e <-	(estado USUARIO ?jugador)
  =>
  (C_msg ?*MSG_PONER* 75)
  (printout t "ERROR no puedes poner esa ficha: "
	    ?x "·" ?y crlf)
  (retract ?p ?e)
  (assert (estado TURNO ?jugador))
  (C_flip)
  )

;; La ficha está en la mesa
(defrule error2
  (declare (salience 200))
  ?p <-	(poner ?x ?y)
  (mesa $?fichas1 ?ficha ?sentido $?fichas2)
  (ficha ?n ?fx ?fy)
  (test (= (mod (length$ $?fichas1) 2) 0))
  (test (= ?n ?ficha))
  (test (or
	 (and (= ?x ?fx) (= ?y ?fy))
	 (and (= ?x ?fy) (= ?y ?fx))
	 ))
  ?e <-	(estado USUARIO ?jugador)
  =>
  (printout t "ERROR, esa ficha esta en la mesa: "
	    ?x "·" ?y crlf)
  (retract ?p ?e)
  (assert (estado TURNO ?jugador))
  )

;; La ficha no le pertenece
(defrule error3
  (declare (salience 200))
  ?e <-	(estado USUARIO ?jugador)
  ?p <-	(poner ?x ?y)
  (ficha ?n ?fx ?fy)
  (test (or
	 (and (= ?x ?fx) (= ?y ?fy))
	 (and (= ?x ?fy) (= ?y ?fx))
	 ))
  (jugador (n ?otro)(fichas $?dummy1 ?n $?dummy2))
  (test (<> ?otro ?jugador))
  =>
  (printout t "ERROR, esa ficha no es tuya: "
	    ?x "·" ?y crlf)
  (retract ?p ?e)
  (assert (estado TURNO ?jugador))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Leemos por el teclado ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Entrada del usuario
(defrule tirada_jugador
  (declare (salience 50))
  (estado USUARIO ?jugador)
  (jugador (n ?jugador) (tipo HUMANO))
  =>
  (C_msg ?*MSG_ESCOGE*)
  (printout t "Escoge la ficha: " crlf)
;;;	   (bind ?x (read))
;;;	   (bind ?y (read))
  (bind $?xy (C_leer_ficha))
  (bind ?x (nth$ 1 $?xy))
  (bind ?y (nth$ 2 $?xy))
  (bind ?head (nth$ 3 $?xy))
  (if (= ?x -1) then
    (assert (pasar ?jugador))
    else (assert (poner ?x ?y))
    )
  (if (= ?head 1) then
    (assert (purga TAIL))
    else (assert (purga HEAD)))
  (C_flip)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction leer_tipo(?j)
  (bind ?tipo nada)
  (C_traza 1)
  (while (and (neq ?tipo CPU)(neq ?tipo HUMANO))
    (C_msg ?*MSG_TIPO*)
    (C_flip)
    (printout t "Elige el tipo del jugador " ?j ": ")
    (bind ?tipo (read))
    )
  (C_traza 0)
  ?tipo
  )

(deffunction iniciar()
  (reset)
  (load cpu.clp)
  (load refranes.clp)
  (seed (mod (C_time) 1024))
  ;;(seed 125)
  (C_sdl_init)
  (C_fichas 0 7)
  (C_fichas 1 7)
  (C_fichas 2 7)
  (C_fichas 3 7)
  (C_mostrar_mesa)
  (printout t "Tipos validos: HUMANO CPU" crlf)
;;  (bind ?tipo0 HUMANO) ;(leer_tipo 0))
;;  (bind ?tipo1 CPU) ;(leer_tipo 1))
;;  (bind ?tipo2 CPU) ;(leer_tipo 2))
;;  (bind ?tipo3 CPU);(leer_tipo 3))
  (C_traza 1)
  (C_msg ?*MSG_TIPO*)
  (C_flip)
  (bind $?elige (C_elige_jugadores))
  (if (= (nth$ 1 $?elige) 0) then
    (bind ?tipo0 CPU)
    else (bind ?tipo0 HUMANO)
    )
  (if (= (nth$ 2 $?elige) 0) then
    (bind ?tipo1 CPU)
    else (bind ?tipo1 HUMANO)
    )
  (if (= (nth$ 3 $?elige) 0) then
    (bind ?tipo2 CPU)
    else (bind ?tipo2 HUMANO)
    )
  (if (= (nth$ 4 $?elige) 0) then
    (bind ?tipo3 CPU)
    else (bind ?tipo3 HUMANO)
    )
  (assert (mano (nth$ 5 $?elige)))
  (assert
   (jugador
    (n 0)
    (tipo ?tipo0) ;; HUMANO o CPU
    (fichas)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   (jugador
    (n 1)
    (tipo ?tipo1)
    (fichas)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   (jugador
    (n 2)
    (tipo ?tipo2)
    (fichas)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   (jugador
    (n 3)
    (tipo ?tipo3)
    (fichas)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   )
  (assert
   (cierre 0 0 0 0 0 0 0)
   (estado REPARTIR)
   (mesa)
   )
  (run)
  )
