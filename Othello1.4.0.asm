#The University of Texas at Dallas, SE3340.501:Computer Architecture, Fall 2017.
#Team Project: Implementing a playable Othello game, which is player vs. computer
#Contributors: Ryan Desmond, Masahiro Yoshida, Abdu Ghulam
.data

opening: 					.asciiz 	"Rolling for who goes first...\n"
playerFirstText: 			.asciiz 	"You go first!\n"
computerFirstText: 			.asciiz 	"The computer goes first!\n"

playerTurnMessage:			.asciiz 	"\nPlayer turn."
computerTurnMessage:		.asciiz 	"\nComputer turn."

computerPlaceCornerMessage:	.asciiz 	"\nComputer placed a piece on corner!!"
computerPlaceMessage:		.asciiz 	"\n...."
playerColor: 				.word 		0x000000
computerColor:				.word 		0x000000
playerColorText:			.asciiz 	"Your color is "
computerColorText:			.asciiz 	"Computer color is "
colorRed:					.asciiz 	"red\n"		#as white
colorBlue:					.asciiz		 "blue\n"	#as black
input_preword1:				.asciiz 	"\nEnter a column letter (A-H): "
input_preword2: 			.asciiz 	"\nEnter a row number (1-8): "

direction:					.word -17, -16, -15, -1, 1, 15, 16, 17
#this one below holds valid moves for the given player on the given board
validMoves:					.space  100		#array of 25 words(decent amount) to hold addresses which is valid and can flip opponent tiles
#this one below holds tiles that can flip by one valid inpud 
tilesToFlip:				.space  100		#array of 25 words(decent amount) to hold addresses which is opponent color and can be flipped by current color
messageChangeTurn:  		.asciiz		 "\nThere's no valid moves. The current turn is over.\n"
messageInputInvalid:		.asciiz 	"The input is invalid! Enter your input again!\n"

onCorner:					.word	68, 75, 180, 187	#for computer move, this is decimal number, array number

ERRORMSG_WRONG_COLUMN_CHAR: .asciiz		"\n\nInvalid Character.\n"
ERRORMSG_WRONG_ROW_INT: 	.asciiz 	"\nInvalid number.\n"

messageGameOver:			.asciiz 	"\nThere's no place for both player and computer to be able to place your pieces on! \nThe game is over!!"
messageNumOfPlayerTile:		.asciiz		"\nThe number of player tiles are: "
messageNumOfComputerTile:	.asciiz 	"\nThe number of computer tiles are: "
messageWinnerPlayer:		.asciiz		"\nThe winner is player! Congratulation!!"
messageWinnerComputer:		.asciiz 	"\nThe winner is computer. Try again!!"
messageGameDraw:			.asciiz 	"\nThe game is draw."

.text
main:
	
	#load board
	jal loadBoard
	
	#start game
	j beginGame
	#this will choose who goes first and ask whoever goes first gives prompt message
	#and works until the game is over and close the program
	
	
loadBoard:	#implemented by Ryan Desmond
	#save address of caller to go back
	addi $sp, $sp, -4       #adjust $sp, allocate 1 word on the stack
	sw $ra, 0($sp)		#save $t0 temporaly for jumping method
	
	
	li $s0, 0x0000ff	#blue tile as black
	li $s1, 0xff0000	#red tile as white 
	li $s2, 0x00ff00	#initialized with '_', green color
	
