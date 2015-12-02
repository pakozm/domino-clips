;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Refranes implícitos por la forma de evaluar las fichas:
;; La salida del contrario, con tu mayor numerario
;; Si peligroso no fuera, doble gordo a la primera
;; Administra bien los dobles, son ricos o pobres
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (deffunction heuristico_puntos_jugador($?arg)
  (bind $?tiene (subseq$ $?arg 1 7))
  (bind $?fichas (subseq$ $?arg 8 (length$ $?arg)))
  (bind ?i 1)
  (bind ?min 10)
  (bind ?max 0)
  (bind ?extra 0)
  (while (<= ?i (length$ $?tiene)) do
	 (bind ?val (nth$ ?i $?tiene))
	 (if (> ?val 0) then
	   (if (< ?i ?min) then
	     (bind ?min ?i))
	   (if (> ?i ?max) then
	     (bind ?max ?i))
	   )
	 (bind ?i (+ ?i 1))
	 )
  (bind ?val (+
	      ?extra
	      (* ?min (length$ $?fichas))
	      (* (/ (+ ?min ?max) 2) (length$ $?fichas))))  
  ?val
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Refranes para controlar la CPU ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Compañerismo ;;;
;; La ficha del compañero, repetirla es lo primero
(defrule repetir_companyero_HEAD
  (declare (salience 75))
  (estado CPU ?jugador)
  (jugador (n ?jugador)
	   (fichas $?dummy1 ?ficha $?dummy2))
  (jugador (n ?compa) (abre $?abre ?ult)
	   (tiene $?tiene))
  (test (= ?compa (mod (+ ?jugador 2) 4)))
  ?v <-	(valor ?ficha ?valorh ?valort)
  (ficha ?ficha ?fx ?fy)
  (mesa ?head ?sentido $?resto)
  (ficha ?head ?hx ?hy)
  (test (or
	 (and
	  (= ?sentido 1)
	  (or
	   (and (= ?fx ?ult) (= ?fy ?hx))
	   (and (= ?fy ?ult) (= ?fx ?hx)))
	  )
	 (and
	  (= ?sentido 0)
	  (or
	   (and (= ?fx ?ult) (= ?fy ?hy))
	   (and (= ?fy ?ult) (= ?fx ?hy)))
	  )
	 ))
  (not (exists (disparo repetir_companyero_HEAD ?ficha)))
  =>
  (if (> (nth$ (+ ?ult 1) $?tiene) 0) then
    (retract ?v)
    (assert
     (valor ?ficha (+ ?valorh 5) ?valort)
     (disparo repetir_companyero_HEAD ?ficha)
     )
    (printout t tab "Repetir ficha compañero: "
	      ?fx "·" ?fy crlf)
    )
  )

(defrule repetir_companyero_TAIL
  (declare (salience 75))
  (estado CPU ?jugador)
  (jugador (n ?jugador) (fichas $?dummy1 ?ficha $?dummy2))
  (jugador (n ?compa) (abre $?abre ?ult)
	   (tiene $?tiene))
  (test (= ?compa (mod (+ ?jugador 2) 4)))
  ?v <-	(valor ?ficha ?valorh ?valort)
  (ficha ?ficha ?fx ?fy)
  (mesa $?resto ?tail ?sentido)
  (ficha ?tail ?tx ?ty)
  (test (or
	 (and
	  (= ?sentido 1)
	  (or
	   (and (= ?fx ?ult) (= ?fy ?ty))
	   (and (= ?fy ?ult) (= ?fx ?ty)))
	  )
	 (and
	  (= ?sentido 0)
	  (or
	   (and (= ?fx ?ult) (= ?fy ?tx))
	   (and (= ?fy ?ult) (= ?fx ?tx)))
	  )
	 ))
  (not (exists (disparo repetir_companyero_TAIL ?ficha)))
  =>
  (if (> (nth$ (+ ?ult 1) $?tiene) 0) then
    (retract ?v)
    (assert
     (valor ?ficha ?valorh (+ ?valort 5))
     (disparo repetir_companyero_TAIL ?ficha)
     )
    (printout t tab "Repetir ficha compañero: "
	      ?fx "·" ?fy crlf)
    )
  )

;; Cuando el otro ofrece el cierre, seguro está que no pierde.
;;(defrule cierre_contrario
;;  (declare (salience 29))
;;  (estado CPU ?jugador)
;;  (jugador (n ?jugador) (fichas $?dummy1 ?ficha $?dummy2))
;;   (jugador (n ?otro) (abre $?abre1 ?abre))
;;   (test (es_rival ?jugador ?otro))
;;   (ficha ?ficha ?x ?y)
;;   (test (or (= ?x ?abre) (= ?y ?abre)))
;;   (mesa $?head ?abre ?sentido $?tail)
;;   (test (or
;; 	 (= (length$ $?head) 0)
;; 	 (= (length$ $?tail) 0)
;; 	 ))
;;   ?v <-	(valor ?ficha ?valorh ?valort)
;;   (cierre $?cierre)
;;   (test (> (nth$ (+ ?abre 1) $?cierre) 6))
;;   (not (exists (disparo cierre_contrario ?ficha)))
;;   ;; TODO: Comprobar la coherencia con la otra regla de cierres
;;   =>
;;   (retract ?v)
;;   (assert
;;    (valor ?ficha (- ?valorh 10) (- ?valort 10))
;;    (disparo cierre_contrario ?ficha)
;;    )
;;   (printout t tab "Cierre del contrario: " ?x " " ?y crlf)
;;   )

;; Mata ficha del amigo, antes que entre el enemigo
(defrule mata_ficha_de_la_amiga___antes_que_entre_la_enemiga_HEAD
  (declare (salience 45))
  (estado CPU ?yo)
  ?f <- (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (jugador (n ?amigo) (abre $?abre1 ?abre))
  (jugador (n ?otro) (tiene $?tiene))
  (test (es_rival ?otro ?yo))
  (test (not (es_rival ?amigo ?yo)))
  (test (<> ?yo ?amigo))
  (mesa ?head ?dir $?mesa)
  (ficha ?ficha ?x ?y)
  (test (<> ?x ?y))
  (test (or (= ?x ?abre) (= ?y ?abre)))
  (ficha ?head ?hx ?hy)
  (test (or (and (= ?dir 1) (= ?hx ?abre))
	    (and (= ?dir 0) (= ?hy ?abre))))
;;;	(test (> (nth$ (+ ?abre 1) $?tiene) 0))
  ?v <-	(valor ?ficha ?valorh ?valort)
  (not (exists (disparo mata_ficha_HEAD ?ficha)))
  =>
  (if (> (nth$ (+ ?abre 1) $?tiene) 0) then
;;;		(printout t (nth$ (+ ?abre 1) $?tiene) crlf)
    (retract ?v)
    (assert (disparo mata_ficha_HEAD ?ficha)
	    (valor ?ficha (+ ?valorh 5) ?valort))
    (printout t tab
	      "Mata ficha del amigo, antes que entre el enemigo: "
	      ?x "·" ?y crlf)
    )
  )

(defrule mata_ficha_de_la_amiga___antes_que_entre_la_enemiga_TAIL
  (declare (salience 45))
  (estado CPU ?yo)
  ?f <- (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (jugador (n ?amigo) (abre $?abre1 ?abre))
  (jugador (n ?otro) (tiene $?tiene))
  (test (es_rival ?otro ?yo))
  (test (not (es_rival ?amigo ?yo)))
  (test (<> ?yo ?amigo))
  (mesa $?mesa ?tail ?dir)
  (ficha ?ficha ?x ?y)
  (test (<> ?x ?y))
  (test (or (= ?x ?abre) (= ?y ?abre)))
  (ficha ?tail ?tx ?ty)
  (test (or (and (= ?dir 0) (= ?tx ?abre)) (and (= ?dir 1) (= ?ty ?abre))))
;;;	(test (> (nth$ (+ ?abre 1) $?tiene) 0))
  ?v <-	(valor ?ficha ?valorh ?valort)
  (not (exists (disparo mata_ficha_TAIL ?ficha)))
  =>	
  (if (> (nth$ (+ ?abre 1) $?tiene) 0) then
    (retract ?v)
    (assert (disparo mata_ficha_TAIL ?ficha)
	    (valor ?ficha ?valorh (+ ?valort 5)))
    (printout t tab
	      "Mata ficha del amigo, antes que entre el enemigo: "
	      ?x "·" ?y crlf)
    )
  )

;; Siendo el compañero mano, ahorcarse si es necesario
;; TODO: Calcular la heurística para cada jugador,
;; y decidir si es necesario
(defrule siendo_el_companyero_mano_ahorcarse_si_es_necesario_HEAD
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo)
	   (fichas $?fichas1 ?ficha1 $?fichas2 ?ficha2 $?fichas3))
  (mano ?mano)
  (test (= ?mano (mod (+ ?yo 2) 4)))
  (ficha ?ficha1 ?x1 ?y1)
  (ficha ?ficha2 ?x2 ?y2)

  (ficha ?ficha_doble ?doble ?doble)
  (ficha ?ficha ?x ?y)
  (test (and
	 (or
	  (and
	   (= ?x1 ?y1)
	   (= ?ficha_doble ?ficha1)
	   (= ?ficha ?ficha2)
	   )
	  (and
	   (= ?x2 ?y2)
	   (= ?ficha_doble ?ficha2)
	   (= ?ficha ?ficha1)
	   ))
	 (or
	  (= ?x2 ?x1)
	  (= ?y2 ?y1))
	 )
	)
  
  (cierre $?cierre)
  (test (= (nth$ (+ ?doble 1) $?cierre) 5))
  ?v <- (valor ?ficha ?valorh ?valort)
  (mesa ?head ?sentido $?resto)
  (ficha ?head ?mx ?my)
  (test (or
	 (and (= ?sentido 1)
	      (= ?mx ?doble)
	      )
	 (and (= ?sentido 0)
	      (= ?my ?doble)
	      )
	 )
	)
  (not (exists
	(disparo
	 siendo_el_companyero_mano_ahorcarse_si_es_necesario_HEAD
	 ?ficha)))
  =>
  (retract ?v)
  (assert (valor ?ficha (+ ?valorh 10) ?valort)
	  (disparo
	   siendo_el_companyero_mano_ahorcarse_si_es_necesario_HEAD
	   ?ficha)
	  )
  (printout t tab
	    "Siendo el compañero mano, ahorcarse si es necesario: "
	    ?x "·" ?y crlf)
  )

(defrule siendo_el_companyero_mano_ahorcarse_si_es_necesario_TAIL
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo)
	   (fichas $?fichas1 ?ficha1 $?fichas2 ?ficha2 $?fichas3))
  (mano ?mano)
  (test (= ?mano (mod (+ ?yo 2) 4)))
  (ficha ?ficha1 ?x1 ?y1)
  (ficha ?ficha2 ?x2 ?y2)

  (ficha ?ficha_doble ?doble ?doble)
  (ficha ?ficha ?x ?y)
  (test (and
	 (or
	  (and
	   (= ?x1 ?y1)
	   (= ?ficha_doble ?ficha1)
	   (= ?ficha ?ficha2)
	   )
	  (and
	   (= ?x2 ?y2)
	   (= ?ficha_doble ?ficha2)
	   (= ?ficha ?ficha1)
	   ))
	 (or
	  (= ?x2 ?x1)
	  (= ?y2 ?y1))
	 )
	)
  (cierre $?cierre)
  (test (= (nth$ (+ ?doble 1) $?cierre) 5))
  ?v <- (valor ?ficha ?valorh ?valort)
  (mesa $?resto ?head ?sentido)
  (ficha ?head ?mx ?my)
  (test (or
	 (and (= ?sentido 0)
	      (= ?mx ?doble)
	      )
	 (and (= ?sentido 1)
	      (= ?my ?doble)
	      )
	 )
	)
  (not (exists
	(disparo
	 siendo_el_companyero_mano_ahorcarse_si_es_necesario_TAIL
	 ?ficha)))
  =>
  (retract ?v)
  (assert (valor ?ficha ?valorh (+ ?valort 10))
	  (disparo
	   siendo_el_companyero_mano_ahorcarse_si_es_necesario_TAIL
	   ?ficha)
	  )
  (printout t tab
	    "Siendo el compañero mano, ahorcarse si es necesario: "
	    ?x "·" ?y crlf)
  )

