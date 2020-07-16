<h1 align="center"> Simulación del juego de azar "El ambicioso"<img src="figuras/dados.png" width="120"></h1>


El ambicioso es un juego de dados por turnos, en el que gana el jugador que primero llega o pasa los **101 puntos**, sumando los puntos de sus tiradas. Por ejemplo: si el primer jugador tira un **6 y después un 2** tendrá **8 puntos**. Se juega con sólo un dado y las reglas son muy sencillas:

- El primer jugador tira el dado. Después de hacer una tirada, cada jugador decide si terminar su turno o seguir tirando.
- Si el jugador termina su turno, los puntos que sumó se acumularán para el siguiente turno. Le toca al siguiente jugador.
- Si el jugador tira y obtiene un 1, se borrarán todos los puntos obtenidos durante el turno en curso. Le toca al siguiente jugador.
- Cada jugador debe tener la misma cantidad de turnos. Esta regla es para anular la ventaja de tener el primer tiro.

## Ejemplo 

1. Ana tira 4, 6, 3, 3, 2 = <b style='color:#008000;'>18</b> puntos. Termina su turno voluntariamente.
2. Jorge tira 2, 2, 6, 5, 2, 4, <b style='color:#FF0000;'>1</b> = 0 puntos. Termina su turno por obligación. 
3. Ana tira 5, 2, <b style='color:#FF0000;'>1</b> = 0 puntos + 18 que guardó = <b style='color:#008000;'>18</b> puntos. Termina su turno por obligación.
4. Jorge tira 5, 6 = <b style='color:#008000;'>11</b> puntos. Termina su turno voluntariamente.

... Finalmente, Ana tiene 98 puntos y obtiene un 4, decide plantarse en 102 puntos. Como ella comenzó, Jorge todavía tiene un turno para superarla.

## Simulación

Entremos al grueso del asunto. El elemento básico del juego es la tirada de un dado de seis caras, que se puede ver como un proceso estocástico. Como se sabe, la tirada de un dado se puede modelar como una variable aleatoria que sigue la distribución uniforme discreta con <img src="https://render.githubusercontent.com/render/math?math=p(x_i) = 1/6">.

La idea principal de este proyecto es aprovechar que la tirada del dado es un evento repetible y usar la [Ley de los grandes números](https://es.wikipedia.org/wiki/Ley_de_los_grandes_números), junto con el lenguage de programación `R` para simular miles turnos del juego y encontrar la *cantidad óptima de tiradas* que maximiza las chances de ganar al juego.

> *Otro enfoque para resolver este problema es la vía matemática. Tal vez ataque al problema de ésta forma en el futuro próximo.*

Para este proyecto probé con 1.000 y 10.000 simulaciones de turnos, obteniendo resultados similares (multiplicar por 10 las simulaciones ralentiza mucho la producción de gráficos y los resultados no varían de 10.000 en adelante). Lo que verán a continuación es el segundo caso.

<img src="figuras/histogramas.png">