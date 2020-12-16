---
layout: lecture
title: "Metaprogramación"
details: build systems, dependency management, testing, CI
date: 2019-01-27
ready: false
video:
  aspect: 56.25
  id: _Ms1Z4xfqv4
---

¿A qué nos referimos por "metaprogramación? Bueno, fue el mejor término
colectivo al que logramos llegar para referirnos a un conjunto de cosas que son 
más acerca de _procesos_ que respecto a escribir código o trabajar de forma
más eficiente. En esta clase, veremos sistemas para armar y probar tú código,
y para gestionar dependencias. Esto puede parecer de poca importancia en tu 
día-a-día como estudiante, pero al momento de interactuar con una base de código
grande en tu práctica, o una vez en el "mundo real", verás esto en todos lados.
Debemos tener en cuenta que "metaprogramación" también significa ["programas que
operan programas"](https://en.wikipedia.org/wiki/Metaprogramming), pero 
esta definición no es del todo exacta para el próposito de como la usamos en esta 
clase. 

# Build systems

Si escribes un artículo en LaTeX, ¿cuáles son los comandos necesarios a ejecutar
para producir el artículo? ¿Cuáles son los utilizados para correr
tu *benchmark*, graficarlo y luego insertar el gráfico en la publicación? ¿O
compilar el código entregado en la clase que estas cursando y luego correr las
pruebas?

Para la mayoría de los proyectos, contengan código o no, hay un proceso de 
"construcción". Algunas secuencia de operaciones que necesitas realizar para ir 
de tus entradas a tus salidas. A menudo, este proceso puede tener varíos 
pasos y muchas ramificaciones. Ejecuta esto para generar tal visualización, 
esto para los resultados, y esto otro para el artículo final. Como con muchas de
las cosas que hemos visto en esta clase, no eres el primero en pasar por
estas molestias, ¡y por suerte existen muchas herramientas que te pueden ayudar!

A esto se le conoce comúnmente como "sistemas de construcción", y hay muchos
de ellos. Cuál usar depende de la tarea que estas realizando, tú lenguaje de
preferencia, y el tamaño del proyecto. En esencia, todos son muy similares.
Defines el número de dependencias, número de objetivos y las reglas para ir
de uno a otro. Le dices al sistema de construcción que objetivo en especifico
quieres, y su trabajo es encontrar todas las dependencias transitivas de ese
objetivo, y luego aplicar las reglas para ir produciendo los objetivos intermedios,
y todo el camino hasta que el objetivo final sea producido. Idealmente, el sistema 
de construcción realiza lo descrito sin la necesidad de ejecutar reglas innecesarias
para objetivos, cuyas dependencias no han sido modificadas, y el resultado se encuentre
disponible de la construcción anterior.


Uno de los sistemas de construcción que encontrarás allí afuera es `make`,
y usualmente se encuentra instalado en la mayoría de los computadores basados
en UNIX. Tiene sus peros, sin embargo, funciona bastante bien para proyectos simples a
moderados. Cuando ejecutas `make`, se consulta un archivo llamado `Makefile` en
el directorio actual. Todos los objetivos, sus dependencias y reglas, se 
encuentran definidas en este archivo. Démosle un vistazo a uno:


```make
paper.pdf: paper.tex plot-data.png
	pdflatex paper.tex

plot-%.png: %.dat plot.py
	./plot.py -i $*.dat -o $@
```

Cada directiva del archivo es una regla de cómo producir lo indicado en el lado
izquierdo usando lo especificado a la derecha. O, dicho de otra forma, las cosas
nombradas a la derecha son las dependencias y las del lado izquierdo son los
objetivos. El bloque indentado es una secuencia de programas para producir el
objetivo a partir de sus dependencias. En `make`, el primer directivo además
define el objetivo por defecto. Si tu ejectuas `make` sin argumento alguno, este
será el objetivo a construir. Alternativamente, puedes ejecutar algo como
`make plot-data.png`, y se construirá este objetivo en vez.

El `%` en una regla es un "patrón", y unirá la misma secuencia en la izquierda
o la derecha. Por ejemplo, si el objetivo `plot-foo.png` es requerido, `make`
buscará en las dependencia `foo.dat` y `plot.py`. Ahora observemos que ocurré
si ejecutamos `make` con un directorio vacío de fuente.

```console
$ make
make: *** No rule to make target 'paper.tex', needed by 'paper.pdf'.  Stop.
```

`make` servicialmente nos dirá que para construir `paper.pdf`, necesita del
archivo `paper.tex`, y no tiene indicación alguna que le diga cómo construirlo.
¡Intentemos hacerlo!

```console
$ touch paper.tex
$ make
make: *** No rule to make target 'plot-data.png', needed by 'paper.pdf'.  Stop.
```
Mmm, interesante, hay _una_ regla para hacer `plot-data.png`, pero es una regla
de patrón. Debido a que el archivo fuente no existe (`foo.dat`), `make` simplemente
declara que no puede hacer ese archivo. Intentemos crear todos los archivos:

```console
$ cat paper.tex
\documentclass{article}
\usepackage{graphicx}
\begin{document}
\includegraphics[scale=0.65]{plot-data.png}
\end{document}
$ cat plot.py
#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', type=argparse.FileType('r'))
parser.add_argument('-o')
args = parser.parse_args()

data = np.loadtxt(args.i)
plt.plot(data[:, 0], data[:, 1])
plt.savefig(args.o)
$ cat data.dat
1 1
2 2
3 3
4 4
5 8
```

Ahora, ¿qué ocurre si ejecutamos `make`?

```console
$ make
./plot.py -i data.dat -o plot-data.png
pdflatex paper.tex
... lots of output ...
```

Observa, ¡hizo un PDF por nosotros!
¿Qué ocurre si ejecutamos `make` nuevamente?

```console
$ make
make: 'paper.pdf' is up to date.
```

¡No hizo nada! ¡¿Por qué no?! Bueno, porqué no necesitaba hacerlo. Verificó que
todos los objetivos previamente construidos estuvieran todavía actualizados 
respecto a sus dependencias listadas. Se puede probar esto al modificar 
`paper.text` y luego re-ejecutar `make`:


```console
$ vim paper.tex
$ make
pdflatex paper.tex
...
```

Date cuenta que `make` no re-ejecutó `plot.py` porque no era necesario; ¡ninguna
de las dependencias de `plot-data.png` ha cambiado!


# Gestión de dependencias 

A un nivel macro, es probable que tus proyectos de *software* tengan dependencias
que sean proyectos. Podrías depender de programas instalados (como `python`), 
paquetes de sistemas (como `openssl`), o librerías dentro de tu lenguaje de 
programación (como `matplotlib`). En estos días, la mayoría de las dependencias 
se encuentran disponibles a través de _repositorios_ que hospedan un gran
número de dependencias en un mismo lugar, y proveen mécanismos convenientes para
instalarlos. Algunos ejemplos incluyen el repositorio de páquetes de Ubuntu para
páquetes de este sistema, al cual se accede a través de la herramienta `apt`, 
RubyGems para librerías de Ruby, PyPi para librerías de Python, o el repositorio
de Usuarios Arch para usuarios contribuyentes de paquetes para la distribución
Arch de Linux.

Dado que los mécanismo para interactuar con estos repositorios varían de 
repositorio en repositorio y de herramienta en herramiento, no entraremos mucho
en los detalles espécificos de algunos de esto en esta clase. Lo que vamos a
cubrir son algunas de las tecnologías comunes que todos ellos usan. La primera
entre todas es el _versionamiento_. La mayoría de los proyectos de los que
dependen de otros proyectos emiten un _número de versión_ con cada publicación.
Usualmente algo como 8.1.3 o 64.1.20192004. Estos generalmente, no siempre, son
númericos. Los números de versión sirven para muchos propósitos, y uno de los
más importantes de ellos es asegurar que un programa continue funcionando. Imagina,
por ejemplo, que yo publicó una nueva versión de mi librería donde he renombrado
una función en particular. Si alguien intenta construir un programa que depende
de mi librería luego de que haya publicado (la modificación), la construción
puede fallar porque llamará a una función que ya no existe! Si alguien intenta construir un programa que depende
de mi librería luego de que haya publicado (la modificación), ¡la construción
puede fallar porque llamará a una función que ya no existe! El versionamiento
intenta solucionar este problema dejando que el proyecto diga de que versión
especifica depende, o un rango de versiones, de otro proyecto. De esta manera, 
incluso si la libreria subyacente cambia, el programa dependiente sigue 
construyendose al usar una versión anterior de mi libreria.

¡Aunque tampoco es lo ideal! Que ocurré si publicó una actualización de seguridad
la cual no cambia la interfaz pública de mi librería (la "API"), ¿y si todo 
proyecto que depende de la antigua versión debiera inmediatamente comenzar a 
usarla? Aquí es donde los distintos grupos en el número de la versión entran en acción. 
El significado exacto de estos varia entre proyectos, pero un estándar relativamente
común es el [_versionado semántico_](https://semver.org/lang/es). Con el versionado
semántico, cada número de versión es de la siguiente forma: _major.minor.patch_. 
Las reglas son:

  - Si una nueva publicación no cambia la API, se incrementa la versión del _patch_.
  - Si _agregas_ un cambio en tu API compatible con versiones anteriores, se 
incrementa la versión _minor_.
  - Si cambias la API en una forma no compatible con las versiones anteriores, se
incrementa la versión _major_.


Esto inmediatamente proporciona algunas ventajas importantes. Ahora, si mi proyecto
depende de tu proyecto, debería ser seguro usar la última versión publicada con
la misma versión _major_ con la que construí el programa cuando la desarrollé,
mientras la versión _minor_ sea al menos la utilizada en ese entonces. En otras
palabras, si yo dependo de tu librería en su versión `1.3.7`, entonces debería
estar bien construyendola con `1.3.8`, `1.6.1`, o incluso `1.3.0`. La versión
`2.2.4` probablemten no estaría bien, porque la versión _major_ fue incrementada. 
Podemos ver un ejemplo de versionado semántico en los números de versión de
Python. Muchos de ustedes probablemente son conscientes de que el código de 
Python 2 y Python 3 no combina muy bien, es por eso que fue un golpe de versión
 _major_. Del mismo modo, código escrito en Python 3.5 podría correr bien en
Python 3.7, pero posiblemente no en la versión 3.4.   

Cuando trabajas con un sistema de gestión de dependencias, también puedes 
encontrarte con la noción de _archivos de bloqueo_. Un archivo de bloqueo es
simplemente un archivo que enumera la versión exacta de la que actualmente
dependes para cada una de las dependencias. Usualmente, necesitas ejecutar
explicitamente un programa de actualización para mejorar las dependencias a 
nuevas versiones. Existen muchas razones para esto, como evitar recompilar 
innecesariamente, disponer de construcciones reproducibles, o no automaticamente
actualizar a la última versión (que puede estar rota). Una versión extrema de
este tipo de bloqueo de dependencia es _vendoring_, que es cuando copias todo
el código de tus dependencias dentro de tu proyecto. Esto te da control total
de los cambios, y te permite introducir tus propios cambios, pero significa 
tambien que tienes que explicitamente incorporar cualquier actualización 
realizada por los mantenedores de tus dependencias en el tiempo.

# Sistemas de integración continua 

A medida que trabajas en proyectos cada vez más grandes, encontraras que hay
a menudo tareas adicionales que debes hacer cada vez que realizas un cambio.
Puede que tengas que subir una nueva versión de la documentación, subir una
versión compilada en algun lado, liberar el código pypi, ejecutar un conjunto
de pruebas, y todo tipo de otras cosas. Quizas cada vez que alguien envía un
_pull requests_ en GitHub, ¿quieres que se revise el estilo del código y 
ejecutar algunos _benchmarks_? Cuando este tipo de necesidades surgen, es tiempo
de echar un vistazo a la integración continua.


As you work on larger and larger projects, you'll find that there are
often additional tasks you have to do whenever you make a change to it.
You might have to upload a new version of the documentation, upload a
compiled version somewhere, release the code to pypi, run your test
suite, and all sort of other things. Maybe every time someone sends you
a pull request on GitHub, you want their code to be style checked and
you want some benchmarks to run? When these kinds of needs arise, it's
time to take a look at continuous integration.

La integración continua (_CI_ en inglés) es un término paraguas para "las cosas
que se ejecutan cada vez que el código cambia", y hay muchas empresas afuera que
proveen tipos de CI, a menudo gratis para proyectos de código abierto. Algunas
de las grandes son Travis CI, Azures Pipelines, y GitHub Actions. Todas ellas
funcionan aproximadamente de la misma manera: agregar un archivo a tu repositorio
que describe lo que deberia pasar cuando varias cosas le pasan a ese repositorio.
Por mucho el más común es una regla como "cuando alguien _pushea_ un código, 
ejecutar el conjunto de pruebas". Cuando el evento se gatilla, el proveedor de CI
invoca una máquina virtual (o más), ejecuta los comandos en tu "receta" y 
usualmente toma nota de los resultados en algún lugar. 

Continuous integration, or CI, is an umbrella term for "stuff that runs
whenever your code changes", and there are many companies out there that
provide various types of CI, often for free for open-source projects.
Some of the big ones are Travis CI, Azure Pipelines, and GitHub Actions.
They all work in roughly the same way: you add a file to your repository
that describes what should happen when various things happen to that
repository. By far the most common one is a rule like "when someone
pushes code, run the test suite". When the event triggers, the CI
provider spins up a virtual machines (or more), runs the commands in
your "recipe", and then usually notes down the results somewhere. You
might set it up so that you are notified if the test suite stops
passing, or so that a little badge appears on your repository as long as
the tests pass.

As an example of a CI system, the class website is set up using GitHub
Pages. Pages is a CI action that runs the Jekyll blog software on every
push to `master` and makes the built site available on a particular
GitHub domain. This makes it trivial for us to update the website! We
just make our changes locally, commit them with git, and then push. CI
takes care of the rest.

## A brief aside on testing

Most large software projects come with a "test suite". You may already
be familiar with the general concept of testing, but we thought we'd
quickly mention some approaches to testing and testing terminology that
you may encounter in the wild:

 - Test suite: a collective term for all the tests
 - Unit test: a "micro-test" that tests a specific feature in isolation
 - Integration test: a "macro-test" that runs a larger part of the
   system to check that different feature or components work _together_.
 - Regression test: a test that implements a particular pattern that
   _previously_ caused a bug to ensure that the bug does not resurface.
 - Mocking: the replace a function, module, or type with a fake
   implementation to avoid testing unrelated functionality. For example,
   you might "mock the network" or "mock the disk".

# Exercises

 1. Most makefiles provide a target called `clean`. This isn't intended
    to produce a file called `clean`, but instead to clean up any files
    that can be re-built by make. Think of it as a way to "undo" all of
    the build steps. Implement a `clean` target for the `paper.pdf`
    `Makefile` above. You will have to make the target
    [phony](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html).
    You may find the [`git
    ls-files`](https://git-scm.com/docs/git-ls-files) subcommand useful.
    A number of other very common make targets are listed
    [here](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html#Standard-Targets).
 2. Take a look at the various ways to specify version requirements for
    dependencies in [Rust's build
    system](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html).
    Most package repositories support similar syntax. For each one
    (caret, tilde, wildcard, comparison, and multiple), try to come up
    with a use-case in which that particular kind of requirement makes
    sense.
 3. Git can act as a simple CI system all by itself. In `.git/hooks`
    inside any git repository, you will find (currently inactive) files
    that are run as scripts when a particular action happens. Write a
    [`pre-commit`](https://git-scm.com/docs/githooks#_pre_commit) hook
    that runs `make paper.pdf` and refuses the commit if the `make`
    command fails. This should prevent any commit from having an
    unbuildable version of the paper.
 4. Set up a simple auto-published page using [GitHub
    Pages](https://help.github.com/en/actions/automating-your-workflow-with-github-actions).
    Add a [GitHub Action](https://github.com/features/actions) to the
    repository to run `shellcheck` on any shell files in that
    repository (here is [one way to do
    it](https://github.com/marketplace/actions/shellcheck)). Check that
    it works!
 5. [Build your
    own](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/building-actions)
    GitHub action to run [`proselint`](http://proselint.com/) or
    [`write-good`](https://github.com/btford/write-good) on all the
    `.md` files in the repository. Enable it in your repository, and
    check that it works by filing a pull request with a typo in it.
