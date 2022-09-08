#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Xue Chengyuan, Student Number: 1007309994
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 5 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
######################################################################
.data
#backgroud colour
	displayAddress: .word 0x10008000
	woodAddress: .word 0x10018000
	vehicleAddress: .word 0x10028000
	goalAddress: .word 0x10048000
	riverColour: .word 0x0070ff
	safeColour: .word 0x9300ff
	goalColour: .word 0xffa500
	retryColour: .word 0xf0f8ff
#object colour
	frogColour: .word 0x00ff00
	woodColour: .word 0x4d3900
	vehicleColour: .word 0xff0000
	roadColour: .word 0x000000
	
	vehicleHeight: .word 2
	vehicleWidth: .word 3
	default_vehicle_y: .word 18
	vehicleNum: .word 10

	frogHeight: .word 2
	frogWidth: .word 2

	woodHeight: .word 2
	woodWidth: .word 4
	default_wood_y: .word 4
	woodNum: .word 10
	
	goalHeight: .word 3
	safeHeight: .word 2

	screenHeight: .word 32
	screenWidth: .word 32
#sound effect
	pitch: .byte 100 
	duration: .byte 80
	instrument: .byte 5
	volume: .byte 100
######################################################################

.text
main:
#initialization
score_init:
	li $s5, 0

frog_life_init:
	li $s4, 3

init:
	li $s3, 0
	li $s2, 0
	li $s6, 0

goal_init:
	lw $t0, goalAddress
	li $t1, 0
	li $t2, 0
	sh $t2, 0($t0)
	sh $t2, 2($t0)
	addi $t0, $t0, 4
	sh $t2, 0($t0)
	sh $t2, 2($t0)
	addi $t0, $t0, 4
	sh $t2, 0($t0)
	sh $t2, 2($t0)
	
#Draw background
draw_background:
	jal draw_score
	
Dynamic_difficulty_init:
	li $s6, 0	
#Initialize location
frog_init:
	lw $t0, displayAddress
	li $t1, 30
	
	jal get_random_number
	sh $a0, 0($t0)
	sh $t1, 2($t0)
	
	lh $s0, 0($t0)
	lh $s1, 2($t0)
	

vehicle_init:
	lw $t0, vehicleAddress
	lw $t1, vehicleNum
	lw $t2, default_vehicle_y
	li $t3, 0 
	
vehicle_generate_loop:
	addi $t2, $t2, 2
	jal get_random_number_2
	addi $t4, $a0, 0
	sh $t4, 0($t0)
	sh $t2, 2($t0)

	jal get_random_number_2
	add $t4, $t4, $a0
	addi $t3, $t3, 2
	addi $t0, $t0, 4
	
	sh $t4, 0($t0)
	sh $t2, 2($t0)
	
	addi $t0, $t0, 4
	blt $t3, $t1, vehicle_generate_loop

wood_init:
	lw $t0, woodAddress
	lw $t1, woodNum
	lw $t2, default_wood_y
	li $t3, 0 
	
wood_generate_loop_1:
	addi $t2, $t2, 4
	jal get_random_number_2
	addi $t4, $a0, 0
	sh $t4, 0($t0)
	sh $t2, 2($t0)

	jal get_random_number_2
	add $t4, $t4, $a0
	addi $t3, $t3, 2
	addi $t0, $t0, 4
	
	sh $t4, 0($t0)
	sh $t2, 2($t0)
	
	addi $t0, $t0, 4
	blt $t3, 6, wood_generate_loop_1

	li $t2, 6
	li $t3, 0
wood_generate_loop_2:
	addi $t2, $t2, 4
	jal get_random_number_2
	addi $t4, $a0, 0
	sh $t4, 0($t0)
	sh $t2, 2($t0)

	jal get_random_number_2
	add $t4, $t4, $a0
	addi $t3, $t3, 2
	addi $t0, $t0, 4
	
	sh $t4, 0($t0)
	sh $t2, 2($t0)
	
	addi $t0, $t0, 4
	blt $t3, 4, wood_generate_loop_2
	
			
#####################################################################
	li $s2, 0
	li $s3, 0
game_loop:
	lw $a1, vehicleColour
	jal draw_vehicle
	lw $a1, woodColour
	jal draw_wood
	lw $a1, frogColour
	jal draw_frog