;; Perseguirás con ahinco al seis doble y doble cinco
(defrule perseguiras_con_ahinco_HEAD
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (mesa ?head $?resto)
  (ficha ?head ?mx ?mx)
  (ficha ?ficha ?x ?y)
  (test (or (= ?x ?mx) (= ?y ?mx)))
  (test (or (= ?mx 5) (= ?mx 6)))
  ?v <-  (valor ?ficha ?valorh ?valort)
  (not (exists (disparo perseguiras_con_ahinco_HEAD ?ficha)))
  =>
  (retract ?v)
  (assert (valor ?ficha (+ ?valorh 10) ?valort)
	  (disparo perseguiras_con_ahinco_HEAD ?ficha)
	  )
  (printout t tab
	    "Perseguiras con ahinco al seis doble y al doble cinco: "
	    ?x "·" ?y crlf)
  )

(defrule perseguiras_con_ahinco_TAIL
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (mesa $?resto ?tail ?sentido)
  (ficha ?tail ?mx ?mx)
  (ficha ?ficha ?x ?y)
  (test (or (= ?x ?mx) (= ?y ?mx)))
  (test (or (= ?mx 5) (= ?mx 6)))
  ?v <-  (valor ?ficha ?valorh ?valort)
  (not (exists (disparo perseguiras_con_ahinco_TAIL ?ficha)))
  =>
  (retract ?v)
  (assert (valor ?ficha ?valorh (+ ?valort 10))
	  (disparo perseguiras_con_ahinco_TAIL ?ficha)
	  )
  (printout t tab
	    "Perseguiras con ahinco al seis doble y al doble cinco: "
	    ?x "·" ?y crlf)
  )

