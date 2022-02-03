README

15 Abril 2018

Alumno:
Emanuel Becerra Soto

Profesor:
Dr. Hiram Calvo

Materia:
Teoria de la computacion

#################################################

El programa re2AFN.py convirte una expresion regular
a un automata finito no determinista.

Ejemplo de uso.

python re2AFN.py '((a|b).c)*'

OUTPUT

AFN-/:
S={0}
F={0,6,8}
0,/->1
1,a->2
0,/->3
3,b->4
2,/->5
5,c->6
4,/->7
7,c->8
6,/->0
8,/->0

El programa se invoca desde la linea de comandos
recibe un solo argumento, una cadena que contenga la
expresion regular a convertirse.
Es indispensable usar comillas ya sea simples o dobles,
debido a que la terminal tiene simbolos reservados que podrian interferir.
Si ningun argumento es suministrado, el programa se detendra e imprimira sus opciones.

Las exresiones regulares que acepta se construyen de la siguiente manera:
1. Un solo caracter 'a'
2. Concatenacion 'a.b'
3. Union 'a|b'
4. Estrella de Kleene 'a*'
5. Estrella de Kleene '(a)*'
6. Para incremetar las operaciones a mas de dos es obligatorio usar parentesis
	Por ejemplo
	'(a.b).c'
	'((a.b).c).d'
	'((a|b).c)|d'
	'(((a|b).c)|d)*'
7. El programa solo realiza el analisis sintactico hacia la derecha, por lo que
las expresiones regulares que no se encuentre en dicha forma deben reescribirse.
	Por ejemplo
	'a.(b.c)'
	Debe rescribirse a
	'(a.b).c'

#################################################

bash re2AFN2sif.sh '((a|b).c)*'

Ademas se incluye un pequeno script
que genera un archivo formato .sif
para visualizar el automata en
programas que acepten formatos de grafos

Visualice algunas corridas de prueba en
el software Cytoskape, el cual acepta .sif

http://www.cytoscape.org/

#################################################

El codigo fuente fue probado en Python 3.6.4
en un sistema:

OS: Ubuntu 16.04 xenial
Kernel: x86_64 Linux 4.13.0-38-generic

#################################################

Nota: Texto sin acentos