#####################################################################
	lw $t0, screenWidth
	li $t1, 5
	lw $t8, 0xffff0000				
	beq $t8, 1, keyboard_input		
	j keyboard_input_done			
	addi $t0, $t0, -3

	keyboard_input:
		lw $t8, 0xffff0004		
		beq $t8, 0x61, frog_left	# If "a", move left
		beq $t8, 0x64, frog_right	# If "d", move right
		beq $t8, 0x77, frog_up		# If "w", move up
		beq $t8, 0x73, frog_down	# If "s", move down
   		beq $t8, 0x72, restart 		# If "r", restart game
    		beq $t8, 0x63, Exit 		# If "c", terminate the program

		j keyboard_input_done		

		frog_left:
			beq $s0, $zero, keyboard_input_done	
			addi $s0, $s0, -1				
			j keyboard_input_done			

		frog_right:
			bge $s0, 30, keyboard_input_done
			addi $s0, $s0, 1
			j keyboard_input_done

		frog_up:
			ble $s1, 5, keyboard_input_done
			addi $s1, $s1, -1
			j keyboard_input_done
			
		frog_down:
			beq $s1, 30, keyboard_input_done
			addi $s1, $s1, 1
			j keyboard_input_done
			
    		restart:
     			j main
	
	keyboard_input_done:
			
	frog_hit:
		jal did_frog_hit_vehicle
		beqz $v0, frog_die
		jal did_frog_hit_river
		beqz $v0, frog_die
		beq $s1, 5, frog_reach_goal
		j frog_hit_done
		

		frog_die:
			li $v0, 31 
			lb $t0, pitch
			lb $t1, duration 
			lb $t2, instrument
			lb $t3, volume 
			move $a0, $t0 
			move $a1, $t1 
			move $a2, $t2
			move $a3, $t3 
			syscall 


		
			addi $s4, $s4, -1
			beq $s4, 0, bye_loop	
			j draw_background		

		frog_reach_goal:
			beq $s0, 7, first_place
			beq $s0, 15, second_place
			beq $s0, 23, third_place
			j frog_hit_done
			
			first_place:
				addi $s5, $s5, 1
				
				lw $t0 goalAddress
				
				sh $s0, 0($t0)
				sh $s1, 2($t0)
				
				li $v0, 31 
				la $t0, pitch
				la $t1, duration 
				la $t2, instrument
				la $t3, volume 
				move $a0, $t0 
				move $a1, $t1 
				move $a2, $t2
				move $a3, $t3 
				syscall 

				j draw_background
			second_place:
				addi $s5, $s5, 1
				
				lw $t0 goalAddress
				addi $t0, $t0, 4
				sh $s0, 0($t0)
				sh $s1, 2($t0)
				
				li $v0, 31 
				la $t0, pitch
				la $t1, duration 
				la $t2, instrument
				la $t3, volume 
				move $a0, $t0 
				move $a1, $t1 
				move $a2, $t2
				move $a3, $t3 
				syscall 
				
				j draw_background
			third_place:
				addi $s5, $s5, 1
				
				lw $t0 goalAddress
				addi $t0, $t0, 8
				sh $s0, 0($t0)
				sh $s1, 2($t0)
				
				li $v0, 31 
				la $t0, pitch
				la $t1, duration 
				la $t2, instrument
				la $t3, volume 
				move $a0, $t0 
				move $a1, $t1 
				move $a2, $t2
				move $a3, $t3 
				syscall 
				
				j draw_background
			
				
	frog_hit_done:
	

level_up:
	bge $s5, 3, level_2

Dynamic_difficulty:
	addi $s6, $s6, 1
	bge $s6, 1800,level_2

level_0: 
	addi $s2, $s2, 3
	j Sleep
level_1:
	addi $s2, $s2, 4
	j Sleep
level_2: 
	addi $s2, $s2, 6



Sleep:	
	li $v0, 32				# Sleep op code
	li $a0, 50				# Sleep 1/20 second 
	syscall
	j refresh
	
	
refresh:
	jal draw_score
	jal draw_reach_goal
	jal draw_frog_lives
	jal draw_points
	
	beq $s2, 12, move_level_1_1
	


	j game_loop
	