;; Siempre que quieras cerrar, los tantos has de contar
(defrule querer_cerrar_HEAD
  (declare (salience 44))
  (estado CPU ?yo)
  (jugador (n ?yo)
	   (fichas $?fichas_H ?ficha $?fichas_T)
	   (palos $?palos))
  (jugador (n ?uno)
	   (fichas $?fichas1) (tiene $?tiene1))
  (jugador (n ?otro)
	   (fichas $?fichas3) (tiene $?tiene3))
  (jugador (n ?compi)
	   (fichas $?fichas2) (tiene $?tiene2))
  (test (and
	 (es_rival ?uno ?yo)
	 (es_rival ?otro ?yo)
	 (<> ?uno ?otro)
	 (not (es_rival ?compi ?yo))
	 (<> ?yo ?compi)
	 )
	)
  (ficha ?ficha ?x ?y)
  ?v <- (valor ?ficha ?valorh ?valort)
  (mesa ?head ?sentidoh $?resto ?tail ?sentidot)
  (dobles_mesa $?dobles)
  (ficha ?head ?mx ?my)
  (ficha ?tail ?tx ?ty)
  (cierre $?cierre)
  (test
   (or
    ;;; Primera parte del test
    (and
     (and
      (= ?sentidoh 1)
      (= ?sentidot 1)
      )
     (or
      (and
       (= ?mx ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?ty ?y)
       )
      (and
       (= ?mx ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?ty ?x)
       )
      )
     )
    ;;; Segunda parte del test
    (and
     (and
      (= ?sentidoh 0)
      (= ?sentidot 1)
      )
     (or
      (and
       (= ?my ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?ty ?y)
       )
      (and
       (= ?my ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?ty ?x)
       )
      )
     )
    ;;; Tercera parte del test
    (and
     (and
      (= ?sentidoh 1)
      (= ?sentidot 0)
      )
     (or
      (and
       (= ?mx ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?tx ?y)
       )
      (and
       (= ?mx ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?tx ?x)
       )
      )
     )
    ;;; Cuarta parte del test
    (and
     (and
      (= ?sentidoh 0)
      (= ?sentidot 0)
      )
     (or
      (and
       (= ?my ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?tx ?y)
       )
      (and
       (= ?my ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?tx ?x)
       )
      )
     )
    )
   )
  (not (exists (disparo querer_cerrar_HEAD ?ficha)))
  =>
  ;; Conteo de puntos
  (bind ?i 1)
  (bind ?puntos_yo 0)
  (while (<= ?i (length$ $?palos)) do
	 (bind ?puntos_yo
	       (+ ?puntos_yo (* (nth$ ?i $?palos) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (bind ?puntos_yo (- ?puntos_yo ?x ?y))
  (bind ?val1 (heuristico_puntos_jugador $?tiene1 $?fichas1))
  (bind ?val2 (heuristico_puntos_jugador $?tiene2 $?fichas2))
  (bind ?val3 (heuristico_puntos_jugador $?tiene3 $?fichas3))
  (if (= (min ?puntos_yo ?val1 ?val2 ?val3) ?puntos_yo) then
    (bind ?val 10)
    else
    (bind ?val -20)
    )
  (if (<= (+ ?valorh ?val) 0) then
    (bind ?val (- 1 ?valorh))
    )
  ;; Valoracion de la ficha
  (retract ?v)
  (assert
   (valor ?ficha (+ ?valorh ?val) ?valort)
   (disparo querer_cerrar_HEAD ?ficha))
  (printout t tab
	    "Si quieres cerrar, los tantos has de contar: "
	    ?x "·" ?y " " ?val crlf
	    tab tab "Jugador " ?yo ": " ?puntos_yo crlf
	    tab tab "Jugador " ?compi ": " ?val2 " " $?tiene2 crlf
	    tab tab "Jugador " ?uno ": " ?val1 " " $?tiene1 crlf
	    tab tab "Jugador " ?otro ": " ?val3 " " $?tiene3 crlf)
  )

(defrule querer_cerrar_TAIL
  (declare (salience 44))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas_H ?ficha $?fichas_T)
	   (palos $?palos))
  (jugador (n ?uno) (fichas $?fichas1) (tiene $?tiene1))
  (jugador (n ?otro) (fichas $?fichas3) (tiene $?tiene3))
  (jugador (n ?compi) (fichas $?fichas2) (tiene $?tiene2))
  (test (and
	 (es_rival ?uno ?yo)
	 (es_rival ?otro ?yo)
	 (<> ?uno ?otro)
	 (not (es_rival ?compi ?yo))
	 (<> ?yo ?compi)
	 )
	)
  (ficha ?ficha ?x ?y)
  ?v <- (valor ?ficha ?valorh ?valort)
  (mesa ?tail ?sentidot $?resto ?head ?sentidoh)
  (dobles_mesa $?dobles)
  (ficha ?head ?my ?mx)
  (ficha ?tail ?ty ?tx)
  (cierre $?cierre)
  (test
   (or
    ;;; Primera parte del test
    (and
     (and
      (= ?sentidoh 1)
      (= ?sentidot 1)
      )
     (or
      (and
       (= ?mx ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?ty ?y)
       )
      (and
       (= ?mx ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?ty ?x)
       )
      )
     )
    ;;; Segunda parte del test
    (and
     (and
      (= ?sentidoh 0)
      (= ?sentidot 1)
      )
     (or
      (and
       (= ?my ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?ty ?y)
       )
      (and
       (= ?my ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?ty ?x)
       )
      )
     )
    ;;; Tercera parte del test
    (and
     (and
      (= ?sentidoh 1)
      (= ?sentidot 0)
      )
     (or
      (and
       (= ?mx ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?tx ?y)
       )
      (and
       (= ?mx ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?tx ?x)
       )
      )
     )
    ;;; Cuarta parte del test
    (and
     (and
      (= ?sentidoh 0)
      (= ?sentidot 0)
      )
     (or
      (and
       (= ?my ?x)
       (or
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 1)
	 (>= (nth$ (+ ?y 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?y 1) $?dobles) 0)
	 (>= (nth$ (+ ?y 1) $?cierre) 5)
	 )
	)
       (= ?tx ?y)
       )
      (and
       (= ?my ?y)
       (or
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 1)
	 (>= (nth$ (+ ?x 1) $?cierre) 6)
	 )
	(and
	 (= (nth$ (+ ?x 1) $?dobles) 0)
	 (>= (nth$ (+ ?x 1) $?cierre) 5)
	 )
	)
       (= ?tx ?x)
       )
      )
     )
    )
   )
  (not (exists (disparo querer_cerrar_TAIL ?ficha)))
  =>
  ;; Conteo de puntos
  (bind ?i 1)
  (bind ?puntos_yo 0)
  (while (<= ?i (length$ $?palos)) do
	 (bind ?puntos_yo (+ ?puntos_yo
			     (* (nth$ ?i $?palos) (- ?i 1))))
	 (bind ?i (+ ?i 1))
	 )
  (bind ?puntos_yo (- ?puntos_yo ?x ?y))
  (bind ?val1 (heuristico_puntos_jugador $?tiene1 $?fichas1))
  (bind ?val2 (heuristico_puntos_jugador $?tiene2 $?fichas2))
  (bind ?val3 (heuristico_puntos_jugador $?tiene3 $?fichas3))
  (if (= (min ?puntos_yo ?val1 ?val2 ?val3) ?puntos_yo) then
    (bind ?val 10)
    else
    (bind ?val -20)
    )
  (if (<= (+ ?valort ?val) 0) then
    (bind ?val (- 1 ?valort))
    )  
  ;; Valoracion de la ficha
  (retract ?v)
  (assert
   (valor ?ficha ?valorh (+ ?valort ?val))
   (disparo querer_cerrar_TAIL ?ficha))
  (printout t tab
	    "Si quieres cerrar, los tantos has de contar: "
	    ?x "·" ?y " " ?val crlf
	    tab tab "Jugador " ?yo ": " ?puntos_yo crlf
	    tab tab "Jugador " ?compi ": " ?val2 " " $?tiene2 crlf
	    tab tab "Jugador " ?uno ": " ?val1 " " $?tiene1 crlf
	    tab tab "Jugador " ?otro ": " ?val3 " " $?tiene3 crlf)
  )

