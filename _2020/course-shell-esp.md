---
layout: lecture
title: "Introducción al curso + la shell"
date: 2019-01-13
ready: true
video:
  aspect: 56.25
  id: Z56Jmr9Z34Q
---

# Motivación
Como científico de la computación, sabemos que las computadoras son
geniales en ayudarnos en tareas repetitivas. Sin embargo, 
demasiado a menudo, olvidamos que aplica tanto a nuestro _uso_ de la
computadora como a los cómputos de nuestras aplicaciones. Tenemos un
gran número de herramientas disponibles a nuestro alcance, habilitante
para ser más productivos y resolver problemas complejos cuando trabajamos
en cualquier problema relacionado con la computación. Todavía muchos de
nosotros utilizamos un pequeño conjunto de esas herramientas: sobrevivimos sabiendo
suficientes fórmulas mágicas de memoria y copipegando comandos de Internet
sin pensar cuando nos bloqueamos. Esta clase 
es un intento de abordarlo.

Queremos enseñarte cómo aprovechar al máximo las herramientas que conoces,
mostrarte nuevas para añadir a tu caja de herramientas y esperamos infundirte
emoción para explorar (y tal vez construir) otras por cuenta propia.

Esto es lo que creemos que falta en los semestres de la mayoría de las currículas
de las ciencias de la computación.

# Estructura de la clase

Las clases consisten de 11 lecciones de 1 hora, cada una centrada
en un [tópico particular](/2020/) y con un conjunto de ejercicios para
guiarte en los puntos principales. Las clases son ampliamente independientes,
aunque mientras las lecciones avanzan, asumimos que estás familiarizado con el
contenido de las lecciones previas. Las notas de las clases -que estás leyendo-
no cubren todo lo visto en las clases grabadas (por ejemplo, las demos).

Puedes enviarnos tus preguntas a [missing-semester@mit.edu](mailto:missing-semester@mit.edu).

Debido al tiempo limitado, no cubriremos todas las herramientas en el mismo nivel de
detalle que una clase de gran escala podría tener. Donde sea posible, intentaremos 
guiarte hacia los recursos para guiarte para allá dentro de la herramienta o tema,
pero si algo en particular te llama la atención, no dudes en comunicarte con nosotros
y pedir sugerencias.

# Tema 1: La shell

##  ¿Qué es la shell?

Las computadoras estos días tienen una variedad de interfaces: 
sofisticadas interfaces gráficas de usuarios, interfaces de voz,
AR/VR y muchas otras. Éstas son geniales para el 80% de los casos de uso, pero
ellas fundamentalmente te restringen lo que puedes hacer: tú no puedes presionar 
un botón que no exista o dar una instrucción por voz que no esté programada.
Para aprovechar por completo las herramientas que tu computadora provee,
tenemos que ir a la vieja escuela y ejecutar una interfaz textual: la shell.

En casi todos los sistemas operativos puedes encontrar una shell de una forma u otra
y muchos de ellos tienen diversas shells para elegir. Por más que varían en los
detalles, en esencia son más o menos lo mismo: te permiten correr tu programas, 
darle una entrada e inspeccionar sus salidas de manera semiestructurada.   

En esta lección, nos enfocamos en la "Bourne Again SHell", o "bash" para abreviar.
Ésta es una de las shells más ampliamente usadas, y su sintáxis es similar al resto.
Para abrir una shell _prompt_ (donde puedas escribir comandos), tú primero necesitas
una _terminal_. Tu computadora probablemente venga de serie con una, o puedes instalar
una muy fácilmente. 

## Usando la shell 

Cuando lanzas tu terminal, ves un _prompt_ que frecuentemente luce así:

```console
missing:~$ 
```

Esta es la principal interfaz contextual a la shell y la terminal nos cuenta
tu nombre de usuario `missing`; tu "directorio de trabajo" o donde actualmente estás, 
que es `~` (abrevia "home"). El `$` cuenta que no eres el usuario administrador -"root"-.
En este prompt tú puedes escribir un `comando`, el cual entonces sería interpretado por
la shell. Uno de los comandos más básicos es: 

```console
missing:~$ date
Fri 10 Jan 2020 11:49:31 AM EST
missing:~$ 
```

