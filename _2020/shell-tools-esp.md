---
layout: lecture
title: "Herramientas de Terminal y scripting"
date: 2019-01-14
ready: true
video:
  aspect: 56.25
  id: kgII-YWo3Zw
---

En esta lectura, vamos a presentar algunos de los conceptos básicos del uso de bash como un lenguaje de scripting junto con un número de herramientas que cubren muchas de las tareas más comunes que estarás ejecutando constantemente en la línea de comandos.

# Secuencias de comandos en la shell

Hasta ahora hemos visto como ejecutar comandos en la terminal y encadenarlos juntos.
Sin embargo, en muchos escenarios vas a querer ejecutar una serie de comandos y hacer uso de expresiones de flujos de comandos como condicionales o ciclos.

Los scripts de terminal son el siguiente paso en complejidad.
Muchas terminales tienen su propio lenguaje de scripting con variables, control de flujo y su propia sintaxis.
Lo que hace diferente el scripting en la shell de otros lenguajes de programacion de scripting es que esta optimizado para realizar tareas relacionadas a la terminal.

Así, crear encadenamientos de comandos, guardar resultados en archivos, y leer del dispositivo de entrada estándar son tareas primitivas en scripts de terminal, que lo hace más fácil que usar un lenguaje scripting de propósito general.

Para esta sección nos enfocaremos en el scripting en bash ya que es el más común.

Para asignar variables en bash, usa la sintaxis `foo=bar` y accede el valor de la variable con `$foo`.
Nota que `foo = bar` no funcionará desde que es interpretado como llamar el programa `foo` con el argumento `=` y `bar`.
En general, en los scripts de shell el caracter de espacio realizará una separación de argumentos. Este comportamiento puede ser confuso al inicio, así que siempre está atento a eso.

Las cadenas de caracteres en bash se pueden definir con `'` y `"`, pero no son lo mismo.
Las cadenas delimitadas con `'` son cadenas literales y no sustituirán los valores de las variables mientras que las delimitadas con `"` si lo harán.

```bash
foo=bar
echo "$foo"
# imprime bar
echo '$foo'
# imprime $foo
```

Como en muchos lenguajes de programación, bash tiene técnicas de flujo de control incluyendo `if`, `case`, `while` y `for`.
Similarmente, `bash` tiene funciones que toman argumentos y pueden operar con ellos. Aquí hay un ejemplo de una función que crea un directorio y hace `cd` a él.


```bash
mcd () {
    mkdir -p "$1"
    cd "$1"
}
```

