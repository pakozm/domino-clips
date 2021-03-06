(deffunction iniciar_instancia_cierre()
  (reset)
  (load cpu.clp)
  (load refranes.clp)
;;;	(seed (mod (C_time) 1024))
  (seed 125)
  (printout t "Tipos validos: HUMANO CPU" crlf)
  (bind ?tipo0 CPU);;(leer_tipo 0))
  (bind ?tipo1 CPU);; (leer_tipo 1))
  (bind ?tipo2 CPU);; (leer_tipo 2))
  (bind ?tipo3 CPU);; (leer_tipo 3))
  (assert
   (jugador
    (n 0)
    (tipo ?tipo0) ;; HUMANO o CPU
    (fichas 9)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 1 1 1 0 1 0 0)
    )
   (jugador
    (n 1)
    (tipo ?tipo1)
    (fichas 13 20)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   (jugador
    (n 2)
    (tipo ?tipo2)
    (fichas 18 21)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   (jugador
    (n 3)
    (tipo ?tipo3)
    (fichas 15 22)
    (tiene)
    (pasa)
    (puso)
    (abre)
    (palos 0 0 0 0 0 0 0)
    )
   )
  (C_sdl_init)
  (C_mostrar_mesa)
  (C_flip)
  (assert
   (cierre 6 6 6 6 6 6 6)
   (estado TURNO 0)
   ;; (mesa 5 1 16 0)
   (mesa 19 1 12 0)
   )
  (run)
  )
