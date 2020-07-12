---
layout: lecture
title: "Editores (Vim)"
date: 2019-01-15
ready: true
video:
  aspect: 56.25
  id: a6Q8Na575qc
---

Escribir palabras en español y escribir código son actividades muy diferentes.
Cuando programas, gastas más tiempo cambiando de archivos, leyendo, navegando y
editando código en vez de escribir largas secuencias de texto. Tiene sentido que 
existan diferentes tipos de programas para escribir palabras en español y
código (e.g. Microsoft Word comparado con Visual Studio Code).

Como programadores, gastamos la mayoría del tiempo editando nuestro código, por lo que
es valioso invertir tiempo en dominar un editor que se ajuste a tus necesidades.
Acá esta la forma de cómo aprender un nuevo editor:

- Comienzas con un tutorial (i.e. esta clase, además de otros recursos que te indicamos)
- Te mantienes usando el editor para todas tus necesidades de edición (incluso si 
al comienzo te vuelves más lento)
- Investigas a medida que avanzas: si parece que debiera existir una mejor 
manera de hacer algo, probablemente la haya

Si sigues el método de arriba al pie de la letra, comprometido totalmente usando
el nuevo programa cada vez que tu proposito sea editar un texto, la línea de tiempo
para aprender el sofisticado editor de texto será algo como esto. En una o dos horas,
aprenderas lo básico de las funciones de edición como abrir y editar archivos, 
guardar/salir, y navegar por los *buffers*. Una vez que lleves 20 horas de práctica,
deberías ser igual de rápido como eras con tu antiguo editor. Luego de esto, 
comienzan los beneficios: tendrás suficiente conocimiento y memoria muscular que 
al usar el nuevo editor ahorrarás tiempo. Los editores de texto modernos son 
herramientas sofisticadas y poderosas, por lo que el aprendizaje nunca termina: 
y te volveras incluso más rápido a medida que aprendas más.

# ¿Qué editor aprender? 

