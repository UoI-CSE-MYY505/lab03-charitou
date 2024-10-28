.globl rgb888_to_rgb565, showImage

.data

image888:  # A rainbow-like image Red->Green->Blue->Red
    .byte 255, 0,     0
    .byte 255,  85,   0
    .byte 255, 170,   0
    .byte 255, 255,   0
    .byte 170, 255,   0
    .byte  85, 255,   0
    .byte   0, 255,   0
    .byte   0, 255,  85
    .byte   0, 255, 170
    .byte   0, 255, 255
    .byte   0, 170, 255
    .byte   0,  85, 255
    .byte   0,   0, 255
    .byte  85,   0, 255
    .byte 170,   0, 255
    .byte 255,   0, 255
    .byte 255,   0, 170
    .byte 255,   0,  85
    .byte 255,   0,   0
# repeat the above 5 times
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
image565:
    .zero 512  # leave a 1Kibyte free space

image888_back:
    .zero 512

.text
# -------- This is just for fun.
# Ripes has a LED matrix in I/O tab. To enable it:
# - Go to the I/O tab and double click on LED Matrix.
# - Change the Height and Width (at top-right part of I/O window),
#     to the size of the image888 (19, 6 in this example)
# - This will enable the LED matrix

    la   a0, image888
    la   a3, image565
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb888_to_rgb565

# convert it back to RGB888.
#  However some colours will be different now
#  (the lsbs were lost when the image was converted to RGB565)!
    la   a0, image565
    la   a3, image888_back
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb565_to_rgb888

    addi a7, zero, 10 
    ecall

# ----------------------------------------
# Subroutine showImage
# a0 - image to display on Ripes' LED matrix
# a1 - Base address of LED matrix
# a2 - Width of the image and the LED matrix
# a3 - Height of the image and the LED matrix
# Caution: Assumes the image and LED matrix have the
# same dimensions!
showImage:
    add  t0, zero, zero # row counter
showRowLoop:
    bge  t0, a3, outShowRowLoop
    add  t1, zero, zero # column counter
showColumnLoop:
    bge  t1, a2, outShowColumnLoop
    lbu  t2, 0(a0) 
    lbu  t3, 1(a0) 
    lbu  t4, 2(a0) 
    slli t2, t2, 16  
    slli t3, t3, 8   
    or   t4, t4, t3  
    or   t4, t4, t2  
    sw   t4, 0(a1)   
    addi a0, a0, 3   
    addi a1, a1, 4  
    addi t1, t1, 1
    j    showColumnLoop
outShowColumnLoop:
    addi t0, t0, 1
    j    showRowLoop
outShowRowLoop:
    jalr zero, ra, 0
# ----------------------------------------

rgb888_to_rgb565:
    add  t0, zero, zero 
rowLoop:
    bge  t0, a2, outRowLoop
    add  t1, zero, zero
columnLoop:
    bge  t1, a1, outColumnLoop
    lbu  t2, 0(a0)  
    lbu  t3, 1(a0)   
    lbu  t4, 2(a0)   
    andi t2, t2, 0xf8   
    slli t2, t2, 8      
    andi t3, t3, 0xfc   
    slli t3, t3, 3      
    srli t4, t4, 3      
    or   t2, t2, t3
    or   t2, t2, t4
    sh   t2, 0(a3)   
    addi a0, a0, 3   
    addi a3, a3, 2  
    addi t1, t1, 1
    j    columnLoop
outColumnLoop:
    addi t0, t0, 1
    j    rowLoop
outRowLoop:
    jalr zero, ra, 0



rgb565_to_rgb888:
    add  t0, zero, zero 
rowl:
    bge  t0, a2, outRowl
    add  t1, zero, zero 
columnl:
    bge  t1, a1, outColumnl
    lhu  t2, 0(a0)
    srli t3, t2, 8  
    andi t3, t3, 0xf8 
    sb   t3, 0(a3) 
    srli t3, t2, 3  
    andi t3, t3, 0xfc 
    sb   t3, 1(a3) 
    slli t3, t2, 3
    andi t3, t3, 0xf8 
    sb   t3, 3(a3)
    addi a0, a0, 2   
    addi a3, a3, 3   
    addi t1, t1, 1
    j    columnl
outColumnl:
    addi t0, t0, 1
    j    rowl
outRowl:
    jalr zero, ra, 0