Aquí, ejecutamos el programa `date`, el cual (tal vez sorpresivamente) imprime la
fecha actual y la hora. La shell, entonces nos pregunta por otro comando a ejecutar.
También podemos ejecutar un comando con _argumentos_:

```console
missing:~$ echo hello
hello
```

En este caso, le ordenamos a la shell ejecutar el programa `echo` con el
argumento `hello`. El programa `echo` simplemente imprime sus argumentos.
La shell analiza el comando dividiéndolo por espacios en blanco, y entonces
corre el programa indicado en la primera palabra, proveyendo cada subsecuente
palabra como un argumento al que el programa puede acceder. Si tú quieres
proveer un argumento que contiene espacios u otro carácter especial (por ejemplo, 
un directorio nombrado "Mis fotos"), puedes citarlo como `'` (`'Mis fotos'`) o `"` 
(`"Mis fotos"`), o escaparlo solamente con el relevante carácter con `\` (`Mis\ fotos`).

```console
missing:~$ echo "Mis fotos"
hello
```

Pero ¿cómo logra la shell encontrar los programas `date` o `echo`?
Bueno, la shell es un entorno de programación, como Python o Ruby,
entonces tiene variables, condicionales, bucles, y funciones. Cuando corres
comandos en tu shell, tú realmente escribes una pequeña porción de código que tu shell
interpreta. Si pides a la shell ejecutar un comando que no coincide con las
palabras reservadas de su lenguaje, consulta una _variable de entorno_ llamada
`$PATH`, que lista los directorios en que buscar programas al recibir un comando:

```console
missing:~$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
missing:~$ which echo
/bin/echo
missing:~$ /bin/echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Cuando corremos el comando `echo`, la shell revisa que pueda ejecutarse el programa 
`echo` buscando a través de los directorios del `$PATH` separados por `:` por un archivo
que coincida. Cuando lo encuentra, lo corre (asumiendo que que el archivo sea _ejecutable_).
Podemos descubrir la ubicación del archivo ejecutado con `which`. Podemos evitar pasar por el
proceso anterior, escribiendo la `ruta` al archivo a ejecutar.

## Navegando en la shell

Una ruta en la shell es una lista de directorios separados por `/` en Linux y Darwin, y por `\` en Windows.
En Linux y Darwin, la ruta `/` es la raíz del sistema de archivos, bajo la cual se encuentran
el resto de los archivos, mientras en Windows hay una raíz para cada partición (ejemplo: `C:\`).
Generalmente asumimos que estás usando un sistema de archivos Linux. 

Una ruta que empieza con `/` es llamada una ruta _absoulta_. Cualquier otra ruta es una ruta _relativa_.
Las rutas relativas son relativas con respecto al directorio de trabajo actual, al que podemos consultar
con el comando `pwd` y cambiar con `cd`. En una ruta, `.` refiere al directorio actual y `..` al 
directorio padre:


```console
missing:~$ pwd
/home/missing
missing:~$ cd /home
missing:/home$ pwd
/home
missing:/home$ cd ..
missing:/$ pwd
/
missing:/$ cd ./home
missing:/home$ pwd
/home
missing:/home$ cd missing
missing:~$ pwd
/home/missing
missing:~$ ../../bin/echo hello
hello
```

Nota que nuestro prompt nos mantuvo informados sobre cuál fue nuestro directorio de trabajo. 
Puedes configurarlo para mostrar todo tipo de información útil, luego veremos cómo.

En general, cuando corremos programas, operamos en el directorio actual, a menos que le digamos
otra cosa. Por ejemplo, usualmente buscamos archivos, y creamos archivos.

Para ver qué vive en un directorio dado, usamos el comando `ls`:

```console
missing:~$ ls
missing:~$ cd ..
missing:/home$ ls
missing
missing:/home$ cd ..
missing:/$ ls
bin
boot
dev
etc
home
...
```

A menos que un directorio sea dado como primer argumento, `ls` imprimirá
el contenido del directorio actual. La mayoría de los comandos aceptan banderas y
opciones (banderas con argumentos) que empiezan con `-` para modificar su comportamiento.
Usualmente, corriendo un programa con la bandera `-h` o `--help` (`/?` en Windows) imprimirá
alguna ayuda textual que nos contará las banderas y opciones disponibles. Por ejemplo, 
`ls --help` nos dice:

```
  -l                         use a long listing format
