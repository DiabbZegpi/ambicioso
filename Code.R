# ~~~~~~~~~~~~~~~~~~~~~Simulación del juego "El ambicioso"~~~~~~~~~~~~~~~~~~~~~~
set.seed(123)


#~~~~~~Función que simula el lanzamiento de un dado hasta obtener un '1'~~~~~~~~
#~~~~~~~~~~~~~El '1' se representa con un '0' porque da cero puntos~~~~~~~~~~~~~
turno <- function(){
  dado <- sample(1:6, 1)
  i <- 1
  tiradas <- vector()
  if(dado == 1) {tiradas[i] <- 0}
  while(dado != 1){
    tiradas[i] <- dado
    dado <- sample(1:6, 1)
    i <- i + 1
    if(dado == 1) {tiradas[i] <- 0}
  }
  return(tiradas)
}

turno()


#~~~~~~~~~~~~~~~~~~~~~~~~~~Simulación de 1000 turnos~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ensayo <- list()
for (i in 1:1000) {
  ensayo[[i]] <- turno()
}


library(tidyverse)

ambicioso <- tibble(n_ensayo = 1:1000,
                    ensayo = ensayo)

amb_map <- ambicioso %>% 
  mutate(suma = map_dbl(ensayo, sum),
         n = map_dbl(ensayo, length))

#~~~~~~~~~~~~~~'suma' es la suma de los puntos hasta obtener un '1'~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~'n' es la cantidad de tiros hasta obtener un 1~~~~~~~~~~~~~~~~

theme_set(theme_light())

ggplot(amb_map, aes(suma)) + 
  geom_histogram(bins = 25, color = "white")

ggplot(amb_map %>% filter(n <= 20), aes(n - 1)) + 
  geom_histogram(bins = 20, color = "white")

mean(amb_map$n > 1) 

probs <- vector()
for(i in 1:20){
  probs[i] <- mean(amb_map$n == i)
}

probs <- as_tibble(probs) %>% 
  mutate(n = 1:20)

depurado <- amb_map %>% 
  left_join(probs, by = "n") %>%  
  filter(n <= 20) %>% 
  mutate(peso = value * suma) %>% 
  arrange(desc(peso))

peso_lanzamiento <- ggplot(depurado, aes(n, peso)) +
  geom_point() +
  geom_smooth(color = "red", method = "loess") +
  labs(x = "Total lanzamientos por turno",
       y = "Suma de puntos * probabilidad de ocurrencia",
       title = "Para ganar al ambicioso hay que lanzar el dado entre 8 y 9 veces")

ggplot(depurado, aes(suma, n)) +
  geom_point()

ggsave("../Desktop/ambicioso.pdf", plot = peso_lanzamiento)