#################################################################################################
#	Load Board Function: creates a fresh version of the Reversi board, starting at $gp	#
#################################################################################################
#	Inputs : null										#
#################################################################################################
#	Outputs: null										#
#################################################################################################
	li   $t0, 0			#in-row index counter 
	add  $a1, $t0, $gp
	addi $a1, $a1, -4
	jal DrawEmptyRow
	jal DrawEmptyRow
	jal DrawEmptyRow
	jal DrawEmptyRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawPlayRow
	jal DrawEmptyRow
	jal DrawEmptyRow
	jal DrawEmptyRow
	jal DrawEmptyRow
	j DrawStartPieces	
	
	DrawEmptyRow:
		la $a2, ($zero)
		li $t0, 0
		la $v0, ($ra)
	DrawEmptyLoop:
		addi $a1, $a1, 4
		jal drawPixel
		addi $t0, $t0, 1
		bne  $t0, 16, DrawEmptyLoop
		la   $ra, ($v0)
		jr   $ra
	
	DrawPlayRow:
		la $a2, ($zero)
		li $t0, 0
		la $v0, ($ra)
	DrawEmptySquare:
		addi $a1, $a1, 4
		jal  drawPixel
		addi $t0, $t0, 1
		bne  $t0, 4, DrawEmptySquare
		la  $a2, ($s2)
	DrawPlayLoop:
		addi $a1, $a1, 4
		jal  drawPixel
		addi $t0, $t0, 1
		bne  $t0, 12, DrawPlayLoop
		la   $a2, ($zero)
	DrawEmptySquares:
		addi $a1, $a1, 4
		jal  drawPixel
		addi $t0, $t0, 1
		bne  $t0, 16, DrawEmptySquares
		la   $ra, ($v0)
		jr   $ra
	

	#The empty board is now drawn, but needs to be initialized with starting pieces in middle
	DrawStartPieces:			#offset at index 135 and 120 are white indexes 136 and 119 are black
		la  $a2, ($s1)			#load $a2, the paintbrush, as the color red(white)
		li  $t1, 119			#set $t1 to the index of 44
		sll $t1, $t1, 2			#multiply that index by 4
		add $a1, $t1, $gp		#set the coordinate $a1 to the $gp plus the memory offset
		jal drawPixel
		li  $t1, 136			#set $t1 to the index of 55
		sll $t1, $t1, 2			#multiply that index by 4
		add $a1, $t1, $gp		#set the coordinate $a1 to the $gp plus the memory offset
		jal drawPixel
	
		la  $a2, ($s0)			#load $a2, the paintbrush, as the color blue(black)
		li  $t1, 120			#set $t1 to the index of 45
		sll $t1, $t1, 2			#multiply that index by 4
		add $a1, $t1, $gp		#set the coordinate $a1 to the $gp plus the memory offset
		jal drawPixel
		li  $t1, 135			#set $t1 to the index of 54
		sll $t1, $t1, 2			#multiply that index by 4
		add $a1, $t1, $gp		#set the coordinate $a1 to the $gp plus the memory offset
		jal drawPixel
		#The board is now ready for a game to begin.
	
	#call back register address
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
	drawPixel:	#takes address in $a1 and color in $a2
		sw $a2, ($a1)
		jr $ra	
	
beginGame:	#implemented by Ryan Desmond
	li $s0, 0x0000ff	#blue tile as black
	li $s1, 0xff0000	#red tile as white 
	li $s2, 0x00ff00	#initialized with '_', green color
	
	li $v0, 4
	la $a0, opening
	syscall			#Open with a randomisation on who goes first
	
	li $v0, 41
	syscall			#call a random int, stored in $a0
	and $t0, $a0, 1		#mask only the first bit. This gives us a value of 0 or 1; a boolean.
	beq $t0, 1, playerFirst	#if $t0 is 1, then the player goes first, and is assigned the blue(black) tile.
	
	computerFirst:
		li $v0, 4
		la $a0, computerFirstText
		syscall			#tell the user that the computer will go first
		sw $s1, playerColor	#set the player color to red
		li $v0, 4
		la $a0, playerColorText
		syscall
		li $v0, 4
		la $a0, colorRed
		syscall
		sw $s0, computerColor	#set the computer's color to black	
		li $v0, 4
		la $a0, computerColorText
		syscall
		li $v0, 4
		la $a0, colorBlue
		syscall
		j computerTurn		#let the computer make the first move
	
	playerFirst:
		li $v0, 4
		la $a0, playerFirstText
		syscall			#tell the user that the player will go first
		sw $s0, playerColor	#set the player color to black
		li $v0, 4
		la $a0, playerColorText
		syscall
		li $v0, 4
		la $a0, colorBlue
		syscall
		sw $s1, computerColor	#set the computer's color to white
		li $v0, 4
		la $a0, computerColorText
		syscall
		li $v0, 4
		la $a0, colorRed
		syscall
		
		j playerTurn		#let the player make the first turn	
		
playerTurn:		#implemented by Masahiro Yoshida
	li $v0, 4
	la $a0, playerTurnMessage
	syscall	
	
	li $s0, 0x0000ff	#blue tile as black
	li $s1, 0xff0000	#red tile as white 
	li $s2, 0x00ff00	#initialized with '_', green color
	#ask user input
	askUserInput:
	#set arguments to player's turn
		lw $a1, playerColor			#$a1 holds color
		li $a2, 0					#0 as player turn
	
		#set current tile and opponent color
		move $s3, $a1
		lw   $s4, computerColor
		
		jal getValidMoves			#get valid moves and check game over condition before it asks player input
		
		jal askUserInputPrompt			#$v0 holds adjusted input number
	
	#check whether the input is valid
	move $a0, $v0
	jal  checkInputIsValid					
	#if the input is invalid, checkInputIsValid function asks user input again(jump to askUserInput)
	#if the input is valid, $v0 holds the valid input
	move $a0, $v0
	jal  storeTilesToFlip		#to get tiles to flip
	jal  flipTiles				#flip tiles stored 
	
	jal soundValid
	#player turn ends
	j computerTurn
	
