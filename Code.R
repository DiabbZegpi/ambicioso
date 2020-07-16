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
for (i in 1:10000) {
  ensayo[[i]] <- turno()
}


library(tidyverse)

ambicioso <- tibble(n_ensayo = 1:10000,
                    ensayo = ensayo)

amb_map <- ambicioso %>% 
  mutate(suma = map_dbl(ensayo, sum),
         n = map_dbl(ensayo, length))

#~~~~~~~~~~~~~~'suma' es la suma de los puntos hasta obtener un '1'~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~'n' es la cantidad de tiros hasta obtener un 1~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Gráficos~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
theme_histogram <- function(){
  theme_minimal() + 
    theme(axis.line.x = element_line(colour = "gray40"),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.major.y = element_line(colour = "gray80"),
          axis.text = element_text(size = 12, colour = "gray20"),
          axis.title = element_text(size = 14))
}

theme_set(theme_minimal())

plot_ntiros <- ggplot(amb_map %>% filter(n <= 35), aes(n - 1)) + 
  geom_histogram(bins = 25, fill = "forestgreen") +
  scale_y_continuous(breaks = c(500, 1000, 1500, 2000, 2500)) +
  labs(x = "N° de tiros hasta obtener un 1",
       y = "Frecuencia absoluta") +
  theme_histogram()

plot_puntos <- ggplot(amb_map %>% filter(suma <= 140), aes(suma)) + 
  geom_histogram(bins = 25, fill = "dodgerblue3") +
  scale_y_continuous(breaks = c(500, 1000, 1500, 2000, 2500)) +
  labs(x = "Suma de puntos por turno",
       y = NULL) +
  theme_histogram()
  
library(patchwork)
library(ggtext)
fig_frecuencias <- plot_ntiros + plot_puntos +
  plot_annotation(title = "<span style='color:#228B22;'>Tiros máximos por turno</span> y <span style='color:#1874CD;'>puntaje obtenido</span>",
                  subtitle = "Frecuencia de ocurrencia en 10.000 simulaciones",
                  theme = theme(plot.title = element_markdown(hjust = .5, size = 18, face = "bold"),
                                plot.subtitle = element_text(hjust = .5, size = 14, face = "italic", colour = "gray40")))
 

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
