; ModuleID = 'xdp_pass_kern.c'
source_filename = "xdp_pass_kern.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.xdp_md = type { i32, i32, i32, i32, i32 }

@_license = global [4 x i8] c"GPL\00", section "license", align 1, !dbg !0
@llvm.used = appending global [2 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_prog_simple to i8*)], section "llvm.metadata"

; Function Attrs: nounwind readnone uwtable
define i32 @xdp_prog_simple(%struct.xdp_md* nocapture readnone) #0 section "xdp" !dbg !22 {
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !38, metadata !DIExpression()), !dbg !39
  ret i32 2, !dbg !40
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!18, !19, !20}
!llvm.ident = !{!21}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 11, type: !14, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !13)
!3 = !DIFile(filename: "xdp_pass_kern.c", directory: "/home/minglei/photon/examples/xdp")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, size: 32, elements: !7)
!6 = !DIFile(filename: "../../headers/linux/bpf.h", directory: "/home/minglei/photon/examples/xdp")
!7 = !{!8, !9, !10, !11, !12}
!8 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!9 = !DIEnumerator(name: "XDP_DROP", value: 1)
!10 = !DIEnumerator(name: "XDP_PASS", value: 2)
!11 = !DIEnumerator(name: "XDP_TX", value: 3)
!12 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!13 = !{!0}
!14 = !DICompositeType(tag: DW_TAG_array_type, baseType: !15, size: 32, elements: !16)
!15 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!16 = !{!17}
!17 = !DISubrange(count: 4)
!18 = !{i32 2, !"Dwarf Version", i32 4}
!19 = !{i32 2, !"Debug Info Version", i32 3}
!20 = !{i32 1, !"wchar_size", i32 4}
!21 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!22 = distinct !DISubprogram(name: "xdp_prog_simple", scope: !3, file: !3, line: 6, type: !23, isLocal: false, isDefinition: true, scopeLine: 7, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !37)
!23 = !DISubroutineType(types: !24)
!24 = !{!25, !26}
!25 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!26 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !27, size: 64)
!27 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !28)
!28 = !{!29, !33, !34, !35, !36}
!29 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !27, file: !6, line: 2857, baseType: !30, size: 32)
!30 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !31, line: 27, baseType: !32)
!31 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "/home/minglei/photon/examples/xdp")
!32 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!33 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !27, file: !6, line: 2858, baseType: !30, size: 32, offset: 32)
!34 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !27, file: !6, line: 2859, baseType: !30, size: 32, offset: 64)
!35 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !27, file: !6, line: 2861, baseType: !30, size: 32, offset: 96)
!36 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !27, file: !6, line: 2862, baseType: !30, size: 32, offset: 128)
!37 = !{!38}
!38 = !DILocalVariable(name: "ctx", arg: 1, scope: !22, file: !3, line: 6, type: !26)
!39 = !DILocation(line: 6, column: 37, scope: !22)
!40 = !DILocation(line: 8, column: 2, scope: !22)