Exit:
	li $v0, 10
	syscall
	

get_random_number:
	li $v0, 42
	li $a0, 0
	li $a1, 31
	syscall
	jr $ra
	
get_random_number_2:
	li $v0, 42
	li $a0, 15
	li $a1, 18
	syscall
	jr $ra
	
draw_frog:	
	sll $t0, $s1, 5
	add $t0, $t0, $s0
	sll $t0, $t0, 2
	add $t0, $t0, $gp


	sw $a1, 0($t0)
	sw $a1, 4($t0)
	sw $a1, 128($t0)
	sw $a1, 132($t0)
	
	jr $ra
	
draw_vehicle:
	lw $t0, vehicleAddress
	li $t3, 0
	lw $t5, vehicleNum
	
draw_vehicle_loop:
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t2, $t2, 5
	add $t2, $t2, $t1
	sll $t2, $t2, 2
	add $t2, $t2, $gp

	sw $a1, 0($t2)
	sw $a1, 4($t2)
	sw $a1, 8($t2)
	sw $a1, 128($t2)
	sw $a1, 132($t2)
	sw $a1, 136($t2)
	
	addi $t3, $t3, 1
	addi $t0, $t0, 4
	blt $t3, $t5, draw_vehicle_loop
	
	jr $ra
	
vehicle_move:
	lw $t0, vehicleAddress
	li $t1, 0 #count for car
	lw $t2, vehicleNum
	lw $t3, screenWidth
	addi $t3, $t3, -3
	
vehicle_move_loop:

	lh $t4, 0($t0)
	beq $t4, $t3, vehicle_transfer
	
	addi $t4, $t4, 1
	sh $t4, 0($t0)
	j vehicle_loop

vehicle_transfer:
	sh $zero, 0($t0)
	
vehicle_loop:
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	blt $t1, $2, vehicle_move_loop
	
	jr $ra
	
draw_wood:
	lw $t0, woodAddress
	li $t3, 0
	lw $t5, woodNum
	
draw_wood_loop:
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t2, $t2, 5
	add $t2, $t2, $t1
	sll $t2, $t2, 2
	add $t2, $t2, $gp

	sw $a1, 0($t2)
	sw $a1, 4($t2)
	sw $a1, 8($t2)
	sw $a1, 12($t2)
	sw $a1, 16($t2)
	sw $a1, 20($t2)
	sw $a1, 128($t2)
	sw $a1, 132($t2)
	sw $a1, 136($t2)
	sw $a1, 140($t2)
	sw $a1, 144($t2)
	sw $a1, 148($t2)
	
	addi $t3, $t3, 1
	addi $t0, $t0, 4
	blt $t3, $t5, draw_wood_loop
	
	jr $ra
#########################################################
		
wood_move_1:
	lw $t0, woodAddress
	li $t1, 0 #count for wood
	li $t2, 6
	lw $t3, screenWidth
	addi $t3, $t3, -6
	
wood_move_loop:

	lh $t4, 0($t0)
	beq $t4, $zero, wood_transfer
	
	addi $t4, $t4, -1
	sh $t4, 0($t0)
	j wood_loop

wood_transfer:
	sh $t3, 0($t0)
	
wood_loop:
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	blt $t1, $t2, wood_move_loop
	
	jr $ra
	
wood_move_2:
	lw $t0, woodAddress
	li $t1, 0 #count for wood
	li $t2, 4
	lw $t3, screenWidth
	addi $t3, $t3, -6
	addi $t0, $t0, 24
	
wood_move_loop_2:
	lh $t4, 0($t0)
	beq $t4, $zero, wood_transfer_2
	
	addi $t4, $t4, -1
	sh $t4, 0($t0)
	j wood_loop_2

wood_transfer_2:
	sh $t3, 0($t0)
	
wood_loop_2:
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	blt $t1, $t2, wood_move_loop_2
	
	jr $ra
	
move_level_1_1:
	jal vehicle_move
	jal wood_move_1
	li $s2, 0
	addi $s3, $s3, 1
	beq $s3, 4, move_level_1_2
	
	j game_loop
	
move_level_1_2:
	jal wood_move_2
	li $s3, 0
	
	j game_loop