computerTurn:	#implemented by Masahiro Yoshida
	li $v0, 4
	la $a0, computerTurnMessage
	syscall	
	li $s0, 0x0000ff	#blue tile as black
	li $s1, 0xff0000	#red tile as white 
	li $s2, 0x00ff00	#initialized with '_', green color
	#set arguments to player's turn
	lw $a1, computerColor			#$a1 holds color
	li $a2, 1						#1 as computer turn
	
	#set current tile and opponent color
	move $s3, $a1
	lw   $s4, playerColor
	
	jal isOnCorner
	#after executing isOnCorner, $v0 holds whether
	#0 as no corner is available
	#address as the corner is available
	#if the corner is available, place the piece onto corner, which is strong move in othello
	bne $v0, $zero, placeOnCorner
	jal getValidMoves		#if there's no valid moves, this will change the turn to player
	#there's at least one vaild move for computer
	#validMoves holds valid address in ascending order, which is BORING
	jal randomlySelect
	#$v0 holds address of randomly selected validMoves[K]
	move $a0, $v0
	jal  storeTilesToFlip
	jal  flipTiles
	
	li $v0, 4
	la $a0, computerPlaceMessage
	syscall
	
	j    playerTurn
	
	
		
getValidMoves:	#implemented by Masahiro  Yoshida
#check all address of boardArray if each address is valid using isValid
#return array of validMoves

	#save address of caller to go back
	la $v1, ($ra)
	
	#initialize array of validMoves with all elements 0
	move $t0, $zero		#initialize i = 0
	loopValidMoves_init_:
		sw   $zero, validMoves($t0)	#store 0 to validMoves[i]
		addi $t0, $t0, 4			#i++
		bne  $t0, 100, loopValidMoves_init_	#until it initializes all elements, keep doing
	
	#check [0,63], adjusted by adjust0To64ToBoard
	move $t0, $zero					#initialize i = 0
	move $t7, $zero					#initialize j = 0
	loopValidMoves:
		move $a0, $t0
		addi $t0, $t0, 1			#i++
		beq  $t0, 64,  returnValidMoves
		jal  adjust0To64ToBoard		#adjust number for 16 by 16, $v0 holds adjusted number
		move $t1, $v0
		sll  $t1, $t1, 2			#adjust word size
		add  $t1, $t1, $gp
		lw   $t2, ($t1)				#check element of board[i]
		#if this contains any tiles regardless of color, skip checking by isValid
		addi $t6, $t6, 1			#increment by 1
		bne  $t2, $s2, loopValidMoves
		subi $t6, $t6, 1			#decrement by 1 since there exists empty place
		#else check isValid
		move $a0, $t1
		jal  isValid
		#$v0 contains address if this is valid
		beq  $v0, $zero, loopValidMoves	#branch if $v0 contains 0 meaning invalid move
		#store $v0 into array of validMoves
		sw   $v0, validMoves($t7)	#store into validMoves[j]
		addi $t7, $t7, 4			#j++
		j loopValidMoves
		
	returnValidMoves:
		#if the counter $s6 for gameOver is 64, meaning there's no empty elements, branch gameOver
		beq $s6, 64, gameOver
		jal checkNoValidMoves
	
	#meaning there's at least one valid move
	#call back register address
	la $ra, ($v1)
	jr $ra
	
					
	checkNoValidMoves:	
		#this function checks if there's valid moves in current turn
		#that is, the first element of validMoves determines whether there's valid moves 
		#if no, then skip current turn
		#$a2 holds whose turn it is currently, 0 as player and 1 as computer
		lw   $t1, validMoves($zero)
		beq  $t1, $zero, changeTurn
		move $s7, $zero 		#reinitiate
		jr   $ra
		changeTurn: 
			addi $s7, $s7, 1		#count up how many times there is no valid moves. if 2, meaning both players don't have valid moves
			beq  $s7, 2, gameOver	#if the game over counter $s7 == 2, game is over
			addi $sp, $sp, 4	#adjust stack pointer 
			li $v0, 4
			la $a0, messageChangeTurn
			syscall
			beq $a2, $zero, computerTurn	#current player is user; change turn to computer
			j playerTurn
	
