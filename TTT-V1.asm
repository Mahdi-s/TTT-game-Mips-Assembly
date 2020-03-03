#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Program Purpose: simple Tic-Tac-Toe Game for CSCI 370
#Author: Mahdi Saeedi-Velashani
#Functionality:
#	Print welcome msg & board
#	Take User Input (Check for correctness)
#	print input on the board
#	Ask for a new game
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.data
square: .space 36  #array of user choices
input: .space 2  #input for y and n continue
User_input: .space 2
   board:  .ascii   "\n\n        | |        1|2|3\n       -----       -----"
           .ascii     "\n        | |        4|5|6\n       -----       -----"
           .asciiz    "\n        | |        7|8|9\n"
start_msg:  .ascii "\n Start a One-Player Tic-Tac-Toe Game. \n"
	    .asciiz "\n Pick a Piece to start with (X/O):"
invalid_input_msg: .asciiz "\n Invalid Input! Please try again!\n"
next_move_prompt:  .asciiz "\n Enter your next move (1-9):"
Pick_piece: .asciiz "\n Pick a Piece (X/O):"
Cont: .asciiz "\n Continue(Y/N):"
NewGame: .asciiz "\n New Game(Y/N):"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text
.globl main
main:
	#print the table
	li $v0, 4
	la $a0, board
	syscall
	jal StartMsg #jump to welcome msg
	#Signals end of program
	li $v0, 10
	syscall
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StartMsg:
	#print start messege
	li $v0, 4
	la $a0, start_msg
	syscall
	#read user input for picking X or O *add error checking
	li $v0, 8
	la $a0, User_input
	li $a1, 2
	syscall
	#move $t0, $a0 #move user input into new location
	jal cmpfunc_userInput
	#Jump back to the main function
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#char compare function
cmpfunc_userInput:
	lb $a0, User_input # load user input
	beq $a0, 'x', TakeInput_x
	beq $a0, 'o', TakeInput_o
	beq $a0, 'X', TakeInput_x
	beq $a0, 'O', TakeInput_o
	#Invalid input notice
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	jal StartMsg
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cont_x:
	#check if user wants to coninue
	li $v0, 4
	la $a0, Cont
	syscall
	li $v0, 12
	syscall
	move $a0, $v0
	beq $a0, 'n', newgame_msg
	beq $a0, 'N', newgame_msg
	beq $a0, 'y', TakeInput_x
	beq $a0, 'Y', TakeInput_x
	j wrong_input_x
	jr $ra
wrong_input_x:
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j cont_x
	jr $ra
TakeInput_x:
	#print prompt asking for user's next move
	li $v0, 4
	la $a0, next_move_prompt
	syscall
	#read user-input for picking next move (1-9) *add error checking
	li $v0, 5
	syscall
	move $t0, $v0
	beq $t0, 1, offset_1_x
	beq $t0, 2, offset_2_x
	beq $t0, 3, offset_3_x
	beq $t0, 4, offset_4_x
	beq $t0, 5, offset_5_x
	beq $t0, 6, offset_6_x
	beq $t0, 7, offset_7_x
	beq $t0, 8, offset_8_x
	beq $t0, 9, offset_9_x
	#Invalid input
	bgt $t0, 9, wrongInput_num_x
	blt $t0, 0, wrongInput_num_x
	#Jump back to the main function
	jr $ra
cont_o:
	#check if user wants to coninue
	li $v0, 4
	la $a0, Cont
	syscall
	li $v0, 12
	syscall
	move $a2, $v0
	beq $a2, 'n', newgame_msg
	beq $a2, 'N', newgame_msg
	beq $a2, 'y', TakeInput_o
	beq $a2, 'Y', TakeInput_o
	j wrong_input_o
	jr $ra
wrong_input_o:
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j cont_o
	jr $ra
TakeInput_o:
	#print prompt asking for user's next move
	li $v0, 4
	la $a0, next_move_prompt
	syscall
	#read user-input for picking next move (1-9) *add error checking
	li $v0, 5
	syscall
	move $t0, $v0
	beq $t0, 1, offset_1_o
	beq $t0, 2, offset_2_o
	beq $t0, 3, offset_3_o
	beq $t0, 4, offset_4_o
	beq $t0, 5, offset_5_o
	beq $t0, 6, offset_6_o
	beq $t0, 7, offset_7_o
	beq $t0, 8, offset_8_o
	beq $t0, 9, offset_9_o
	#Invalid input
	bgt $t0, 9, wrongInput_num_o
	blt $t0, 0, wrongInput_num_o
	#Jump back to the main function
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wrongInput_num_x:
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j TakeInput_x
	jr $ra
wrongInput_num_o:
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j TakeInput_o
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
newgame_msg:
	li $v0, 4
	la $a0, NewGame
	syscall
	li $v0, 12
	syscall
	beq $v0, 'n', exit
	beq $v0, 'N', exit
	beq $v0, 'y', new_g
	beq $v0, 'Y', new_g

exit:
	li $v0, 10
	syscall
new_g:
	addi $t5, $zero, 9
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 11
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 13
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 59
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 61
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 63
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 109
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 111
	li $t6, ' '
	sb $t6, board($t5)
	addi $t5, $zero, 113
	li $t6, ' '
	sb $t6, board($t5)
	#print board
	li $v0, 4
	la $a0, board
	syscall
	jal StartMsg

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Off-set for x~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
offset_1_x:
	addi $t5, $zero, 9
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_2_x:
	addi $t5, $zero, 11
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_3_x:
	addi $t5, $zero, 13
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_4_x:
	addi $t5, $zero, 59
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_5_x:
	addi $t5, $zero, 61
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_6_x:
	addi $t5, $zero, 63
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_7_x:
	addi $t5, $zero, 109
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_8_x:
	addi $t5, $zero, 111
	li $t6, 'X'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_9_x:
	addi $t5, $zero, 113
	li $t7, 'X'
	sb $t7, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_o
	#j TakeInput_o
	jr $ra
offset_1_o:
	addi $t5, $zero, 9
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_2_o:
	addi $t5, $zero, 11
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_3_o:
	addi $t5, $zero, 13
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_4_o:
	addi $t5, $zero, 59
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_5_o:
	addi $t5, $zero, 61
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_6_o:
	addi $t5, $zero, 63
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_7_o:
	addi $t5, $zero, 109
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j TakeInput_x
	jr $ra
offset_8_o:
	addi $t5, $zero, 111
	li $t6, 'O'
	sb $t6, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
offset_9_o:
	addi $t5, $zero, 113
	li $t7, 'O'
	sb $t7, board($t5)
	la $a0, board
	li $v0, 4
	syscall
	j cont_x
	#j TakeInput_x
	jr $ra