;; La ficha que debes dar, la que al mano haga pasar

(defrule la_que_al_mano_haga_pasar_HEAD
  (declare (salience 45))
  (estado CPU ?yo)
  (mano ?mano)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (jugador (n ?mano) (tiene $?tiene))
  (test (es_rival ?mano ?yo))
  (mesa ?head ?sentido $?resto ?tail ?sentidot)
  (ficha ?ficha ?x ?y)
  (ficha ?head ?mx ?my)
  (ficha ?tail ?tx ?ty)
;; TODO: Este test falla
;;   (test
;;    (or
;;     (and
;;      (= ?sentido 1)
;;      (or
;;       (and
;;        (= ?y ?mx)
;;        (= (nth$ (+ ?x 1) $?tiene) 0)
;;        )
;;       (and
;;        (= ?x ?mx)
;;        (= (nth$ (+ ?y 1) $?tiene) 0)
;;        )
;;       )
;;      )
;;     (and
;;      (= ?sentido 0)
;;      (or
;;       (and
;;        (= ?y ?my)
;;        (= (nth$ (+ ?x 1) $?tiene) 0)
;;        )
;;       (and
;;        (= ?x ?my)
;;        (= (nth$ (+ ?y 1) $?tiene) 0)
;;        )
;;       )
;;      )
;;     )
;;    )
  ?v <- (valor ?ficha ?valorh ?valort)
  (not (exists
	(disparo la_que_haga_al_mano_pasar_HEAD ?ficha)))
  =>
  (if
      (or
       (and
	(= ?sentido 1)
	(or
	 (and
	  (= ?y ?mx)
	  (= (nth$ (+ ?x 1) $?tiene) 0)
	  )
	 (and
	  (= ?x ?mx)
	  (= (nth$ (+ ?y 1) $?tiene) 0)
	  )
	 )
	)
       (and
	(= ?sentido 0)
	(or
	 (and
	  (= ?y ?my)
	  (= (nth$ (+ ?x 1) $?tiene) 0)
	  )
	 (and
	  (= ?x ?my)
	  (= (nth$ (+ ?y 1) $?tiene) 0)
	  )
	 )
	)
       )
      then
    (bind ?val 10)
    (if
    	(or
	 (and
	  (= ?sentidot 1)
	  (= (nth$ (+ ?ty 1) $?tiene) 0)
	  )
	 (and
	  (= ?sentidot 0)
	  (= (nth$ (+ ?tx 1) $?tiene) 0)
	  )
	 ) then
      (bind ?val 18)
      )
    (retract ?v)
    (assert
     (disparo la_que_haga_al_mano_pasar_HEAD ?ficha)
     (valor ?ficha (+ ?valorh ?val) ?valort)
     )
    (printout t tab
	      "La ficha que debes dar, la que al mano haga pasar: "
	      ?x "·" ?y " " ?val crlf)
    )
  )

