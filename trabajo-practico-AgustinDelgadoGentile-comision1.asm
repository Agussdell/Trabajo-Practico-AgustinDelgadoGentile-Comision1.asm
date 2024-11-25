.data
slist: 	.word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: 	.ascii "Colecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Anterior categoria\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
	
error: 	.asciiz "Error: "

return: .asciiz "\n"

catName:.asciiz "\nIngrese el nombre de una categoria: "

selCat: .asciiz "\nSe ha seleccionado la categoria:"

idObj: 	.asciiz "\nIngrese el ID del objeto a eliminar: "

objName:.asciiz "\nIngrese el nombre de un objeto: "

success:.asciiz "La operacion se ha realizo con exito\n\n"

greater_symbol: .asciiz ">"

invalid_option: .asciiz "\nOpcion invalida. Intente de nuevo.\n"

not_found_msj: .asciiz "Not Found. \n"

.text
main:

	la $t0, schedv
	la $t1, newcategory
	sw $t1, 0($t0)              # Opcion 1: Nueva categoria


	la $t1, nextcategory
	sw $t1, 4($t0)              # Opcion 2: Siguiente categoria


	la $t1, prevcategory
	sw $t1, 8($t0)              # Opcion 3: Categoria anterior


	la $t1, listcategories
	sw $t1, 12($t0)             # Opcion 4: Listar categorias


	la $t1, delcategory
	sw $t1, 16($t0)             # Opcion 5: Borrar categoria


	la $t1, newobject
	sw $t1, 20($t0)             # Opcion 6: A�adir objeto


	la $t1, listobjects
	sw $t1, 24($t0)             # Opcion 7: Listar objetos


	la $t1, delobject
	sw $t1, 28($t0)             # Opcion 8: Borrar objeto

menu_loop:

    	la $a0, menu # Mostrar el menu
    	li $v0, 4
    	syscall
    	
    	li $v0, 5 # Leer opcion del usuario
    	syscall
    	move $t2, $v0 # Guardar opcion en $t2

    	beqz $t2, exit # Verificar rango de opcion valida (1-8)
    	li $t3, 1
    	blt $t2, $t3, invalid_option_label
    	li $t3, 8
    	bgt $t2, $t3, invalid_option_label

    	subi $t2, $t2, 1 # Calcular la posicion en schedv (opcion - 1) * 4
    	sll $t2, $t2, 2
    	la $t0, schedv
    	add $t0, $t0, $t2  # $t0 ahora tiene la direccion de la funcion en schedv

    	# Llamar a la subrutina a traves de la direccion en $t0
    	lw $t1, 0($t0)
    	#move $t1, $ra
    	jalr $t1                 # Saltar a la subrutina correspondiente

    	# Regresar al bucle del menu despues de ejecutar la opcion
    	j menu_loop

invalid_option_label:

    	# Mensaje de opcion invalida
    	la $a0, invalid_option
    	li $v0, 4
    	syscall
    	j menu_loop                # Regresar al menu

newcategory:

	addiu $sp, $sp, -4 #reserva word en stack
	sw $ra, 4($sp)	   #	
	la $a0, catName    # input category name, en el argumento $a0 para poder imprimirlo
	jal getblock
	move $a2, $v0 # $a2 = *char to category name
	la $a0, cclist # $a0 = list
	li $a1, 0 # $a1 = NULL
	jal addnode
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist # update working list if was NULL
	
newcategory_end:

	li $v0, 0 # return success
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
	
nextcategory:

    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)

    	lw $t0, cclist # Dejo en $t0 el comienzo de la lista
    	beqz $t0, error_201 #Si es igual a 0, error 201

    	lw $t1, wclist # Dejo en $t1 la cat en curso
    	lw $t2, 12($t1) # Cargo en $t2 la sig
    	beq $t1, $t2, error_202 # Si la sig es igual a la en curso, significa que hay una sola.

    	sw $t2, wclist
    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	li $v0, 0
    	j nextcategory_end
    	
error_201:

    	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 201
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 201
    	j nextcategory_end
    	
error_202:

    	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 202
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 202 # borrar esto
    	
