.text
.globl main

main:
   addi x28, x0, 5
    addi x2, x0, 511
    addi x5, x0, 768
    addi x6, x0, 512
    sw x28, 0(x5)
    IDLE_STATE:
    sw x0, 0(x6)
    READ_INPUT:
    lw x11, 0(x5)
    beq x11, x0, READ_INPUT
    add x10, x11, x0
    jal x1, RUN_COUNTER
    beq x0, x0, IDLE_STATE
    RUN_COUNTER:
    addi x2, x2, -8
    sw x1, 4(x2)
    sw x12, 0(x2)
    add x12, x10, x0
    DECREMENT_LOOP:
    sw x12, 0(x6)
    beq x12, x0, EXIT_COUNTER
    addi x12, x12, -1
    addi x13, x0, 3
    WAIT_LOOP:
    addi x13, x13, -1
    bne x13, x0, WAIT_LOOP
    beq x0, x0, DECREMENT_LOOP
    EXIT_COUNTER:
    sw x0, 0(x6)
    lw x12, 0(x2)
    lw x1, 4(x2)
    addi x2, x2, 8
    ret           
end:
    beq  x0, x0, end         # infinite loop to stop execution