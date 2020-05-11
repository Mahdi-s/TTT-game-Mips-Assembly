#Program 2 CS 370 
#Author: Mahdi Saeedi Velashani 
#ID: 1132375
#Note: the computer looks ahead one move to either win or block opponent
# certain blocks by the computer are not taken in order to make the game winable
# If the computer makes the winning move it will still allow you to make one more move before
# declering itself the winner, that just the way program loops around. 
# The game declares a winner and a tie

.data
player_move: .space 36
comp_move: .space 36
grid: .word 9,11,13,59,61,63,109,111,113
iterator: .word 0
User_input: .byte ' '
Comp_input: .byte ' '
   board:  .ascii   "\n\n        | |        1|2|3\n       -----       -----"
           .ascii     "\n        | |        4|5|6\n       -----       -----"
           .asciiz    "\n        | |        7|8|9\n"  	
start_msg:  .ascii "\n Start a One-Player Tic-Tac-Toe Game. \n"
	    .asciiz "\n Pick a Piece to start with (X/O):"
invalid_input_msg: .asciiz "\n Invalid Input! Please try again!\n"
next_move_prompt:  .asciiz "\n Enter your next move (1-9):"
system_move_prompt:  .asciiz "\n Enter space to view system's move:"
win_promt: .asciiz "\n X won the game!"
win_promt_o: .asciiz "\n O won the game!"
check_tie_m: .asciiz "\n Tie game better luck next time!"
Cont: .asciiz "\n Continue(Y/N):"
test: .asciiz "\n test:"	
NewGame: .asciiz "\n New Game(Y/N):"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text
.globl main
main: 
	jal start_game  
	li $v0, 10 #Signals end of program 
	syscall
start_game:
	li $v0, 4 #print the table
	la $a0, board
	syscall
	jal randomPCchoice #generate 0 or 1 saved to $t1
	beq $t1, 1 ,StartMsg #jump to welcome msg and let user go first if seed = 1
	beq $t1, 0, pcmove1 #computer goes first if seed = 0
	jr $ra
randomPCchoice: # this function generates 0-1 to decide who goes first
	xor  $a0, $a0, $a0
	li $a1, 2
	li $v0, 42 #random 
	syscall
	move $t1, $a0
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StartMsg:
	li $v0, 4 #print start messege
	la $a0, start_msg
	syscall
	li $v0, 12 #let user pick X/O
	syscall
	move $t6, $v0
	sb $t6, User_input
	jal assign_compt_char
	jal cmpfunc_userInput 
	jr $ra
cmpfunc_userInput:
	#lb $t6, User_input # load user input
	beq $t6, 'x', user_choice
	beq $t6, 'o', user_choice
	beq $t6, 'X', user_choice
	beq $t6, 'O', user_choice
	li $v0, 4 #Invalid input notice
	la $a0, invalid_input_msg
	syscall
	jal StartMsg
	jr $ra	
assign_compt_char:
	beq $t6, 'x', set_comp_to_o
	beq $t6, 'X', set_comp_to_o
	beq $t6, 'o', set_comp_to_x
	beq $t6, 'O', set_comp_to_x
	jr $ra
set_comp_to_o:
	la $t1, 'O'
	sb $t1, Comp_input
	jr $ra
set_comp_to_x:
	la $t1, 'X'
	sb $t1, Comp_input
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
user_choice: 
	#print prompt asking for user's next move
	li $v0, 4
	la $a0, next_move_prompt
	syscall
	#read user-input for picking next move (1-9) *add error checking
	li $v0, 5
	syscall	
	bgt $v0, 9, wrongInput_num
	blt $v0, 1 , wrongInput_num	
	# add fucntion to check is position is already taken
	move $t0, $v0
	#save move to array
	#lw $t1, iterator 
	#la $t2, player_move
	#sw $t0, $t1($t2)
	#addi $t1, $t1 , 1
	#sw $t1, iterator
	jal findoffset
	lb $a0, User_input # load user input
	jal place_offset
	#jal Check_win
	jal check1
	jal check2
	jal check3
	jal check4
	jal check7
	jal check_tie
	jal pcmove
findoffset: #calculating offset
	mul $t1, $t0, 2 #2*v  *1*
	add $t1, $t1, 7 #+7
	sub $t2, $t0, 1 #v-1  *2*
	div $t2, $t2, 3 # (v-1)/3
	mul $t2, $t2, 6 # [(v-1)/3]*6
	sub $t3, $t0, 1 #v-1  *3*
	div $t3, $t3, 3 # (v-1)/3
	mul $t3, $t3, 50 # [(v-1)/3]*6
	sub $t4, $t1, $t2 # *1* - *2* + *3*
	add $t4, $t4, $t3 # offset is now in $t4
	#print offset
	#sb $t4, Temp
	#li $v0, 1
	#lb $a0, Temp
	#syscall
	jr $ra
