; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -domtree -instcombine -loops -S < %s | FileCheck %s
; Note: The -loops above can be anything that requires the domtree, and is
; necessary to work around a pass-manager bug.

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define void @foo(i32* %a, i32* %b) #0 {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint i32* [[A:%.*]] to i64
; CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
; CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
; CHECK-NEXT:    tail call void @llvm.assume(i1 [[MASKCOND]])
; CHECK-NEXT:    [[PTRINT1:%.*]] = ptrtoint i32* [[B:%.*]] to i64
; CHECK-NEXT:    [[MASKEDPTR2:%.*]] = and i64 [[PTRINT1]], 63
; CHECK-NEXT:    [[MASKCOND3:%.*]] = icmp eq i64 [[MASKEDPTR2]], 0
; CHECK-NEXT:    tail call void @llvm.assume(i1 [[MASKCOND3]])
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[ARRAYIDX]], align 64
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP0]], 1
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX5]], align 64
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 16
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[TMP1]], 1648
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[FOR_END:%.*]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %ptrint = ptrtoint i32* %a to i64
  %maskedptr = and i64 %ptrint, 63
  %maskcond = icmp eq i64 %maskedptr, 0
  tail call void @llvm.assume(i1 %maskcond)
  %ptrint1 = ptrtoint i32* %b to i64
  %maskedptr2 = and i64 %ptrint1, 63
  %maskcond3 = icmp eq i64 %maskedptr2, 0
  tail call void @llvm.assume(i1 %maskcond3)
  br label %for.body


for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %b, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4
  %add = add nsw i32 %0, 1
  %arrayidx5 = getelementptr inbounds i32, i32* %a, i64 %indvars.iv
  store i32 %add, i32* %arrayidx5, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 16
  %1 = trunc i64 %indvars.iv.next to i32
  %cmp = icmp slt i32 %1, 1648
  br i1 %cmp, label %for.body, label %for.end

for.end:                                          ; preds = %for.body
  ret void
}

; Function Attrs: nounwind
declare void @llvm.assume(i1) #1

attributes #0 = { nounwind uwtable }
attributes #1 = { nounwind }