(defrule la_que_al_mano_haga_pasar_TAIL
  (declare (salience 45))
  (estado CPU ?yo)
  (mano ?mano)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (jugador (n ?mano) (tiene $?tiene))
  (test (es_rival ?mano ?yo))
  (mesa ?head ?sentidoh $?resto ?tail ?sentido)
  (ficha ?ficha ?x ?y)
  (ficha ?tail ?my ?mx)
  (ficha ?head ?hx ?hy)
;; TODO: Este test falla
;;   (test
;;    (or
;;     (and
;;      (= ?sentido 1)
;;      (or
;;       (and
;;        (= ?y ?mx)
;;        (= (nth$ (+ ?x 1) $?tiene) 0)
;;        )
;;       (and
;;        (= ?x ?mx)
;;        (= (nth$ (+ ?y 1) $?tiene) 0)
;;        )
;;       )
;;      )
;;     (and
;;      (= ?sentido 0)
;;      (or
;;       (and
;;        (= ?y ?my)
;;        (= (nth$ (+ ?x 1) $?tiene) 0)
;;        )
;;       (and
;;        (= ?x ?my)
;;        (= (nth$ (+ ?y 1) $?tiene) 0)
;;        )
;;       )
;;      )
;;     )
;;    )
  ?v <- (valor ?ficha ?valorh ?valort)
  (not (exists
	(disparo la_que_haga_al_mano_pasar_TAIL ?ficha)))
  =>
  (if
      (or
       (and
	(= ?sentido 1)
	(or
	 (and
	  (= ?y ?mx)
	  (= (nth$ (+ ?x 1) $?tiene) 0)
	  )
	 (and
	  (= ?x ?mx)
	  (= (nth$ (+ ?y 1) $?tiene) 0)
	  )
	 )
	)
       (and
	(= ?sentido 0)
	(or
	 (and
	  (= ?y ?my)
	  (= (nth$ (+ ?x 1) $?tiene) 0)
	  )
	 (and
	  (= ?x ?my)
	  (= (nth$ (+ ?y 1) $?tiene) 0)
	  )
	 )
	)
       )
      then
    (bind ?val 10)
    (if
    	(or
	 (and
	  (= ?sentidoh 1)
	  (= (nth$ (+ ?hx 1) $?tiene) 0)
	  )
	 (and
	  (= ?sentidoh 0)
	  (= (nth$ (+ ?hy 1) $?tiene) 0)
	  )
	 ) then
      (bind ?val 18)
      )
    (retract ?v)
    (assert
     (disparo la_que_haga_al_mano_pasar_TAIL ?ficha)
     (valor ?ficha ?valorh (+ ?valort ?val))
     )
    (printout t tab
	      "La ficha que debes dar, la que al mano haga pasar: "
	      ?x "·" ?y " " ?val crlf)
    )
  )