place_offset:
	add $t5, $t4, $zero
	move $t6, $a0
	sb $t6, board($t5) #print user input into the board
	la $a0, board
	li $v0, 4
	syscall
	jr $ra	
wrongInput_num: 
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j user_choice
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pcmove1:
	la $t1, 'O'
	sb $t1, Comp_input
	la $t1, 'X'
	sb $t1, User_input
pcmove:
	li $v0, 4
	la $a0, system_move_prompt
	syscall
	li $v0, 12
	syscall
	move $a0, $v0 
	beq $a0, ' ', computer_move
	j Wrong_input_space
	jr $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
computer_move:
        #call functions for move blocks
        jal look_ahead1
        jal look_ahead2
        jal look_ahead3
        jal smart_move1
        jal smart_move2
        jal smart_move3
	jal RandomMove
	li $v0, 4 #print the table
	la $a0, board
	syscall
RandomMove:
	xor   $a0, $a0, $a0      # Set a seed number.
	li    $a1, 9             # random number from 0 to 8
	li    $v0, 42            # random number generator
	syscall
	move $t0, $a0
	addi $t0, $t0, 1
	jal findoffset
	#move $s1, $t4
	lb  $t5, board($t4)
	bne $t5, ' ', RandomMove        # Go to R1 if the cell is not empty.
	lb $a0, Comp_input
	jal place_offset
	#jal Check_win
	jal check1
	jal check2
	jal check3
	jal check4
	jal check7
	jal check_tie
	j cont
	jr    $ra                # Return.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Wrong_input_space:
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j pcmove
	jr $ra
cont:
	#check if user wants to coninue
	li $v0, 4
	la $a0, Cont
	syscall
	li $v0, 12
	syscall
	move $a2, $v0
	beq $a2, 'n', newgame_msg
	beq $a2, 'N', newgame_msg
	beq $a2, 'y', user_choice
	beq $a2, 'Y', user_choice
	j wrong_input
	jr $ra
wrong_input: 
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j cont
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
	j wrong_msg_newGame
wrong_msg_newGame:
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	j newgame_msg
	jr $ra	
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
	jal start_game
dec_win:
	li $v0, 4 #print win promt
	la $a0, win_promt
	syscall	
	j newgame_msg
dec_win_o:
	li $v0, 4 #print win promt
	la $a0, win_promt_o
	syscall	
	j newgame_msg
check_tie:
	li $t0, 9
	lb  $s0, board($t0) #check position 1
	sne $t1, $s0, ' '
	
	li $t0, 11
	lb  $s0, board($t0) #check position 1
	sne $t3, $s0, ' '
	
	li $t0, 13
	lb  $s0, board($t0) #check position 1
	sne $t4, $s0, ' '
	
	li $t0, 59
	lb  $s0, board($t0) #check position 1
	sne $t5, $s0, ' '
	
	li $t0, 61
	lb  $s0, board($t0) #check position 1
	sne $t6, $s0, ' '
	
	li $t0, 63
	lb  $s0, board($t0) #check position 1
	sne $t7, $s0, ' '
	
	li $t0, 109
	lb  $s0, board($t0) #check position 1
	sne $t8, $s0, ' '
        
        #add $t1, $t1, $t2
        add $t1, $t1, $t3
        add $t1, $t1, $t4
        add $t1, $t1, $t5
        add $t1, $t1, $t6
        add $t1, $t1, $t7
        add $t1, $t1, $t8 #$t1 final
        #addi $t2, $zero, 0
        
	li $t0, 111
	lb  $s0, board($t0) #check position 1
	sne $t9, $s0, ' '
	
       	add $t1, $t1, $t9 #$t1 final
       	
       	li $t0, 113
	lb  $s0, board($t0) #check position 1
	sne $t2, $s0, ' '
	
	add $t1, $t1, $t2
	beq $t1, 9, dec_tie
	#li $t8, 113
	jr $ra
dec_tie:
	li $v0, 4 #print win promt
	la $a0, check_tie_m
	syscall	
	j newgame_msg
check1:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb  $s0, board($t0) #check position 1
	beq $s0, 'x', cnx11and59
        beq $s0, 'o', cno11and59
        beq $s0, 'X', cnx11and59
        beq $s0, 'O', cno11and59
        jr $ra
