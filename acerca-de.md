---
layout: lecture
title: "¿Por qué enseñamos esta clase?"
---
Cuando estudias ciencias computacionales por medios tradicionales, probablemente 
aprendas sobre temas avanzados dentro de la disciplina, desde sistemas operativos a 
lenguajes de programación y aprendizaje automático. Pero en muchas instituciones raramente cubren 
un tema esencial y en su lugar, lo estudias por cuenta propia: el ecosistema computacional.
 
Al pasar los años, enseñamos bastantes clases en el MIT; vemos, una y otra vez, que muchos de 
los estudiantes saben poco de las herramientas disponibles para ellos.
Las computadoras fueron construidas para automatizar tareas manuales; todavía algunos
estudiantes, ejecutan tareas manuales o fallan al tomar ventaja completa del poder
de las herramientas como control de versiones y editores de texto. 
En el mejor de los casos, estos resultan en ineficiencias y pérdidas de tiempo; en el peor de los casos,
resulta en problemas como extravío de datos o falta de capacidad para terminar tareas.

Por la falta de enseñanza en el currículum  universitario de estos temas, los estudiantes no aprenden 
como usar esas herramientas, o por lo menos no como usarlas eficientemente, así evitando gastar tiempo y 
esfuerzo en tareas que deberían ser simples.

El currículum estándar de las ciencias computacionales esta olvidando los temas críticos    
sobre el ecosistema computacional que podría hacer la vida de los estudiantes    
significativamente más fácil.


# El semestre faltante en tu educación de Ciencias Computacionales

Para ayudar a remediar esto, iniciamos una clase que cubre todos los temas considerados 
cruciales para ser un científico de la computación y programador efectivo. La clase es 
práctica y promueve una introducción activa sobre las herramientas y técnicas que puedes 
aplicar inmediatamente en una amplia variedad de situaciones que encontrarás a 
lo largo de tu camino.  La clase está siendo impartida durante el periodo de actividades independientes 
(intersemestral, un mes del semestre caracterizado por clases cortas organizadas por estudiantes)
en el MIT en enero del 2020. Mientras que sus conferencias están sólo disponibles para los
estudiantes del MIT; al público proveemos todo el material de las clases.

Si esto suena como para ti, aquí algunos ejemplos de lo que la clase enseña:

## Terminal de comandos

Como automatizar tareas comunes y repetitivas mediante alias, _scripts_ y construir sistemas.
No más copiar y pegar comandos desde un documento de texto. No más correr estos comandos uno 
tras de otro. No más "olvide correr esa cosa" u "olvide pasar ese parámetro".

Por ejemplo, búsquedas a través de tu historial pueden ser un gran ahorro de tiempo. En el ejemplo
de abajo mostramos muchos trucos relacionados a la navegación del historial de tu terminal para 'convertir' comandos:

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/history.mp4" type="video/mp4">
</video>

## Control de versiones

Como usar _apropiadamente_ el control de versiones, tomar ventaja de este 
para salvarte del desastre, colaborar con otros, rápidamente encontrar y aislar cambios problemáticos. 
No más `rm -rf; git clone`. No más conflictos en las combinaciones *merges* (bueno, al menos en menor cantidad).
No más grandes bloques de código comentado. No más preocupaciones para encontrar
que rompió tu código. No más "oh no, ¿debemos eliminar todo el código producido?". 
Incluso te enseñaremos cómo contribuir a otros proyectos mediante solicitudes de contribución *pull requests*.

En el ejemplo de abajo usamos `git bisect` para encontrar cuál liberación *commit*
rompió las pruebas unitarias y entonces lo arreglamos mediante `git revert`
<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/git.mp4" type="video/mp4">
</video>

## Edición de texto

Como editar eficientemente archivos desde la línea de comandos, tanto como local como
remoto, y tomar ventaja de las características avanzadas del editor. No más
copiar archivos erráticamente. No más edición de archivos repetitiva.

Las macros de vim son una de sus mejores características, en el ejemplo de 
abajo convertimos rápidamente una tabla de HTML al formato CSV usando una macro de vim anidada.  

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/vim.mp4" type="video/mp4">
</video>

## Máquinas remotas

Como no quedarte colgado cuando trabajas con máquinas remotas usando claves *SSH* y
una terminal multiplexor *multiplexing*. No más mantener bastantes terminales abiertas 
solamente para correr dos comandos a la vez. No más escribir tu contraseña por conexión. 
No más perder todo tu trabajo, solo porque tu Internet falla o por un reinicio inesperado de tu computadora.

En el ejemplo de abajo usamos `tmux` para mantener sesiones vivas en servidores remotos y `mosh` para soportar la itinerancia *roaming* de la red y las desconexiones.

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/ssh.mp4" type="video/mp4">
</video>

## Búsqueda de archivos 

Como buscar rápidamente archivos que intentas encontrar. No más
uso innecesario de la interfaz gráfica para hallar en tu proyecto el
código requerido.

En el ejemplo de abajo encontramos rápidamente archivos con `fd` y 
por trozos *snippets* de código con `rg`. También ejecutamos rápidamente 
`cd` and `vim` archivos/directorios recientes o frecuentes.

<video autoplay="autoplay" loop="loop" controls muted playsinline  oncontextmenu="return false;"  preload="auto"  class="demo">
  <source src="/static/media/demos/find.mp4" type="video/mp4">
</video>

## Disertación sobre el tratamiento de datos

Como rápida y fácilmente modificar, ver, formatear, graficar y computar
sobre los datos y archivos directamente desde la línea de comandos.
No más copiar y pegar desde la salida de los archivos. No más estadísticas computacionales manuales sobre los datos. No más hojas de cálculo para graficar.

## Máquinas virtuales

Como usar máquinas virtuales para probar nuevos sistemas operativos, proyectos
aislados y mantener tu computadora principal organizada. 
No más corromper tu computadora accidentalmente mientras haces un laboratorio de seguridad.
No más millones de paquetes aleatorios instalados con diferentes versiones.

## Seguridad

Como estar en el Internet sin inmediatamente revelar todos tus secretos al mundo.
No más plantearse contraseñas que coincidan con insanos criterios propios. No
más mensajes desencriptados. 


# Conclusión
Esto y más, será cubierto durante las 12 conferencias, cada una incluirá un
ejercicio para que tu obtengas familiaridad con las herramientas en tu poder.

Para ver las conferencias precursoras ve a [Herramientas Hacker](https://hacker-tools.github.io/lectures/),
el cual impartimos durante IAP del 2019.

Feliz hacking,<br>
Anish, Jose, and Jon
