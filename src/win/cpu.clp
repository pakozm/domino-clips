;;;;;;;;;;;;;;;;;;;;;;;
;; Estados de la CPU ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Cambio de estado para busar la ficha más favorable
(defrule cambiar_estado0
  (declare (salience 25))
  ?e <-	(estado CPU ?jugador)
  =>
  (retract ?e)
  (assert (estado MAXIMIZAR ?jugador)
	  (max -1 -1)
	  (elige -1 -1))
  )

;; Cambio de estado para poner la ficha elegida anteriormente
(defrule cambiar_estado1
  (declare (salience 25))
  ?e <-	(estado MAXIMIZAR ?jugador)
  =>
  (retract ?e)
  (assert (estado PONER_CPU ?jugador))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reglas para buscar la ficha mejor valorada ;;
;;	      y borrar los valores	      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Eliminamos todas las marcas de las reglas
;; que valoran las fichas
(defrule eliminar_reglas
  (declare (salience 40))
  ?r <-	(disparo $?datos)
  (estado MAXIMIZAR ?jugador)
  =>
  (retract ?r)
  )

;; Ponemos a cero todos los valores
(defrule poner_a_cero
  (declare (salience 50))
  ?v <-	(valor ?n ?valorh ?valort)
  (estado MAXIMIZAR ?jugador)
  (test (or (> ?valorh 0) (> ?valort 0)))
  =>
  (retract ?v)
  (assert (valor ?n 0 0))
  )

;; Eliminamos las valoraciones de fichas que no se pueden
;; colocar en la mesa
(defrule eliminar_valores_erroneos_HEAD
  (declare (salience 200))
  (estado MAXIMIZAR ?jugador)
  ?v <-	(valor ?n ?valorh ?valort)
  (ficha ?n ?x ?y)
  (mesa ?head ?sentido $?resto)
  (ficha ?head ?hx ?hy)
  (test (not
	 (or
	  (and (= ?sentido 1) (or (= ?x ?hx) (= ?y ?hx)))
	  (and (= ?sentido 0) (or (= ?x ?hy) (= ?y ?hy)))
	  )
	 ))
  (test (> ?valorh 0))
  =>
  (retract ?v)
  (assert (valor ?n 0 ?valort))
  )

(defrule eliminar_valores_erroneos_TAIL
  (declare (salience 200))
  ?v <-	(valor ?n ?valorh ?valort)
  (estado MAXIMIZAR ?jugador)
  (ficha ?n ?x ?y)
  (mesa $?resto ?tail ?sentido)
  (ficha ?tail ?tx ?ty)
  (test (not
	 (or
	  (and (= ?sentido 1) (or (= ?x ?ty) (= ?y ?ty)))
	  (and (= ?sentido 0) (or (= ?x ?tx) (= ?y ?tx)))
	  )
	 ))
  (test (> ?valort 0))
  =>
  (retract ?v)
  (assert (valor ?n ?valorh 0))
  )

;; Buscamos la ficha con el máximo valor
(defrule buscar_maximo_HEAD
  (declare (salience 100))
  (estado MAXIMIZAR ?jugador)
  ?v <-	(valor ?n ?valorh ?valort)
  ?m <-	(max ?maxh ?maxt)
  ?e <-	(elige ?eligeh ?eliget)
  (ficha ?n ?x ?y)
;; TODO: Solo para trazas
;;  (test (>= ?valorh ?maxh))
  (test (> ?valorh 0))
  =>
  (if (>= ?valorh ?maxh) then
    (retract ?v ?m ?e)
    (assert (valor ?n 0 ?valort)
	    (max ?valorh ?maxt)
	    (elige ?n ?eliget))
    )
  (printout t "  =====> Ficha_head: "
	    ?x "·" ?y " " ?valorh crlf)
  )

(defrule buscar_maximo_TAIL
  (declare (salience 100))
  (estado MAXIMIZAR ?jugador)
  ?v <-	(valor ?n ?valorh ?valort)
  ?m <-	(max ?maxh ?maxt)
  ?e <-	(elige ?eligeh ?eliget)
  (ficha ?n ?x ?y)
;; TODO: Solo para trazas
;;  (test (> ?valort ?maxt))
  (test (> ?valort 0))
  =>
  (if (> ?valort ?maxt) then
    (retract ?v ?m ?e)
    (assert (valor ?n ?valorh 0)
	    (max ?maxh ?valort)
	    (elige ?eligeh ?n))
    )
  (printout t "  =====> Ficha_tail: "
	    ?x "·" ?y " " ?valort crlf)
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Regla para indicar cual es la ficha elegida ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; No hemos encontrado ninguna ficha 
(defrule indicar_que_pasa
  (declare (salience 200))
  ?e <-	(estado PONER_CPU ?jugador)
  ?m <-	(max -1 -1)
  ?l <-	(elige -1 -1)
  (tirada ?tirada)
  =>
  (retract ?e ?m ?l)
  (assert
   (estado PONER_FICHA ?jugador)
   (pasar ?jugador)
   )
  )

;; Pone la primera ficha
(defrule indicar_ficha_primera
  (declare (salience 100))
  ?e <-	(estado PONER_CPU ?jugador)
  ?m <-	(max ?maxh ?maxt)
  ?l <-	(elige ?eligeh ?eliget)
  (tirada 0)
  (ficha ?eligeh ?hx ?hy)
  (ficha ?eliget ?tx ?ty)
  (mesa)
  =>
  (bind ?px ?tx)
  (bind ?py ?ty)
  (if (> ?maxh ?maxt) then
    (bind ?px ?hx)
    (bind ?py ?hy)
    )
  (retract ?e ?m ?l)
  (assert
   (estado PONER_FICHA ?jugador)
   (poner ?px ?py)
   )
  )

;; Pone una ficha
(defrule indicar_ficha_CPU_HEAD
  (declare (salience 100))
  ?e <-	(estado PONER_CPU ?jugador)
  ?m <-	(max ?maxh ?maxt)
  ?l <-	(elige ?eligeh ?eliget)
  (tirada ?tirada)
  (test (>= ?maxh ?maxt))
  (ficha ?eligeh ?x ?y)
  (mesa ?head ?sentido $?resto)
  (ficha ?head ?fx ?fy)
  (test (or
	 (and (= ?sentido 1) (or (= ?y ?fx) (= ?x ?fx)))
	 (and (= ?sentido 0) (or (= ?y ?fy) (= ?x ?fy)))
	 ))
  =>
  (bind ?px ?x)
  (bind ?py ?y)
  (if (or
       (and (= ?sentido 1) (= ?x ?fx))
       (and (= ?sentido 0) (= ?x ?fy))) then
    (bind ?px ?y)
    (bind ?py ?x)
    )
  (retract ?e ?m ?l)
  (assert
   (purga TAIL)
   (estado PONER_FICHA ?jugador)
   (poner ?px ?py)
   )
  )

(defrule indicar_ficha_CPU_TAIL
  (declare (salience 100))
  ?e <-	(estado PONER_CPU ?jugador)
  ?m <-	(max ?maxh ?maxt)
  ?l <-	(elige ?eligeh ?eliget)
  (tirada ?tirada)
  (test (> ?maxt ?maxh))
  (ficha ?eliget ?x ?y)
  (mesa $?resto ?tail ?sentido)
  (ficha ?tail ?fx ?fy)
  (test (or
	 (and (= ?sentido 1) (or (= ?y ?fy) (= ?x ?fy)))
	 (and (= ?sentido 0) (or (= ?y ?fx) (= ?x ?fx)))
	 ))
  =>
  (bind ?px ?x)
  (bind ?py ?y)
  (if (or
       (and (= ?sentido 1) (= ?y ?fy))
       (and (= ?sentido 0) (= ?y ?fx))) then
    (bind ?px ?y)
    (bind ?py ?x)
    )
  (retract ?e ?m ?l)
  (assert
   (purga HEAD)
   (estado PONER_FICHA ?jugador)
   (poner ?px ?py)
   )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reglas parar poner fichas al azar ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; La primera ficha será la de mayor valor
(defrule valorar_ficha_primera
  (declare (salience 50))
  (estado CPU ?jugador)
  ?m <-	(mesa)
  ?j <-	(jugador (n ?jugador) (tipo CPU)
		 (fichas $?fichas1 ?ficha $?fichas2))
  ?f <-	(ficha ?ficha ?fx ?fy)
  ?v <-	(valor ?ficha ?valorh ?valort)
  (not (exists (disparo ?ficha valorar_ficha_primera)))
  =>
  (retract ?v)
  (assert (valor ?ficha
		 (+ ?valorh (+ ?fx ?fy 1))
		 (+ ?valort (+ ?fx ?fy 1)))
	  (disparo ?ficha valorar_ficha_primera))
  )

;; Valoramos las fichas dando mayor preferencia
;; a las más grandes
(defrule valorar_ficha_HEAD
  (declare (salience 50))
  (estado CPU ?jugador)
  ?m <-	(mesa ?head ?sentido $?resto)
  ?j <-	(jugador (n ?jugador) (tipo CPU)
		 (fichas $?fichas1 ?ficha $?fichas2))
  ?f <-	(ficha ?ficha ?fx ?fy)
  (ficha ?head ?hx ?hy)
  ?v <-	(valor ?ficha ?valorh ?valort)
  (not (exists (disparo ?ficha valorar_ficha_HEAD)))
  ;; La ficha debe poderse encadenar con la que está en la mesa
  (test (or
	 (and (= ?sentido 1) (or (= ?fx ?hx) (= ?fy ?hx)))
	 (and (= ?sentido 0) (or (= ?fx ?hy) (= ?fy ?hy)))
	 ))
  =>
  (bind ?s 1)
  (if (or
       (and (= ?sentido 1) (= ?fx ?hx))
       (and (= ?sentido 0) (= ?fx ?hy))) then
    (bind ?s 0)
    )
  (retract ?v)
  (assert (valor ?ficha (+ ?valorh (+ ?fx ?fy 1)) ?valort)
	  (disparo ?ficha valorar_ficha_HEAD))
  )

(defrule valorar_ficha_TAIL
  (declare (salience 50))
  (estado CPU ?jugador)
  ?m <-	(mesa $?resto ?tail ?sentido)
  ?j <-	(jugador (n ?jugador) (tipo CPU)
		 (fichas $?fichas1 ?ficha $?fichas2))
  ?f <-	(ficha ?ficha ?fx ?fy)
  (ficha ?tail ?tx ?ty)
  ?v <-	(valor ?ficha ?valorh ?valort)
  (not (exists (disparo ?ficha valorar_ficha_TAIL)))
  ;; La ficha debe poderse encadenar con la que está en la cola de la mesa
  (test (or
	 (and (= ?sentido 1) (or (= ?fx ?ty) (= ?fy ?ty)))
	 (and (= ?sentido 0) (or (= ?fx ?tx) (= ?fy ?tx)))
	 ))
  =>
  (bind ?s 1)
  (if (or
       (and (= ?sentido 1) (= ?fy ?ty))
       (and (= ?sentido 0) (= ?fy ?tx))) then
    (bind ?s 0)
    )
  (retract ?v)
  (assert (valor ?ficha ?valorh (+ ?valort (+ ?fx ?fy 1)))
	  (disparo ?ficha valorar_ficha_TAIL))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reglas extra, a parte de los refranes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; las metemos todas en tiene
(defrule averiguar_que_puede_tener1
  (declare (salience 200))
  (estado CPU ?yo)
  ?bla <- (jugador (n ?jugador) (tipo ?tipo)
		   (tiene $?tiene) (abre $?abre)
		   (pasa $?pasa) (fichas $?fichas)
		   (puso $?puso) (palos $?palos))
  (test (<> ?yo ?jugador))
  (not (exists (disparo averiguar1 ?jugador)))
  =>
  (retract ?bla)
  (assert (jugador (n ?jugador)
		   (tiene 1 1 1 1 1 1 1)
		   (abre $?abre)
		   (pasa $?pasa)
		   (fichas $?fichas)
		   (puso $?puso)
		   (tipo ?tipo)
		   (palos $?palos)
		   )
	  (disparo averiguar1 ?jugador)
	  )
  )

;; quitamos de la lista si ha pasado al tener que lanzar ese numero
(defrule averiguar_que_puede_tener2
  (declare (salience 180))
  (estado CPU ?yo)
  ?bla <- (jugador (n ?jugador) (tiene $?tiene)
		   (abre $?abre)
		   (pasa $?pasa1 ?pasa $?pasa2)
		   (fichas $?fichas)
		   (puso $?puso)
		   (tipo ?tipo)
		   (palos $?palos)
		   )
  (test (<> ?yo ?jugador))
  (not (exists (disparo averiguar2 ?jugador ?pasa)))
  =>
  (retract ?bla)
  (bind $?tiene (replace$ $?tiene (+ ?pasa 1) (+ ?pasa 1) 0))
  (assert (jugador (n ?jugador)
		   (tiene $?tiene)
		   (abre $?abre)
		   (pasa $?pasa)
		   (fichas $?fichas)
		   (puso $?puso)
		   (tipo ?tipo)
		   (palos $?palos)
		   ))
  (assert (disparo averiguar2 ?jugador ?pasa))
  )

;; quitamos de la lista aquellas que ya están en la mesa o tengo yo
(defrule averiguar_que_puede_tener4
  (declare (salience 170))
  (estado CPU ?yo)
  (jugador (n ?yo) (palos $?palos1 ?palo $?palos2))
  ?bla <- (jugador (n ?jugador)
		   (tiene $?tiene)
		   (abre $?abre)
		   (pasa $?pasa)
		   (fichas $?fichas)
		   (puso $?puso)
		   (tipo ?tipo)
		   (palos $?palos)
		   )
  (cierre $?cierre1 ?cierre $?cierre2)
  ;; Esto produce que se equivoque cuando
  ;; tiene una ficha doble, ya que la cuenta
  ;; dos veces y produce cierre en ocasiones
  ;; en las que no toca
  (test (>= (+ ?cierre ?palo) 7))
  (test (<> ?yo ?jugador))
  (ficha ?numero ?x ?y)
  (test (= ?numero (length$ $?cierre1)))
  (test (= ?numero (length$ $?palos1)))
  (not (exists (disparo averiguar4 ?jugador ?numero)))
  =>
  (retract ?bla)
  (bind $?tiene (replace$ $?tiene
			  (+ ?numero 1)
			  (+ ?numero 1) 0))
  (assert (jugador (n ?jugador)
		   (tiene $?tiene)
		   (abre $?abre)
		   (pasa $?pasa)
		   (fichas $?fichas)
		   (puso $?puso)
		   (tipo ?tipo)
		   (palos $?palos)
		   ))
  (assert (disparo averiguar4 ?jugador ?numero))
  )

;; dar mas prioridad a las que ha abierto
(defrule averiguar_que_puede_tener3
  (declare (salience 190))
  (estado CPU ?yo)
  ?bla <- (jugador (n ?jugador)
		   (tiene $?tiene)
		   (abre $?abre1 ?abre $?abre2)
		   (pasa $?pasa)
		   (fichas $?fichas)
		   (puso $?puso)
		   (tipo ?tipo)
		   (palos $?palos)
		   )
  (test (<> ?yo ?jugador))
  (not (exists (disparo averiguar3 ?jugador ?abre)))
  =>
  (retract ?bla)
  (bind $?tiene (replace$ $?tiene
			  (+ ?abre 1) (+ ?abre 1)
			  (+ (nth$ (+ ?abre 1) $?tiene) 1)))
  (assert (jugador (n ?jugador) (tiene $?tiene)
		   (abre $?abre1 ?abre $?abre2)
		   (pasa $?pasa) (fichas $?fichas)
		   (puso $?puso) (tipo ?tipo)
		   (palos $?palos)
		   ))
  (assert (disparo averiguar3 ?jugador ?abre))
  )

;; Valoramos mejor las fichas que tenemos repetidas
(defrule cuenta_repetidas_X
  (declare (salience 30))
  (estado CPU ?jugador)
  (ficha ?una ?rep ?y)
  ?v <-	(valor ?una ?valorh ?valort)
  (jugador (n ?jugador) (fichas $?dummy1 ?una $?dummy2)
	   (palos $?palos1 ?palo $?palos2))
  (test (= ?rep (length$ $?palos1)))
  (mesa ?head ?sh $?resto ?tail ?st)
  (ficha ?head ?hx ?hy)
  (ficha ?tail ?tx ?ty)
  (test
   (or
    (or
     (and (= ?sh 1) (= ?y ?hx))
     (and (= ?sh 0) (= ?y ?hy))
     )
    (or
     (and (= ?st 1) (= ?y ?ty))
     (and (= ?st 0) (= ?y ?tx))
     )
    )
   )
  (not (exists (disparo cuenta_repetidas_X ?una ?rep)))
  =>
  (bind ?addh 0)
  (bind ?addt 0)
  (if (or
       (and (= ?sh 1) (= ?y ?hx))
       (and (= ?sh 0) (= ?y ?hy))) then (bind ?addh 3)
       )
  (if (or
       (and (= ?st 1) (= ?y ?ty))
       (and (= ?st 0) (= ?y ?tx))) then (bind ?addt 3)
       )
		
  (retract ?v)
  (assert
   (valor ?una (+ ?valorh ?addh) (+ ?valort ?addt))
   (disparo cuenta_repetidas_X ?una ?rep)
   )
  )

(defrule cuenta_repetidas_Y
  (declare (salience 30))
  (estado CPU ?jugador)
  (ficha ?una ?x ?rep)
  ?v <-	(valor ?una ?valorh ?valort)
  (jugador (n ?jugador) (fichas $?dummy1 ?una $?dummy2)
	   (palos $?palos1 ?palo $?palos2))
  (test (= ?rep (length$ $?palos1)))
  (mesa ?head ?sh $?resto ?tail ?st)
  (ficha ?head ?hx ?hy)
  (ficha ?tail ?tx ?ty)
  (test
   (or
    (or
     (and (= ?sh 1) (= ?x ?hx))
     (and (= ?sh 0) (= ?x ?hy))
     )
    (or
     (and (= ?st 1) (= ?x ?ty))
     (and (= ?st 0) (= ?x ?tx))
     )
    )
   )
  (not (exists (disparo cuenta_repetidas_Y ?una ?rep)))
  =>
  (bind ?addh 0)
  (bind ?addt 0)
  (if (or
       (and (= ?sh 1) (= ?x ?hx))
       (and (= ?sh 0) (= ?x ?hy))) then (bind ?addh 3)
       )
  (if (or
       (and (= ?st 1) (= ?x ?ty))
       (and (= ?st 0) (= ?x ?tx))) then (bind ?addt 3)
       )
  (retract ?v)
  (assert
   (valor ?una (+ ?valorh ?addh) (+ ?valort ?addt))
   (disparo cuenta_repetidas_Y ?una ?rep)
   )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