#############################################
draw_score:
	lw $t0, displayAddress
	lw $t2, roadColour
	addi $t1, $t0, 640

draw_score_loop:
	beq $t1, $t0, draw_goal
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_score_loop
	
draw_goal:
	addi $t1, $t0, 28
	lw $t2, goalColour

draw_goal_loop:
	beq $t0, $t1, draw_goal_2
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop

draw_goal_2:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_2:
	beq $t0, $t1, draw_goal_3
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_2
	
draw_goal_3:
	addi $t1, $t0, 24
	lw $t2, goalColour

draw_goal_loop_3:
	beq $t0, $t1, draw_goal_4
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_3

draw_goal_4:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_4:
	beq $t0, $t1, draw_goal_5
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_4
	
draw_goal_5:
	addi $t1, $t0, 24
	lw $t2, goalColour

draw_goal_loop_5:
	beq $t0, $t1, draw_goal_6
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_5

draw_goal_6:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_6:
	beq $t0, $t1, draw_goal_7
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_6

draw_goal_7:
	addi $t1, $t0, 28
	lw $t2, goalColour

draw_goal_loop_7:
	beq $t0, $t1, draw_goal_8
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_7

draw_goal_8:
	addi $t1, $t0, 28
	lw $t2, goalColour

draw_goal_loop_8:
	beq $t0, $t1, draw_goal_9
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_8

draw_goal_9:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_9:
	beq $t0, $t1, draw_goal_10
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_9
	
draw_goal_10:
	addi $t1, $t0, 24
	lw $t2, goalColour

draw_goal_loop_10:
	beq $t0, $t1, draw_goal_11
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_10

draw_goal_11:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_11:
	beq $t0, $t1, draw_goal_12
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_11
	
draw_goal_12:
	addi $t1, $t0, 24
	lw $t2, goalColour

draw_goal_loop_12:
	beq $t0, $t1, draw_goal_13
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_12

draw_goal_13:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_13:
	beq $t0, $t1, draw_goal_14
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_13

draw_goal_14:
	addi $t1, $t0, 28
	lw $t2, goalColour

draw_goal_loop_14:
	beq $t0, $t1, draw_goal_15
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_14
	
draw_goal_15:
	addi $t1, $t0, 28
	lw $t2, goalColour

draw_goal_loop_15:
	beq $t0, $t1, draw_goal_16
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_15

draw_goal_16:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_16:
	beq $t0, $t1, draw_goal_17
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_16
	
draw_goal_17:
	addi $t1, $t0, 24
	lw $t2, goalColour

draw_goal_loop_17:
	beq $t0, $t1, draw_goal_18
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_17

draw_goal_18:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_18:
	beq $t0, $t1, draw_goal_19
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_18
	
draw_goal_19:
	addi $t1, $t0, 24
	lw $t2, goalColour

draw_goal_loop_19:
	beq $t0, $t1, draw_goal_20
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_19

draw_goal_20:
	addi $t1, $t0, 8
	lw $t2, roadColour

draw_goal_loop_20:
	beq $t0, $t1, draw_goal_21
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_20

draw_goal_21:
	addi $t1, $t0, 28
	lw $t2, goalColour

draw_goal_loop_21:
	beq $t0, $t1, draw_river
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_goal_loop_21

draw_river:
	addi $t1, $t0, 1280
	lw $t2, riverColour
	
draw_river_loop:
	beq $t0, $t1, draw_safe
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_river_loop

draw_safe:
	addi $t1, $t0, 256
	lw $t2, safeColour

draw_safe_loop:
	beq $t0, $t1, draw_road
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_safe_loop

draw_road:
	addi $t1, $t0,1280
	lw $t2, roadColour
	
draw_road_loop:
	beq $t0, $t1, draw_start
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_road_loop
	
draw_start:
	addi $t1, $t0, 256
	lw $t2, safeColour

draw_start_loop:
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	blt $t0, $t1 draw_start_loop
	
	jr $ra
	
#########################################################
draw_reach_goal:
	lw $t0, goalAddress
	lw $a1, frogColour
	li $t3, 0
	
