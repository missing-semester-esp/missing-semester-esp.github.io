---
layout: lecture
title: "Control de versiones (Git)"
date: 2019-01-22
ready: true
video: 
  aspect: 56.25
  id: 2sjqTHE0zok
---

Los sistemas de control de versiones (o VCSs en ingles) son herramientas utilzadas
para registrar y seguir los cambios en el código fuente (u otros archivos o carpetas). 
Tal como su nombre implica, estas herramientas ayudan a mantener un historial 
de cambios y además facilitan la colaboración. Los VCSs registran los cambios
realizados en las carpetas y su contenido en una serie de fotos, donde cada foto 
encapsula el estado completo de los archivos/carpetas dentro de un directorio 
superior. Los VCSs tambien mantienen metadata como quién fue el creador de la 
foto, mensajes asociados a cada foto, entre otros.

 	
¿Porqué un sistema de control de versiones es útil? Incluso si estas
trabajando solo, puedes mirar antiguas versiones del proyecto, mantener
un *log* respecto al por qué de ciertos cambios realizados, trabajar en ramas
paralelas de desarrollo y mucho más. Cuando estas trabajando colaborativamente,
se transforma en una herramienta invaluable para saber los cambios  realizados
por otras personas, así como tambien para resolver conflictos en versiones 
simultáneas de desarrollo.


Los sistemas de control de versiones modernos te permiten responder fácilmente
, y a menudo automatizar, preguntas como las siguientes:

- ¿Quién escribio este módulo?
- ¿Cuándo fue que esta línea particular de este archivo particular fue editada?
¿Por quién? ¿Y porqué fue editada?
- Sobre las últimas 1000 revisiones, ¿cuándo y por qué un *test* unitario 
particular dejó de funcionar?


