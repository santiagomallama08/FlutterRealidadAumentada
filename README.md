🧠 FlutterRealidadAumentada
Descripción general

FlutterRealidadAumentada es una aplicación móvil innovadora desarrollada con Flutter que combina tecnologías de realidad aumentada (AR), inteligencia artificial (IA) y almacenamiento en la nube.
El propósito del proyecto es ofrecer una experiencia interactiva en la que el usuario pueda visualizar modelos 3D en su entorno real y, al mismo tiempo, generar o describir contenido mediante IA conectada con la API de OpenAI.

Esta aplicación está pensada como un espacio experimental de creatividad digital, donde la visión artificial, la generación de contenido y el aprendizaje automático convergen para crear entornos de visualización personalizados e inteligentes.

Objetivo del proyecto

El principal objetivo del proyecto es desarrollar una plataforma móvil que permita explorar el potencial de la realidad aumentada en conjunto con la inteligencia artificial, ofreciendo al usuario la capacidad de visualizar modelos tridimensionales en tiempo real y complementarlos con información generada automáticamente.
Adicionalmente, el sistema aprovecha la infraestructura de Supabase para gestionar autenticaciones, almacenar datos e imágenes, y mantener un flujo de información sincronizado y seguro.

Funcionamiento general

El flujo del sistema se basa en tres componentes esenciales:

Interfaz móvil en Flutter:
El usuario interactúa con una aplicación de diseño limpio e intuitivo. Desde esta interfaz puede acceder a las funciones principales: iniciar sesión, visualizar los modulos de cargar imagen y de visualizar las imagenes creadas, una vez se selecciona el modulo de cargar imagen, pide cargar la imagen, agregar un prompt y al aplicacion se conecta con el modelo de ia y nos entrega la imagen ya editada, tambien podemos visualizar todas las imagenes que realizamos dia a dia 

Conexión con Supabase:
Supabase actúa como el servicio de backend que permite manejar la autenticación de usuarios, el registro de datos y el almacenamiento de archivos. A través de este servicio, la aplicación mantiene la información sincronizada y centralizada, asegurando una administración eficiente de los recursos generados por el usuario, como imágenes, prompts o modelos tridimensionales.

Integración con OpenAI:
La aplicación se comunica con la API de OpenAI con el modelo de Dall-e2 para procesar solicitudes inteligentes. Gracias a esta conexión, el usuario puede generar descripciones de objetos, recibir recomendaciones o crear contenido a partir de texto.
Esta integración representa el componente de inteligencia artificial del proyecto y convierte la experiencia de realidad aumentada en un entorno dinámico, capaz de interpretar y generar información de manera contextual.

Proceso de desarrollo

El desarrollo del proyecto se llevó a cabo siguiendo una estructura modular y bien definida. En la primera fase se configuró el entorno de desarrollo en Flutter, estableciendo la arquitectura base y los componentes visuales. Posteriormente se integró Supabase, configurando las funciones de autenticación, base de datos y almacenamiento.
En una segunda etapa, se conectó el sistema con la API de OpenAI, lo que permitió incorporar la inteligencia artificial como un elemento activo en la experiencia del usuario. Finalmente, se implementaron las funcionalidades de realidad aumentada, donde se habilita la cámara del dispositivo o el almacenamiento interno y se integran los modelos para su visualización e interacción.

Durante el proceso se realizaron pruebas en dispositivos Android y se validaron las capacidades de renderizado y detección de superficies compatibles con ARCore. Se priorizó la fluidez, la estabilidad y la experiencia del usuario como aspectos centrales del desarrollo.

Estructura funcional

El proyecto se compone de diferentes módulos, cada uno con una función específica que contribuye al flujo general de la aplicación:

Módulo de autenticación: Permite el registro y el inicio de sesión de usuarios mediante la conexión con Supabase, garantizando la seguridad y el manejo individual de sesiones.

Módulo de realidad aumentada: Gestiona la cámara del dispositivo, la detección de superficies y la representación de modelos  en el entorno real.

Módulo de inteligencia artificial: Envía las solicitudes a la API de OpenAI para obtener respuestas, descripciones o sugerencias generadas automáticamente según los datos o comandos del usuario.

Módulo de almacenamiento en la nube: Gestiona los recursos multimedia (imágenes, modelos o resultados) almacenándolos en los buckets de Supabase, permitiendo su consulta o descarga posterior.

Módulo de interfaz de usuario: Diseñado bajo principios de usabilidad y estética, permite al usuario navegar con facilidad entre las funciones del sistema.



Implementación de la realidad aumentada

La funcionalidad de realidad aumentada es el componente visual más importante del proyecto. Utiliza los sensores y la cámara del dispositivo móvil para detectar superficies y superponer modelos tridimensionales en el entorno real.
El usuario puede observar objetos virtuales integrados en su espacio físico, moverlos, escalarlos o rotarlos de manera intuitiva.
Esta función se complementa con las capacidades de la IA, que permite que el sistema proporcione información o genere descripciones sobre los modelos que el usuario está observando.

Resultados obtenidos

El resultado final es una aplicación funcional que combina de forma exitosa la realidad aumentada con la inteligencia artificial y el almacenamiento en la nube.
El usuario puede autenticarse, generar contenido inteligente, visualizar objetos 3D e interactuar con ellos en tiempo real.
La conexión con Supabase garantiza la persistencia de los datos, mientras que OpenAI aporta la inteligencia contextual que da sentido a la interacción.
El proyecto demuestra la viabilidad técnica y creativa de integrar múltiples tecnologías en un mismo entorno móvil con un enfoque innovador.

Conclusión

FlutterRealidadAumentada es una propuesta tecnológica que evidencia la convergencia entre la realidad aumentada, la inteligencia artificial y las plataformas en la nube.
El proyecto no solo cumple una función técnica, sino que también representa una exploración creativa de cómo la IA puede complementar experiencias visuales inmersivas en tiempo real.
La aplicación se plantea como una base sólida para futuros desarrollos orientados a la educación, el diseño, la simulación o el entretenimiento, donde el usuario no solo observa, sino que también interactúa y crea contenido de manera inteligente.