draw_reach_goal_loop:
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t2, $t2, 5
	add $t2, $t2, $t1
	sll $t2, $t2, 2
	add $t2, $t2, $gp


	sw $a1, 0($t2)
	sw $a1, 4($t2)
	sw $a1, 128($t2)
	sw $a1, 132($t2)
	
	addi $t3, $t3, 1
	addi $t0, $t0, 4
	
	blt $t3, 3, draw_reach_goal_loop
	
	jr $ra





#########################################################
		
did_frog_hit_vehicle:
	li $t0, 0					
	lw $t1, vehicleNum
	lw $t2, vehicleAddress		
	li $v0, 1					

frog_hit_vehicle_loop: 
	lh $a0, 2($t2)						
	beq $a0, $s1, frog_hit_vehicle_loop_1	
	addi $a0, $a0, -1
	beq $a0, $s1, frog_hit_vehicle_loop_1	

	j frog_hit_vehicle_loop_2

frog_hit_vehicle_loop_1:
	lh $a0, 0($t2)						
	addi $a0, $a0, -1					
	blt $s0, $a0, frog_hit_vehicle_loop_3	
				
	addi $a0, $a0, 4
	bge $s0, $a0, frog_hit_vehicle_loop_3	

	li $v0, 0					
	jr $ra
	
	
frog_hit_vehicle_loop_2:
	addi $t0, $t0, 2
	addi $t2, $t2, 8
	blt $t0, $t1, frog_hit_vehicle_loop
	
	
frog_hit_vehicle_loop_3:
	addi $t0, $t0, 1
	addi $t2, $t2, 4
	blt $t0, $t1, frog_hit_vehicle_loop
	
frog_hit_vehicle_loop_end:
	jr $ra						
	
	
did_frog_hit_river:
	li $t0, 0					
	lw $t1, woodNum
	lw $t2, woodAddress		
	li $v0, 1					
	bgt $s1, 17, frog_below_river
	ble $s1, 7, frog_below_river

frog_hit_river_loop: 
	lh $a0, 2($t2)						
	beq $a0, $s1, frog_hit_river_loop_1	
	addi $a0, $a0, 1
	beq $a0, $s1, frog_hit_river_loop_1	
	j frog_hit_river_loop_2

frog_hit_river_loop_1:
	lh $a0, 0($t2)						
	blt $s0, $a0, frog_hit_river_loop_3   
				
	addi $a0, $a0, 5
	bgt $s0, $a0, frog_hit_river_loop_3	
	li $v0, 1
	jr $ra
	
frog_hit_river_loop_3:
	addi $t0, $t0, 1
	addi $t2, $t2, 4
	blt $t0, $t1, frog_hit_river_loop
	
frog_hit_river_loop_2:
	addi $t0, $t0, 2
	addi $t2, $t2, 8
	blt $t0, $t1, frog_hit_river_loop
	
	
frog_hit_river_loop_end:
	li $v0, 0
	jr $ra		
	
frog_below_river:
	li $v0, 1
	jr $ra	


##################################
draw_frog_lives:
	lw $t0, displayAddress
	lw $a1, frogColour
	beq $s4, 3, draw_three_lives
	beq $s4, 2, draw_two_lives
	jr $ra
	
draw_three_lives:
	sw $a1, 12($t0)
	sw $a1, 16($t0)
	sw $a1, 140($t0)
	sw $a1, 144($t0)
	
	sw $a1, 24($t0)
	sw $a1, 28($t0)
	sw $a1, 152($t0)
	sw $a1, 156($t0)
	
	jr $ra
	
draw_two_lives:
	sw $a1, 12($t0)
	sw $a1, 16($t0)
	sw $a1, 140($t0)
	sw $a1, 144($t0)
	
	jr $ra
##################################
draw_points:
	lw $t0, displayAddress
	lw $t1, vehicleColour
	beq $s5, 0, draw_000_points
	beq $s5, 1, draw_100_points
	beq $s5, 2, draw_200_points
	beq $s5, 3, draw_300_points
	
	
