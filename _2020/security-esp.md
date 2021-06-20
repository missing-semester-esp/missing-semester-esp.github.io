---
layout: lecture
title: "Seguridad y criptografía"
date: 2019-01-28
ready: true
video:
  aspect: 56.25
  id: tjwobAmnKTo
---

En la [conferencia de seguridad y privacidad](/2019/security) del año 2019,
Nos enfocamos en cómo puedes ser un _usuario_ más seguro.
Este 2021, nos enfocaremos en los conceptos de seguridad y criptografía
considerados relevantes para entender las herramientas cubiertas antes de empezar
esta clase, tales como las funciones hash en Git o las claves de derivación y 
simetría/asimetría correspondientes a los sistemas criptográficos en _SSH_.

Esta conferencia no sustituye a los más rigurosos y completos cursos: 
[sistemas de seguridad computacionales 6.858](https://css.csail.mit.edu/6.858/),
[criptografia 6.857](https://courses.csail.mit.edu/6.857/) y 6.875. No realices
tareas de seguridad sin entrenamiento formal en la materia, a menos que tu 
seas un experto: [no implementes tus propias librerías de criptografía](https://www.schneier.com/blog/archives/2015/05/amateurs_produc.html). El mismo principio aplica a los sistemas de seguridad.

Esta conferencia posee un tratamiento informal y práctico sobre los fundamentos
criptográficos. Así, no representa suficiente contenido para _ diseñar y sistemas seguros,
aunque esperamos suficiente, para darte un entendimiento general de los programas y protocolos
que ya usas. 

# Entropía

[Entropía](https://es.wikipedia.org/wiki/Entrop%C3%ADa_(informaci%C3%B3n)) es una medida
aleatoria; útil, por ejemplo, cuando determinamos la fortaleza de una contraseña.

![XKCD 936: Password Strength](https://imgs.xkcd.com/comics/password_strength.png)

Como vemos arriba [XKCD comic](https://xkcd.com/936/) en la ilustración, una contraseña como
"correcthorsebatterystaple" es más segura que "Tr0ub4dor&3". Pero  ¿cómo lo cuantificamos?

Entropía, medida en _bits_,  selecciona de manera uniformemente aleatoria desde un 
conjunto de posibles salidas, la entropía es igual a `log_2(# of posibilidades)`.
Una moneda sesgada lanzada significa 1 bit de entropía.  Un dado, \~2.58 bits de
entropía.

Deberías considerar que el atacante sabe el _modelo_ de tu contraseña, pero no
la aleatoriedad [dice rolls](https://en.wikipedia.org/wiki/Diceware) usada para seleccionar
una contraseña particular.

¿Cuántos bits de entropía son suficientes? Depende del hilo de tu modelo. Para en línea 
invitaciones, como indica XKCD, \~40 bits de entropía son excelentes. Para persistir 
fuera de línea registros, una contraseña más fuerte debería ser necesaria: mínimo 80 bits o más.

# Funciones hash

Una [función hash criptográfica](https://es.wikipedia.org/wiki/Funci%C3%B3n_hash_criptogr%C3%A1fica) 
relaciona datos de un tamaño arbitrario a un tamaño fijo, generando algunas propiedades especiales.
Una simple especificación de una función hash::
```
hash(value: array<byte>) -> vector<byte, N> (para algún valor fijo N) 
```

Un ejemplo de una función es [SHA1](https://es.wikipedia.org/wiki/SHA-1),
la cual es usada en Git. Relaciona una arbitraria entrada a una salida 160-bits de salida, es decir,
puede ser representado como 40 caracteres hexadecimales. Podemos experimentar SHA1 en una entrada usando
el comando `shasum`:

```consola
$ printf 'hola' | sha1sum
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
$ printf 'hola' | sha1sum
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
$ printf 'Hola' | sha1sum 
f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0
```

En un alto nivel, un función *hash* puede pensarse como una función difícil para invertir y de comportamiento
aleatorio (pero determinístico) -[modelo ideal de una función hash](https://es.wikipedia.org/wiki/Modelo_de_or%C3%A1culo_aleatorio)-.
Una función hash puede describirse como:
- Determinista: la misma entrada genera siempre la misma salida.
- No invertible: es difícil de encontrar una entrada `m` tal que `hash(m)=h` para alguna codiciada salida `h`.
- La resistencia de colisión objetivo: dada una entrada `m_1`, es complicado encontrar una entrada diferente
`m_2` tal que `hash(m_1) = hash(m_2)`. 
- Resistenca de colisión. Es difícil encontrar dos entradas `m_1` y `m_2` tal que `hash(m_1)=hash(m_2)`.
Nótese que esta es una propiedad estrictamente más fuerte que la resistencia a 
la colisión objetivo.

Nota: mientras eso podría trabajar para ciertos propósitos, SHA-1 es [(no más)](https://shattered.io/)
considerada una fuerte función criptográfica hash. Tu podrás encontrar esta tabla de 
[tiempo de vida de funciones criptográficas hash] interesantes. Sin embargo, nota que recomendar especificar
funciones hash se escapa al alcance de esta conferencia. Si tu estas trabajando donde esto importa, tu necesitas
formal entrenamiento en seguridad/criptografía.

## Aplicaciones
- Git, para el direccionar el contenido y almacenarlo). ¿Por qué usa Git una función criptográfica hash?
- Es un resumen corto de los contenidos de un archivo. EL software puede algunas veces descargarse
 (potencialmente de fuentes no deseables) espejos. Por ejemplo, los ISO de Linux, y estaría bien no tener que confiar
 en ellos. Los sitios oficiales muestran los hashes a largo del enlace de descarga (ese es el punto de *mirrors* de terceras partes),
 entonces puedes revisarlo después de descargar un archivo.
 - [Esquemas de compromiso *commitment*](https://es.wikipedia.org/wiki/Esquema_de_compromiso).
Supón, quieres comprometer *commit* un particular valor, pero relevar el valor en sí mismo después. Por ejemplo, quieres experimentar 
mediante una moneda ajustada "en mi cabeza", sin una moneda confiable compartida que dos partes puedan ver. Tu podria elegir un valor 
`r = random()`, y entonces compartir `h = sha256(r)`.  Entonces, tú podrías llamar a la cabeza o a la cola (por convención, el valor par `r` 
significa cabeza y valor impar `r` significa cola). Después que tu llames, tú puedes revelar mi valor `r`, y tu puedes confirmar que no has facilitado encontrar `sha256(r)`, coincidiendo con el hash que tu diste. 




# Función clave de derivación
Un concepto relacionado a la criptografía [función de derivación de clave](https://es.wikipedia.org/wiki/Funci%C3%B3n_de_derivaci%C3%B3n_de_clave) (KDFs por sus siglas en inglés) 
son usadas por un número de aplicaciones, incluyendo la producción de una salida de tamaño fijo para ser usado por un número de aplicaciones, incluyendo otras salidas filas para ser usadas como llaves en otros algoritmos criptográficos. Usualmente, KDFS son deliberadamente lentos, en orden para garantizar los ataques por fuerza bruta fuera de línea.

## Aplicaciones

- Producción llaves desde frases para usarse en otros algoritmos (por ejemplo, algoritmos criptográficos, ver abajo).
- Almacenamiento de credenciales para autenticación. El almacenamiento de contraseñas sobre texto plano es malo; la manera correcta es generar
y almacenar una [sal](https://es.wikipedia.org/wiki/Sal_(criptograf%C3%ADa)) aleatoria `sal = aleatoria()` para cada usuario, guarda 
`KDF(contraseña + sal)`, y verifica los intento de iniciar sesión por cada recálculo de la KDF dada la contraseña ingresada y la sal guardada.

# Criptografia simétrica

Ocultar el contenido de los mensajes es el primer concepto que piensas cuando escuchas sobre criptografía. La criptografía simétrica logra esto con el siguiente conjunto de funcionalidades:

```
generadorClaves() -> clave  (esta función es aleatoria)

encripta(textoPlano: array<byte>, clave) -> array<byte> (texto cifrado)
descripta(textoCifrado: array<byte>, clave) -> array<byte>  (texto plano)
```

La función encriptadora tiene la propiedad que dada la salida (texto cifrado), es difícil determinar la entrada (texto plano) sin la clave.
La función desencriptadora tiene la propiedad exacta imaginada, tal que `decripta(encripta(m,k)) = m`.

Un ejemplo de un sistema simétrico criptográfico con amplio uso hoy es: [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard).

## Aplicaciones

- Archivos encriptados para almacenamiento en un servicio en la nube poco confiable. Esto puede ser combinado con KDF's, entonces tu puedes encriptar
archivos con una frase semilla. Generar `clave = KDF(frase semilla)`, y entonces guardar con `encriptar(archivo, clave)`.

# Criptografía asimetrica

El término "asimétrico" se refiere a la existencia de dos claves, con diferentes responsabilidades. Una clave privada, 
como su nombre indica, significa mantenerse oculta al mundo exterior, mientras la clave pública puede ser ampliamente compartida y no afectará sistemas
seguros (caso contrario a las llaves en los sistemas criptográficos simétricos). Los sistemas simétricos asimétricos proveen las siguientes funcionalidades,
para encriptar/desencriptar y para verificar/firmar:

```
keygen() -> (clave pública y clave privada)  (esta función es aleatoria)

encriptar(texto_plano: array<byte>, clave pública) -> array<byte>  (texto cifrado)
desencriptar(texto_cifrado: array<byte>, clave privada) -> array<byte>  (texto plano)

firmar(mensaje: array<byte>, clave privada) -> array<byte>  (the signature)
verificar(mensaje: array<byte>, firma: array<byte>, clave pública) -> bool  (es una firma válida?)
```
Las funciones encriptadores/desencriptadores tienen propiedades similares a sus análogos de los criptosistemas simétricos.
Un mensaje puede ser encriptado usando la clave _pública_. Dado la salida (texto cifrado), es difícil determinar la entrada
(texto plano) sin la clave _privada_. La función desencriptadora tiene la obvia propiedad indicada, tal que `desencriptar(encriptar(m, clave pública), clave privada)=m`.

La encriptación simétrica y asimétrica puede ser comparada a las cerraduras. Un criptosistema asimétrico es como una puerta cerrada:cualquiera con la llave puede abrirla y cerrarla. En los sistemas asimétricos es como un buzón de correo con llave. Puedes dar un desbloqueo candado a alguien (la clave pública), ellos pueden poner un mensaje en la caja y entonces pueden bloquearse, y después de eso, solamente tú puedes abrir el candado porque tu mantienes la llave (la clave privada).  

Las funciones de verificación y firma tienen algunas propiedades que tu esperarías tener en las formas físicas: son difíciles de falsificar. No importa el mensaje, sin la clave _privada_, es difícil producir una firma tal que `verficar(mensaje, firma, clave pública)` retorna verdadero. Y por supuesto, la función verificada tiene la exacta propiedad: `verifica(mensaje, firmar(mensaje, clave privada), clave pública)=verdadero`

## Aplicaciones

- [Encriptación de correos electronicos PGP](https://es.wikipedia.org/wiki/Pretty_Good_Privacy).
Las personas pueden tener claves públicas publicadas en línea (por ejemplo, en un PGP servidor de claves o en 
[Keybase](https://keybase.io/)). Cualquiera puede enviarles un correo encriptado. 
- Mensajería privada. Aplicaciones como [Signal](https://signal.org/) y
[Keybase](https://keybase.io/) usan claves asimetricas para establecer canales de comunicación privados.
- Software firmador. Git puede tener GPG-firmados _commits_ y las etiquetas _tags_. Con un publicada clave pública,
cualquiera puede verificar la autenticidad del software descargado.

## Distribución de claves

La clave simétrica criptografía es maravillosa, pero tiene un gran reto para distribuir las claves públicas / relacionar claves públicas
a identidades del mundo real. Hay muchas soluciones a este problema, Signal, por ejemplo, confía en el primer uso, y soporta un fuera de banda de intercambio
de claves publicas (tu verificas a tus amigos, la seguridad de números en persona). Otro ejemplo, PGP, cuya solución es 
[red de confianza](https://es.wikipedia.org/wiki/Red_de_confianza). Keybase mediante [prueba social](https://keybase.io/blog/chat-apps-softer-than-tofu) lo resuelve, junto con otras buenas ideas, por eso nos gusta, aunque cada modelo tiene sus propios méritos.

# Casos de estudio

## Gestores de contraseña

Esta es una herramienta esencial que todos deberían intentar usar (por ejemplo [KeePassXC](https://keepassxc.org/)). Los gestos de contraseña te permiten usar contraseñas únicas, aleatorias generadas con alta entropía para todos los sitios web -apps-, y guardan todas tus contraseñas en un único lugar, encriptados un cifrado simétrico con una clave producida desde una frase usada un KDF.

Usando un gestor de contraseña te evita usar contraseñas, entonces cuando los sitios web estén comprometidos, el impacto a tu seguridad será menor.
Usando contraseñas con alta entropía (tu estarás menos comprometido), y solamente necesitas recordar una única contraseña altamente entrópica. 

## Doble factor de autenticación

[Autenticación de múltiples factores](https://es.wikipedia.org/wiki/Autenticaci%C3%B3n_de_m%C3%BAltiples_factores)
(2FA) requiere usar una frase (algo que tu sabes) junto con un 2FA autenticador (a traves de, por ejemplo, [YubiKey](https://www.yubico.com/), "algo que tu tienes")
en orden para proteger contra contraseñas robadas y ataques por [phishing](https://es.wikipedia.org/wiki/Phishing).

## Encriptación completa de disco

Manteniendo el disco de tu laptop enteramente encriptado es una manera fácil de proteger tus datos en caso que tu computadora sea robada.
Puedes usar [cryptsetup +
LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)
en Linux,
[BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/) en Windows o [FileVault](https://support.apple.com/en-us/HT204837) en macOS.
Estos encriptan el disco entero con una clave simétrica, con una clave protegida por una frase.

## Mensajería privada

Usa [Signal](https://signal.org/) o [Keybase](https://keybase.io/). La seguridad de las claves de extremo a extremo es arrancada desde una encriptación por clave asimétrica. Obtener las claves públicas de tus contactos es el paso crítico aquí. Si quieres una buena seguridad, necesitas autenticar las claves públicas fuera de banda (como Signal o Keybase) o confiar en la prueba social (como Keybase).

## SSH

Hemos cubierto el uso de SSH y las claves SSH en una [conferencia anterior](/2020/command-line/#remote-machines). Miramos algunos aspectos criptográficos.
Cuando tu corres `ssh-keygen`, es generada una clave asimétrica par, `clave_publica, clave_privada`. Esta es generada aleatoriamente, usando la entropía generada por el sistema operativo (coleccionada desde eventos del hardware, etc.). La clave pública es guardada como es pública, entonces mantenerla en secreto no es importante, pero en el reposo, la clave privada debería ser encriptar el disco.

El programa `ssh-keygen` pide al usuario una frase, y este se alimenta a través de una función de clave derivada para producir una clave, la cual entonces
es usada para encriptar la clave privada con un cifrado simétrico.

En uso, una vez que el servidor sabe que la clave pública del cliente (almacenadas en el archivo `.ssh/authorized_keys`), 
una conexión al  cliente puede probar su identidad usando las firmas asimétricas. Esto es hecho a través de la [challenge-response](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication). En un alto nivel, el servidor elige un número aleatorio y lo envía al cliente. El cliente entonces firma este mensaje y envía la firma de regreso al servidor, el cual revisa la firma contra la clave pública en el registro. Esto efectivamente prueba que el cliente es el poseedor de la clave privada correspondiente a la clave pública que está en el archivo `.ssh/authorized_key` del servidor, entonces el servidor puede permitir al cliente continuar.

{% comment %}
extra topics, if there's time

security concepts, tips
- biometrics
- HTTPS
{% endcomment %}

# Recursos

- [Notas del año pasado](/2019/security/): cuando esta conferencia estaba más enfocada en la seguridad y privacidad como  usuario final.
- [Correctas respuestas criptograficas](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html): respuestas a "¿qué sistema criptografico deberia usar para X?", para esas comunes X.

# Ejercicios

1. **Entropía.**
    1. Supone una contraseña es elegida como una concatenación de 5 palabras minúsculas del diccionario,
       donde cada palabra es seleccionada uniformemente aleatoria desde un diccionario de 100,000 palabras.
       Un ejemplo el cual la contraseña sea `correctocaballobateriagrapa`. ¿cuántos bits de entropía tiene esto?
    2. Considera un esquema alternativo donde una contraseña es elegida como una secuencia de 8 caracteres aleatorios
       alfanuméricos (incluyendo minúsculas y mayúsculas). Un ejemplo es `rg8Ql34g`. ¿cuántos bits de entropía tiene esto?
    3. ¿Cuál es la contraseña más fuerte?
    4. Supone un atacante puede intentar 10,000 contraseñas por segundo. En promedio, ¿cuánto tiempo tomará romper cada contraseña?

2. **Funciones hash criptográficas.** 
   1. Descarga una imagen Debian desde un [mirror](https://www.debian.org/CD/http-ftp/) (ejemplo [Mirror argentino](http://debian.xfree.com.ar/debian-cd/current/amd64/iso-cd/).
   Verifica de forma cruzada  el hash (ejemplo usando el comando `sha256sum`) con el hash mostrado desde el sitio oficial desde Debian (ejemplo [este archivo](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS)
   almacenados en `debian.org`, si tu has descargado el archivo vinculado al mirror argentino).

3. **Criptografía simétrica.** Encripta un archivo por AES, usando
   [OpenSSL](https://www.openssl.org/): `openssl aes-256-cbc -salt -in {input
   filename} -out {output filename}`. Mira el contenido usando `cat` o `hexdump`. Desencripta con `openssl aes-256-cbc -d -in {input filename} -out
   {output filename}` y confirma que el contenido  coincida con el original con `cmp`.

1. **Criptografía asimétrica.**
    1. Configura [las claves SSH](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
       en una computadora a la que tengas acceso (no Athena, porque Kerberos interactúa externamente con claves SSH).
       En un lugar de usar claves RSA como en el tutorial vinculado, usa la más segura 
       [claves ED25519](https://wiki.archlinux.org/index.php/SSH_keys#Ed25519).
       Asegurate que tu contraseña está encriptada con una frase, entonces eso te protegerá del resto.
    2. [Configure GPG](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)
    3. Envia a Anish un email encriptado. ([clave pública](https://keybase.io/anish)).
    4. Firma un git commit con `git commit -S` o create una etiqueta git firmada con `git tag -s`.
       Verifica la firma en el commit con `git show --show-signature` o en el caso de la etiqueta con `git tag -v`. 
