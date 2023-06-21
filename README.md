
# SSVEP con FPGA y ADS1299

Adquisidor de señales de EEG con deteccion de SSVEPs implementado en un ads1299 y una FPGA Max10. 


## Configuración de la operacion con botones y pulsadores:

COMPLETAR (La hoja que tengo esta impresa supongo que está tipeado en algun lado)


## Conexion con ADS1299 

Aparte de las conexiones de tierra y alimentación deben conectarse:

	GPIO(11) (AA15)	-> ADS_R/P
	GPIO(13) (W13) 	-> ADC_CLK
	GPIO(15) (AB13)	-> ADS_START
	GPIO(17) (Y11)	-> ADS_DRDY

	GPIO(19) (W11) 	-> ADS_MOSI
	GPIO(21) (AA10)	-> ADS_CS
	GPIO(23) (Y8)	-> ADS_SCLK
	GPIO(25) (Y7)	-> ADS_MISO

## Conexion con Bluepill para transmision de datos

COMPLETAR 

## Bitstreams para hacer andar la FPGA con SSVEPS 

eeg_ssvep_1: 

	* Mide la señal de entrada al ads1299 en dos modos, canal 1 directo o promediando los 8 canales, con 1 kHz de frecuencia de muestreo
	
	* Esta señal la pasa por un lockin a tres frecuencias distintas ->	16 Hz, 12 Hz y 20 Hz
	
	* La señal medida y los resultados de la amplitud del lockin los envía a la PC a través de un puerto serie
	
	* En total se envían 17 bytes -> 4 de señal cruda, 4 del lockin a 16, 4 del lockin a 12 y 4 del lockin a 20 y un byte de separacion 0x0F (en ese orden)
	
	* La FPGA tambien genera estimulos a las frecuencias de interés, sincronizados con el muestreo disponibles en pines: GPIO(31) -> 16Hz | GPIO(33) -> 12 Hz | GPIO(35) -> 20 Hz 