askUserInputPrompt:		#implemented by Ryan Desmond
	#save address of caller to go back
	addi $sp, $sp, -12      #adjust $sp, allocate 3 words on the stack
	sw 	 $ra, 0($sp)		#save $t0 temporarily for jumping method
	sw 	 $a1, 4($sp)		#save $a1 temporarily for syscall reset
	sw   $a2, 8($sp)		#save $a2 temporarily for syscall reset
	
	askColumn:	
		li $v0, 4
		la $a0, input_preword1
		syscall				#ask the user for a column letter
		
		li $v0, 12			#read a char
		syscall		
		move $t0, $v0			#save the column character to $t0
		
		blt $t0, 97, skipToUpper	#check if the character is outside the lowercase letter asciis
	toUpper:	
		subi $t0, $t0, 32		#change the lowercase letter to uppercase. There will be some cases where it is a bracket(123,125) or dash(126) but this will be caught by the A-H range check
	skipToUpper:
		blt $t0, 'A', errorColumn
		bgt $t0, 'H', errorColumn	#parse the input to make sure it is an uppercase letter A-H
		
	askRow:		
		li  $v0, 4
		la  $a0, input_preword2
		syscall				#ask the user for a row number
		
		li  $v0, 5
		syscall				#read an int
		la  $t1,($v0)			#save the row int to $t1
		blt $t1, 1, errorRow
		bgt $t1, 8, errorRow		#parse row input to make sure it is within bounds (integer 1-8)
		
	inputToAddress:	
		sll $t1, $t1, 4			#multiply the row value by 16 (16 elements per row)
		addi $t1, $t1, 48		#add 48 to the result, so as to avoid the empty rows
		subi $t0, $t0, 61		#change the ascii char to an integer value directly related to the rank of the letter
		add $t0, $t0, $t1		#add the row and column offsets

#		subi $t0, $t0, 60		#change the character ascii to the column number
#		li $t2, 16			#set $t2 to 16, the width of the playfield
#		mult $t1, $t2			#multiply the row number by 16
#		mflo $t1			#$t1 contains the previous t1 multiplied by 16 (16, 32,... 128): Therefore, no need to regard the hi register.
#		add $t0, $t0, $t1		#$t0 now contains the grid number of the location the player entered
		sll $t0, $t0, 2			#$t0 now has the address shift with regard to the base of the board array
		
		add $v0, $t0, $gp		#set $v0 to the address of the particular board square
		
		#call back register address, restore values in stack pointer
		lw   $ra, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $sp, $sp, 12
		jr   $ra

	errorColumn:
		la $a0, ERRORMSG_WRONG_COLUMN_CHAR
		li $v0, 4
		syscall
		j askColumn
	errorRow:
		la $a0, ERRORMSG_WRONG_ROW_INT
		li $v0, 4
		syscall
		j askRow		
		

adjust0To64ToBoard:		#implemented by Masahiro Yoshida
	#adjust any numbers generated by random to correct position of array
	#68 is left-top corner, 75 is right-top corner, 183 is left-bottom corner, and 190 is right-bottom corner
	#any number from [0, 63] in 8 by 8 board should be converted the center 8 by 8 in 16 by 16 board
	#[0,7] => [68,75], [8,15] => [84,91], [16,23] => [100,107], [24,31] => [116,123]
	#[32,39] => [132,139], [40,47] => [148,155], [48,55] => [164,171], [56,63] => [180,187]
	
	#$a0 contains the random generated number, $v0 returns the converted number
	#assertion: this number isn't bigger than 64
	bgt $a0, 64, error 
	blt $a0, 8, lessThan8
	blt $a0, 16, lessThan16
	blt $a0, 24, lessThan24
	blt $a0, 32, lessThan32
	blt $a0, 40, lessThan40
	blt $a0, 48, lessThan48
	blt $a0, 56, lessThan56
	blt $a0, 64, lessThan64
	
	error:
		#ask again
		beq $a2, $zero, askUserInput
		j computerTurn
	lessThan8:
		add $v0, $a0, 68
		jr $ra
	lessThan16:
		add $v0, $a0, 76
		jr $ra
	lessThan24:
		add $v0, $a0, 84
		jr $ra
	lessThan32:
		add $v0, $a0, 92
		jr $ra
	lessThan40:
		add $v0, $a0, 100
		jr $ra
	lessThan48:
		add $v0, $a0, 108
		jr $ra
	lessThan56:
		add $v0, $a0, 116
		jr $ra
	lessThan64:
		add $v0, $a0, 124
		jr $ra
		