nextcategory_end:

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    
prevcategory:

    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)
    	
    	lw $t0, cclist        # Cargar la lista de categorias
    	beqz $t0, error_201   # Si cclist es NULL, no hay categorias (error 201)

    	lw $t1, wclist # Dejo en $t1 la cat en curso
    	lw $t2, 0($t1) # Cargo en $t2 la ant
    	beq $t1, $t2, error_202 # Si la ant es igual a la en curso, significa que hay una sola.
 
    	sw $t2, wclist

    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall              # Imprimir mensaje

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra               # Volver

listcategories:

    	lw $t0, cclist
    	beqz $t0, list_error_301
    	lw $t2, wclist
    	move $t1, $t0
       
list_loop:

    	bne $t1, $t2, list_loop2
    	
print_symbol:

    	la $a0, greater_symbol
    	syscall
    	
list_loop2:

    	lw $a0, 8($t1)
    	li $v0, 4
    	syscall
    	lw $t1, 12($t1)
    	bne $t1, $t0, list_loop

listcategories_end:

    	jr $ra

list_error_301:

	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 301
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 301
    	j listcategories_end
    
    
delcategory:

    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_401

    	lw $t1, 4($t0)   # Lista de objetos en la categoria
    	beqz $t1, delcat_no_objs

    	move $a0, $t1
    	jal delobject_all  # Llama a una funcion que borra todos los objetos
	
delcat_no_objs:

    	lw $a0, wclist
    	lw $a1, cclist
    	lw $t5, 12($a0)
    	beq $t5, $a0, del_last_cat
    	sw $t5, wclist
    	bne $a0, $a1,  del_node_cat
    	sw $t5, cclist
    	j del_node_cat
    	#sw $t5, cclist
    	
del_last_cat:

    	sw $zero, cclist
	sw $zero, wclist
    	
del_node_cat:
	
	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

error_401:

	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 401
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 401
    	jr $ra
    
newobject:

    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, cclist
    	beqz $t0, error_501

    	# Obtener nombre del objeto
    	la $a0, objName
    	jal getblock
    	move $a2, $v0
    	lw $t0, wclist
    	addi $t0, $t0, 4
    	move $a0, $t0
    	lw $t5, ($a0)
    	bnez  $t5, otherobject
    	li   $a1, 1
    	jal addnode
    	j   newobject_exit
    
otherobject:

    	lw $t4, ($t5)
    	lw $t5, 4($t4)
    	addiu $a1, $t5, 1
    	jal addnode

newobject_exit:

    	li $v0, 0
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
	
error_501:

	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 501
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 501
    	jr $ra
    
    
listobjects:

    	lw $t0, wclist
    	beqz $t0, error_601

    	lw $t1, 4($t0)
   	beqz $t1, error_602

    	move $t2, $t1
list_objects_loop:

    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	lw $t2, 12($t2)
    	bne $t2, $t1, list_objects_loop

    	li $v0, 0
    	jr $ra

error_601:

	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 601
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 601
    	jr $ra

delobject_all:

    	addiu $sp, $sp, -4           
    	sw $ra, 4($sp)               

    	lw $t0, wclist               # $t0 apunta a la categoria seleccionada

    	beqz $t1, error_602          # Si la lista esta vacia, saltamos a error_602

    	# Comenzamos a recorrer la lista de objetos
delobject_loop:

    	lw $t2, 12($t1)              # $t2 contiene el puntero al siguiente objeto
    	lw $t3, 0($t1)               # $t3 contiene el puntero al objeto anterior
    	lw $t4, 8($t1)               # $t4 apunta al puntero de nombre del objeto (suponiendo que esta en el offset 8)
    
    	sw $t3, 0($t2)		# Establecer el anterior puntero del objeto siguiente
    	sw $t2, 12($t3) 		# Establecer el siguiente puntero del objeto anterior
    	# Limpiar los valores dentro del objeto
    	li $t5, 0                    # Cargar el valor 0
    	sw $t5, 0($t1)               # Poner a cero el puntero anterior (nodo anterior)
    	sw $t5, 4($t1)               # Poner a cero el puntero siguiente (nodo siguiente)
    	sw $t5, 8($t1)               # Poner a cero el puntero al nombre (nodo nombre)
    	move $a0, $t1 # Liberar el bloque de memoria del objeto
    	jal sfree                   
    	beq $t2, $t1, delobject_end  # Si hemos llegado al final de la lista (el siguiente es igual al primero), terminamos Si el siguiente objeto es el primero, salimos del bucle
    	move $t1, $t2 # Continuamos con el siguiente objeto
    	j delobject_loop

