---
layout: lecture
title: "Seguridad y criptografía"
date: 2019-01-28
ready: false
video:
  aspect: 56.25
  id: tjwobAmnKTo
---

En la [conferencia de seguridad y privacidad](/2019/security) del ano 2019,
nos enfocamos en como puedes ser un _usuario_ mas seguro.
Este 2021, nos enfocaremos en los conceptos de securidad y criptografia
considerados relevantes para entender las herramientas cubiertas antes de empezar
esta clase, tales como las funciones has en Git o las claves de derivacion y 
simetria/asimetria correspondientes a los sistemas criptograficos en _SSH_.

Esta conferencia no sustituye a los mas rigurosos y completos cursos: 
[sistemas de seguridad computacionales 6.858](https://css.csail.mit.edu/6.858/),
[criptografia 6.857](https://courses.csail.mit.edu/6.857/) y 6.875. No realices
tareas de seguridad sin formal entrenamiento en la materia, a menos que tu 
seas un experto: [no implementes tus propias librerias de criptografia](https://www.schneier.com/blog/archives/2015/05/amateurs_produc.html). El mismo principio aplica a los sistemas de seguridad.

Esta conferencia posee un tratamiento informal y practico sobre los fundamentos
criptograficos. Asi, no representa suficiente contenido para _disenar_ sistemas seguros,
aunque esperamos suficiente, para darte un entendimiento general de los programas y protocolos
que ya usas. 

# Entropia

[Entropia](https://en.wikipedia.org/wiki/Entropy_(information_theory)) es una medida
aleatoria; util, por ejemplo, cuando determinanamos la fortaleza de una contrasena.

![XKCD 936: Password Strength](https://imgs.xkcd.com/comics/password_strength.png)

Como vemos arriba [XKCD comic](https://xkcd.com/936/) en la ilustacion, una contrasena como
"correcthorsebatterystaple" es mas segura que "Tr0ub4dor&3". Pero como cuantificamos dicha
algo como esto?

Entropia, medida en _bits_,  selecciona de manerea uniformemente aleatoria desde un 
conjunto de posibles salidas, la entropia es igual a `log_2(# of posibilidades)`.
Un moneda sesgada lanzanda significa 1 bit de entropia.  Un dado, \~2.58 bits de
entropia.

Deberias considerar que el atacante sabe el _modelo_ de tu contrasena, pero no
la aleatoriedad [dice rolls](https://en.wikipedia.org/wiki/Diceware) usada para seleccionar
una contrasena particular.

Cuantos bits de entropia son suficientes? Depende del hilo de tu model. Para en linea 
invitaciones, como indica XKCD, \~40 bits de entropia son excelentes. Para persistir 
fuera de linea registors, una contrasena mas fuerte deberia ser necesaria: minimo 80 bits o mas.

# Funciones hash

Una [funcion hash criptografica](https://en.wikipedia.org/wiki/Cryptographic_hash_function) 
relaciona datos de un tamano arbitario a un tamano fijo, generando algunas propiedades especiales.
Una simple especificacion de una funcion hash es como sigue:

```
hash(value: array<byte>) -> vector<byte, N> (para algun valor fijo N) 
```

Un ejemplo de una funcion es [SHA1](https://en.wikipedia.org/wiki/SHA-1),
la cual es usada en Git. Relaciona una arbitriria entrada a una salida 160-bits de salida, es decir,
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

En un alto nivel, un funcion *hash* puede pensarse como una funcion dificil para invertir y de comportamiento
aleatorio (pero deterministico) -[modelo ideal de una funcion hash](https://en.wikipedia.org/wiki/Random_oracle)-.
Una funcion hash puede describerse como:
- Determinista: la misma entrada genera siempre la mism salida.
- No invertible: es dificl de encontrar una entrada `m` tal que `hash(m)=h` para alguna codiciada salida `h`.
- La resistencia de colision objetivo: dada una entrada `m_1`, es complicado encontrar una entrada diferente
`m_2` tal que `hash(m_1) = hash(m_2)`. 
- Resistencia de colision. Es deficil encontrar dos entradas `m_1` y `m_2` tal que `hash(m_1)=hash(m_2)`.
Notese que esta es una propiedad estrictamente más fuerte que la resistencia a 
la colisión objetivo.

Nota: mientras eso podria trabajar para ciertos propositos, SHA-1 es [no mas larga](https://shattered.io/)
considerada una fuerte funcion criptografica hash. Tu podras encontrar esta tabla de 
[tiempo de vida de funciones criptograficas hash] interesantes. Sin embargo, nota que recomendar especificar
funciones has se escapa al alcance de esta conferencia. Si tu estas trabajando donde esto importa, tu necesitas
formal entramiento en seguridad/criptografia.

## Aplicaciones
- Git, para el direccionar el contenido y almacenarlo. La idea de un [hash
function](https://en.wikipedia.org/wiki/Hash_function) es una mas general concepto 
(no hay funciones criptograficas hash). Por que usa Git una funcion criptografica hash?
- Es un resumen corto de los contenidos de un archivo. EL software puede algunas veces descargarse
 (potencialmente de fuentes no deseables) espejos. Por ejemplo, los ISO de Linux, y estaria bien no tener que confiar
 en ellos. Los sitios oficiales muestran los hashes a largo del enlace de descarga (ese es el punto de *mirros* de terceras partes),
 entonces puedes revisarlo despues de decargar un archivo.
 - [Esquemas de comprometimiento *commitment*](https://en.wikipedia.org/wiki/Commitment_scheme).
Supon, quieres comprometer *commit* un particular valor, pero relevar el valor en si mismo despues. Por ejemplo, quieres experimentar 
mediante una moneda ajustada "en mi cabeza", sin una moneda confiable compartida que dos partes puedan ver. You podria elegir un valor 
`r = random()`, y entonces compartir `h = sha256(r)`.  Entonces, tu podrias llamar a la cabeza o a la cola (por convencion, el valor par `r` 
signfica cabeza y valor impar `r` signifca cola). Despues que tu llames, tu puedes revelar mi valor `r`, y tu puedes confirmar que no has faciltado
encontrar `sha256(r)`, coincidir que el hash you comparti antes. 


# Funcion clave de derivacion
Un concepto relacionado a la criptografia [funcion clave de derivacion](https://en.wikipedia.org/wiki/Key_derivation_function) (KDFs por sus siglas en ingles) 
son usadas por un numero de aplicaciones, incluyendo la produccion de una salida de tamano fijo para ser usado por un numero de aplicaciones, incluyendo otras salidas filas para ser usadas como llaves en otros algoritmos criptograficos. Usualmente, KDFS son deliberidamente lentos, en orden para relentizar los ataques por fuerza bruda fuera de linea.

## Aplicaciones

- Produccion llaves desde fraeses para usarse en otros algoritmos (por ejemplo, algoritmos criptograficos, ver abajo).
- Almacenamiento de credenciales para autenticacion. El almacenamiento de contrasenas sobre texto plano es malo; la manera correcta es generar
y almacenar una [sal](https://en.wikipedia.org/wiki/Salt_(cryptography)) aleatoria `sal = aleatoria()` para cada usuario, guarda 
`KDF(contrasena + sal)`, y verifica los intento de iniciar sesion por cada recalculo de la KDF dada la contrasena ingresada y la sal guardada.

# Criptografia simetrica

Ocultar el contenido de los mensajes es el primer concepto que piensas cuando escuchas sobre criptografia. La criptografia simetirca logra
esto con el siguiente conjunto de funcionalidades:

```
generadorClaves() -> clave  (esta funcion es aleatoria)

encripta(textoPlano: array<byte>, clave) -> array<byte> (texto cifrado)
descripta(textoCifrado: array<byte>, clave) -> array<byte>  (texto plano)
```

La funcion encriptadora tiene la propiedad que dada la salida (texto cifrado), es dificil determinar la entrada (texto plano) sin la clave.
La funcion descriptadora tiene la propiedad exacta imaginda, tal que `decripta(encripta(m,k)) = m`.

Un ejemplo de un sistema simetrico criptografico con amplio uso hoy es: [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard).

## Aplicaciones

- Archivos encriptados para almacenamiento en un servicio en la nube poco confiable. Esto puede ser combinado con KDF's, entonces tu puedes encriptar
archivos con un frase semilla. Generar `clave = KDF(frase semilla)`, y entonces guardar con `encriptar(archivo, clave)`.

# Criptografia asimetrica

El termino "asimetrico" refiere a la existencia de dos claves, con diferntes responsabilidades. Una clave privada, 
como su nombre indica, signifca mantenerse oculta al mundo exterior, mientras la clave publica puede ser ampliamente compartida y no afectara sistemas
seguros (caso contrario a las llaves en los sistemas critograficos simetricos). Los sistemas simetricos asimetricos proveen las siguientes funcionalidades,
para encriptar/desencriptar y para verficar/firmar:

```
keygen() -> (clave publica y clave privada)  (esta funcion es aleatoria)

encriptar(texto_plano: array<byte>, clave publica) -> array<byte>  (texto crifado)
desencriptar(texto_cifrado: array<byte>, clave privada) -> array<byte>  (texto plano)

firmar(mensaje: array<byte>, clave privada) -> array<byte>  (the signature)
verificar(mensaje: array<byte>, firma: array<byte>, clave publica) -> bool  (es una firma valida?)
```
La funciones encriptadoras/desencriptadoras tienen propiedades similares a sus analogos de los cripto-sistemas simetricos.
Un mensaje puede ser encriptado usando la clave _publica_. Dado la salida (texto cifrado), es dificil determinar la entrada
(texto plano) sin la clave _privada_. La funcion desenscriptadora tiene la obvia propiedad indicada, tal que `desencriptar(encriptar(m, clave publica), clave privada)=m`.

La encripctacion simetrica y asimetrica puede ser comparada a las cerraduras. Un cripto-sistema simetrico es como una puerta cerrada:cualquiera con la llave puede abrirla y cerrarla. En los sistemas asimetricos es como buzon de correo con llave. Puedes dar un desbloquedo candado a alguien (la clave publica), ellos pueden poner un mensaje en la caja y entonces pueden bloquerdo, y despues de eso, solamente tu puedes abrir el candado porque tu mantienes la llave (la clave privada).  

Las funciones de verificacion y firma tienen algunas propiedades que tu esperarias tener en las firmas fisicas: son dificiles de falsificar. No importa el mensaje, sin la clave _privada_, es dificil producir una firma tal que `verficar(mensaje, firma, clave publica)` retorna verdadero. Y por supuesto, la funcion verificada tiene la exacta propiedad: `verifica(mensaje, firmar(mensaje, clave privada), clave publica)=verdadero`

## Aplicaciones

- [Encriptacion de correos electronicos PGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy).
Las personas pueden tener claves publicas publicadas en linea (por ejemplo, en un PGP servidor de claves o en 
[Keybase](https://keybase.io/)). Cualquiera puede enviarles un correo encriptado. 
- Mensajeria privada. Aplicaciones como [Signal](https://signal.org/) y
[Keybase](https://keybase.io/) usan claves asimetricas para establecer canales de comunicacion privados.
- Sofware firmador. Git puede tener GPG-firmados _commits_ y las etiquetas _tags_. Con un publicada clave publica,
cualqueira puede verificar la autencidad del software descargado.

## Distribucion de claves

La clave asimetrica criptografica es maravillosa, pero tiene un gran reto para distruibuir las claves publicas / relacionar claves publicas
a identidades del mundo real. Hay muchas soluciones a este problema, Signal, por ejemplo, confia en el primer uso, y soporta un fuera de banda de intercambio
de claves publicas (tu verificas a tus amigos, la seguridad de numeros en persona). Otro ejemplo, PGP, cuya solucion es 
[web of trust](https://en.wikipedia.org/wiki/web_of_trust). Keybase mediante [prueba social](https://keybase.io/blog/chat-apps-softer-than-tofu) lo resuelve, juntocon otras buenas ideas, por eso nos gusta, aunque cada modelo tiene sus propias meritos.

# Casos de estudio

## Los gestores de contrasena

Esta es una esencial herramienta que todos deberian intenatar usar (por ejemplo [KeePassXC](https://keepassxc.org/)). Los gestos de contrasena te permiten usar
contrasenas unicas, aleatorias generadas con alta entropia para todos los sitios web -apps-, y guardan todas tus contrasenas en un unico lugar, encriptados
un cifrado simetrico con una clave producida desde una frase usado un KDF.

Usando un gestor de contrasena te evita reusar contrasenas, entonces cuando los sitios web sean comprometidos, el impacto a tu seguridad sera menor.
Usando contrasenas con alta entropia (tu estaras menos comprometido), y soalmente necesitas recordar una unica contrasena altamente entropica. 

## Doble factor de autenticacion

[Doble factor de autententicacion](https://en.wikipedia.org/wiki/Multi-factor_authentication)
(2FA) requiere usar una frase (algo que tu sabes) junto con un 2FA autenticador (como con [YubiKey](https://www.yubico.com/), "algo que tu tienes")
en orden para proteger contra contrasenas robadas y ataques por [phishing](https://en.wikipedia.org/wiki/Phishing).

## Encriptacion completa de disco

Manteniendo el disco de tu laptop enteramente encriptado es una manera facil de proteger tus datos en caso que tu computadora sea robada.
Tu puedes usar [cryptsetup +
LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)
en Linux,
[BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/) en Windows o [FileVault](https://support.apple.com/en-us/HT204837) en macOS.
Estos encriptan el disco entero con una clave simetrica, con una clave protegida por una frase.

## Mensajeria privada

Usa [Signal](https://signal.org/) o [Keybase](https://keybase.io/). La seguridad de las claves de extremo a extremo es arrancada desde una encriptacion por clave
asimetrica. Obtener las claves publicas de tus contactos es el paso crtico aqui. Si quieres una buena seguridad, necesitas autenticar las claves publicas
fuera de banda (como Signal o Keybase) o confiar en la prueba social (como Keybase).

## SSH

Hemos cubierto el uso de SSH y las claves SSH en una [conferencia anterior](/2020/command-line/#remote-machines). Miramos algunos aspectos criptograficos.
Cuando tu corres `ssh-keygen`, es generada una clave asimetrica par, `clave_publica, clave_privada`. Esta es generada aleatoriamente, usando la entropia generada por el sistema operativo (collecionada desde eventos del hardware, etc.). La clave publica es guardada como es (es publica, entonces mantenerla en secreto no es importante), pero en el reposo, la clave privada deberia ser encriptarse el disco.

El programa `ssh-keygen` pide al usuario una frase, y este se alimenta a traves de una funcion de clave derivada para producir una clave, la cual entonces
es usada para encriptar la clave privada con un cifraco simetrico.

En uso, una vez que el servidor sabe que la clave publica del cliente (almacenadas en el archivo `.ssh/authorized_keys`), 
una conexion al  cliente puede provar su identidad usando las firmas asimetricas. Esto es hecho a traves de la [challenge-response](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication). En un alto nivel, el servidor elige un numero aleatorio y lo envia al cliente. El cliente entonces firma este mensaje y envia la firma de regreso al servidor, el cual revisa la firma contra la clave publica en el registro. Esto efectivamente prueba que el cliente es el poseedor de la clave privada correspondiente a la clave publica que esta en el archivo `.ssh/authorized_key` del servidor, entonces el servidor puede permitir al cliente continuar.

{% comment %}
extra topics, if there's time

security concepts, tips
- biometrics
- HTTPS
{% endcomment %}

# Recursos

- [Notas del ano pasado](/2019/security/): cuando esta conferencia estaba mas enfocada en la seguridad y privacidad como un usuario final.
- [Correctas respuestas criptograficas](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html): respuestas a "que cripto deberia usar para X?", para esas comunes X.

# Ejercicios

1. **Entropia.**
    1. Supon una contrasena es elegida como una concadenacion de 5 palabras minisculas del diccionario,
       donde cada palabra es seleccionada uniformemente aleatoria desde un diccionario de 100,000 palabras.
       Un ejemplo el cual la contrasena sea `correctocaballobateriagrapa`. Cuantos bits de entropia tiene esto?
    2. Considera un esquema alternativo donde una contrasena es elegida como una sequencia de 8 caracteres aleatorios
       alfanumericos (incluyendo minisculas y mayusculas). Un ejemplo es `rg8Ql34g`. Cuantos bits de entropia tiene esto?
    3. Cual es la contrasena mas fuerte?
    4. Supon un atacante puede intentar 10,000 contrasenas por segundo. En promedio, cuanto tiempo tomara romper cada contrasena?

2. **Funciones hash criptograficas.** 
   1. Descarga una imagen Debian desde un [mirror](https://www.debian.org/CD/http-ftp/) (ejemplo [Mirror argentino](http://debian.xfree.com.ar/debian-cd/current/amd64/iso-cd/).
   Verifica de forma cruzada  el hash (ejemplo usando el comando `sha256sum`) con el hash mostrado desde el sitio oficial desde Debian (ejemplo [este archivo](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS)
   almacenados en `debian.org`, si tu has descargado el archivo vinculado al mirror argentino).

3. **Criptografia simetrica.** Encripta un archivo por AES, usando
   [OpenSSL](https://www.openssl.org/): `openssl aes-256-cbc -salt -in {input
   filename} -out {output filename}`. Mira el contenido usando `cat` o `hexdump`. Desencripta con `openssl aes-256-cbc -d -in {input filename} -out
   {output filename}` y confirma que el contenido  coindicida con el original con `cmp`.

1. **Criptografia asimetrica.**
    1. Configura [las claves SSH](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
       en una computadora que tengas acceso (no Athena, porque Kerberos interactua extranamente con claves SSH).
       En un lugar de usar claves RSA como en el tutorial vinculado, usa la mas segura 
       [claves ED25519](https://wiki.archlinux.org/index.php/SSH_keys#Ed25519).
       Asegurate que tu contrasena esta encriptada con una frase, entonces eso te protegera del resto.
    2. [Configura GPG](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)
    3. Envia a Anish un email encriptado. ([clave publica](https://keybase.io/anish)).
    4. Firma un git commit con `git commit -S` o create una etiqueda git firmada con `git tag -s`.
       Verifica la firma en el commit con `git show --show-signature` o en el caso de la etiqueta con `git tag -v`. 