isValid:  	#implemented by Masahiro Yoshida
#save counter for caller
	addi $sp, $sp, -12      #adjust $sp, allocate 3 words on the stack
	sw 	 $t0, 0($sp)		
	sw 	 $t6, 4($sp)		
	sw   $t7, 8($sp)	
#$a0 contains the address of input in board
#$a1 contains the tile's color of current player
#$a2 contains which turn currently playing, 0 as player and 1 as computer turn
#$v0 contains 0 if this is not valid, or address of input if this is valid
#assert(boardArray is initialized with '_' or 0x5F except for out of bounds, which are initialized 0x00)

	li $s0, 0x0000ff	#blue tile as black
	li $s1, 0xff0000	#red tile as white 
	li $s2, 0x00ff00	#initialized with '_', green color

#--------------------------------------------------------------------------
#subnote 
#$t0:element in input address
#$t1:input address + direction
#$t2:
#$t3:i counter for address of direction array
#$t4:
#$t5:element of direction address[i]
#$t6:element of $t1
#$t7:
#$t8:
#$t9:counter for storing addresses in tilesToFlip
#$s0:black tile
#$s1:white tile
#$s2:empty(green)
#$s3:current tile
#$s4:other tile
#$s5:
#$s6:counter to save address in validMoves 
#$s7:
#--------------------------------------------------------------------------

		  #inplemented by Masahiro Yoshida
		  #check if the move is valid
		  #return false if the move is invalid, set boolean value false(0) at first
		  #if this move is valid, hold addresses of flippable tiles in array
		  #and return the address of valid input
	#set boolean value false(0) at first into $v0
	move $v0, $zero
	
	#branch if there has been placed anything or out of bound in input address
	lw  $t0, ($a0)
	bne $t0, $s2, returnIsValid
		
	move $t3, $zero				#initialize i = 0 for direction
	move $t9, $zero				#initialize j = 0 for storing addresses in tilesToFlip
	forDirection:	#check each direction
		beq  $t3, 32, returnIsValid		#if i > 32, meaning it has checked all direction, branch 
		lw   $t5, direction($t3)	#element of address of direction[i]
		sll  $t5, $t5, 2			#adjust to a word size
		add  $t1, $a0, $t5			#$t1 = address of input + direction[i]
		lw   $t6, ($t1)				#element of $t1
		addi $t3, $t3, 4			#i++
		bne  $t6, $s4, forDirection	#if element of A isn't the other tile, back to loop and check next direction
		#there is a piece belonging to the other player next to our piece

		whileDirection:	
		#while $t6 == other tile, keep moving next
		#if it hits out of bound, break out of while loop, and then continue in for loop
		#if $t6 == current tile, there are pieces to flip over	
		add $t1, $t1, $t5			#A = A + direction[i]
		lw  $t6, ($t1)
		beq $t6, $zero, forDirection	#if the $t1 is out of bound, then go for loop 
		beq $t6, $s4, whileDirection	#if element of A is other tile, go while loop to check next element
		beq $t6, $s2, forDirection		#if element of A is empty, go for loop to check next direction
		#element of A is current tile, meaning there's pieces to flip over
		#set $v0 to address of input, meaning valid move
		move $v0, $a0
			
	returnIsValid:	#inplemented by Masahiro Yoshida
		#call back counter in stack pointer
		lw   $t0, 0($sp)
		lw   $t6, 4($sp)
		lw   $t7, 8($sp)
		addi $sp, $sp, 12
		#this move is valid, $v0 holds valid input address
		#if this move is invalid, $v0 keeps holding 0
		jr $ra

storeTilesToFlip:		#implemented by Masahiro Yoshida
#mostly same function as isValid, however, this stores tiles to flip
	
#$a0 contains the address of valid input in board
#$a1 contains the tile's color of current player
#$a2 contains which turn currently playing, 0 as player and 1 as computer turn
#assert(boardArray is initialized with '_' or 0x5F except for out of bounds, which are initialized 0x00)

	li $s0, 0x0000ff	#blue tile as black
	li $s1, 0xff0000	#red tile as white 
	li $s2, 0x00ff00	#initialized with '_', green color

