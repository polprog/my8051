	;; Knight Rider pattern on PORT at SFR 90


	.module test
	stash = 0x01
	.area FOOBAR (ABS)
	.org 0x0000

reset:
	mov A, #0x01 		;initial value
loop:	
	rl A			;Rotate left
	mov 0x90, A
	ljmp loop		;loop back
