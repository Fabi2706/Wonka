#include "BluetoothSerial.h"
#include <Ticker.h>

Ticker timer; // Declaración de un objeto Ticker llamado 'timer'

String msn ="";
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif
String receivedData = ""; // Variable para almacenar la cadena recibida

BluetoothSerial SerialBT;

///////////VARIABLES GLOBALES/////////////77
double tiempo =0;
const int pwmPin = 2; // Define el pin que se utilizará como salida PWM
int contar =0;
int duty = 0;

void setup() {

  ///CONFIGURACION BLUETOOTH ///
  Serial.begin(115200);
  SerialBT.begin("WON");
  Serial.println("The device started, now you can pair it with bluetooth!");
  //SerialBT.begin(115200);


  //CONFIGURACION PWM /////
   // Inicializa el pin PWM como salida
  pinMode(pwmPin, OUTPUT);
  
  // Inicializa la frecuencia PWM (en Hz)
  // El rango típico es de 1 a 1000 Hz
  int frecuencia = 1000; // 1000 Hz (1 kHz)
  ledcSetup(0, frecuencia, 8); // Configura el canal 0 (puedes utilizar otros canales)
  
  // Asocia el pin PWM al canal configurado anteriormente
  ledcAttachPin(pwmPin, 0);

  //CONFIGURACION TIMER///
   
}

void loop() {

String msn = "Hola mundo";
//Para enviar datos
//SerialBT.println(msn);
  if (Serial.available()) {
    SerialBT.write(Serial.read());
    
  }
  //Recibir datos
    if (SerialBT.available()) {

       char incomingChar = SerialBT.read(); // Leer un carácter del puerto serial
       
        if (incomingChar == '\n' ) { //|| incomingChar == '\r'

      // Si es un delimitador, hemos terminado de recibir la cadena
      // Puedes hacer algo con la cadena recibida, por ejemplo, imprimir o procesar
      //Serial.print("Cadena recibida: ");
      Serial.println(receivedData);
      
      int foundIndex = receivedData.indexOf('#');   
       if(foundIndex > -1){
        
        RecibirTiempo(receivedData);
        
        }else{
          
          foundIndex = receivedData.indexOf('*');    
               
          if(foundIndex > -1){

            RecibirComando(receivedData);
            
            }else{

              RecibirIntensidad(receivedData);
              
              }
          
          }
       
     // Reiniciar la variable para la próxima cadena
         receivedData = "";
    } else {
      // Concatenar el carácter a la cadena en construcción
      receivedData += incomingChar;
    }


       
    //Serial.write(SerialBT.read());
   
    //char dato =  SerialBT.read();
    //Serial.println(dato);

  }
  delay(20);
}


void ContarMin(){

  contar +=1;

  if(contar == tiempo)
  {
    contar =0;
    tiempo=0;
    ApagarTimer();
   
  }else{

    SerialBT.println(contar);  //Envio a la aplicacion transcurrido cada segundo

  }

}
void ApagarTimer(){

   timer.detach(); // Detiene el temporizador si está en funcionamiento

}


void IniciarTimer(){

  timer.attach(1, ContarMin); // Adjunta la función 'onTimer' para que se ejecute cada 1 segundo

}


void RecibirIntensidad(String vel){

 int porc = vel.toInt(); //convierto el string a entero 
 duty = (porc*255)/100;
 ledcWrite(0, duty); // Escribe el valor en el canal 0

  Serial.print("La intesidad es: ");
  Serial.println(vel);
  
  }


void RecibirTiempo(String txt){
  txt = txt.substring(1);

  //tiempo=toDouble(txt); //convertir a double el string de tiempp
     
  Serial.print("El tiempo recibido: ");
  Serial.println(txt);
  
  }

  void RecibirComando(String tst ){

    tst = tst.substring(1);
    
    Serial.print("El comando recibido es: ");
    Serial.println(tst);

    if(tst=="s"){

      IniciarTimer();
    }

    if(tst=="r"){

      ApagarTimer();

    }

    
    
  }