#--------------------------------------------------------------------------
#subnote 
#$t0:element in input address
#$t1:input address + direction
#$t2:
#$t3:i counter for address of direction array
#$t4:
#$t5:element of direction address[i]
#$t6:element of $t1
#$t7:
#$t8:
#$t9:counter for storing addresses in tilesToFlip
#$s0:black tile
#$s1:white tile
#$s2:empty(green)
#$s3:current tile
#$s4:other tile
#$s5:
#$s6:counter to save address in validMoves 
#$s7:
#--------------------------------------------------------------------------

		  #inplemented by Masahiro Yoshida
		  #hold addresses of flippable tiles in array

		  	
	#initialize array of tilesToFlip with all elements 0
	move $t0, $zero		#initialize i = 0
	loopTilesToFlip_init_:
		sw   $zero, tilesToFlip($t0)	#store 0 to array[i]
		addi $t0, $t0, 4				#i++
		bne  $t0, 100, loopTilesToFlip_init_	#until it initialize all elements, keep doing
		
	move $t3, $zero				#initialize i = 0 for direction
	move $t9, $zero				#initialize j = 0 for storing addresses in tilesToFlip
	forDirectionStoreTilesToFlip:	#check each direction
		beq  $t3, 32, returnStoreTilesToFlip		#if i > 28, meaning it has checked all direction, branch
		lw   $t5, direction($t3)	#element of address of direction[i]
		sll  $t5, $t5, 2			#adjust to a word size
		add  $t1, $a0, $t5			#$t1 = address of input + direction[i]
		lw   $t6, ($t1)				#element of $t1
		addi $t3, $t3, 4			#i++ 
		bne  $t6, $s4, forDirectionStoreTilesToFlip	#if element of A isn't the other tile, back to loop and check next direction
		#there is a piece belonging to the other player next to our piece

		whileDirectionStoreTilesToFlip:	
		#while $t6 == other tile, keep moving next
		#if it hits out of bound, break out of while loop, and then continue in for loop
		#if $t6 == current tile, there are pieces to flip over	
		add $t1, $t1, $t5			#A = A + direction[i]
		lw  $t6, ($t1)
		beq $t6, $zero, forDirectionStoreTilesToFlip	#if the $t1 is out of bound, then go for loop 
		beq $t6, $s4, whileDirectionStoreTilesToFlip	#if element of A is other tile, go while loop to check next element
		beq $t6, $s2, forDirectionStoreTilesToFlip		#if element of A is empty, go for loop to check next direction
		#element of A is current tile, meaning there's pieces to flip over
		loopStoreTilesToFlip:
			sub  $t1, $t1, $t5					#this address contains of other tile
			beq  $t1, $a0, forDirectionStoreTilesToFlip			#if address goes back to input address, back to check the next direction
			sw   $t1, tilesToFlip($t9)			#store the address to flip in tilesToFlip[j]
			addi $t9, $t9, 4					#j++
			j loopStoreTilesToFlip					#back to flipOver loop to check next address, until it reach the original address
			
	returnStoreTilesToFlip:	#inplemented by Masahiro Yoshida
		jr $ra
		
flipTiles:		#implemented by Masahiro Yoshida
	#tilesToFlip holds address whose tiles can be flipped by the argument address $a0
	#until it reaches 0, keep changing the color of tile
	#$a0 contains address of input
	#$a1 contains color of tile
	move $t0, $zero		#initialize i = 0 
	flipOver:
		lw 	 $t1, tilesToFlip($t0)		#load address whose tiles can be flipped
		beq  $t1, $zero, placeInputPiece #if it reaches 0, finally place the tiles in input address
		sw   $a1, ($t1)					#store the color of current player tile
		addi $t0, $t0, 4				#i++
		j flipOver						#keep doing
		placeInputPiece:
			#finally place the current color tile to input address
			sw $a1, ($a0)
			jr $ra			#return back to caller

checkInputIsValid:	#implemented by Masahiro Yoshida
	la $s5, ($ra)
	#$a0 holds user input. 
	#if the validMoves doesn't include the input address, then obviously this isn't valid move	
	#if there's valid moves for player, ask user input
	#if there's no valid moves, this will change the turn to computer
	move $t0, $zero
	loopInputIsValid:
		lw   $t1, validMoves($t0)
		addi $t0, $t0, 4
		beq  $t1, $zero, returnInputIsValid		#branch if there's no more valid moves in validMoves
		bne  $t1, $a0, loopInputIsValid
		#user input is valid
		#return $v0 as address of valid move
		la   $ra, ($s5)
		move $v0, $a0
		jr   $ra
		
	returnInputIsValid:
		#this input is invalid
		#ask user again
		li $v0, 4
		la $a0, messageInputInvalid
		syscall
		
		jal soundInvalid
		
		j askUserInput
		
