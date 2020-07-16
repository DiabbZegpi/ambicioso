# ~~~~~~~~~~~~~~~~~~~~~Simulación del juego "El ambicioso"~~~~~~~~~~~~~~~~~~~~~~
set.seed(123)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Paquetes~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(tidyverse)  # Manipulación de datos
library(ggtext)     # Personalización de texto usando HTML
library(patchwork)  # Combinación de gráficos

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

ambicioso <- tibble(n_ensayo = 1:10000,
                    ensayo = ensayo)

amb_map <- ambicioso %>% 
  mutate(suma = map_dbl(ensayo, sum),
         n = map_dbl(ensayo, length))

#~~~~~~~~~~~~~~'suma' es la suma de los puntos hasta obtener un '1'~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~'n' es la cantidad de tiros hasta obtener un 1~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~Generando los datos para el gráfico de optimización~~~~~~~~~~~~~~

probs <- vector()
for(i in 1:30){
  probs[i] <- mean(amb_map$n == i)
}

probs <- as_tibble(probs) %>% 
  mutate(n = 1:30)

amb_map <- amb_map %>% 
  left_join(probs, by = "n") %>%  
  filter(n <= 30) %>% 
  mutate(peso = value * suma) %>% 
  arrange(desc(peso))


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Gráficos~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
theme_histogram <- function(){
  theme_minimal() + 
    theme(axis.line.x = element_line(colour = "gray40"),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.major.y = element_line(colour = "gray80"),
          axis.text = element_text(size = 8, colour = "gray20"),
          axis.title = element_text(size = 9))
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
  

histogramas <- plot_ntiros + plot_puntos +
  plot_annotation(title = "<span style='color:#228B22;'>Tiros máximos por turno</span> y <span style='color:#1874CD;'>puntaje obtenido</span>",
                  subtitle = "Frecuencia de ocurrencia sobre 10.000 simulaciones",
                  theme = theme(plot.title = element_markdown(hjust = .5, size = 12, face = "bold"),
                                plot.subtitle = element_text(hjust = .5, size = 10, face = "italic", colour = "gray40")))
 

sam <- sample(1:10000, 1000, replace = FALSE)
muestra <- amb_map[sam,]

esperanza <- ggplot(amb_map, aes(n, peso)) +
  geom_jitter(height = .05, width = .3, alpha = .3, 
              aes(size = suma/10, colour = log(peso+.5)), 
              show.legend = FALSE, shape = 16) +
  geom_smooth(method = "loess", se = FALSE, colour = "brown2", size = 1.2) +
  geom_vline(xintercept = 6, linetype = "dashed", colour = "gray40") +
  scale_x_continuous(breaks = c(0,10,20,30)) +
  scale_color_gradient2(low = "black", mid = "red4", high = "yellow") +
  labs(title = "Tirar 6 veces: la estrategia más consistente para ganar",
       subtitle = "Resultados sobre 10.000 simulaciones",
       x = "N° de lanzamientos",
       y = "Puntos esperados por tiro") +
  theme(plot.title = element_text(size = 12, hjust = .5, face = "bold"),
        plot.subtitle = element_text(size = 10, hjust = .5, face = "italic"),
        axis.line = element_line(colour = "gray40"),
        axis.text = element_text(size = 8, colour = "gray20"),
        axis.title = element_text(size = 9),
        panel.grid.minor.y = element_blank())


  
saveRDS(amb_map, file = "data.rds")
ggsave("figuras/histogramas.png", plot = histogramas, type = "cairo", dpi = 1200)
ggsave("figuras/esperanza.png", plot = esperanza, type = "cairo", dpi = 1200)