```

```console
missing:~$ ls -l /home
drwxr-xr-x 1 missing  users  4096 Jun 15  2019 missing
```

Esto nos da un montón de información sobre cada archivo o directorio 
presente. Primero, la `d` en el inicio de la línea nos dice que
`missing` es un directorio. Entonces le siguen tres grupos de tres caracteres `rwx`.
Estos 3 grupos indican qué permisos tiene el dueño del archivo `missing`, el grupo del dueño
`users`, y todos los demás. Arriba, solamente el dueño se le permite escribir `w` (añadir/remover archivos) en el directorio `missing`.
Para entrar a un directorio, un usuario debe tener permisos para "buscar" (representado por "ejecutar": `x`)
en ese directorio (y sus padres). Para listar su contenido, un usuario debe tener permisos de lectura `r` en 
ese directorio. Para los archivos, los permisos son los que esperarías. `-` indica que no se tiene ninguno de los
permisos anteriores (ni lectura, ni ejecutar, ni escribir). Nota que casi todos los archivos en `/bin` tienen
los permisos para ejecutar -`x`- establecidos para el último grupo -para los demás-, entonces
cualquiera puede ejecutar esos programas.

Algunos otros programas comunes para conocer en este punto son `mv` (para renombrar/mover un archivo), `cp`
(para copiar un archivo) y `mkdir` (para crear un nuevo directorio).

Si alguna vez quieres _más_ información sobre los argumentos de un programa, sus entradas, salidas,
o como trabaja en general, prueba el comando `man` (páginas de manual). Eso toma como un argumento el nombre de un programa,
y te muestra su _página del manual_. Presiona `q` para salir.

```console
missing:~$ man ls
```

## Conectando programas

En la shell, los programas tienen dos flujos ("streams") primarios asociados:
su flujo de entrada y su flujo de salida. Cuando el programa intenta leer la entrada,
lo intenta desde el flujo de entrada, y cuando imprime algo, eso lo imprime a su flujo de salida.
Normalmente, la entrada y la salida de un programa son ambos tu terminal. Esto es, tu teclado como
flujo de entrada y tu pantalla como flujo de salida. Sin embargo, podemos reconectar esos flujos.

La manera más simple de redireccionar es haciendo `< archivo` y `> archivo`. Esto te permite redirigir la entrada
y la salida de un programa a un archivo, respectivamente:

```console
missing:~$ echo hello > hello.txt
missing:~$ cat hello.txt
hello
missing:~$ cat < hello.txt
hello
missing:~$ cat < hello.txt > hello2.txt
missing:~$ cat hello2.txt
hello
```

También puedes usar `>>` para agregar al final de un archivo. Donde realmente brilla este tipo de
redirección de entrada/salida es en el uso de _pipes_. El operador `|` te permite "encadenar"
programas tal que la salida de uno sea la entrada de otro:

```console
missing:~$ ls -l / | tail -n1
drwxr-xr-x 1 root  root  4096 Jun 20  2019 var
missing:~$ curl --head --silent google.com | grep --ignore-case content-length | cut --delimiter=' ' -f2
219
```

## Una herramienta versátil y poderosa

En la mayoría parecidos a Unix, sobresale un usuario: el usuario "root", administrador o superusuario. 
Tu podrás verlo visto, cuando listamos los archivos arriba. "root" está por encima (casi) de todas las restricciones 
en el sistema: puede crear, leer, actualizar, y eliminar cualquier archivo en el sistema. 
Sin embargo, tú usualmente no inicias sesión como "root" dado que es 
demasiado fácil romper accidentalmente algo. En su lugar, usamos el comando `sudo`. Como su nombre implica, eso 
te permite hacer algo "do" como superusuario "su" (abreviación para super usuario). Cuando obtienes mensajes de
error por permisos denegados, usualmente necesitas permisos como "root", aunque asegurate dos veces de que es lo que 
realmente quieres.

Necesitas ser "root" para poder escribir al archivo `sysfs` montado sobre `/sys`. `sysfs` expone unos parametros del kernel
como archivos, entonces tu puedes fácil reconfigurar el kernel al vuelo sin herramientas especializadas. 
**Nota que sysfs no existe en Windows o macOS.**

Por ejemplo, el brillo de tu pantalla es expuesto a través de un archivo llamado `brightness` bajo

```
/sys/class/backlight
```
Por escribir un valor dentro de ese archivo, podemos cambiar el brillo de la pantalla. Tu primer instinto podría
ser algo como:

```console
$ sudo find -L /sys/class/backlight -maxdepth 2 -name '*brightness*'
/sys/class/backlight/thinkpad_screen/brightness
$ cd /sys/class/backlight/thinkpad_screen
$ sudo echo 3 > brightness
An error occurred while redirecting file 'brightness'
open: Permission denied
```

Este error puede parecer de sorpresa. Después de todo, corremos el comando con `sudo`. Esto es un importante
cosa que debes saber sobre la shell. Las operaciones como `|`, `>` y `<` se logran _por la shell_, no por 
los programas individuales. `echo` y compañía no saben sobre `|`. Ellos solamente leen su entrada y escriben
a su salida. cualquiera que esta sea. En el caso de arriba, la _shell_ (la cual es autenticada como un usuario)
intenta abrir el archivo de brillo para escribir, antes de la salida `sudo echo`. pero no puede prevenirlo porque
la shell no corre como "root" Usando este conocimiento, podemos trabajar esto:

```console
$ echo 3 | sudo tee brightness
```

Dado que el programa `tee` es el que abre el archivo `/sys` para escribir y corre como `root`. 
Los permisos ahora funcionan. Tu puedes controlar todo tipo de divertidos y útiles cosas a través de `/sys`, tales
como el estado de varios sistemas LED (tu ruta podría ser diferente):

```console
$ echo 1 | sudo tee /sys/class/leds/input6::scrolllock/brightness
```

# Siguientes pasos

En este punto, conoce lo suficiente alrededor de la shell para completar la mayoría de las tareas. Tú deberías poder navegar para encontrar archivos y usar las funcionalidades básicas para la mayoría de los programas. En la
próxima lección, hablaremos sobre como automatizar tareas más complejas usando la shell y muchos otros comandos prácticos.

# Ejercicios

 1. Crea un nuevo directorio llamado `missing` bajo `tmp`.
 2. Busca el programa `touch`. El programa `man` es tu amigo.
 3. Usa `touch` para crear un nuevo archivo `semester` en `missing`.
 4. Escribe lo siguiente dentro ese archivo, una línea a la vez:
    ```
     #!/bin/sh
     curl --head --silent https://missing.csail.mit.edu
    ```

    La primera línea puede ser difícil de poner en funcionamiento. Te será de ayuda saber que 
    con `#` comienzas un comentario en Bash, y `!` tiene un especial significado incluso dentro de
    comillas dobles (`"`). Bash trata a las comillas simples (`'`) diferente: ellas podrían ayudarte en este caso.
    Ve más en ["quoting"](https://www.gnu.org/software/bash/manual/html_node/Quoting.html).
 
 5.  Prueba a ejecutar el archivo, es decir escribe la ruta del archivo (`./semester`) en tu shell y presiona "enter".
     Para entender el por qué no trabaja consulta la salida de `ls` (pista: mira los bits de permisos).
 
 6. Corre el comando explícitamente empezando con el intérprete `sh`, y dando el archivo `semester` como el primer
    argumento, es decir `sh semester`. ¿Por qué este funcionó mientras `./semester` no lo hace?

 7. Busca el programa `chmod`.  
 
 8. Usa `chmod` para asegurarte que es posible correr el comando `./semester` en lugar  de tener que escribir
   `sh semester`. ¿Cómo sabe tu shell que el archivo  debe ser interpretado usando `sh`? Ve esta página
    [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) para más información.

 9. Usa `|` y `>` para escribir la fecha salida del "último modificado" por `semester` dentro de un archivo
    llamado `last-modified.txt` en tu directorio "home".
 
 10. Escribe un comando que lea la batería de tu laptop o la temperatura de tu computadora de escritorio desde `/sys`.
     Nota: si tu eres un usuario de mac OSX o Windows, tu sistema operativo no tiene `sysfs`.


 
