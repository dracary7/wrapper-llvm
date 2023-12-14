; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -ppc-asm-full-reg-names -verify-machineinstrs -ppc-formprep-chain-commoning \
; RUN:   -mtriple=powerpc-ibm-aix-xcoff -mcpu=pwr9 < %s | FileCheck %s

; Test that on 32 bit AIX, the chain commoning still works without crash.

; addresses:
; 1: base1 + offset
; 2: + offset
; 3: + offset
; 4: + offset
;
; chains:
; 1: base: base1 + offset, offsets: (0, offset)
; 2: base: base1 + 3*offset, offsets: (0, offset)
;
; long long two_chain_same_offset_succ_i32(char *p, int offset, int base1, long long n) {
;   int o1 = base1 + offset;
;   int o2 = base1 + 2 * offset;
;   int o3 = base1 + 3 * offset;
;   int o4 = base1 + 4 * offset;
;   char *p1 = p + o1;
;   char *p2 = p + o2;
;   char *p3 = p + o3;
;   char *p4 = p + o4;
;   long long sum = 0;
;   for (long long i = 0; i < n; ++i) {
;     unsigned long x1 = *(unsigned long *)(p1 + i);
;     unsigned long x2 = *(unsigned long *)(p2 + i);
;     unsigned long x3 = *(unsigned long *)(p3 + i);
;     unsigned long x4 = *(unsigned long *)(p4 + i);
;     sum += x1 * x2 * x3 * x4;
;   }
;   return sum;
; }
;
define i64 @two_chain_same_offset_succ_i32(i8* %p, i32 %offset, i32 %base1, i64 %n) {
; CHECK-LABEL: two_chain_same_offset_succ_i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmplwi r6, 0
; CHECK-NEXT:    cmpwi cr1, r6, 0
; CHECK-NEXT:    stw r30, -8(r1) # 4-byte Folded Spill
; CHECK-NEXT:    stw r31, -4(r1) # 4-byte Folded Spill
; CHECK-NEXT:    crandc 4*cr5+lt, 4*cr1+lt, eq
; CHECK-NEXT:    cmpwi cr1, r7, 0
; CHECK-NEXT:    bc 12, 4*cr5+lt, L..BB0_5
; CHECK-NEXT:  # %bb.1: # %entry
; CHECK-NEXT:    crand 4*cr5+lt, eq, 4*cr1+eq
; CHECK-NEXT:    bc 12, 4*cr5+lt, L..BB0_5
; CHECK-NEXT:  # %bb.2: # %for.body.preheader
; CHECK-NEXT:    slwi r8, r4, 1
; CHECK-NEXT:    li r10, 0
; CHECK-NEXT:    li r11, 0
; CHECK-NEXT:    add r8, r4, r8
; CHECK-NEXT:    add r9, r5, r8
; CHECK-NEXT:    add r5, r5, r4
; CHECK-NEXT:    add r8, r3, r5
; CHECK-NEXT:    add r9, r3, r9
; CHECK-NEXT:    li r3, 0
; CHECK-NEXT:    li r5, 0
; CHECK-NEXT:    .align 4
; CHECK-NEXT:  L..BB0_3: # %for.body
; CHECK-NEXT:    #
; CHECK-NEXT:    lwz r12, 0(r8)
; CHECK-NEXT:    lwzx r0, r8, r4
; CHECK-NEXT:    lwz r31, 0(r9)
; CHECK-NEXT:    lwzx r30, r9, r4
; CHECK-NEXT:    addi r8, r8, 1
; CHECK-NEXT:    addi r9, r9, 1
; CHECK-NEXT:    mullw r12, r0, r12
; CHECK-NEXT:    mullw r12, r12, r31
; CHECK-NEXT:    mullw r12, r12, r30
; CHECK-NEXT:    addc r5, r5, r12
; CHECK-NEXT:    addze r3, r3
; CHECK-NEXT:    addic r11, r11, 1
; CHECK-NEXT:    addze r10, r10
; CHECK-NEXT:    cmplw r10, r6
; CHECK-NEXT:    cmpw cr1, r10, r6
; CHECK-NEXT:    crandc 4*cr5+lt, 4*cr1+lt, eq
; CHECK-NEXT:    cmplw cr1, r11, r7
; CHECK-NEXT:    bc 12, 4*cr5+lt, L..BB0_3
; CHECK-NEXT:  # %bb.4: # %for.body
; CHECK-NEXT:    #
; CHECK-NEXT:    crand 4*cr5+lt, eq, 4*cr1+lt
; CHECK-NEXT:    bc 12, 4*cr5+lt, L..BB0_3
; CHECK-NEXT:    b L..BB0_6
; CHECK-NEXT:  L..BB0_5:
; CHECK-NEXT:    li r3, 0
; CHECK-NEXT:    li r5, 0
; CHECK-NEXT:  L..BB0_6: # %for.cond.cleanup
; CHECK-NEXT:    lwz r31, -4(r1) # 4-byte Folded Reload
; CHECK-NEXT:    lwz r30, -8(r1) # 4-byte Folded Reload
; CHECK-NEXT:    mr r4, r5
; CHECK-NEXT:    blr
entry:
  %add = add nsw i32 %base1, %offset
  %mul = shl nsw i32 %offset, 1
  %add1 = add nsw i32 %mul, %base1
  %mul2 = mul nsw i32 %offset, 3
  %add3 = add nsw i32 %mul2, %base1
  %mul4 = shl nsw i32 %offset, 2
  %add5 = add nsw i32 %mul4, %base1
  %add.ptr = getelementptr inbounds i8, i8* %p, i32 %add
  %add.ptr6 = getelementptr inbounds i8, i8* %p, i32 %add1
  %add.ptr7 = getelementptr inbounds i8, i8* %p, i32 %add3
  %add.ptr8 = getelementptr inbounds i8, i8* %p, i32 %add5
  %cmp49 = icmp sgt i64 %n, 0
  br i1 %cmp49, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %entry
  %sum.0.lcssa = phi i64 [ 0, %entry ], [ %add19, %for.body ]
  ret i64 %sum.0.lcssa

for.body:                                         ; preds = %entry, %for.body
  %sum.051 = phi i64 [ %add19, %for.body ], [ 0, %entry ]
  %i.050 = phi i64 [ %inc, %for.body ], [ 0, %entry ]
  %idx.ext = trunc i64 %i.050 to i32
  %add.ptr9 = getelementptr inbounds i8, i8* %add.ptr, i32 %idx.ext
  %0 = bitcast i8* %add.ptr9 to i32*
  %1 = load i32, i32* %0, align 4
  %add.ptr11 = getelementptr inbounds i8, i8* %add.ptr6, i32 %idx.ext
  %2 = bitcast i8* %add.ptr11 to i32*
  %3 = load i32, i32* %2, align 4
  %add.ptr13 = getelementptr inbounds i8, i8* %add.ptr7, i32 %idx.ext
  %4 = bitcast i8* %add.ptr13 to i32*
  %5 = load i32, i32* %4, align 4
  %add.ptr15 = getelementptr inbounds i8, i8* %add.ptr8, i32 %idx.ext
  %6 = bitcast i8* %add.ptr15 to i32*
  %7 = load i32, i32* %6, align 4
  %mul16 = mul i32 %3, %1
  %mul17 = mul i32 %mul16, %5
  %mul18 = mul i32 %mul17, %7
  %conv = zext i32 %mul18 to i64
  %add19 = add nuw nsw i64 %sum.051, %conv
  %inc = add nuw nsw i64 %i.050, 1
  %cmp = icmp slt i64 %inc, %n
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}
