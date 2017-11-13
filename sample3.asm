      XOR     r0,     r0,    r0#ゼロレジスタの用意
      ADDI    r8,     r0,    0#変数iの用意
      ADDI    r10,    r0,    512#要素を100個持つ配列変数flagを用意#配列変数flagのアドレスを初期化
      ADDI    r14,    r0,    1#配列変数flagの要素を初期化する定数
      ADDI    r8,     r0,    0#i = 0の変換
      ADDI    r24,    r0,    400#iの上限となる定数
FOR0S:BLE     r24,    r8,    FOR0E#flagの全要素を1（true）に初期化#for (i = 0; i < 100; i++)#i < 100（100 <= i）の変換
      ADD     r15,    r8,    r10#forブロック内
      SW      r14,    0(r15)
      ADDI    r8,     r8,    4#i++の変換
      J       FOR0S
FOR0E:SW      r0,     0(r10)#flag[0]とflag[1]に0を代入
      SW      r0,     4(r10)
      ADDI    r9,     r0,    2#判定用の変数divを用意して1ずつ加算、flag[divのi（ > 1）倍]に0を代入#div = 2の変換
      ADDI    r25,    r0,    51#divの上限となる定数
FOR1S:BLE     r25,    r9,    FOR1E#for (div = 2; div < 51; div++)#divが50を超えた場合は判定終了#div < 51（51 <= div）の変換
      SLL     r14,    r9,    2#divのforブロック内#シフト演算で4倍
      ADD     r15,    r10,    r14
      LW      r11,    0(r15)
      BNE     r0,     r11,    IF0E    #if (flag[div] == 0)
      ADDI    r9,     r9,    1#ifブロック内
      J       FOR1S
IF0E:SLL     r14,    r9,    3#i = div * 2の変換（アドレスのためさらに4倍）
      ADD     r8,     r0,    r14
      ADDI    r24,    r0,    400#iの上限となる定数
FOR2S:BLE     r24,    r8,    FOR2E#for (i = div * 2; i < 100; i = i + div)#i < 100（100 <= i）の変換
      ADD     r15,    r8,    r10#forブロック内
      SW      r0,     0(r15)
      SLL     r14,    r9,    2#i = i + divの変換（アドレスのため4倍）
      ADD     r8,     r8,    r14
      J       FOR2S
FOR2E:ADDI    r9,     r9,    1#div++の変換
      J       FOR1S
FOR1E:ADDI    r8,     r0,    8#素数をメモリに保存#i = 0の変換
      ADDI    r24,    r0,    400#iの上限となる定数
FOR3S:BLE     r24,    r8,    FOR3E#for (i = 2; i < 100; i++)#i < 100（100 <= i）の変換
      ADD     r15,    r8,    r10#iのforブロック内
      LW      r11,    0(r15)
      BEQ     r0,     r11,    IF1E    #if (flag[div] != 0)
      SRA     r14,    r8,    2#ifブロック内#シフト演算で1/4
      ADD     r15,    r8,    r10
      SW      r14,    0(r15)
IF1E:ADDI    r8,     r8,    4#i++の変換
      J       FOR3S
FOR3E:HALT