;; De seis doble, cinco o cuatro, salir de ellos es barato

(defrule de_seis_cuatro_o_cinco_barato
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (mesa)
  (ficha ?ficha ?x ?x)
  (test
   (or
    (= ?x 6)
    (= ?x 5)
    (= ?x 4)
    )
   )
  ?v <- (valor ?ficha ?valorh ?valort)
  (not (exists (disparo de_seis_cuatro_o_cinco ?ficha)))
  =>
  (assert
   (disparo de_seis_cuatro_o_cinco ?ficha)
   (valor ?ficha (+ ?valorh 5) (+ ?valort 5))
   )
  (retract ?v)
  (printout t tab
	    "De seis doble, cinco o cuatro, salir de ellos es barato: "
	    ?x "·" ?x crlf)
 )

;; Pero con cinco de un palo, salir del fallo doblado

(defrule con_cinco_de_un_palo_salir_fallo_doblado
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2)
	   (palos $?palos))
  (mesa)
  (ficha ?ficha ?x ?x)
  (test (>= (nth$ (+ ?x 1) $?palos) 6))
  ?v <- (valor ?ficha ?valorh ?valort)
  (not (exists (disparo con_cinco_palo ?ficha)))
  =>
  (assert
   (disparo con_cinco_palo ?ficha)
   (valor ?ficha (+ ?valorh 8) (+ ?valort 8))
   )
  (retract ?v)
  (printout t tab
	    "Pero con cinco de un palo, salir del fallo doblado: "
	    ?x "·" ?x crlf)
  )