Los programadores tienen [fuertes opiniones](https://en.wikipedia.org/wiki/Editor_war)
acerca de sus editores de texto.

¿Qué editores son populares hoy? Echa un vistazo a esta encuesta de [Stack Overflow](https://insights.stackoverflow.com/survey/2019/#development-environments-and-tools)
(puede haber sesgos debido a que los usuarios de Stack Overflow no necesariamente
son una muestra representativa de todos los programadores). [Visual Studio
Code](https://code.visualstudio.com/) es el editor más popular y [Vim](https://www.vim.org/) 
es el editor más popular basado en la consola (línea de comandos).

## Vim

Todos los instructores de esta clase usan Vim como editor. Vim tiene una gran
historia; fue creado a partir del editor Vi (1976) y aún hasta el día de hoy
sigue siendo desarrollado. Vim tiene algunas ideas realmente interesantes detras de él, y 
por esta razón, muchas herramientas soportan un modo de emular Vim (por ejemplo,
1.4 millones de personas tienen instalado [el modo de emulación de Vim para VS code](https://github.com/VSCodeVim/Vim)).
Es probable que valga la pena aprender Vim incluso si decides finalmente cambiarte
a otro editor de texto. 

No es posible enseñar todas las funcionalidades de Vim en 50 mínutos, por lo que
nos enfocaremos en explicar la filosofía de Vim, enseñarte lo básico, mostrarte
algunas de las funcionalidades más avanzadas y darte los recursos necesarios
para que domines la herramienta.

# La filosofía de Vim 

Cuando programas gastas la mayor parte de tu tiempo leyendo, o editando, y no escribiendo.
Por esta razón, Vim es un editor _modal_: tiene diferentes modos para insertar
texto y manipular texto. Vim es programable (con Vimscript y otros lenguajes
como python) y la interfaz de Vim en sí es un lenguage de programación: teclas
designadas (con nombres mnemónicos) que son comandos, y con estos comandos se pueden
crear composiciones. Vim evita el uso del *mouse* porque es muy lento, incluso 
evita el uso de las flechas del teclado porque requieren de mucho movimiento.

El resultado final de esto es un editor que puede igualar la velocidad a la que piensas.

# Modos de edición

El diseño de Vim esta basado en la idea de que la mayor parte del tiempo de un 
programador se utiliza leyendo, navengado, realizando pequeñas ediciones, contrario 
a escribir texto de forma regular en los que se escriben grandes secuencias de 
texto. Por esta razón, Vim tiene multiples modos para operar:

- **Normal**: para moverse dentro del archivo y realizar ediciones
- **Inserción**: para insertar texto
- **Remplazo**: para reemplazar texto
- **Visual** (plano, línea o bloque): para seleccionar bloques de texto
- **Comando**: para ejecutar comandos

Las teclas tienen un significado distinto según el modo en el cuál se esta operando.
Por ejemplo, la letra `x` en el modo Inserción solo va a insertar el carácter
'x', pero en modo Normal va a borrar el carácter que se encuentra debajo del 
cursor, y en modo Visual se borrará todo lo que se encuentra seleccionado.

En la configuración por defecto, Vim te muestra el modo actual abajo a la 
izquierda. El modo por defecto es el modo Normal. La mayoría de tu tiempo 
estarás entre los modos Normal e Inserción.

Desde cualquier modo al apretar `<ESC>` (tecla escape) regresas al modo Normal.
Desde el modo Normal te puedes cambiar al modo Inserción con la tecla `i`. 
Para ir al modo Remplazo debes utilizar la tecla `R`, al modo Visual con `v`, 
al modo Visual Línea con `V`, al modo Visual Bloque con `<C-v>` (Ctrl-V, a veces como `^V`),
y finalmente al modo Comando con `:`.

Utilizaras un monton la tecla `<ESC>` cuando estes usando Vim: considera reasignar
la tecla bloq mayús a escape ([instrucciones para macOS](https://vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)).

# Básico

## Insertar texto 

Desde el modo Normal, presiona la tecla `i` para entrar al modo Inserción. Ahora
Vim se comporta como cualquier otro editor de texto hasta que presiones la tecla
`<ESC>` para regresar al modo Normal. Esto, con lo básico explicado anteriormente,
es todo lo que necesitar para comenzar a editar archivos usando Vim (aunque no
particularmente eficiente, si estas todo el tiempo editando desde el modo Insertar).

## _Buffers_, pestañas, y ventanas

Vim mantiene un conjunto de archivos abiertos llamados *buffers*. Una sesión de
Vim tiene un número de pestañas, de las cuáles cada una tiene un número de 
ventanas (paneles separados). Cada ventana muestra un único *buffer*. A diferencia
de otros programas con los que puedes estar familiarizado, como los exploradores
web, no hay una correspondencia 1-a-1 entre *buffers* y ventanas; Las ventanas
son simplemente vistas. Un *buffer* puede estar abierto en multiples ventanas,
incluso dentro de la misma pestaña. Esto puede ser útil para ver diferentes 
partes de un mismo archivo.

Por defecto, Vim se inicia con una única pestaña abierta y esta contiene una
única ventana.

## Modo comando (o línea de comandos)

Se ingresa al modo Comando tipeando `:` en modo Normal. El cursor se posicionara
en la línea de comandos que se encuentra en la parte de abajo de la pantalla 
cuando presiones `:`. Este modo tiene muchas funcionalidades, incluyendo las de
abrir, guardar y cerrar archivos, además de [salir de Vim](https://twitter.com/iamdevloper/status/435555976687923200).

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">I&#39;ve been using Vim for about 2 years now, mostly because I can&#39;t figure out how to exit it.</p>&mdash; I Am Devloper (@iamdevloper) <a href="https://twitter.com/iamdevloper/status/435555976687923200?ref_src=twsrc%5Etfw">February 17, 2014</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

- `:q` salir o cerrar ventana (`q` de *quit* en inglés)
- `:w` guardar (`w` de *write* en inglés)
- `:wq` guardar y salir
- `:e {nombre del archivo}` abrir un archivo para su edición (`e` de *edit* en inglés)
- `:ls` muestra los *buffers* que están abiertos
- `:help {topic}` abrir ayuda
    - `:help :w` abre la documentación del comando `:w`
    - `:help w` abre la documentación de la tecla de movimiento `w`

# La interfaz de Vim es un lenguaje de programación 

La idea más importante en Vim es que su interfaz de comando es un lenguaje de
programación en sí. Las teclas (con nombres mnemónicos) son comandos, y con estos
se puede _componer_. Lo que permite moverse y editar de manera eficiente, 
especialmente cuando los comandos se transforman en memoría muscular.

## Movimiento

Deberías pasar la mayor parte de tu tiempo en modo Normal, usando comandos de
movimiento para navegar en el *buffer*. Los movimientos en Vim son llamados 
"sustantivos" porque hacen referencia a fragmentos del texto.

- Movimientos básicos: `hjkl` (izquierda, abajo, arriba, derecha)
- Palabras: `w` (siguiente palabra), `b` (comienzo de la palabra), `e` (final de la palabra)
- Líneas: `0` (comienzo de la línea), `^` (primer carácter no en blanco), `$` (final de la línea)
- Pantalla: `H` (parte superior de la pantalla), `M` (parte media de la pantalla), `L` (parte inferior de la pantalla)
- Desplazarse: `Ctrl-u` (hacia arriba), `Ctrl-d` (hacia abajo)
- Archivo: `gg` (comienzo del archivo), `G` (fin del archivo)
- Número de línea: `:{número}<CR>` or `{número}G` (línea {número})
- Misceláneos: `%` (objeto respectivo)
- Encontrar: `f{carácter}`, `t{carácter}`, `F{carácter}`, `T{carácter}`
    - encontrar/ir hacia adelante/ir hacia atras {carácter} sobre la línea actual 
    - `,` / `;` para navegar entre las coincidencias
- Buscar: `/{regex}`, una vez apretada la tecla enter para buscar, con `n` / `N` puedes
navegar entre las coincidencias encontradas anterior/siguiente respectivamente

## Selección

Modo visual (visualización):

- Visual
- Visual Line
- Visual Block

Se pueden usar las teclas de movimiento para seleccionar.

## Edición

Todo lo que sueles hacer con el mouse, lo puedes hacer con el teclado usando
los comandos de edición y movimiento. Aquí es donde la interfaz de Vim comienza
a parecerse a un lenguaje de programación. Los comandos de edición de Vim también
se conocen como "verbos" porque actuan sobre "sustantivos".

- `i` entrar al modo Insertar 
    - pero para manipular/borrar texto, quieres usar algo como backspace (tecla retroceso) 
- `o` / `O` insertar una línea abajo / arriba 
- `d{movimiento}` borrar {movimiento}
    - e.g. `dw` es borrar palabra (`dw` de *delete word* en inglés), `d$` es borrar hasta el final
de la línea, `d0` es borrar hasta el principio de la línea (se combinan con los
sustantivos de movimiento vistos arriba como `w`, `$` y `0`)
- `c{motion}` cambiar {movimiento}
    - e.g. `cw` es cambiar palabra (`cw` de *change word* en inglés)
    - es equivalente a usar `d{motion}` seguido de `i`
- `x` borrar carácter (equivalente a `dl` o borrar una posición)
- `s` sustituir carácter (equivalente a `xi`)
- Modo visual + manipulación
    - seleccionar texto, `d` para borrarlo o `c` para cambiarlo 
- `u` para deshacer (`u` de *undone* en inglés), `<C-r>` para rehacer (la `r` es de *redo* en inglés) 
- `y` para copiar / del inglés *"yank"* (algunos comandos como `d` también copian)
- `p` para pegar
- Mucho más para aprender: e.g. `~` cambiar de minúsculas/mayúsculas un carácter

## Conteo

Puedes combinar sustantivos y verbos con un *conteo*, esto hará que la acción se 
realice el número de veces especificado.

- `3w` moverse 3 palabras hacía adelante
- `5j` moverse 5 líneas hacía abajo 
- `7dw` borrar 7 palabras 

## Modificadores

Los modificadores se pueden utilizar para cambiar el significado de un sustantivo.
Algunos modificares son `i`, que significa "interior" o "dentro", y `a` que
significa "alrededor".

- `ci(` cambiar el contenido dentro del actual par de paréntesis 
- `ci[` cambiar el contenido dentro del actual par de paréntesis cuadrados (*square brackets*)
- `da'` eliminar el texto en comillas simples, incluyendo las comillas a su alrededor

# Demo

Aquí una implementación incorrecta del juego infantil [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz):

```python
def fizz_buzz(limit):
    for i in range(limit):
        if i % 3 == 0:
            print('fizz')
        if i % 5 == 0:
            print('fizz')
        if i % 3 and i % 5:
            print(i)

def main():
    fizz_buzz(10)
```

Arreglaremos los siguientes problemas:

- La función `main()` nunca es llamada en el programa
- El índice comienza en 0 en vez de 1
- Prints "fizz" y "buzz" en líneas separadas para los múltiplos de 15
- Prints "fizz" para múltiplos de 5
- Se fija con código el argumento al llamar a `fizz_buzz` (en 10), esto en vez de 
tomar el *input* de la línea de comandos como el argumento 

{% comment %}
- main is never called
  - `G` end of file
  - `o` open new line below
  - type in "if __name__ ..." thing
- starts at 0 instead of 1
  - search for `/range`
  - `ww` to move forward 2 words
  - `i` to insert text, "1, "
  - `ea` to insert after limit, "+1"
- newline for "fizzbuzz"
  - `jj$i` to insert text at end of line
  - add ", end=''"
  - `jj.` to repeat for second print
  - `jjo` to open line below if
  - add "else: print()"
- fizz fizz
  - `ci'` to change fizz
- command-line argument
  - `ggO` to open above
  - "import sys"
  - `/10`
  - `ci(` to "int(sys.argv[1])"
{% endcomment %}

[Ve el video de la clase en el mínuto exacto de la demostración](https://youtu.be/a6Q8Na575qc?t=2247){:target="_blank"}. 
Compara como los cambios de arriba se aplican usando Vim respecto a cómo 
aplicarías las mismas ediciones usando algún otro programa. Nota que tan pocos 
tipeos de teclas requiere Vim, permitiendote editar a la velocidad que piensas.


# Personalizar Vim

Vim es personalizable a través de un archivo de configuración de texto-plano
en `~/.vimrc` (que contiene comandos Vimscript). Probablemente existen un 
monton de configuraciones básicas que quieras activar.

Nosotros proporcionamos una configuración básica bien documentada que puedes
usar como punto de partida. Recomendamos usarla porque arregla alguno de los
comportamientos raros de Vim. **Descarga nuestra configuración [aquí](/2020/files/vimrc)
y guardala en `~/.vimrc`.**

Vim es altamente personificable y vale la pena gastar tiempo explorando las 
opciones que se pueden modificar. Puedes echarle un ojo a los *dotfiles* de
personas en GitHub para usarlas como inspiración, por ejemplo, las configuraciones
de Vim de los instructores ([Anish](https://github.com/anishathalye/dotfiles/blob/master/vimrc),
[Jon](https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim) (usa [neovim](https://neovim.io/)),
[Jose](https://github.com/JJGO/dotfiles/blob/master/vim/.vimrc)). Existen también
muchas entradas de blog sobre estos temas. Intenta no copiar-y-pegar
configuraciones completas de otras personas, sino que leelas y entiéndelas, y
toma lo que te sirva.


# Extendiendo Vim 

Existen cientos de complementos para expandir las funcionalidades de Vim. Contrario
al desactualizado consejo que puedes encontrar en internet, _no_ es necesario 
utilizar un gestor de complementos para Vim (desde Vim 8.0). En vez de eso, puedes
utilizar el sistema de gestión de paquetes incorporado en el sistema. Simplemente
debes crear el directorio `~/.vim/pack/vendor/start/` y poner los complementos
ahí (e.g. vía `git clone`).

Aquí algunos de nuestros complementos favoritos: 

- [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim): para busquedas imprecisas de archivos (*fuzzy*)
- [ack.vim](https://github.com/mileszs/ack.vim): buscador de código
- [nerdtree](https://github.com/scrooloose/nerdtree): explorador de archivos
- [vim-easymotion](https://github.com/easymotion/vim-easymotion): movimientos mágicos

Tratamos de evitar dar una lista abrumadoramente larga de complementos.
Puedes revisar en los *dotfiles* de los instructores ([Anish](https://github.com/anishathalye/dotfiles),
[Jon](https://github.com/jonhoo/configs),
[Jose](https://github.com/JJGO/dotfiles)) para ver que otros complementos
usamos.
Revisar el sitio [Vim Awesome](https://vimawesome.com/) para más complementos
geniales de Vim.
Adicionalmente existen cientos de entradas de blog sobre estos temas: solo tienes que
buscar por *"best Vim plugins"* (en inglés se máximiza el contenido de la búsqueda).

# Modo Vim en otros programas 

Muchas herramientas soportan emular Vim. La calidad varía de buena a excelente;
Dependiendo de la herramienta, esta puede no soportar las caracteristicas más
elaboradas de Vim, pero la mayoría cubre lo básico bastante bien.

## Consola (Shell)

Si eres usuario de Bash, usa `set -o vi`. Si usas Zsh, `bindkey -v`. Para Fish,
`fish_vi_key_bindings`. Adicionalmente, no importa cual consola ocupes, puedes
usar `export EDITOR=vim`. Esta es la variable ambiente utilizada para decirle a
la consola cual editor debe abrir cuando un programa requiera uno. Por ejemplo,
`git` utilizará Vim como editor para los mensajes de los *commits*.

## Readline

Muchos programas usan la librería [GNU
Readline](https://tiswww.case.edu/php/chet/readline/rltop.html) para su 
interfaz de línea de comandos. Readline también soporta emular Vim (básica),
la cual se puede activar agregando la siguiente línea al archivo `~/.inputrc`:

```
set editing-mode vi
```

Esta configuración permite que, por ejemplo, el [REPL](https://es.wikipedia.org/wiki/REPL)
de Python soporte las combinaciones de teclas de Vim.

## Otros

Existen extensiones para los [exploradores web](http://vim.wikia.com/wiki/Vim_key_bindings_for_web_browsers) 
para usar las combinaciones de teclas de Vim - algunos de los más populares 
son [Vimium](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en)
para Google Chrome y [Tridactyl](https://github.com/tridactyl/tridactyl) para
Firefox. Incluso puedes usar las combinaciones de teclas de Vim con [Jupyter
notebooks](https://github.com/lambdalisue/jupyter-vim-binding).


# Vim avanzado 

Aquí algunos ejemplos para demostrar el poder del editor. No podemos enseñarte
todo este tipo de cosas, pero las aprenderas a medida que avances. Una buena
heurística es: siempre que estes usando el editor y pienses "debe existir una mejor
forma de hacerlo", probablemente exista: búscala en internet.

## Buscar y remplazar

`:s` (sustituir) comando ([documentación](http://vim.wikia.com/wiki/Search_and_replace)).

- `%s/foo/bar/g`
    - remplaza foo por bar globalmente en el archivo 
- `%s/\[.*\](\(.*\))/\1/g`
    - remplaza los hipervinculos con etiqueta en Markdown por URLs planas 

## Multiples Ventanas

- `:sp` / `:vsp` para dividir la ventana 
- Puedes tener multiples vistas del mismo *buffer* 

## Macros

- `q{character}` para comenzar a grabar una macro y registrarla en `{character}`
- `q` para dejar de grabar
- `@{character}` repetir la macro 
- Las ejecuciones de macros se detienen por error 
- `{number}@{character}` ejecuta una macro {número} de veces 
- Las macros pueden ser recursivas 
    - primero borra la macro con `q{character}q`
    - graba la macro con `@{character}` para invocarla recursivamente 
    (será una *no-op* hasta que su grabación sea completada)
- Ejemplo: convertir de xml a json ([archivo](/2020/files/example-data.xml))
    - Lista de objetos con llaves "name" / "email" 
    - Usar un programa en Python? 
    - Usa sed / regexes
        - `g/people/d`
        - `%s/<person>/{/g`
        - `%s/<name>\(.*\)<\/name>/"name": "\1",/g`
        - ...
    - Comandos Vim / macros
        - `Gdd`, `ggdd` borra la primera y última de las líneas 
        - Macro para dar formato a un único elemento (register `e`)
            - Dirigirse a la línea con `<name>`
            - `qe^r"f>s": "<ESC>f<C"<ESC>q`
        - Macro para dar formato a person
            - Dirigirse a la línea con `<person>`
            - `qpS{<ESC>j@eA,<ESC>j@ejS},<ESC>q`
        - Macro para dar formato a persona y luego ir a la siguiente persona 
            - Dirigirse a la línea con `<person>`
            - `qq@pjq`
        - Ejecutar macro hasta el final del archivo 
            - `999@q`
        - Manualmente remover el último `,` y agregar los delimitadores `[` y `]` 

# Recursos

- `vimtutor` es un tutorial que viene instalado con Vim - Si Vim se encuentra
instalado deberías poder correr `vimtutor` desde tu consola 
- [Vim Adventures](https://vim-adventures.com/) es un juego para aprender Vim 
- [Vim Tips Wiki](http://vim.wikia.com/wiki/Vim_Tips_Wiki)
- [Vim Advent Calendar](https://vimways.org/2019/) tiene varios consejos de Vim 
- [Vim Golf](http://www.vimgolf.com/) es [code golf](https://en.wikipedia.org/wiki/Code_golf)
, pero donde el lenguaje de programación es la interfaz de usuario de Vim
- [Vi/Vim Stack Exchange](https://vi.stackexchange.com/)
- [Vim Screencasts](http://vimcasts.org/)
- [Practical Vim](https://pragprog.com/book/dnvim2/practical-vim-second-edition) (libro)

# Ejercicios

1. Completar `vimtutor`. Nota: se ve mejor si la ventana del terminal esta en
   [80x24](https://en.wikipedia.org/wiki/VT100) (80 columnas por 24 líneas).
1. Descargar nuestro [vimrc básico](/2020/files/vimrc) y guárdalo en `~/.vimrc`. Leer
   a través del archivo documentado (usando Vim!), y observa como Vim se ve y 
   comporta un poco diferente con la nueva configuración. 
1. Instalar y configurar el complemento: 
   [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim).
   1. Crear el directorio para el complemento con `mkdir -p ~/.vim/pack/vendor/start`
   1. Descargar el complemento: `cd ~/.vim/pack/vendor/start; git clone
      https://github.com/ctrlpvim/ctrlp.vim`
   1. Leer la 
      [documentación](https://github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md)
      del complemento. Intenta usar CtrlP para localizar un archivo navegando en el
      directorio de un proyecto, abriendo Vim, y usando el modo comando para 
      comenzar `:CtrlP`.
   1. Personaliza tu Vim modificando el archivo de [configuración](https://github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md#basic-options)
      `~/.vimrc` para que el complemento CtrlP se abrá al teclear Ctrl-P.
1. Para que practiques con Vim, rehace la [Demo](#demo) de la clase en tu propio
equipo. 
1. Usa Vim para _todas_ tus ediciones de texto el mes siguiente. Siempre que algo 
   parezca ineficiente, o cuando pienses "debe existir una mejor forma de hacerlo",
   intenta Googlear, probablemente exista. Si te quedas entrampado, envíanos un
   correo.
1. Configurar tus otras herramientas para usar las teclas de Vim (ver instrucciones arriba).
1. Personaliza aún más tu archivo `~/.vimrc` e instala complementos adicionales.
1. (Avanzado) Convierte XML a JSON ([archivo de ejemplo](/2020/files/example-data.xml))
   usando macros de Vim. Intenta hacerlo por tu cuenta, pero puedes mirar la sección 
   [macros](#macros) más arriba si te quedas entrampado. 
