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

Así, crear encadenamientos de comandos, guardar resultados en archivos, y leer del dispositivo de entrada estandar son tareas primitivas en scripts de terminal, que lo hace más faicl que usar un lenguaje scripting de propósito general.

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


## Finding files

One of the most common repetitive tasks that every programmer faces is finding files or directories.
All UNIX-like systems come packaged with [`find`](https://www.man7.org/linux/man-pages/man1/find.1.html), a great shell tool to find files. `find` will recursively search for files matching some criteria. Some examples:

```bash
# Find all directories named src
find . -name src -type d
# Find all python files that have a folder named test in their path
find . -path '*/test/*.py' -type f
# Find all files modified in the last day
find . -mtime -1
# Find all zip files with size in range 500k to 10M
find . -size +500k -size -10M -name '*.tar.gz'
```
Beyond listing files, find can also perform actions over files that match your query.
This property can be incredibly helpful to simplify what could be fairly monotonous tasks.
```bash
# Delete all files with .tmp extension
find . -name '*.tmp' -exec rm {} \;
# Find all PNG files and convert them to JPG
find . -name '*.png' -exec convert {} {}.jpg \;
```

Despite `find`'s ubiquitousness, its syntax can sometimes be tricky to remember.
For instance, to simply find files that match some pattern `PATTERN` you have to execute `find -name '*PATTERN*'` (or `-iname` if you want the pattern matching to be case insensitive).
You could start building aliases for those scenarios, but part of the shell philosophy is that it is good to explore alternatives.
Remember, one of the best properties of the shell is that you are just calling programs, so you can find (or even write yourself) replacements for some.
For instance, [`fd`](https://github.com/sharkdp/fd) is a simple, fast, and user-friendly alternative to `find`.
It offers some nice defaults like colorized output, default regex matching, and Unicode support. It also has, in my opinion, a more intuitive syntax.
For example, the syntax to find a pattern `PATTERN` is `fd PATTERN`.

Most would agree that `find` and `fd` are good, but some of you might be wondering about the efficiency of looking for files every time versus compiling some sort of index or database for quickly searching.
That is what [`locate`](https://www.man7.org/linux/man-pages/man1/locate.1.html) is for.
`locate` uses a database that is updated using [`updatedb`](https://www.man7.org/linux/man-pages/man1/updatedb.1.html).
In most systems, `updatedb` is updated daily via [`cron`](https://www.man7.org/linux/man-pages/man8/cron.8.html).
Therefore one trade-off between the two is speed vs freshness.
Moreover `find` and similar tools can also find files using attributes such as file size, modification time, or file permissions, while `locate` just uses the file name.
A more in-depth comparison can be found [here](https://unix.stackexchange.com/questions/60205/locate-vs-find-usage-pros-and-cons-of-each-other).

## Finding code

Finding files by name is useful, but quite often you want to search based on file *content*. 
A common scenario is wanting to search for all files that contain some pattern, along with where in those files said pattern occurs.
To achieve this, most UNIX-like systems provide [`grep`](https://www.man7.org/linux/man-pages/man1/grep.1.html), a generic tool for matching patterns from the input text.
`grep` is an incredibly valuable shell tool that we will cover in greater detail during the data wrangling lecture.

For now, know that `grep` has many flags that make it a very versatile tool.
Some I frequently use are `-C` for getting **C**ontext around the matching line and `-v` for in**v**erting the match, i.e. print all lines that do **not** match the pattern. For example, `grep -C 5` will print 5 lines before and after the match.
When it comes to quickly searching through many files, you want to use `-R` since it will **R**ecursively go into directories and look for files for the matching string.

But `grep -R` can be improved in many ways, such as ignoring `.git` folders, using multi CPU support, &c.
Many `grep` alternatives have been developed, including [ack](https://beyondgrep.com/), [ag](https://github.com/ggreer/the_silver_searcher) and [rg](https://github.com/BurntSushi/ripgrep).
All of them are fantastic and pretty much provide the same functionality.
For now I am sticking with ripgrep (`rg`), given how fast and intuitive it is. Some examples:
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

Note that as with `find`/`fd`, it is important that you know that these problems can be quickly solved using one of these tools, while the specific tools you use are not as important.

## Finding shell commands

So far we have seen how to find files and code, but as you start spending more time in the shell, you may want to find specific commands you typed at some point.
The first thing to know is that typing the up arrow will give you back your last command, and if you keep pressing it you will slowly go through your shell history.

The `history` command will let you access your shell history programmatically.
It will print your shell history to the standard output.
If we want to search there we can pipe that output to `grep` and search for patterns.
`history | grep find` will print commands that contain the substring "find".

In most shells, you can make use of `Ctrl+R` to perform backwards search through your history.
After pressing `Ctrl+R`, you can type a substring you want to match for commands in your history.
As you keep pressing it, you will cycle through the matches in your history.
This can also be enabled with the UP/DOWN arrows in [zsh](https://github.com/zsh-users/zsh-history-substring-search).
A nice addition on top of `Ctrl+R` comes with using [fzf](https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings#ctrl-r) bindings.
`fzf` is a general-purpose fuzzy finder that can be used with many commands.
Here it is used to fuzzily match through your history and present results in a convenient and visually pleasing manner.

Another cool history-related trick I really enjoy is **history-based autosuggestions**.
First introduced by the [fish](https://fishshell.com/) shell, this feature dynamically autocompletes your current shell command with the most recent command that you typed that shares a common prefix with it.
It can be enabled in [zsh](https://github.com/zsh-users/zsh-autosuggestions) and it is a great quality of life trick for your shell.

Lastly, a thing to have in mind is that if you start a command with a leading space it won't be added to your shell history.
This comes in handy when you are typing commands with passwords or other bits of sensitive information.
If you make the mistake of not adding the leading space, you can always manually remove the entry by editing your `.bash_history` or `.zhistory`.

## Directory Navigation

So far, we have assumed that you are already where you need to be to perform these actions. But how do you go about quickly navigating directories?
There are many simple ways that you could do this, such as writing shell aliases or creating symlinks with [ln -s](https://www.man7.org/linux/man-pages/man1/ln.1.html), but the truth is that developers have figured out quite clever and sophisticated solutions by now.

As with the theme of this course, you often want to optimize for the common case.
Finding frequent and/or recent files and directories can be done through tools like [`fasd`](https://github.com/clvv/fasd) and [`autojump`](https://github.com/wting/autojump).
Fasd ranks files and directories by [_frecency_](https://developer.mozilla.org/en/The_Places_frecency_algorithm), that is, by both _frequency_ and _recency_.
By default, `fasd` adds a `z` command that you can use to quickly `cd` using a substring of a _frecent_ directory. For example, if you often go to `/home/user/files/cool_project` you can simply use `z cool` to jump there. Using autojump, this same change of directory could be accomplished using `j cool`.

More complex tools exist to quickly get an overview of a directory structure: [`tree`](https://linux.die.net/man/1/tree), [`broot`](https://github.com/Canop/broot) or even full fledged file managers like [`nnn`](https://github.com/jarun/nnn) or [`ranger`](https://github.com/ranger/ranger).

# Exercises

1. Read [`man ls`](https://www.man7.org/linux/man-pages/man1/ls.1.html) and write an `ls` command that lists files in the following manner

    - Includes all files, including hidden files
    - Sizes are listed in human readable format (e.g. 454M instead of 454279954)
    - Files are ordered by recency
    - Output is colorized

    A sample output would look like this

    ```
    -rw-r--r--   1 user group 1.1M Jan 14 09:53 baz
    drwxr-xr-x   5 user group  160 Jan 14 09:53 .
    -rw-r--r--   1 user group  514 Jan 14 06:42 bar
    -rw-r--r--   1 user group 106M Jan 13 12:12 foo
    drwx------+ 47 user group 1.5K Jan 12 18:08 ..
    ```

{% comment %}
ls -lath --color=auto
{% endcomment %}

1. Write bash functions  `marco` and `polo` that do the following.
Whenever you execute `marco` the current working directory should be saved in some manner, then when you execute `polo`, no matter what directory you are in, `polo` should `cd` you back to the directory where you executed `marco`.
For ease of debugging you can write the code in a file `marco.sh` and (re)load the definitions to your shell by executing `source marco.sh`.

{% comment %}
marco() {
    export MARCO=$(pwd)
}

polo() {
    cd "$MARCO"
}
{% endcomment %}

1. Say you have a command that fails rarely. In order to debug it you need to capture its output but it can be time consuming to get a failure run.
Write a bash script that runs the following script until it fails and captures its standard output and error streams to files and prints everything at the end.
Bonus points if you can also report how many runs it took for the script to fail.

    ```bash
    #!/usr/bin/env bash

    n=$(( RANDOM % 100 ))

    if [[ n -eq 42 ]]; then
       echo "Something went wrong"
       >&2 echo "The error was using magic numbers"
       exit 1
    fi

    echo "Everything went according to plan"
    ```

{% comment %}
#!/usr/bin/env bash

count=0
until [[ "$?" -ne 0 ]];
do
  count=$((count+1))
  ./random.sh &> out.txt
done

echo "found error after $count runs"
cat out.txt
{% endcomment %}

1. As we covered in the lecture `find`'s `-exec` can be very powerful for performing operations over the files we are searching for.
However, what if we want to do something with **all** the files, like creating a zip file?
As you have seen so far commands will take input from both arguments and STDIN.
When piping commands, we are connecting STDOUT to STDIN, but some commands like `tar` take inputs from arguments.
To bridge this disconnect there's the [`xargs`](https://www.man7.org/linux/man-pages/man1/xargs.1.html) command which will execute a command using STDIN as arguments.
For example `ls | xargs rm` will delete the files in the current directory.

    Your task is to write a command that recursively finds all HTML files in the folder and makes a zip with them. Note that your command should work even if the files have spaces (hint: check `-d` flag for `xargs`)
    {% comment %}
    find . -type f -name "*.html" | xargs -d '\n'  tar -cvzf archive.tar.gz
    {% endcomment %}

1. (Advanced) Write a command or script to recursively find the most recently modified file in a directory. More generally, can you list all files by recency?