;; Si ha salido tu contrario, las gordas respetarás

;; Si piensas es porque no sabes, si no sabes ¿para que piensas?

(defrule intuicion
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (test (= (length$ $?fichas1)
	   (random 0 (+ (length$ $?fichas1)
			(length$ $?fichas2)))))
  (mesa ?head ?sentidoh $?resto ?tail ?sentidot)
  (ficha ?ficha ?x ?y)
  (ficha ?head ?hx ?hy)
  (ficha ?tail ?tx ?ty)
  (test
   (or
    (and
     (= ?sentidoh 1)
     (or
      (= ?x ?hx)
      (= ?y ?hx)
      )
     )
    (and
     (= ?sentidoh 0)
     (or
      (= ?x ?hy)
      (= ?y ?hy)
      )
     )
    (and
     (= ?sentidot 1)
     (or
      (= ?x ?ty)
      (= ?y ?ty)
      )
     )
    (and
     (= ?sentidot 0)
     (or
      (= ?x ?tx)
      (= ?y ?tx)
      )
     )
    )
   )
  ?v <- (valor ?ficha ?valorh ?valort)
  (not (exists (disparo intuicion)))
  =>
  (assert
   (disparo intuicion)
   (valor ?ficha (+ ?valorh 1) (+ ?valort 1))
   )
  (retract ?v)
  (printout t tab
	    "Si piensas es porque no sabes, si no sabes ¿para que piensas?: "
	    ?x "·" ?y crlf)
  )