check4:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
        lb  $s0, board($t3) #check position 4 
	beq $s0, 'x', cnx61
        beq $s0, 'o', cno61
        beq $s0, 'X', cnx61
        beq $s0, 'O', cno61
        jr $ra
check7:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
        lb  $s0, board($t6) #check position 7 
	beq $s0, 'x', cnx111
        beq $s0, 'o', cno111
        beq $s0, 'X', cnx111
        beq $s0, 'O', cno111
        jr $ra
check2:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
        lb  $s0, board($t1) #check position 2 
	beq $s0, 'x', cnx5
        beq $s0, 'o', cno5
        beq $s0, 'X', cnx5
        beq $s0, 'O', cno5
        jr $ra
check3:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
        lb  $s0, board($t2) #check position 3 
	beq $s0, 'x', cnx63
        beq $s0, 'o', cno63
        beq $s0, 'X', cnx63
        beq $s0, 'O', cno63
        jr $ra
        
        
             cnx63:  
        	lb  $s0, board($t5)
		beq $s0, 'x', cnx9
		beq $s0, 'X', cnx9
		lb  $s0, board($t4)
		beq $s0, 'x', cnx7
		beq $s0, 'X', cnx7
		jr $ra
	     cnx9: #check 113
	     	lb  $s0, board($t8)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
        	jr $ra
             cnx7: #check 109
	     	lb  $s0, board($t6)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
        	jr $ra
        
        
             cnx5:  
        	lb  $s0, board($t4)
		beq $s0, 'x', cnx8
		beq $s0, 'X', cnx8
		jr $ra
	     cnx8: #check 111
	     	lb  $s0, board($t7)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
        	jr $ra
        
             cnx111:  
        	lb  $s0, board($t7)
		beq $s0, 'x', cnx113
		beq $s0, 'X', cnx113
		jr $ra
	     cnx113: #check 113
	     	lb  $s0, board($t8)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
        	jr $ra
        
        
             cnx61:  
        	lb  $s0, board($t4)
		beq $s0, 'x', cnx6
		beq $s0, 'X', cnx6
		jr $ra
	     cnx6: #check 63
	     	lb  $s0, board($t5)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
		jr $ra
        
        
        
	     cnx11and59:
		lb  $s0, board($t1)
		beq $s0, 'x', cnx13
		beq $s0, 'X', cnx13
		lb  $s0, board($t3)
		beq $s0, 'x', cnx59
		beq $s0, 'X', cnx59
		lb  $s0, board($t4)
		beq $s0, 'x', cnxp9
		beq $s0, 'X', cnxp9
		jr $ra
		cnx13: #check 13
		lb  $s0, board($t2)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
		jr $ra
		# save caller address
		cnx59: #check 109
		lb  $s0, board($t6)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
		jr $ra
		#save caller address
		cnxp9: #check 113
		lb  $s0, board($t8)
		beq $s0, 'x', dec_win
		beq $s0, 'X', dec_win
		jr $ra
		#save caller address
#---------------------------------------------
             cno63:  
        	lb  $s0, board($t5)
		beq $s0, 'o', cno9
		beq $s0, 'O', cno9
		lb  $s0, board($t4)
		beq $s0, 'o', cno7
		beq $s0, 'O', cno7
		jr $ra
	     cno9: #check 113
	     	lb  $s0, board($t8)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
        	jr $ra
             cno7: #check 109
	     	lb  $s0, board($t6)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
        	jr $ra
        
        
             cno5:  
        	lb  $s0, board($t4)
		beq $s0, 'o', cno8
		beq $s0, 'O', cno8
		jr $ra
	     cno8: #check 113
	     	lb  $s0, board($t7)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
        	jr $ra
        
             cno111:  
        	lb  $s0, board($t7)
		beq $s0, 'o', cno113
		beq $s0, 'O', cno113
		jr $ra
	     cno113: #check 113
	     	lb  $s0, board($t8)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
        	jr $ra
        
        
             cno61:  
        	lb  $s0, board($t4)
		beq $s0, 'O', cno6
		beq $s0, 'o', cno6
		jr $ra
	     cno6: #check 63
	     	lb  $s0, board($t5)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
		jr $ra
        
        
        
	     cno11and59:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
		lb  $s0, board($t1)
		beq $s0, 'o', cno13
		beq $s0, 'O', cno13
		lb  $s0, board($t3)
		beq $s0, 'o', cno59
		beq $s0, 'O', cno59
		lb  $s0, board($t4)
		beq $s0, 'o', cnop9
		beq $s0, 'O', cnop9
		jr $ra
		cno13: #check 13
		lb  $s0, board($t2)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
		jr $ra
		# save caller address
		cno59: #check 109
		lb  $s0, board($t6)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
		jr $ra
		#save caller address
		cnop9: #check 113
		lb  $s0, board($t8)
		beq $s0, 'o', dec_win_o
		beq $s0, 'O', dec_win_o
		jr $ra
		#save caller address