isOnCorner:		#implemented by Masahiro Yoshida
	#save address of caller to go back
	addi $sp, $sp, -4       #adjust $sp, allocate 1 word on the stack
	sw 	 $ra, 0($sp)		#save $t0 temporaly for jumping method
	
	#this function checks whether any corner is available
	#if yes, return the address of corner in $v0
	#this function is used on computer turn
	move $v0, $zero
	move $t0, $zero				#initialize i = 0 for counter onCorner
	loopIsOnCorner:
		beq  $t0, 16, returnIsOnCorner		#isOnCorner is false
		lw   $t1, onCorner($t0)				#$t2 contains the onCorner[i]
		sll  $t1, $t1, 2					#adjust to word address
		add  $a0, $gp, $t1					#address of corner
		addi $t0, $t0, 4					#i++
		jal  isValid						#check if this address is valid, $v0 contains result
		bne  $v0, $zero, returnIsOnCorner	#branch if the result is valid input
		j    loopIsOnCorner
		
	returnIsOnCorner:
		#call back register address
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		#$v0 contains the result of this function, 0 as no corner is available, address as available corner
		jr $ra

placeOnCorner:		#implemented by Masahiro Yoshida
	#place a computer piece on corner, and change turn	
	move $a0, $v0
	jal  storeTilesToFlip		#to get tilesToFlip
	jal  flipTiles
	
	li $v0, 4
	la $a0, computerPlaceCornerMessage
	syscall
	j playerTurn
		
randomlySelect:
	#save address of caller to go back
	addi $sp, $sp, -4       #adjust $sp, allocate 1 word on the stack
	sw 	 $ra, 0($sp)		#save $t0 temporaly for jumping method
	
	#this randomly selects a number: J
	#count the number of elements in validMoves: I
	#mod the number of elements in validMoves by the number: K = I % J
	#return $v0 as validMoves[K]
	jal  generateRandomNumber
	move $t0, $v0
	
	move $t1, $zero			#initialize i = 0
	forCountValidMoves:
		addi $t1, $t1, 4					#assert that validMoves contains at least one valid address, so can ignore the first element 
		lw   $t3, validMoves($t1)			#validMoves[i]
		bne  $t3, $zero, forCountValidMoves 
		subi $t1, $t1, 4
		srl  $t1, $t1, 2		#the number of elements in validMoves
		
	div  $t1, $t0	#HI = $t1 mod $t0
	mfhi $t2
	sll  $t2, $t2, 2		  	#word size
	lw   $v0, validMoves($t2)	#validMoves[K]
	
	#call back register address
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
	generateRandomNumber:
		la $t3, ($a1)
		la $t4, ($a2)
		#this generates number[0,5] randomly
		#-------------------------------------------------------
		#seed the random number generator
		li $v0, 30		#64 bits of system time
		syscall
		#$a0 contains low order, $a1 contains high order
		move $t0, $a0	#save the lower 32-bits of time
	
		#seed the random generator, just once 
		li   $a0, 1		#random generator i.d.
		move $a1, $t0	#seed from time
		li   $v0, 40		#seed random number generator syscall
		syscall
		#---------------------------------------------------------		
		li $a0, 1 	#i.d. is same as random generator i.d.
		li $a1, 6	#upper bound.
		li $v0, 42
		syscall
	
		la $a1, ($t3)
		la $a2, ($t4)
		#$a0 holds the random number	
		move $v0, $a0
		jr $ra
	
gameOver:		#implemented by Masahiro Yoshida
	#this function checks whether the game is over, meaning it is possible for neither player to be able to make a move
	#condition of game over: 1.all 64 pieces are filled
	#						 2.all pieces on the board is either color: https://www.youtube.com/watch?v=6ehiWOSp_wk
	#						 3.there's no piece to place for both player and computer: https://i.stack.imgur.com/tgxGl.png
	
	#valid moves for both player and computer are empty in row, 
	#for example, no valid moves for player and change turn to computer, then no valid moves for computer
	#this satisfies all condition 2-3
	#$s7 counts the number how many times no valid moves executed in row
	#reset anytime after there exists at least one valid move
	#in isValid function, reset $s7 to 0 in returnIsValid, and increment by 1 in askInputTurn
	#if the counter is 2, then the game is over
	
	#conditin 1 is also checked by getValidMoves since it checks all addresses of board
	#increment by 1 before "bne  $t2, $s2, loopValidMoves" #if this contains any tiles regardless of color, skip checking by isValid
	#and decreent by 1 if there doesn't contain tile, which means not filled yet
	
	li $v0, 4
	la $a0, messageGameOver
	syscall
	
	j getScore	