draw_000_points:
	addi $t0, $t0, 84
	sw $t1, 0($t0)
	sw $t1, 4($t0)	
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	
	sw $t1, 8($t0)
	sw $t1, 16($t0)	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 136($t0)
	sw $t1, 144($t0)
	sw $t1, 152($t0)
	sw $t1, 160($t0)
	sw $t1, 168($t0)
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 280($t0)
	sw $t1, 288($t0)
	sw $t1, 296($t0)
	sw $t1, 392($t0)
	sw $t1, 400($t0)
	sw $t1, 408($t0)
	sw $t1, 416($t0)
	sw $t1, 424($t0)
	sw $t1, 520($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t1, 544($t0)
	sw $t1, 548($t0)
	sw $t1, 552($t0)

	jr $ra
	
draw_100_points:
	addi $t0, $t0, 92
	sw $t1, 0($t0)	
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 136($t0)
	sw $t1, 144($t0)
	sw $t1, 152($t0)
	sw $t1, 160($t0)
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 280($t0)
	sw $t1, 288($t0)
	sw $t1, 392($t0)
	sw $t1, 400($t0)
	sw $t1, 408($t0)
	sw $t1, 416($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 536($t0)
	sw $t1, 540($t0)
	sw $t1, 544($t0)

	jr $ra
	

draw_200_points:
	addi $t0, $t0, 84
	sw $t1, 0($t0)
	sw $t1, 4($t0)	
	sw $t1, 384($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	
	sw $t1, 8($t0)
	sw $t1, 16($t0)	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 136($t0)
	sw $t1, 144($t0)
	sw $t1, 152($t0)
	sw $t1, 160($t0)
	sw $t1, 168($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 280($t0)
	sw $t1, 288($t0)
	sw $t1, 296($t0)
	sw $t1, 400($t0)
	sw $t1, 408($t0)
	sw $t1, 416($t0)
	sw $t1, 424($t0)
	sw $t1, 520($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t1, 544($t0)
	sw $t1, 548($t0)
	sw $t1, 552($t0)

	jr $ra

draw_300_points:
		addi $t0, $t0, 84
	sw $t1, 0($t0)
	sw $t1, 4($t0)	
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	
	sw $t1, 8($t0)
	sw $t1, 16($t0)	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 136($t0)
	sw $t1, 144($t0)
	sw $t1, 152($t0)
	sw $t1, 160($t0)
	sw $t1, 168($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 280($t0)
	sw $t1, 288($t0)
	sw $t1, 296($t0)
	sw $t1, 392($t0)
	sw $t1, 400($t0)
	sw $t1, 408($t0)
	sw $t1, 416($t0)
	sw $t1, 424($t0)
	sw $t1, 520($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t1, 544($t0)
	sw $t1, 548($t0)
	sw $t1, 552($t0)

	jr $ra
		
				
##################################
bye_loop:
	lw $t0, displayAddress
	lw $t2, roadColour
	lw $t1, retryColour
	addi $t3, $t0, 4096

draw_all_black:
	beq $t3, $t0, draw_bye
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j draw_all_black
	
	

draw_bye:
	lw $t0, displayAddress
	# draw o
	addi $t0, $t0, 1568

	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 396($t0)
	sw $t1, 524($t0)
	sw $t1, 516($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	sw $t1, 652($t0)
	#draw v
	sw $t1, 404($t0)
	sw $t1, 532($t0)
	sw $t1, 412($t0)
	sw $t1, 540($t0)
	sw $t1, 664($t0)


	#draw E
	sw $t1, 676($t0)
	sw $t1, 680($t0)
	sw $t1, 684($t0)
	sw $t1, 548($t0)
	sw $t1, 420($t0)
	sw $t1, 424($t0)
	sw $t1, 428($t0)
	sw $t1, 292($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 172($t0)
	
	#draw r
	
	sw $t1, 436($t0)
	sw $t1, 440($t0)
	sw $t1, 444($t0)
	sw $t1, 564($t0)
	sw $t1, 692($t0)
	
	#draw !
	sw $t1, 196($t0)
	sw $t1, 324($t0)
	sw $t1, 452($t0)
	sw $t1, 708($t0)
	
	li $v0, 31 
	la $t0, pitch
	la $t1, duration 
	la $t2, instrument
	la $t3, volume 
	move $a0, $t0 
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3 
	syscall 
  	
  	li $v0, 32				
	li $a0, 5000				
	syscall
	
  	j main
	
	
