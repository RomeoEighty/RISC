    XOR     r0, r0,    r0#ゼロレジスタの用意
    ADDI    r10,    r0,    0#変数mの初期化
    ADDI    r29,    r0,    1024#スタックポインタの初期化
    ADDI    r15,    r0,    512#32bit定数の用意
    LUI         r14,    1883#static x
    ORI     r14,    r14,    52501
    SW      r14,    0(r15)
    LUI         r14,    5530#static y
    ORI     r14,    r14,    21989
    SW      r14,    4(r15)
    LUI         r14,    7954#static z
    ORI     r14,    r14,    15285
    SW      r14,    8(r15)
    LUI         r14,    1353#static w
    ORI     r14,    r14,    4915
    SW      r14,    12(r15)
    LUI         r14,    16383#static mul16(0x7fff)
    ORI     r14,    r14,    1
    SW      r14,    16(r15)
    ADDI    r8,    r0,    0#i = 0の変換
    ADDI    r24,    r0,    400#iの上限となる定数
FOR0S:BLE    r24,    r8,    FOR0E#for (i = 0; i < 400; i++)#i < 400（400 <= i）の変換
    JAL     _xor128#forブロック内#Xorshiftと呼ばれる方法を、関数xor128として使い、乱数を生成
    ADD     r16,    r0,    r2
    SRL     r14,    r16,    16
    ANDI    r17,    r14,    65535
    ANDI    r18,    r16,    65535
    SRL     r17,    r17,    1#オーバーフロー防止のため2でわる
    SRL     r18,    r18,    1
    ADD     r4,    r0,    r17#2乗を関数powで計算#pow(x)
    SW      r8,    0(r29)
    ADDI    r14,    r0,    4#スタックポインタの引き算（定数ではビットが足りないことに注意）
    SUB     r29,    r29,    r14
    JAL     _pow
    ADDI    r29,    r29,    4
    LW      r8,    0(r29)
    ADD     r17,    r0,    r2
    ADD     r4,    r0,    r18#pow(y)
    SW      r8,    0(r29)
    ADDI    r14,    r0,    4
    SUB     r29,    r29,    r14
    JAL     _pow
    ADDI    r29,    r29,    4
    LW      r8,    0(r29)
    ADD     r17,    r2,    r17
    ADDI    r15,    r0,    528#mul16(0x7fff)のロード
    LW      r18,    0(r15)
    BLE     r18,    r17,    IF0E        #if (mul16(x) + mul16(y) <= mul16(0x7fff))
    ADDI    r10,    r10,    1#ifブロック内
IF0E:ADDI    r8,    r8,    1#i++の変換
    J       FOR0S
FOR0E:ADDI    r17,    r0,    0#変数xの再利用
    ADDI    r8,    r0,    8#iを負の数として扱えないので、アセンブリではすべて1を加算して扱うものとする#i = 7[+1]の変換
    ADDI    r24,    r0,    0#iの下限となる定数
FOR1S:BLE    r8,    r0,    FOR1E#(i = 7[+1]; i[+1] >= 0; i--)#mを16進数で表現する10進数として出力#i[+1] >= 0（i <= 0）の変換
    ADDI    r18,    r0,    1#forブロック内#変数yの再利用
    ADDI    r9,    r0,    0#j = 0の変換
FOR2S:ADDI    r14,    r9,    1#for (j = 0; j < i[+1]; j++)#j < i[+1]（i <= (j + 1)）の変換
    BLE     r8,    r14,    FOR2E
    SLL     r14,    r18,    3#forブロック内
    SLL     r18,    r18,    1
    ADD     r18,    r14,    r18
    ADDI    r9,    r9,    1#j++の変換
    J       FOR2S
FOR2E:SLL    r17,    r17,    4
WHILE0S:BLT    r10,    r18,    WHILE0E#while (m >= y)#m >= y（m < y）の変換
    SUB     r10,    r10,    r18#whileブロック内
    ADDI    r17,    r17,    1
    J       WHILE0S
WHILE0E:ADDI    r14,    r0,    1#i[+1]--の変換
    SUB     r8,    r8,    r14
    J       FOR1S
FOR1E:ADDI    r15,    r0,    528#return x（mul16(0x7fff)の隣に書き込み）
    SW      r17,    4(r15)
    J       END
_pow:ADDI,    r2,    r0,    0#int pow(int a)#変数sumの初期化
    ORI     r8,    r0,    32768#bit = 0x8000の変換
FORPS:BEQ    r0,    r8,    FORPE#for (bit = 0x8000; bit; bit = bit >> 1)#bit（bit != 0）の変換
    SLL     r2,    r2,    1#forブロック内
    AND     r14,    r4,    r8
    BEQ     r0,    r14,    IFPE        #if (a16 & bit)
    ADD     r2,    r2,    r4#ifブロック内
IFPE:SRL    r8,    r8,    1#bit = bit >> 1の変換
    J       FORPS
FORPE:JR    r31#return sum
_xor128:ADDI    r15,    r0,    512#int xor128()#_xの読みこみ
    LW      r14,    0(r15)
    SLL     r11,    r14,    11#x ^ (x << 11)の計算
    XOR     r11,    r11,    r14
    LW      r14,    4(r15)#_yの読み込み、_xへの書き込み（_xの次の行であることに注意、以下定数以外繰り返し）
    SW      r14,    0(r15)
    LW      r14,    8(r15)
    SW      r14,    4(r15)
    LW      r14,    12(r15)
    SW      r14,    8(r15)
    SRL     r2,    r14,    19#(w ^ (w >> 19))の計算
    XOR     r14,    r2,    r14
    SRL     r2,    r11,    8#(t ^ (t >> 8))
    XOR     r11,    r11,    r2
    XOR  r2,    r11,    r14
    SW      r2,    12(r15)
    JR      r31#return w
END:HALT