getScore:	#implemented by Masahiro Yoshida
	#get the number of each color pieces 
	lw $t8, playerColor
	lw $t9, computerColor

	move $t0, $zero		#counter [0,63]
	move $t3, $zero		#counter for # of playerColor
	move $t4, $zero 	#counter for # of computerColor
	loopGetScore:
		move $a0, $t0
		addi $t0, $t0, 1			#i++
		beq  $t0, 64,  returnGetScore
		jal  adjust0To64ToBoard		#adjust number for 16 by 16, $v0 holds adjusted number
		move $t1, $v0
		sll  $t1, $t1, 2			#adjust word size
		add  $t1, $t1, $gp
		lw   $t2, ($t1)	#check elements of board[i]
		beq  $t2, $t8, addPlayerColor
		beq  $t2, $t9, addComputerColor
		#at this point $t2 has to be empty
		j loopGetScore
		
	addPlayerColor:	
		addi $t3, $t3, 1
		j loopGetScore
		
	addComputerColor:
		addi $t4, $t4, 1
		j loopGetScore
		
	returnGetScore:
		beq $t3, $t4, gameDraw
		slt $t5, $t3, $t4		#if the player wins, set $t5 0. if the computer wins, set $t5 1

		li $v0, 4
		la $a0, messageNumOfPlayerTile
		syscall
		
		li $v0, 1
		move $a0, $t3
		syscall
		
		li $v0, 4
		la $a0, messageNumOfComputerTile
		syscall
		
		li $v0, 1
		move $a0, $t4
		syscall
		
		
		beq $t5, $zero, playerWin
		j computerWin
		
		computerWin:	
			li $v0, 4
			la $a0, messageWinnerComputer
			syscall
			
			jal soundLose
			
			li $v0, 10
			syscall
			
		playerWin:
			li $v0, 4
			la $a0, messageWinnerPlayer
			syscall
			
			jal soundWin
			li $v0, 10
			syscall
		
		gameDraw:
			li $v0, 4
			la $a0, messageGameDraw
			syscall
			li $v0, 10


#implemented by Abdu Ghulam
#################################################################################################
#	Subroutines for Sound									#
#################################################################################################


#Plays sound after every move the player or computer makes
soundValid: 											
	addi $a0, $zero, 65 #Pitch: 65/127
	addi $a1, $zero, 1000 #Duration: 1000 milliseconds
	addi $a2, $zero, 14 #Instrument: Organ
	addi $a3, $zero, 100 #Volume 100/127

	addi $v0, $zero, 33 #Play tone and delay until tone completes 
	syscall
	jr $ra #return after sound plays
	
#Plays sound if a move is invalid
soundInvalid:
	addi $a0, $zero, 40 #Pitch: 40/127
	addi $a1, $zero, 1000 #Duration: 1000 milliseconds
	addi $a2, $zero, 80 #Instrument: Synth Lead
	addi $a3, $zero, 100 #Volume 100/127

	addi $v0, $zero, 33 #Play tone and delay until tone completes
	syscall
	jr $ra #return after sound plays
	
#Plays sound if Player won	
soundWin:
	addi $a0, $zero, 65 #Pitch: 65/127
	addi $a1, $zero, 5000 #Duration: 5000 milliseconds
	addi $a2, $zero, 24 #Instrument: Guitar
	addi $a3, $zero, 100 #Volume 100/127
	addi $v0, $zero, 31 #Play tone at every Syscall without delay
	syscall
	syscall

	addi $a2, $zero, 1 #Instrument: Piano
	syscall
	syscall
	syscall
	
	addi $a2, $zero, 26 #Instrument: Guitar
	addi $a0, $zero, 65 #Pitch: 65/127
	syscall
	syscall
	syscall
	
	
	addi $a2, $zero, 24 #Instrument: Guitar
	syscall
	
	
	
	
	
	
	jr $ra #return after sound plays

#Plays sound if Player lost
soundLose: 
	addi $a0, $zero, 62 #Pitch: 62/127
	addi $a1, $zero, 2000 #Duration: 2000 milliseconds
	addi $a2, $zero, 102 #Instrument: Synth Effects
	addi $a3, $zero, 100 #Volume 100/127

	addi $v0, $zero, 31 #Play tone at every Syscall without delay
	syscall
	syscall
	syscall
	
	addi $a0, $zero, 55 #Pitch: 55/127
	addi $a3, $zero, 80 #Volume: 80/127
	addi $a2, $zero, 1 #Instrument: Piano
	syscall
	syscall
	syscall
	
	jr $ra #return after sound plays
	

#################################################################################################
#	End Subroutines for Sound								#
#################################################################################################
