library(readxl)
library(dplyr)
library(httr)

# Temperaturas conseguidas desde NOA solicitandolo via web mediante un token
# Algunas de las temperaturas han sido extraidas manualmente desde https://sy.freemeteo.com/


#TEMPERATURAS DE NAYPYITAW
url <- "https://github.com/Juanmick/TFM/blob/master/NayPyiTaw.xlsx?raw=true"
httr::GET(url, write_disk(tf <- tempfile(fileext = ".xlsx")))
tf

NayPyiTaw <- read_excel(tf, 1L)


mean(NayPyiTaw$tmax, na.rm = TRUE) #35

# Se reemplaza NA con la media los valores
NayPyiTaw$tmax[is.na(NayPyiTaw$tmax)] <- 35

# Se hace una columna con la nueva media
NayPyiTaw$tmed <- apply(NayPyiTaw[ ,c(2,3)], 1, mean, na.rm = TRUE)
NayPyiTaw[,2:3] <- NULL
NayPyiTaw <- NayPyiTaw %>% rename(Date1 = date)
NayPyiTaw$Date1 <- as.Date(NayPyiTaw$Date1, "%Y-%m-%d")


# TEMPERATURAS DE YANGON

yangon <- read.csv(url("https://raw.githubusercontent.com/Juanmick/TFM/master/yangon.csv"))
yangon$City <- rep("Yangon",90)

yangon[,1:2] <- NULL
yangon[,4:5] <- NULL
yangon$PRCP <- NULL
yangon <- yangon %>% rename(Date1 = DATE, tmed = TAVG)
yangon$Date1 <- as.Date(yangon$Date1, "%Y-%m-%d")
yangon <- as_tibble(yangon)

# TEMPERATURAS DE MANDALAY

mandalay <- read.csv(url("https://raw.githubusercontent.com/Juanmick/TFM/master/mandalay.csv"))
mandalay$City <- rep("Mandalay",87)

mandalay[,1:2] <- NULL
mandalay[,4:5] <- NULL
mandalay$PRCP <- NULL
mandalay <- mandalay %>% rename(Date1 = DATE, tmed = TAVG)
#falta 3 de febrero 20,5º, 27 marzo 31º, 16 marzo 29.5º

#añadimos las temperaturas de esas fechas manualmente
tmed <- c(20.5,29.5,31)
Date1 <- c('2019-02-03','2019-03-16','2019-03-27')
City <- rep("Mandalay",3)
mandalay1 <-data.frame(Date1,tmed,City)
mandalay <- rbind(mandalay, mandalay1)
mandalay$Date1 <- as.Date(mandalay$Date1, "%Y-%m-%d")

mandalay <- as_tibble(mandalay)

temperaturas <- rbind(mandalay, yangon, NayPyiTaw)

saveRDS(temperaturas, file = "temp.rds")
