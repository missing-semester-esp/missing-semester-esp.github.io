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
keygen() -> (public key, private key)  (this function is randomized)

encrypt(plaintext: array<byte>, public key) -> array<byte>  (the ciphertext)
decrypt(ciphertext: array<byte>, private key) -> array<byte>  (the plaintext)

sign(message: array<byte>, private key) -> array<byte>  (the signature)
verify(message: array<byte>, signature: array<byte>, public key) -> bool  (whether or not the signature is valid)
```

The encrypt/decrypt functions have properties similar to their analogs from
symmetric cryptosystems. A message can be encrypted using the _public_ key.
Given the output (ciphertext), it's hard to determine the input (plaintext)
without the _private_ key. The decrypt function has the obvious correctness
property, that `decrypt(encrypt(m, public key), private key) = m`.

Symmetric and asymmetric encryption can be compared to physical locks. A
symmetric cryptosystem is like a door lock: anyone with the key can lock and
unlock it. Asymmetric encryption is like a padlock with a key. You could give
the unlocked lock to someone (the public key), they could put a message in a
box and then put the lock on, and after that, only you could open the lock
because you kept the key (the private key).

The sign/verify functions have the same properties that you would hope physical
signatures would have, in that it's hard to forge a signature. No matter the
message, without the _private_ key, it's hard to produce a signature such that
`verify(message, signature, public key)` returns true. And of course, the
verify function has the obvious correctness property that `verify(message,
sign(message, private key), public key) = true`.

## Applications

- [PGP email encryption](https://en.wikipedia.org/wiki/Pretty_Good_Privacy).
People can have their public keys posted online (e.g. in a PGP keyserver, or on
[Keybase](https://keybase.io/)). Anyone can send them encrypted email.
- Private messaging. Apps like [Signal](https://signal.org/) and
[Keybase](https://keybase.io/) use asymmetric keys to establish private
communication channels.
- Signing software. Git can have GPG-signed commits and tags. With a posted
public key, anyone can verify the authenticity of downloaded software.

## Key distribution

Asymmetric-key cryptography is wonderful, but it has a big challenge of
distributing public keys / mapping public keys to real-world identities. There
are many solutions to this problem. Signal has one simple solution: trust on
first use, and support out-of-band public key exchange (you verify your
friends' "safety numbers" in person). PGP has a different solution, which is
[web of trust](https://en.wikipedia.org/wiki/Web_of_trust). Keybase has yet
another solution of [social
proof](https://keybase.io/blog/chat-apps-softer-than-tofu) (along with other
neat ideas). Each model has its merits; we (the instructors) like Keybase's
model.

# Case studies

## Password managers

This is an essential tool that everyone should try to use (e.g.
[KeePassXC](https://keepassxc.org/)). Password managers let you use unique,
randomly generated high-entropy passwords for all your websites, and they save
all your passwords in one place, encrypted with a symmetric cipher with a key
produced from a passphrase using a KDF.

Using a password manager lets you avoid password reuse (so you're less impacted
when websites get compromised), use high-entropy passwords (so you're less likely to
get compromised), and only need to remember a single high-entropy password.

## Two-factor authentication

[Two-factor
authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication)
(2FA) requires you to use a passphrase ("something you know") along with a 2FA
authenticator (like a [YubiKey](https://www.yubico.com/), "something you have")
in order to protect against stolen passwords and
[phishing](https://en.wikipedia.org/wiki/Phishing) attacks.

## Full disk encryption

Keeping your laptop's entire disk encrypted is an easy way to protect your data
in the case that your laptop is stolen. You can use [cryptsetup +
LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)
on Linux,
[BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/) on
Windows, or [FileVault](https://support.apple.com/en-us/HT204837) on macOS.
This encrypts the entire disk with a symmetric cipher, with a key protected by
a passphrase.

## Private messaging

Use [Signal](https://signal.org/) or [Keybase](https://keybase.io/). End-to-end
security is bootstrapped from asymmetric-key encryption. Obtaining your
contacts' public keys is the critical step here. If you want good security, you
need to authenticate public keys out-of-band (with Signal or Keybase), or trust
social proofs (with Keybase).

## SSH

We've covered the use of SSH and SSH keys in an [earlier
lecture](/2020/command-line/#remote-machines). Let's look at the cryptography
aspects of this.

When you run `ssh-keygen`, it generates an asymmetric keypair, `public_key,
private_key`. This is generated randomly, using entropy provided by the
operating system (collected from hardware events, etc.). The public key is
stored as-is (it's public, so keeping it a secret is not important), but at
rest, the private key should be encrypted on disk. The `ssh-keygen` program
prompts the user for a passphrase, and this is fed through a key derivation
function to produce a key, which is then used to encrypt the private key with a
symmetric cipher.

In use, once the server knows the client's public key (stored in the
`.ssh/authorized_keys` file), a connecting client can prove its identity using
asymmetric signatures. This is done through
[challenge-response](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication).
At a high level, the server picks a random number and sends it to the client.
The client then signs this message and sends the signature back to the server,
which checks the signature against the public key on record. This effectively
proves that the client is in possession of the private key corresponding to the
public key that's in the server's `.ssh/authorized_keys` file, so the server
can allow the client to log in.

{% comment %}
extra topics, if there's time

security concepts, tips
- biometrics
- HTTPS
{% endcomment %}

# Resources

- [Last year's notes](/2019/security/): from when this lecture was more focused on security and privacy as a computer user
- [Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html): answers "what crypto should I use for X?" for many common X.

# Exercises

1. **Entropy.**
    1. Suppose a password is chosen as a concatenation of five lower-case
       dictionary words, where each word is selected uniformly at random from a
       dictionary of size 100,000. An example of such a password is
       `correcthorsebatterystaple`. How many bits of entropy does this have?
    1. Consider an alternative scheme where a password is chosen as a sequence
       of 8 random alphanumeric characters (including both lower-case and
       upper-case letters). An example is `rg8Ql34g`. How many bits of entropy
       does this have?
    1. Which is the stronger password?
    1. Suppose an attacker can try guessing 10,000 passwords per second. On
       average, how long will it take to break each of the passwords?
1. **Cryptographic hash functions.** Download a Debian image from a
   [mirror](https://www.debian.org/CD/http-ftp/) (e.g. [from this Argentinean
   mirror](http://debian.xfree.com.ar/debian-cd/current/amd64/iso-cd/).
   Cross-check the hash (e.g. using the `sha256sum` command) with the hash
   retrieved from the official Debian site (e.g. [this
   file](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS)
   hosted at `debian.org`, if you've downloaded the linked file from the
   Argentinean mirror).
1. **Symmetric cryptography.** Encrypt a file with AES encryption, using
   [OpenSSL](https://www.openssl.org/): `openssl aes-256-cbc -salt -in {input
   filename} -out {output filename}`. Look at the contents using `cat` or
   `hexdump`. Decrypt it with `openssl aes-256-cbc -d -in {input filename} -out
   {output filename}` and confirm that the contents match the original using
   `cmp`.
1. **Asymmetric cryptography.**
    1. Set up [SSH
       keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
       on a computer you have access to (not Athena, because Kerberos interacts
       weirdly with SSH keys). Rather than using RSA keys as in the linked
       tutorial, use more secure [ED25519
       keys](https://wiki.archlinux.org/index.php/SSH_keys#Ed25519). Make sure
       your private key is encrypted with a passphrase, so it is protected at
       rest.
    1. [Set up GPG](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)
    1. Send Anish an encrypted email ([public key](https://keybase.io/anish)).
    1. Sign a Git commit with `git commit -S` or create a signed Git tag with
       `git tag -s`. Verify the signature on the commit with `git show
       --show-signature` or on the tag with `git tag -v`.