#---------------------------------------------------------------
smart_move1:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb $t9, User_input
	#Comp_input
	lb  $s0, board($t0) #check position 1 
	beq $s0, $t9, sm1
	lb  $s0, board($t1) #check position 2 
	beq $s0, $t9, check3and5
	jr $ra
	     	check3and5:
	     	li $t1, 13
	     	lb $t9, User_input
		lb  $s0, board($t1) #check position 2 
		beq $s0, $t9, check_1_empty
		li $t1, 61
		lb  $s0, board($t1) #check position 5
		beq $s0, $t9, cnc_empty8
		jr $ra
		cnc_empty8:
		li $t2, 111
		lb  $s0, board($t2) #check position 9 
		beq $s0, ' ', take_move_8
		jr $ra
		take_move_8:
		addi $t5, $zero,111
		lb $t6, Comp_input
		sb $t6, board($t5) #use 3
		la $a0, board
		li $v0, 4
		syscall
		j cont
		check_1_empty:
	        li $t2, 9
		lb  $s0, board($t2) #check position 9 
		beq $s0, ' ', take_move_1
		jr $ra
		take_move_1:
		addi $t5, $zero,9
		lb $t6, Comp_input
		sb $t6, board($t5) #use 3
		la $a0, board
		li $v0, 4
		syscall
		j cont
	     sm1:
	     	li $t1, 11
	     	lb $t9, User_input
		lb  $s0, board($t1) #check position 2 
		beq $s0, $t9, cnc_empty3
		li $t1, 61
		lb  $s0, board($t1) #check position 5
		beq $s0, $t9, cnc_empty9v
		jr $ra
	     cnc_empty9v:
	     	li $t2, 113
		lb  $s0, board($t2) #check position 9 
		beq $s0, ' ', take_move_9v
		jr $ra
             cnc_empty3:
             	li $t2, 13
		lb  $s0, board($t2) #check position 3 
		beq $s0, ' ', take_move_3
		jr $ra
	     take_move_3:
		addi $t5, $zero,13
		lb $t6, Comp_input
		sb $t6, board($t5) #use 3
		la $a0, board
		li $v0, 4
		syscall
		j cont
             take_move_9v:
		addi $t5, $zero,113
		lb $t6, Comp_input
		sb $t6, board($t5) #use 9
		la $a0, board
		li $v0, 4
		syscall
		j cont