delobject_end:	
	
    	lw $t0, wclist # Si hemos eliminado todos los objetos, actualizamos la lista de objetos de la categoria
    	sw $zero, 4($t0)# Establecemos la lista de objetos a NULL en la categoria seleccionada
    	li $v0, 0 # Indicamos que la operacion se completa con éxito

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra 

error_602:  # Si la lista de objetos esta vacia, devolvemos un error
	
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 602
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 602
    	jr $ra


 
    
delobject:

    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_701
	
	
    	la $a0, idObj
    	li $v0, 4
    	syscall
     
    	li $v0, 5
    	syscall
    								
    	move $t1, $v0  # ID buscado
    	lw $t2, 4($t0) # Primer objeto
    	
    	#lw $t3, 4($t2) #ID del primer objeto
    	#blt $t1, $t3, not_found
    	
    	lw $t4, 0($t2) # ultimo objeto
    	lw $t3, 4($t4) #ID ultimo objeto
    	#bgt $t1, $t3, not_found
    	li $t5, 0
  
    	move $a1, $t2
       
delobj_loop:

    	lw $t3, 4($t2)
    	beq $t1, $t3, delobj_found
    	lw $t2, 12($t2)
    	bgt $t5, $t3, not_found
    	addiu $t5, $t5, 1
    	bne $t2, $zero, delobj_loop

not_found:

	la $a0, not_found_msj
    	li $v0, 4
    	syscall
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

delobj_found:

    	lw $t4, 4($t0)
    	beq $t2, $t4, updateObjList
    	
delobj_found2:   

    	move $a0, $t2
    	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
   	jr $ra
    
updateObjList:

    	lw  $t5, 12($t2)     #$t5 queda con el objeto siguiente
    	addiu $t4, $t0, 4    #cargo la direccion donde la categoria tiene el puntero de la lista de objetos
    	seq $t6, $t5, $t2    #si el siguiente objeto es el mismo a eliminar significa que hay uno solo
    	bnez $t6, updateObjList2 #si lo anterior era ver $t6 tendria q ser 1 y saltar a update2
    	sw  $t5, 0($t4)	
    	j   delobj_found2
    
updateObjList2:

    	sw  $zero, 0($t4)	#actualizo el puntero de lista objetos a 0
    	j   delobj_found2   
    
error_701:

	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 701
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
   	li $v0, 701
    	jr $ra
    
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:

	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc
	sw $a1, 4($v0) # set node content
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) # first node address
	beqz $t0, addnode_empty_list
	
addnode_to_end:

	lw $t1, ($t0) # last node address
	# update prev and next pointers of new node
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	# updat	e prev and first node to new node
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit
	
addnode_empty_list:

	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)
	
addnode_exit:

	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra
# a0: node address to delete
# a1: list address where node is deleted

delnode:

	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0) # get block address
	jal sfree # free block
	lw $a0, 4($sp) # restore argument a0
	lw $t0, 12($a0) # get address to next node of a0
	
node:

	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0) # get address to prev node
	sw $t1, 0($t0) # el anterior pasa a la siguiente categoria
	sw $t0, 12($t1)
	lw $t1, 0($a1) # get address to first node
	
again:

	bne $a0, $t1, delnode_exit
	sw $t0, ($a1) # list point to next node
	j delnode_exit
	
delnode_point_self:

	sw $zero, ($a1) # only one node
	#sw $zero, cclist
	#sw $zero, wclist
	
delnode_exit:

	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

# a0: msg to ask
# v0: block address allocated with string

getblock:

	addi $sp, $sp, -4
	sw $ra, 4($sp) #guarda en stack el ra de new category
	li $v0, 4
	syscall	
	jal smalloc
	move $a0, $v0 # guarda en a0 la direccion de heap + 16 bytes
	li $a1, 16
	li $v0, 8
	syscall
	move $v0, $a0
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	 
smalloc:

	lw $t0, slist
	beqz $t0, sbrk
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
sbrk:

	li $a0, 16 # node size fixed 4 words
	li $v0, 9  # llamo al heap reservando 16 bytes / 4 words
	syscall # return node address in v0
	jr $ra
	
sfree:

	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address in unused list
	jr $ra
	
exit:

	li $v0, 10
	syscall