Mientras otros sistemas de control de versiones existen, **Git** es el estandar de 
facto de los sistemas de control de versiones. Este [comic de XKCD](https://xkcd.com/1597/)
refleja la reputación de Git:

![xkcd 1597](https://imgs.xkcd.com/comics/git.png)

Debido a que la interfaz de Git es en enredada, aprender Git 
utilizando un enfoque de «arriba-a-abajo» (comenzando con su interfaz o línea
de comandos) puede ser muy confuso. Claro que es posible memorizar un puñado 
de comandos y pensarlos como si fueran fórmulas mágicas, y si algo malo llegará a
ocurrir, siempre puedes aplicar la estrategia descrita en el *comic* de arriba.
 
Si bien la interfaz de Git es poco agraciada, su diseño e ideas fundamentales son hermosas.
Mientras que una interfaz horrible tiene que ser _memorizada_, un hermoso diseño
puede ser _entendido_. Es por esto que damos una explicación de «abajo-a-arriba»
sobre Git. Comenzando con su modelo de datos para luego abarcar la interfaz o 
línea de comandos. Una vez que se entiende el modelo de datos, los comando se
pueden entender mejor en términos de cómo manipulan el modelo de datos subyacente.

# El modelo de datos de Git

Existen muchos enfoques ad-hoc que puedes realizar para controlar versiones.
Git tiene un modelo bien pensado que permite todas las buenas características de
un sistema de control de versiones, como mantener un historial, soportar ramas y 
permitir colaboración.

## Fotos

La forma en que Git modela la historia de una colección de archivos y carpetas
que comparten un mismo directorio superior es a traves de una serie de fotos. 
En terminología Git , un archivo es llamado "blob" y es un puñado de *bytes*. A
un directorio se le llama "árbol" y vincula nombres a "blobs" o a otros "árboles" 
(ya que los directorios pueden contener otros directorios). Una foto es el árbol 
de nivel superior que esta siendo seguido. Por ejemplo, podríamos tener un árbol 
como el siguiente:

```
<root> (tree)
|
+- foo (tree)
|  |
|  + bar.txt (blob, contents = "hola mundo")
|
+- baz.txt (blob, contents = "git es genial")
```

El árbol de nivel superior (_root_) contiene dos elementos, el primero es un árbol con el 
nombre de "foo", que a su vez contiene un blob llamado "bar.txt", y el segundo es
un blob que se llama "baz.txt".

## Modelando la historia: conexión entre fotos

¿Cómo un sistema de control de versiones puede relacionar fotos? Un modelo 
simple podría ser una historia líneal. La historia podría ser una lista de
fotos ordenadas en base al tiempo. Por varias razones, Git no utiliza un modelo simple
como este.

En Git, la historia es un [grafo acíclico dirigido](https://es.wikipedia.org/wiki/Grafo_ac%C3%ADclico_dirigido)
 (o DAG en inglés) de fotos. Esto puede sonar como una sofisticada palabra matemática,
pero que no te intimide. Todo esto significa que cada foto en Git esta vinculada a un 
conjunto de "nodos padres", que son las fotos que la preceden. Es un conjunto de
nodos en vez de uno solo (como sería el caso de una historia líneal) porque una 
foto puede descender de multiples padres, por ejemplo, al ser fusionadas (*merging*)
dos ramas paralelas de desarrollo.

Git llama a estas fotos *"commits"*. Visualizar una historia de *commits* puede
verse parecido a algo como esto:

```
o <-- o <-- o <-- o
            ^  
             \
              --- o <-- o
```

En el arte ASCII de arriba, las `o`s corresponden a *commits* o fotos 
individuales. Las flechas apuntan al padre de cada uno de los *commit* (es una
relación de "precedente" y no de "procedente"). Luego del tercer *commit*, la
rama de la historia se separa en dos ramas. Esto puede corresponder, por
ejemplo, a dos características que se están desarrollando en paralelo e 
independiente de la otra. En el futuro, estas ramas se van a fusionar para crear
una nueva foto que incorporará ambas características, produciendo una nueva 
historia que es como la siguiente, con el nuevo *commit fusionado* destacado en
negrita:

<pre>
o <-- o <-- o <-- o <---- <strong>o</strong>
            ^            /
             \          v
              --- o <-- o
</pre>


Los *commits* en Git son inmutables. Esto no significa que los errores no se
pueden correjir, sino que cualquier "edición" a la historia de *commits*
implica crear un nuevo *commit*, y las referencias (ver abajo) son 
actualizadas para apuntar a los nuevos *commits*. 

## Modelo de datos como pseudocódigo

Puede ser instructivo ver el modelo de datos de Git escrito en pseudocódigo:

```
// un archivo es un puñado de bytes 
type blob = array<byte>

// un directorio contiene archivos y directorios con nombres 
type tree = map<string, tree | blob>

// un commit tiene padres, metadata, y un arbol de alto nivel 
type commit = struct {
    parent: array<commit>
    author: string
    message: string
    snapshot: tree
}
```

Es un limpio y simple modelo de la historia.

## Objetos y direccionamiento del contenido

Un "objeto" es un blob, árbol o *commit*:

```
type object = blob | tree | commit
```
En el almacenamiento de datos de Git, todos los objetos son direccionados a su
contenido por su [SHA-1 hash](https://en.wikipedia.org/wiki/SHA-1).

```
objects = map<string, object>

def store(object):
    id = sha1(object)
    objects[id] = object

def load(id):
    return objects[id]
```

Blobs, árboles y *commits* están unificados de esta forma: todos son objetos. 
Cuando estos referencian a otros objetos, realmente no es que esten contenidos en
su "representación" de disco, sino que se refieren a ellos por su *hash*.

Por ejemplo, el árbol usado como ejemplo de una estructura de directorio 
[arriba](#fotos) (se visualiza usando el comando `git cat-file -p 
698281bc680d1995c5f4caaf3359721a5a58d48d`), y se ve algo parecido a esto: 

```
100644 blob 4448adbf7ecd394f42ae135bbeed9676e894af85    baz.txt
040000 tree c68d233a33c5c06e0340e4c224f0afca87c8ce87    foo
```
El árbol en sí contiene punteros a su contenido, `baz.txt` (un blob) y `foo` 
(un árbol). Si miramos el contenido que nos direcciona el *hash* correspondiente al
objeto baz.txt usando `git cat-file -p 4448adbf7ecd394f42ae135bbeed9676e894af85`,
obtenemos lo siguiente:

```
git es genial
```

## Referencias

Ahora, todas las fotos pueden ser identificas por su SHA-1 *hash*. Esto es 
inconveniente ya que los humanos no somos buenos recordando secuencias 
hexadecimales de 40 caracteres.

La solución de Git a este problema son nombres legibles por humanos para 
los SHA-1 *hashes*, llamado "referencias". Las referencias son punteros para los
*commits*.
A diferencia de los objetos que son inmutables, las referencias son mutables
(pueden ser actualizados para referenciar a un nuevo *commit*). 
Por ejemplo, la referencia `master` usualmente apunta al último *commit* de la
rama principal de desarrollo.

```
references = map<string, string>

def update_reference(name, id):
    references[name] = id

def read_reference(name):
    return references[name]

def load_reference(name_or_id):
    if name_or_id in references:
        return load(references[name_or_id])
    else:
        return load(name_or_id)
```

Con esto, Git puede utilizar nombres legibles por humanos como "master" para
referirse a una foto particular en la historia, en vez de utilizar una larga
secuencia hexadecimal.

Un detalle es que nosotros frecuentemente queremos esta noción de _saber donde
estamos ahora_ en la historia, por lo tanto cuando tomamos una nueva foto, sabemos
que es respecto al como fijamos los `padres` en el *commit*. En Git, el _saber
donde estamos actualmente_ es la referencia especial "HEAD".

## Repositorios

Finalmente podemos definir (aproximadamente) que es un _repositorio_ en Git: es
la data de los `objetos` y `referencias`.

En el disco, todo lo que Git almacena son objetos y referencias: esto es todo 
el  modelo de datos de Git. Todos los comandos de `git` vinculan alguna
manipulación del *commit* DAG (grafo) ya sea añadiendo objetos y agregando/actualizando
referencias.

Cada vez que estas tipeando algún comando, piensa acerca de la manipulación
que el comando esta realizando en la estructura de grafo subyacente. Por el contrario,
si estas intentando hacer algún tipo de cambio particular en el *DAG commit*,
e.g. "descartar un cambio que no ha sido ingresado por *commit* y hacer que la
referencia `master` apunte al *commit* `5d83f9e`", existe probablemente un 
comando para hacer esto (e.g. en este caso, `git checkout master; git reset --hard 
5d83f9e`).

# Área de preparación 

Este es otro concepto que es ortogonal al modelo de datos, pero que es parte de
la interfaz para crear **commits**.

Una forma  de imaginarse la implementación de la toma de fotos que se describe
arriba es tener un comando para "tomar la foto" que lo haga basandose en el 
_estado actual_ del directorio de trabajo. Algunas herramientas para controlar
versiones trabajan de esta forma, pero no Git. Queremos fotos limpias, y podría
ser que no siempre sea ideal tomar una foto del estado actual. Por ejemplo, imagina
un escenario donde has implementado dos características separadas, y quieres
crear dos *commits* separados, donde primero se incluye la primera característica,
y luego se incorpore la segunda. O imagina un escenario donde tienes que debuggear
imprimiendo sentencias por todo el código, para arreglar un error; y quieres realizar
un *commit* para incorporar el arreglo pero descartando todas las sentencias
utilizadas. 

Git se acomoda a esos escenario permitiendote especificar cuáles modificaciones
deben ser incluidas en la siguiente foto a través de este mécanismo llamado
área de preparación (o _staging area_).

# La interfaz de línea de comandos de Git

Para evitar duplicidad de información, no vamos a explicar en detalle los comandos
de abajo. Se recomienda encarecidamente ver el libro [Pro Git](https://git-scm.com/book/en/v2)
para mayor información, o ver el video de la clase.

## Básicos

{% comment %}

El comando `git init` inicia un nuevo repositorio Git, con la metadata del 
repositorio guardada en el directorio `.git`:

The `git init` command initializes a new Git repository, with repository

metadata being stored in the `.git` directory:

```console
$ mkdir myproject
$ cd myproject
$ git init
Initialized empty Git repository in /home/missing-semester/myproject/.git/
$ git status
On branch master

No commits yet

nothing to commit (create/copy files and use "git add" to track)
```

How do we interpret this output? "No commits yet" basically means our version
history is empty. Let's fix that.

```console
$ echo "hello, git" > hello.txt
$ git add hello.txt
$ git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

        new file:   hello.txt

$ git commit -m 'Initial commit'
[master (root-commit) 4515d17] Initial commit
 1 file changed, 1 insertion(+)
 create mode 100644 hello.txt
```

With this, we've `git add`ed a file to the staging area, and then `git
commit`ed that change, adding a simple commit message "Initial commit". If we
didn't specify a `-m` option, Git would open our text editor to allow us type a
commit message.

Now that we have a non-empty version history, we can visualize the history.
Visualizing the history as a DAG can be especially helpful in understanding the
current status of the repo and connecting it with your understanding of the Git
data model.

The `git log` command visualizes history. By default, it shows a flattened
version, which hides the graph structure. If you use a command like `git log
--all --graph --decorate`, it will show you the full version history of the
repository, visualized in graph form.

```console
$ git log --all --graph --decorate
* commit 4515d17a167bdef0a91ee7d50d75b12c9c2652aa (HEAD -> master)
  Author: Missing Semester <missing-semester@mit.edu>
  Date:   Tue Jan 21 22:18:36 2020 -0500

      Initial commit
```

This doesn't look all that graph-like, because it only contains a single node.
Let's make some more changes, author a new commit, and visualize the history
once more.

```console
$ echo "another line" >> hello.txt
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   hello.txt

no changes added to commit (use "git add" and/or "git commit -a")
$ git add hello.txt
$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   hello.txt

$ git commit -m 'Add a line'
[master 35f60a8] Add a line
 1 file changed, 1 insertion(+)
```

Now, if we visualize the history again, we'll see some of the graph structure:

```
* commit 35f60a825be0106036dd2fbc7657598eb7b04c67 (HEAD -> master)
| Author: Missing Semester <missing-semester@mit.edu>
| Date:   Tue Jan 21 22:26:20 2020 -0500
|
|     Add a line
|
* commit 4515d17a167bdef0a91ee7d50d75b12c9c2652aa
  Author: Anish Athalye <me@anishathalye.com>
  Date:   Tue Jan 21 22:18:36 2020 -0500

      Initial commit
```

Also, note that it shows the current HEAD, along with the current branch
(master).

We can look at old versions using the `git checkout` command.

```console
$ git checkout 4515d17  # previous commit hash; yours will be different
Note: checking out '4515d17'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at 4515d17 Initial commit
$ cat hello.txt
hello, git
$ git checkout master
Previous HEAD position was 4515d17 Initial commit
Switched to branch 'master'
$ cat hello.txt
hello, git
another line
```

Git can show you how files have evolved (differences, or diffs) using the `git
diff` command:

```console
$ git diff 4515d17 hello.txt
diff --git c/hello.txt w/hello.txt
index 94bab17..f0013b2 100644
--- c/hello.txt
+++ w/hello.txt
@@ -1 +1,2 @@
 hello, git
 +another line
```

{% endcomment %}

- `git help <command>`: obtener ayuda acerca de un comando de git
- `git init`: crea un nuevo repositorio de git, con la data almacenada en el directorio `.git`
- `git status`: te dice que esta ocurriendo
- `git add <filename>`: agrega un archivo al área staging
- `git commit`: crea un nuevo *commit* 
    - Escribe [buenos mensajes para los commit](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)!
    - Incluso más rázones para escribir [buenos mensajes para los commit](https://chris.beams.io/posts/git-commit/)!
- `git log`: muestra un log plano de la historia 
- `git log --all --graph --decorate`: muestra la historia como un *DAG* (grafo)
- `git diff <filename>`: muestra las diferencias desde el último *commit*
- `git diff <revision> <filename>`: muestra las diferencias de un archivo entre fotos
- `git checkout <revision>`: actualiza HEAD y la rama actual

## Ramificación y fusión (Branching - merging)

{% comment %}

Branching allows you to "fork" version history. It can be helpful for working
on independent features or bug fixes in parallel. The `git branch` command can
be used to create new branches; `git checkout -b <branch name>` creates and
branch and checks it out.

Merging is the opposite of branching: it allows you to combine forked version
histories, e.g. merging a feature branch back into master. The `git merge`
command is used for merging.

{% endcomment %}

- `git branch`: muestra las ramificaciones
- `git branch <name>`: crea una rama
- `git checkout -b <name>`: crea una rama y te cambia a ella
    - esto es un atajo para `git branch <name>; git checkout <name>`
- `git merge <revision>`: fusiona con la rama actual.
- `git mergetool`: usa una sofisticada herramienta que te ayuda a resolver los
conflictos por combinar ramas 
- `git rebase`: rebase set of patches onto a new base

## Remoto

- `git remote`: lista de ubicaciones remotas
- `git remote add <name> <url>`: agregar ubicación remota
- `git push <remote> <local branch>:<remote branch>`:  envíar objeto a ubicación remota y actualizar las referencias remotas
- `git branch --set-upstream-to=<remote>/<remote branch>`: configurar correspondencia entre ubicación local y rama remota
- `git fetch`: extraer objetos/referencias desde una ubicación remota
- `git pull`: es lo mismo que `git fetch; git merge`
- `git clone`: descargar un repositorio desde una ubicación remota

## Undo

- `git commit --amend`: editar el contenido/mensaje de un *commit*
- `git reset HEAD <file>`: para deshacer la preparación del archivo
- `git checkout -- <file>`: descartar cambios

# Advanced Git

- `git config`: Git es [muy personalizable](https://git-scm.com/docs/git-config)
- `git clone --depth=1`: clonar simplificadamente, sin el historial completo de las versiones 
- `git add -p`: área de preparación (staging) interactiva
- `git rebase -i`: rebase interactivo 
- `git blame`: muestra quien fue el último en editar alguna línea
- `git stash`: eliminar temporalmente las modificaciones del directorio de trabajo
- `git bisect`: busqueda binaria en el historial (e.g. para regresión)
- `.gitignore`: [específica](https://git-scm.com/docs/gitignore) los archivos que 
intencionalmente no estas siguiendo para que sean ignorados 

# Misceláneos

- **GUIs**: existen muchas [interfaces gráficas](https://git-scm.com/downloads/guis)
para Git por ahí . Nosotros personalmente no utilizamos, y en vez de eso, solo
usamos la interfaz de línea de comandos.
- **Integración con la consola**: Es súper útil tener el estado de Git como parte del 
*prompt* en la consola ([zsh](https://github.com/olivierverdier/zsh-git-prompt),
[bash](https://github.com/magicmonty/bash-git-prompt)). Generalmente incluido en
entornos de trabajo como [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).
- **Integraciones con el editor**: similar a lo de arriba,  existen integraciones
útiles con muchas caracteristicas. [fugitive.vim](https://github.com/tpope/vim-fugitive)
es el estándar para Vim.
- **Flujos de trabajo**: te enseñamos el modelo de datos, además de algunos comandos
básicos; No te dijimos cuales son las practicas que debes seguir cuando estas
trabajando en grandes proyectos (y hay [muchos](https://nvie.com/posts/a-successful-git-branching-model/)
[enfoques](https://www.endoflineblog.com/gitflow-considered-harmful)
[distintos](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)).
- **GitHub**: Git no es GitHub. GitHub tiene una forma especifica de contribuir
con código a otros proyectos, llamada [pull
requests](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests).
- **Otros proveedores de Git**: GitHub no es especial; hay muchos hospedadores de 
repositorios de Git, como [GitLab](https://about.gitlab.com/) y
[BitBucket](https://bitbucket.org/).

# Recursos	

- [Pro Git](https://git-scm.com/book/en/v2) es **altamente recomendable de leer**.
Los primeros capítulos, del 1-al-5, abarcan casi todo lo necesario para 
usar Git de manera competente, dado que ahora entiendes el modelo de datos. Los
últimos capítulos tienen material interesante y avanzado.
- [Oh Shit, Git!?!](https://ohshitgit.com/) es una breve guia de cómo recuperarse
de algunos errores típicos usando Git.
- [Git for Computer
Scientists](https://eagain.net/articles/git-for-computer-scientists/) es una
breve explicación del modelo de datos de Git, con menos pseudocódigo y más
diagramas elaborados que los utilizado en las notas de esta clase.
- [Git from the Bottom Up](https://jwiegley.github.io/git-from-the-bottom-up/)
es una explicación detallada de los detalles de la implementación de Git más 
allá del modelo de datos, solo para los curiosos.
- [How to explain git in simple
words](https://smusamashah.github.io/blog/2017/10/14/explain-git-in-simple-words)
- [Learn Git Branching](https://learngitbranching.js.org/) es un juego basado
en el explorador web que te enseña Git.

# Ejercicios

1. Si no tienes experiencia previa utilizando Git, intenta con cualquiera de las dos
   alternativas siguientes: leer los primeros capítulos del libro [Pro Git](https://git-scm.com/book/en/v2)
   o hacer un tutorial como [Learn Git Branching](https://learngitbranching.js.org/).
   A medida que vayas trabajando en esto, relaciona los comandos de Git a su modelo
   de datos.
1. Clona el [repositorio del sitio web de la clase](https://github.com/missing-semester/missing-semester).
    1. Explora el historial de versiones visualizándolo como un grafo.
    1. ¿Quién fue la última persona en modificar `README.md`? (Pista: usa `git log` con
       un argumento).
    1. ¿Cuál fue el mensaje del **commit** de la última modificación en
       `collections:` línea de `_config.yml`? (Pista: usa `git blame` y `git
       show`)
1. Una equivocación común cuando se esta aprendiendo Git es hacer **commit** de
   grandes archivos que no se deberían manejar con Git o agregar información sensible.
   Intenta agregar un archivo al repositorio, realizar algunos **commits** y luego
   borra el archivo de la historia (quizás quieras echar un vistazo a 
   [esto](https://help.github.com/articles/removing-sensitive-data-from-a-repository/)).
1. Clona algún repositorio desde Github, y modifica uno de los archivos existentes.
   ¿Qué ocurre cuando usas `git stash`? ¿Qué vez cuando corres `git log
   --all --oneline`? Ejecuta `git stash pop` para deshacer lo que hiciste con `git stash`. 
   ¿Bajo que escenario esto puedo ser útil?
1. Como muchas otras herramientas de líneas de comando, Git provee un archivo
   de configuración (o dotfile) llamado `~/.gitconfig`. Crea un alias en `~/.gitconfig` 
   para que cuando corras `git graph`, obtengas el resultado de `git log --all --graph --decorate
   --oneline`.
1. Puedes definir de manera general patrones a ignorar en `~/.gitignore_global` 
   luego correr `git config --global core.excludesfile ~/.gitignore_global`. 
   Haz esto, y configura tu archivo global gitignore para ignorar archivos
   temporales especificos de OS o del editor, como `.DS_Store`.
1. Clona el [repositorio del sitio web de la clase](https://github.com/missing-semester/missing-semester),
   encuentra un error de tipeo u otra mejora que puedas hacer, y envía un
   *pull request* por Github.