#---------------------------
smart_move2:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb $t9, User_input
	#Comp_input
	lb  $s0, board($t3) #check position 4 
	beq $s0, $t9, sm2
	lb  $s0, board($t4) #check position 5 
	beq $s0, $t9, go6
	jr $ra
	     go6:
	     	li $t4, 63 
	     	lb $t9, User_input
		lb  $s0, board($t4) #check position 61 
		beq $s0, $t9, see_4empty
		jr $ra
	     see_4empty:
	     	li $t5, 59
		lb  $s0, board($t5) #check position 3 
		beq $s0, ' ', block_4
		jr $ra
	     block_4:
	     	addi $t5, $zero, 59
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
	     sm2:
	     	li $t4, 61 
	     	lb $t9, User_input
		lb  $s0, board($t4) #check position 61 
		beq $s0, $t9, cnc_empty6
		jr $ra
             cnc_empty6:
             	li $t5, 63
		lb  $s0, board($t5) #check position 3 
		beq $s0, ' ', take_move_6
		jr $ra
	     take_move_6:
		addi $t5, $zero, 63
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
#--------------
smart_move3:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb $t9, User_input
	#Comp_input
	lb  $s0, board($t6) #check position 7 
	beq $s0, $t9, sm3
	jr $ra
	     sm3:
	     	li $t7, 111 
	     	lb $t9, User_input
		lb  $s0, board($t7) #check position 8 
		beq $s0, $t9, cnc_empty9
		li $t7, 61 
		lb  $s0, board($t7) #check position 5 
		beq $s0, $t9, cnc_empty13
		jr $ra
	        cnc_empty13:
             	li $t8, 13
		lb  $s0, board($t8) #check position 3 
		beq $s0, ' ', take_move_13
		jr $ra
		take_move_13:
		addi $t5, $zero, 13
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
             cnc_empty9:
             	li $t8, 113
		lb  $s0, board($t8) #check position 9 
		beq $s0, ' ', take_move_9
		jr $ra
	     take_move_9:
		addi $t5, $zero, 113
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
#-------------
look_ahead1:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb $t9, Comp_input
	#User_input 
	lb  $s0, board($t0) #check position 1 
	beq $s0, $t9, lookat2
	lb  $s0, board($t1) #check position 2 
	beq $s0, $t9, lookat3
	jr $ra
	lookat3:
		li $t7, 13 
	     	lb $t9, Comp_input
		lb  $s0, board($t7) #check position 2 
		beq $s0, $t9, nextlookat1
		jr $ra
	nextlookat1:
		li $t8, 9
		lb  $s0, board($t8) #check position 2 
		beq $s0, ' ', put_lookahead_1
		jr $ra
	 put_lookahead_1:
	 	addi $t5, $zero, 9
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
	lookat2:
	        li $t7, 11 
	     	lb $t9, Comp_input
		lb  $s0, board($t7) #check position 2 
		beq $s0, $t9, nextlookat3
		li $t7, 13 
		lb  $s0, board($t7) #check position 3 
		beq $s0, $t9, nextlookat2
		jr $ra
	nextlookat2:
             	li $t8, 11
		lb  $s0, board($t8) #check position 2 
		beq $s0, ' ', put_lookahead_2
		jr $ra
	nextlookat3:
             	li $t8, 13
		lb  $s0, board($t8) #check position 9 
		beq $s0, ' ', put_lookahead_3
		jr $ra	
	put_lookahead_3:
		addi $t5, $zero, 13
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
	put_lookahead_2:
		addi $t5, $zero, 11
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
#-------------
look_ahead2:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb $t9, Comp_input
	#User_input 
	lb  $s0, board($t3) #check position 4 
	beq $s0, $t9, lookat5
	lb  $s0, board($t4) #check position 5 
	beq $s0, $t9, lookat6
	jr $ra
	lookat6:
	        li $t7, 63 
	     	lb $t9, Comp_input
		lb  $s0, board($t7) #check position 5 
		beq $s0, $t9, nextlookat4
		jr $ra
	nextlookat4:
	        li $t8, 59
		lb  $s0, board($t8) #check position 2 
		beq $s0, ' ', put_lookahead_4
		jr $ra	
	put_lookahead_4:
	        addi $t5, $zero, 59
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
	lookat5:
	        li $t7, 61 
	     	lb $t9, Comp_input
		lb  $s0, board($t7) #check position 5 
		beq $s0, $t9, nextlookat6
		li $t7, 13 
		lb  $s0, board($t7) #check position 3 
		beq $s0, $t9, nextlookat2
		jr $ra
	nextlookat6:
             	li $t8, 63
		lb  $s0, board($t8) #check position 2 
		beq $s0, ' ', put_lookahead_6
		jr $ra
	put_lookahead_6:
		addi $t5, $zero, 63
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
#---------
look_ahead3:
	li $t0, 9
	li $t1, 11
	li $t2, 13
	li $t3, 59
	li $t4, 61
	li $t5, 63
	li $t6, 109
	li $t7, 111
	li $t8, 113
	lb $t9, Comp_input
	#User_input 
	lb  $s0, board($t6) #check position 7 
	beq $s0, $t9, lookat7
	lb  $s0, board($t7) #check position 8 
	beq $s0, $t9, lookat6
	jr $ra
		lookat7:
	        li $t7, 111 
	     	lb $t9, Comp_input
		lb  $s0, board($t7) #check position 8 
		beq $s0, $t9, nextlookat9
		
		li $t7, 61 
		lb  $s0, board($t7) #check position 5 
		beq $s0, $t9, nextlookat3vert
		jr $ra
		nextlookat3vert:
		li $t8, 13
		lb  $s0, board($t8) #check position 2 
		beq $s0, ' ', put_lookahead_3vert
		jr $ra
		put_lookahead_3vert:
                addi $t5, $zero, 13
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
		nextlookat9:
		li $t8, 113
		lb  $s0, board($t8) #check position 2 
		beq $s0, ' ', put_lookahead_9
		jr $ra
		put_lookahead_9:
	        addi $t5, $zero, 113
		lb $t6, Comp_input
		sb $t6, board($t5) #print user input into the board
		la $a0, board
		li $v0, 4
		syscall
		j cont