Aquí `$1` es el primer argumento al script/función.
A diferencia de otros lenguajes de scripting, bash usa una variedad de variables especiales para referirse a los argumentos, códigos de rror, y otras variables relevantes. Abajo hay una lista de algunas de ellas. Una lista más completa puede ser encontrada [aquí](https://www.tldp.org/LDP/abs/html/special-chars.html).
- `$0` es el nombre del script
- `$1` a `$9` - Argumentos del script. `$1` es el primer argumento y así sucesivamente.
- `$@` - Todos los argumentos del script. Usado para iterar sobre todos los argumentos.
- `$#` - Número de argumentos que se pasaron al script.
- `$?` - El código regresado del último comando ejecutado.
- `!!` - El último comando ejecutado entero, incluyendo argumentos. Un patrón comun es ejecutar un comando solamente para que falle debido a permisos faltatantes; puedes rápidamente re-ejecutar el comando con sudo usando `sudo !!`.
- `$_` - El último argumento del último comando ejecutado. Si estás en una shell interactiva, también puedes obtener este valor escribiendo `Esc` seguido de `.`

Los comandos frecuentemente regresarán salida usando `STDOUT`, los errores usando `STDERR`, y un Codigo de Regreso (Return Code) para reportar errores en una manera más script-amigable.
El codigo de regreso o estado de salida es la manera en la que los scripts/comandos comunican como fue la ejecución.
Un valor de 0 indica que el comando fue exitoso, mientras que cualquier otro valor indica que hubo un error.

Los códigos de salida pueden ser usados para ejecutar comandos condicionalmente usando `&&` (operador AND) y `||` (operador OR), ambos son operadores de [corto circuito](https://es.wikipedia.org/wiki/Evaluaci%C3%B3n_de_cortocircuito). Los comandos tambíen pueden ser separados dentro de la misma linea usando `;` (punto y coma).
El programa `true` siempre tendra como código de salida 0, mientras que `false` siempre tendrá un código de salida diferente de 1.


```bash
false || echo "Oops, falló"
# Oops, falló

true || echo "No será impreso"
#

true && echo "Las cosas fueron bien"
# Las cosas fueron bien

false && echo "No será impreso"
# 

true ; echo "Esto siempre correrá"
# Esto siempre correrá

false ; echo "Esto siempre correrá"
# Esto siempre correrá
```

Otro patrón común es querer obtener la salida de un comando como una variable.
Esto puede ser conseguidor con _sustitución de comandos_ (command substitution).
Cuando se usa `$( CMD )` ejecutará `CMD`, obtiene la salida del comando y la sustituye en el lugar.
Por ejemplo, si haces `for archivo in $(ls)`, la shell primero ejecutará `ls` y entonces iterará sobre esos valores.
Una característica menos conocida es _sustitución de procesos_ (process substitution), `<( CMD )>` ejecutará `CMD` y colocará su salida en un archivo temporal y sustituirá el `<()` con ese nombre de archivo. Esto es muy útil cuando los comandos esperan valores para ser pasados por un archivo en lugar por STDIN. Por ejemplo, `diff <(ls foo) <(ls bar)` ejecutará `ls foo` y `ls bar` y comparará sus salidas.


Ya que eso fue mucha información para ser procesada, veamos un ejemplo que muestra algunas de esas características. Iterará sobre los argumentos que le proveamos, aplicará `grep` para la cadena `foobar` en cada archivo, y si no encuentra una coincidencia lo agregará al final del archivo como comentario.

```bash
#!/bin/bash

echo "Iniciando el programa a las $(date)" # La fecha será sustituida por la salida de `date`

echo "Ejecutando el programa $0 con $# argumentos y el identificador de proceso (pid) $$"

for archivo in "$@"; do
    grep foobar "$archivo" > /dev/null 2> /dev/null
    # Cuando el patrón no es encontrado, grep tiene un estado de salida de 1
    # Redirigimos STDOUT y STDERR a un registro nulo debido a que no nos interesa la salida
    if [[ $? -ne 0 ]]; then
        echo "El archivo $archivo no contiene foobar, agregando comentario"
        echo "# foobar" >> "$archivo"
    fi
done
```

// NOTA DEL EDITOR: Propongo este ejemplo de la salida en la terminal

Si ejecutas el script con `./script.sh foo bar baz`, el resultado será algo como:

```
Iniciando el programa a las Thu  1 Aug 23:30:01 EDT 2019
Ejecutando el programa ./script.sh con 3 argumentos y el identificador de proceso (pid) 12345
El archivo foo no contiene foobar, agregando comentario
El archivo bar no contiene foobar, agregando comentario
El archivo baz no contiene foobar, agregando comentario
```

En la comparación no probamos si `$?` es igual a 0, sino que si es diferente de 0.
Bash implementa muchas comparaciones de este tipo - puedes encontrar una lista en el [manual de test](https://www.man7.org/linux/man-pages/man1/test.1.html).
Cuando se hacen comparaciones en bash, trata de usar corchetes dobles `[[ ]]` en lugar de corchetes simple `[ ]`. 
Las posibilidades de hacer errores son menos, aunque no serán portables a `sh`. Una explicación más detallada puede ser encontrada [aquí](https://mywiki.wooledge.org/BashFAQ/031).

Cuando se ejecutan scripts, frecuentemente se quieren pasar argumentos similares entre sí. Bash tiene maneras de hacer esto de una manera más sencilla, expandiendo expresiones llevando a cabo la expansión del nombre de archivo. Estas tecnicas a menudo se refieren a shell _globbing_ (expansión de nombre de archivo).

- Membresías (Wildcards) - Siempre que quieras realizar alguna clase de coincidencia con membresías, puedes usar `?` y `*` para representar un sólo caracter o cualquier cantidad de caracteres respectivamente. Por ejemplo, dados los archivos `foo`, `foo1`, `foo2`, `foo10` y `bar`, el comando `rm foo?` eliminará `foo1` y `foo2` mientras que `rm foo*` borrará todos los archivos excepto `bar`.
- Llaves (Curly braces) `{}` - Cuando tengas un patrón en una serie de comandos, puedes usar llaves para que bash lo expanda automáticamente. Por ejemplo, `echo foo{1,2,3}` imprimirá `foo1 foo2 foo3`. Esto viene muy bien para mover o convertir archivos.

```bash
convert imagen.{png,jpg}
# Se expande a
convert imagen.png imagen.jpg

cp /ruta/al/proyecto/{foo,bar,baz}.sh /nuevaruta
# Se expande a
cp /ruta/al/proyecto/foo.sh /ruta/al/proyecto/bar.sh /ruta/al/proyecto/baz.sh /newpath

# Las técnicas de globbing pueden ser combinadas
mv *{.py,.sh} directorio
# Va a mover todos los archivos con extensión .py y .sh al directorio


mkdir foo bar
# Esto crea los archivos foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h
touch {foo,bar}/{a..h}


touch foo/x bar/y
# Muestra las diferencias entre los archivos que hay en foo y bar
diff <(ls foo) <(ls bar)
# Salida
# < x
# ---
# > y
```

<!-- Por ultimo, las tuberias (pipes) `|` son una característica fundamental del scripting. Las pipes pueden conectar la salida de un programa como entrada de otro programa. Esto se cubrirá más a detalle en la lectura de procesamiento de datos (data wrangling) -->

Escribir scripts de `bash` puede ser engañoso y contra-intuitivo. Hay herramientas como [shellcheck](https:github.com/koalaman/shellcheck) que pueden ayudar a encontrar errores tus scripts de sh/bash.

Nota que los scripts no necesariamente tienen que ser escritos en bash para ser ejecutados desde la terminal. Por ejemplo, aqui hay un simple script en Python que imprime los argumentos en orden inverso:

```python
#!/usr/local/bin/python
import sys
for argumento in reversed(sys.argv[1:]):
    print(argumento)
```

El kernel sabe como ejecutar este script con un intérprete de Python en lugar de shell porque incluimos un [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) `#!/usr/local/bin/python` en la primera línea del script. El shebang es una línea que indica al kernel que el script debe ser ejecutado con un intérprete de Python en lugar de con el shell. El shebang es opcional, pero es una buena práctica incluirlo en los scripts.

Es buena prática escribir las líneas de  __shebang__ usando el comando [`env`](https://www.man7.org/linux/man-pages/man1/env.1.html) que resolverá cualquier comando que exista en el sistema, incrementando la portabilidad de tus scripts. Para resolver la ubicación, `env` hará uso de la variable de entorno `PATH` que vimos en la primera lectura.
Para este ejemplo el shebang sería `#!/usr/bin/env python`.

Algunas diferencias entre las funciones de la shell y los scripts que debes de tener en cuenta:
- Las funciones deben de ser en el mismo lenguaje que la shell, mientras que los scripts pueden ser escritos en cualquier lenguaje. Esto es porque las funciones son ejecutadas por la shell, mientras que los scripts son ejecutados por un intérprete. Por eso es importante que los scripts incluyan un shebang.
- Las funciones son cargadas una vez que su definición es leída. Los scripts son cargados cada vez que son ejecutados.Esto significa que las funciones son un poco más rápidas que los scripts, pero en cuanto los cambias tienes que recargar toda su definición.
- Las funciones son ejecutadas en el ambiente de actual de la shell, mientras que los scripts son ejecutados en sus propios procesos. Así, las funciones pueden modificar variables de entorno, por ejemplo, cambiar tu directorio actual, mientras que los scripts no pueden hacerlo. Los scripts serán pasados por los valores de variables de entorno que han sido exportados usando [`export`](https://www.man7.org/linux/man-pages/man1/export.1p.html)
- Como en muchos lenguajes de programación, las funciones son muy útiles para alcanzar modularidad, reusabilidad de código, y claridad del código de la shell. Frecuentemente los scripts de shell incluirán sus propias definiciones de funciones.

# Herramientas de la shell

## Descubriendo como usar los comandos

En este punto, puede que te estés preguntando como encontrar las banderas para los comandos en la sección de aliasing como `ls -l`, `mv -i` y `mkdir -p`. Generalmente, dado un comando, ¿cómo puedes encontrar lo que hace y sus diferentes opciones? Siempre puedes empezar a buscar en Google, pero dado que UNIX es anterior a StackOverflow, hay maneras de obtener esta información.

Como vimos en la lectura de la shell, el enfoque de primer orden es llamar al comando con las banderas `-h` o `--help`. Un enfoque más detallado es usar el comando `man`.
Una abreviacion para manual, [`man`](https://www.man7.org/linux/man-pages/man1/man.1.html) provee una página de manual (manpage) para un comando que especificas.
Por ejemplo, `man rm` imprimirá el comportamiento del comando `rm` junto con las banderas que toma, incluyendo la bandera `-i` que mostramos anteriormente.
De hecho, lo que hemos estado enlazando hasta ahora para cada comando es la versión en línea de las manpages de Linux para los comandos.
Incluso los comandos no nativos que instalas tendrán entradas de manpage si el desarrollador las escribió e incluyó como parte del proceso de instalación.
Para herramientas interactivas como las basadas en ncurses, la ayuda para los comandos a menudo se puede acceder dentro del programa usando el comando `:help` o escribiendo `?`.

Algunas veces las `manpages` pueden proveer descripciones excesivamente detalladas de los comandos, haciendo difícil descifrar que banderas/sintaxis usar para casos de uso comunes.
Las páginas [TLDR](https://tldr.sh/) son una solución complementaria que se enfoca en dar casos de uso de ejemplo de un comando para que puedas descifrar rápidamente que opciones usar.
Por ejemplo, me encuentro refiriéndome a las páginas de tldr para [`tar`](https://tldr.ostera.io/tar) y [`ffmpeg`](https://tldr.ostera.io/ffmpeg) mucho más seguido que a las manpages.


## Encontrando archivos

Una de las tareas repetitivas más comunes que cada programador enfrenta es encontrar archivos o directorios.
Todos los sistemas tipo UNIX vienen empaquetados con [`find`], una gran herramienta de shell para encontrar archivos. `find` buscará recursivamente archivos que coincidan con algún criterio. Algunos ejemplos:

```bash
# Encuentra todos los directorios llamados src
find . -name src -type d
# Encuentra todos los archivos python que tienen una carpeta llamada test en su ruta
find . -path '*/test/*.py' -type f
# Encuentra todos los archivos modificados en el último día
find . -mtime -1
# Encuentra todos los archivos zip con tamaño en el rango de 500k a 10M
find . -size +500k -size -10M -name '*.tar.gz'
```

Más allá de listar archivos, `find` también puede realizar acciones sobre archivos que coinciden con tu consulta.
Esta propiedad puede ser increíblemente útil para simplificar lo que podría ser tareas bastante monótonas.
```bash
# Elimina todos los archivos con extensión .tmp
find . -name '*.tmp' -exec rm {} \;
# Encuentra todos los archivos PNG y conviértelos a JPG
find . -name '*.png' -exec convert {} {}.jpg \;
```

A pesar de la ubicuidad de `find`, su sintaxis puede ser complicada de recordar.
Por ejemplo, para simplemente encontrar archivos que coincidan con algún patrón `PATTERN` tienes que ejecutar `find -name '*PATTERN*'` (o `-iname` si quieres que la coincidencia de patrones sea insensible a mayúsculas y minúsculas).
Podrías empezar a construir alias para esos escenarios, pero parte de la filosofía de la shell es que es bueno explorar alternativas.
Recuerda, una de las mejores propiedades de la shell es que estás llamando programas, así que puedes encontrar (o incluso escribir tu mismo) reemplazos para algunos.
Por ejemplo, [`fd`](https://github.com/sharkdp/fd) es una alternativa simple, rápida y amigable para `find`.
Ofrece algunos valores predeterminados agradables como salida en color, coincidencia de expresiones regulares predeterminada y soporte Unicode. También tiene, en mi opinión, una sintaxis más intuitiva.
Por ejemplo, la sintaxis para encontrar un patrón `PATTERN` es `fd PATTERN`.

Muchos estarían de acuerdo que `find` y `fd` son buenos, pero algunos de ustedes podrían preguntarse acerca de la eficiencia de buscar por arhcivo cada vez
que contra compilar algún tipo de índice o base de datos para buscar rápidamente.
Aquí es donde usamos [`locate`](https://www.man7.org/linux/man-pages/man1/locate.1.html)
El comando `locate` usa una base de datos que es actualizada usando [`updatedb`](https://www.man7.org./linux/man-pages/man1/updatedb.1.html)
En muchos sistemas, `updatedb` es actualizado todos los días usando [`cron`](https://www.man7.org/linux/man-pages/man8/cron.8.html)
Por lo tanto, un intercambio entre los dos es velocidad vs frescura.
Además, `find` y herramientas similares también pueden encontrar archivos usando atributos como tamaño de archivo, tiempo de modificación, o permisos de archivo, mientras que `locate` solo usa el nombre del archivo.
Una comparación más detallada puede ser encontrada [aquí](https://unix.stackexchange.com/questions/60205/locate-vs-find-usage-pros-and-cons-of-each-other).

## Encontrando código

Encontrar archivos por su nombre es útil, pero muy frecuentemente quieres buscar por el *contenido* del archivo.
Un escenario muy común es querer buscar todos los archivos que contengan algún patron, junto con en donde en esos archivos ocurre dicho patrón.
Para lograr esto, muchos sitemas UNIX-like proveen [`grep`](https://www.man7/org/linux/man-pages/man1/grep.1.html), una herramienta generica para realizar coincidencias de patrones en el texto de entrada.
`grep` es una herramienta increíblemente valiosa de la shell que cubriremos en mayor detalle durante la lectura de procesamiento de datos (data wrangling).

Por ahora, sepan que `grep` tiene muchas banderas que lo hacen una herramienta muy versátil.
Algunas que frecuentemente uso son `-C` para obtener **C**ontexto alrededor de la línea que coincide y `-v` para invertir la coincidencia, es decir, imprimir todas las líneas que **no** coinciden con el patrón.
Por ejemplo, `grep -C 5` imprimirá 5 líneas antes y después de la coincidencia.
Cuando se trata de buscar rápidamente a través de muchos archivos, quieres usar `-R` ya que irá **R**ecursivamente a los directorios y buscará archivos para la cadena que coincida.

Pero `grep -R` puede ser mejorado de muchas maneras, como ignorar carpetas `.git`, usar soporte multi CPU, &c.
Muchas alternativas a `grep` han sido desarrolladas, incluyendo [ack](https://beyondgrep.com/), [ag](https://github.com/ggreer/the_silver_searcher) y [rg](https://github.com/BurntSushi/ripgrep).
Todas son fantásticas y proveen prácticamente la misma funcionalidad.
Por ahora me quedo con `rg`, dado lo rápido e intuitivo que es. Algunos ejemplos:
```bash
# Encuentra todos los archivos python donde usé la librería requests
rg -t py 'import requests'
# Encuentra todos los archivos (incluyendo archivos ocultos) sin una línea shebang
rg -u --files-without-match "^#!"
# Encuentra todas las coincidencias de foo e imprime las siguientes 5 líneas
rg foo -A 5
# Imprime estadísticas de coincidencias (# de líneas y archivos coincidentes)
rg --stats PATTERN
```

```bash
# Find all python files where I used the requests library
rg -t py 'import requests'
# Find all files (including hidden files) without a shebang line
rg -u --files-without-match "^#!"
# Find all matches of foo and print the following 5 lines
rg foo -A 5
# Print statistics of matches (# of matched lines and files )
rg --stats PATTERN
```

Note que como con `find`/`fd`, es importante que sepas que estos problemas pueden ser resueltos rápidamente usando una de estas herramientas, mientras que las herramientas específicas que uses no son tan importantes.

## Encontrando comandos de la shell

Hasta ahora hemos visto como encontrar archivos y código, pero a medida que pases más tiempo en la shell, puede que quieras encontrar comandos específicos que escribiste en algún momento.
Lo primero que debes saber es que escribir la flecha hacia arriba te devolverá tu último comando, y si sigues presionándola lentamente pasarás por tu historial de la shell.
So far we have seen how to find files and code, but as you start spending more time in the shell, you may want to find specific commands you typed at some point.
The first thing to know is that typing the up arrow will give you back your last command, and if you keep pressing it you will slowly go through your shell history.

Pero, ¿qué pasa si quieres buscar un comando que escribiste hace mucho tiempo?
El comando `history` te permitirá acceder a tu historial de la shell de manera programática.
Imprimirá tu historial de la shell en la salida estándar.
Si queremos buscar ahí podemos redirigir esa salida a `grep` y buscar patrones.
`history | grep find` imprimirá comandos que contengan la subcadena "find".

En muchas shells, puedes usar `Ctrl+R` para realizar una búsqueda hacia atrás a través de tu historial.
Después de presionar `Ctrl+R`, puedes escribir una subcadena con la que quieras hacer coincidir comandos en tu historial.
A medida que sigas presionándolo, pasarás por las coincidencias en tu historial.
Esto también se puede habilitar con las flechas ARRIBA/ABAJO en [zsh](https://github.com/zsh-users/zsh-history-substring-search).
Una buena adición a `Ctrl+R` viene con el uso de los enlaces de [fzf](https://github.comjunegunn/fzg/wiki/Configuring-shell-key-bindings#ctrl-r).
`fzf` es un buscador difuso de propósito general que se puede usar con muchos comandos.
Aquí se usa para hacer coincidir difusamente a través de tu historial y presentar los resultados de una manera conveniente y visualmente agradable.

Otra característica genial relacionada con la historia que realmente disfruto es la de **sugerencias automáticas basadas en la historia**.
Introducida por primera vez por la shell [fish](https://fishshell.com/), esta característica completa dinámicamente tu comando de shell actual con el comando más reciente que escribiste que comparte un prefijo común con él.
Se puede habilitar en [zsh](https://github.com/zsh-users/zsh-autosuggestions) y es un gran truco de calidad de vida para tu shell.

Por último, una cosa a tener en cuenta es que si comienzas un comando con un espacio inicial, no se agregará a tu historial de la shell.
Esto es útil cuando escribes comandos con contraseñas u otros bits de información sensible.
Si cometes el error de no agregar el espacio inicial, siempre puedes eliminar manualmente la entrada editando tu `.bash_history` o `.zhistory`.

## Navegación de directorios

Hasta ahora, hemos asumido que ya estás donde necesitas estar para realizar estas acciones. Pero, ¿cómo haces para navegar rápidamente entre directorios?
Hay muchas maneras simples de hacer esto, por ejemplo, escribir aliases en la terminal o creando *symlinks* con [ln -s](https://www.man7.org/linux/man-pages/man1/ln.1.html), pero la verdad es que los desarrolladores han encontrado soluciones bastante inteligentes y sofisticadas hasta ahora.

Como con el tema de este curso, a menudo quieres optimizar para el caso común.
Encontrar archivos y directorios frecuentes y/o recientes se puede hacer a través de herramientas como [`fasd`](https://github.com/clvv/fasd) y [`autojump`](https://github.com/wting/autojump).
Fasd clasifica archivos y directorios por [_frecuencia_](https://developer.mozilla.org/en/The_Places_frecency_algorithm), es decir, por _frecuencia_ y _recencia_.
Por defecto, `fasd` agrega un comando `z` que puedes usar para `cd` rápidamente usando una subcadena de un directorio _frecente_.Por ejemplo, si a menudo vas a `/home/user/files/cool_project` puedes usar simplemente `z cool` para saltar ahí.Usando autojump, este mismo cambio de directorio podría ser logrado usando `j cool`.

Existen herramientas más complejas para obtener una vista de la estructura de un directorio: [`tree`](https://linux.die.net/man/1/tree), [`broot`](https://github.com/Canop/broot) o incluso administradores de archivos como [`nnn`](https://github.com/jarun/nnn) o [`ranger`](https://github.com/ranger/ranger).

# Ejercicios

1. Lee [`man ls`](https://www.man7.org/linux/man-pages/man1/ls.1.html) y escribe un comando `ls` que liste archivos de la siguiente manera

    - Incluye todos los archivos, incluyendo archivos ocultos
    - Los tamaños se listan en formato legible por humanos (por ejemplo, 454M en lugar de 454279954)
    - Los archivos están ordenados por recencia
    - La salida está coloreada

    Una salida de ejemplo se vería así

    ```bash
    -rw-r--r--   1 user group 1.1M Jan 14 09:53 baz
    drwxr-xr-x   5 user group  160 Jan 14 09:53 .
    -rw-r--r--   1 user group  514 Jan 14 06:42 bar
    -rw-r--r--   1 user group 106M Jan 13 12:12 foo
    drwx------+ 47 user group 1.5K Jan 12 18:08 ..
    ```

{% comment %}
ls -lath --color=auto
{% endcomment %}

1. Escribe bash functions `marco` y `polo` que hagan lo siguiente.
Cada vez que ejecutes `marco` el directorio de trabajo actual debe ser guardado de alguna manera, luego cuando ejecutes `polo`, no importa en que directorio estés, `polo` debe `cd` al directorio donde ejecutaste `marco`.
Para facilitar la depuración puedes escribir el código en un archivo `marco.sh` y (re)cargar las definiciones a tu shell ejecutando `source marco.sh`.

{% comment %}
marco() {
    export MARCO=$(pwd)
}

polo() {
    cd "$MARCO"
}
{% endcomment %}

1. Digamos que tienes un comando que falla raramente. Para depurarlo necesitas capturar su salida estándar y de error para que puedas inspeccionarlos.
Sin embargo, la falla es rara, así que quieres ejecutar el comando en un bucle y solo capturar la salida cuando el comando falla.
Escribe un script de bash que ejecute el siguiente script hasta que falle y capture su salida estándar y flujos de error a archivos y los imprima al final.
Puntos extra si también puedes reportar cuantas veces tomó que el script fallara.

    ```bash
    #!/usr/bin/env bash

    n=$(( RANDOM % 100 ))

    if [[ n -eq 42 ]]; then
       echo "Algo fue mal"
       >&2 echo "Ocurrio un error al usar números mágicos"
       exit 1
    fi

    echo "Todo salio bien"
    ```

{% comment %}
#!/usr/bin/env bash

count=0
until [[ "$?" -ne 0 ]];
do
  count=$((count+1))
  ./random.sh &> out.txt
done

echo "Error encontrado despúes de $count ejecuciones"
cat out.txt
{% endcomment %}

1. Como cubrimos en la lectura de `find`, su `-exec` puede ser muy poderoso para realizar operaciones sobre los archivos que estamos buscando.
Sin embargo, ¿qué pasa si queremos hacer algo con **todos** los archivos, como crear un archivo zip?
Como hemos visto hasta ahora, los comandos tomarán entradas tanto de argumentos como de STDIN.
Cuando se enlazan comandos, estamos conectando STDOUT a STDIN, pero algunos comandos como `tar` toman entradas de argumentos.
Para conectar esta separación existe el comando [`xargs`](https://www.man7.org/linux/man-pages/man1/xargs.1.html) que ejecutará un comando usando STDIN como argumentos.
Por ejemplo, `ls | xargs rm` eliminará los archivos en el directorio actual.

    Tu tarea es escribir un comando que encuentre recursivamente todos los archivos HTML en la carpeta y cree un zip con ellos. Ten en cuenta que tu comando debe funcionar incluso si los archivos tienen espacios (pista: revisa la bandera `-d` para `xargs`).
    {% comment %}
    find . -type f -name "*.html" | xargs -d '\n'  tar -cvzf archive.tar.gz
    {% endcomment %}

1. (Avanzado) Escribe un comando o script para encontrar recursivamente el archivo más recientemente modificado en un directorio. Más generalmente, ¿puedes listar todos los archivos por recencia?