;; Si te obligan a dar golpe, hazlo siempre a la del doble

(defrule golpe_a_la_del_doble
  (declare (salience 45))
  (estado CPU ?yo)
  (jugador (n ?yo) (fichas $?fichas1 ?ficha $?fichas2))
  (mesa ?head ?sentidoh $?resto ?tail ?sentidot)
  (ficha ?head ?hx ?hy)
  (ficha ?tail ?tx ?ty)
  (ficha ?ficha ?x ?y)
  (test
   (or
    (and
     (or
      (= ?x ?hx)
      (= ?y ?hx)
      )
     (= ?hx ?hy)
     )
    (and
     (or
      (= ?x ?ty)
      (= ?y ?ty)
      )
     (= ?tx ?ty)
     )
    )
   )
  ?v <- (valor ?ficha ?valorh ?valort)
  (not (exists (disparo golpe_al_doble ?ficha)))
  =>
  (bind ?valh 0)
  (bind ?valt 0)
  (if (= ?hx ?hy) then (bind ?valh 3))
  (if (= ?tx ?ty) then (bind ?valt 3))
  (assert
   (disparo golpe_al_doble ?ficha)
   (valor ?ficha (+ ?valorh ?valh) (+ ?valort ?valt))
   )
  (retract ?v)
  (printout t tab
	    "Si te obligan a dar golpe, hazlo siempre a la del doble: "
	    ?x "·" ?y crlf)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
