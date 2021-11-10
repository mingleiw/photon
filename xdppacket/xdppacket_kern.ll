; ModuleID = 'xdppacket_kern.c'
source_filename = "xdppacket_kern.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.packet_meta = type { %union.anon, %union.anon.0, [2 x i16], i16, i16, i16, i16, i32 }
%union.anon = type { [4 x i32] }
%union.anon.0 = type { [4 x i32] }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }

@packet_map = global %struct.bpf_map_def { i32 4, i32 4, i32 4, i32 128, i32 0 }, section "maps", align 4, !dbg !0
@_license = global [4 x i8] c"GPL\00", section "license", align 1, !dbg !74
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @packet_map to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_packet_prog to i8*)], section "llvm.metadata"

; Function Attrs: nounwind uwtable
define i32 @xdp_packet_prog(%struct.xdp_md*) #0 section "xdp_packet" !dbg !99 {
  %2 = alloca %struct.packet_meta, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !111, metadata !DIExpression()), !dbg !150
  %3 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !151
  %4 = load i32, i32* %3, align 4, !dbg !151, !tbaa !152
  %5 = zext i32 %4 to i64, !dbg !157
  %6 = inttoptr i64 %5 to i8*, !dbg !158
  call void @llvm.dbg.value(metadata i8* %6, metadata !112, metadata !DIExpression()), !dbg !159
  %7 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !160
  %8 = load i32, i32* %7, align 4, !dbg !160, !tbaa !161
  %9 = zext i32 %8 to i64, !dbg !162
  %10 = inttoptr i64 %9 to i8*, !dbg !163
  call void @llvm.dbg.value(metadata i8* %10, metadata !113, metadata !DIExpression()), !dbg !164
  call void @llvm.dbg.value(metadata i8* %10, metadata !165, metadata !DIExpression()), !dbg !176
  call void @llvm.dbg.value(metadata i8* %6, metadata !171, metadata !DIExpression()), !dbg !179
  call void @llvm.dbg.value(metadata i8* %10, metadata !172, metadata !DIExpression()), !dbg !180
  %11 = getelementptr i8, i8* %10, i64 14, !dbg !181
  %12 = icmp ugt i8* %11, %6, !dbg !183
  br i1 %12, label %113, label %13, !dbg !184

; <label>:13:                                     ; preds = %1
  %14 = getelementptr inbounds i8, i8* %10, i64 12, !dbg !185
  %15 = bitcast i8* %14 to i16*, !dbg !185
  %16 = load i16, i16* %15, align 1, !dbg !185, !tbaa !186
  %17 = icmp ne i16 %16, 8, !dbg !189
  %18 = getelementptr inbounds i8, i8* %10, i64 34, !dbg !190
  %19 = icmp ugt i8* %18, %6, !dbg !192
  %20 = or i1 %19, %17, !dbg !193
  call void @llvm.dbg.value(metadata i8* %11, metadata !173, metadata !DIExpression()), !dbg !194
  br i1 %20, label %113, label %21, !dbg !193

; <label>:21:                                     ; preds = %13
  %22 = getelementptr inbounds i8, i8* %10, i64 23, !dbg !195
  %23 = load i8, i8* %22, align 1, !dbg !195, !tbaa !197
  %24 = icmp eq i8 %23, 6, !dbg !199
  br i1 %24, label %25, label %113

; <label>:25:                                     ; preds = %21
  call void @llvm.dbg.value(metadata %struct.ethhdr* %27, metadata !114, metadata !DIExpression()), !dbg !200
  %26 = bitcast %struct.packet_meta* %2 to i8*, !dbg !201
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %26) #3, !dbg !201
  call void @llvm.memset.p0i8.i64(i8* nonnull %26, i8 0, i64 48, i32 4, i1 false), !dbg !202
  call void @llvm.dbg.value(metadata i32 14, metadata !149, metadata !DIExpression()), !dbg !203
  %27 = inttoptr i64 %9 to %struct.ethhdr*, !dbg !204
  %28 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %27, i64 0, i32 2, !dbg !205
  %29 = load i16, i16* %28, align 1, !dbg !205, !tbaa !186
  %30 = tail call i16 @llvm.bswap.i16(i16 %29), !dbg !205
  %31 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 3, !dbg !206
  store i16 %30, i16* %31, align 4, !dbg !207, !tbaa !208
  switch i16 %29, label %60 [
    i16 8, label %32
    i16 -8826, label %45
  ], !dbg !210

; <label>:32:                                     ; preds = %25
  call void @llvm.dbg.value(metadata %struct.packet_meta* %2, metadata !125, metadata !DIExpression()), !dbg !202
  call void @llvm.dbg.value(metadata i64 14, metadata !211, metadata !DIExpression()), !dbg !221
  %33 = load i8, i8* %11, align 4, !dbg !226
  %34 = and i8 %33, 15, !dbg !226
  %35 = icmp eq i8 %34, 5, !dbg !228
  br i1 %35, label %36, label %112, !dbg !229

; <label>:36:                                     ; preds = %32
  %37 = getelementptr inbounds i8, i8* %10, i64 26, !dbg !230
  %38 = bitcast i8* %37 to i32*, !dbg !230
  %39 = load i32, i32* %38, align 4, !dbg !230, !tbaa !231
  %40 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 0, i32 0, i64 0, !dbg !232
  store i32 %39, i32* %40, align 4, !dbg !233, !tbaa !234
  %41 = getelementptr inbounds i8, i8* %10, i64 30, !dbg !235
  %42 = bitcast i8* %41 to i32*, !dbg !235
  %43 = load i32, i32* %42, align 4, !dbg !235, !tbaa !236
  %44 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 1, i32 0, i64 0, !dbg !237
  store i32 %43, i32* %44, align 4, !dbg !238, !tbaa !234
  br label %54, !dbg !239

; <label>:45:                                     ; preds = %25
  call void @llvm.dbg.value(metadata %struct.packet_meta* %2, metadata !125, metadata !DIExpression()), !dbg !202
  call void @llvm.dbg.value(metadata i64 14, metadata !240, metadata !DIExpression()) #3, !dbg !277
  call void @llvm.dbg.value(metadata i8* %10, metadata !246, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)) #3, !dbg !282
  %46 = getelementptr inbounds i8, i8* %10, i64 54, !dbg !283
  %47 = icmp ugt i8* %46, %6, !dbg !285
  br i1 %47, label %112, label %48, !dbg !286

; <label>:48:                                     ; preds = %45
  %49 = getelementptr inbounds i8, i8* %10, i64 22, !dbg !287
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull %26, i8* nonnull %49, i64 16, i32 4, i1 false) #3, !dbg !288
  %50 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 1, i32 0, i64 0, !dbg !289
  %51 = bitcast i32* %50 to i8*, !dbg !289
  %52 = getelementptr inbounds i8, i8* %10, i64 38, !dbg !290
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull %51, i8* nonnull %52, i64 16, i32 4, i1 false) #3, !dbg !289
  %53 = getelementptr inbounds i8, i8* %10, i64 20, !dbg !291
  br label %54, !dbg !292

; <label>:54:                                     ; preds = %36, %48
  %55 = phi i8* [ %53, %48 ], [ %22, %36 ]
  %56 = phi i32 [ 54, %48 ], [ 34, %36 ]
  %57 = load i8, i8* %55, align 1, !tbaa !234
  %58 = zext i8 %57 to i16
  %59 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 4
  store i16 %58, i16* %59, align 2, !tbaa !293
  br label %60, !dbg !294

; <label>:60:                                     ; preds = %54, %25
  %61 = phi i8 [ 0, %25 ], [ %57, %54 ]
  %62 = phi i32 [ 14, %25 ], [ %56, %54 ]
  call void @llvm.dbg.value(metadata i32 %62, metadata !149, metadata !DIExpression()), !dbg !203
  %63 = zext i32 %62 to i64, !dbg !294
  %64 = getelementptr i8, i8* %10, i64 %63, !dbg !294
  %65 = icmp ugt i8* %64, %6, !dbg !296
  br i1 %65, label %112, label %66, !dbg !297

; <label>:66:                                     ; preds = %60
  switch i8 %61, label %95 [
    i8 6, label %67
    i8 17, label %83
  ], !dbg !298

; <label>:67:                                     ; preds = %66
  call void @llvm.dbg.value(metadata %struct.packet_meta* %2, metadata !125, metadata !DIExpression()), !dbg !202
  call void @llvm.dbg.value(metadata i8* %10, metadata !299, metadata !DIExpression()), !dbg !327
  call void @llvm.dbg.value(metadata i64 %63, metadata !302, metadata !DIExpression()), !dbg !332
  call void @llvm.dbg.value(metadata i8* %6, metadata !303, metadata !DIExpression()), !dbg !333
  call void @llvm.dbg.value(metadata %struct.packet_meta* %2, metadata !304, metadata !DIExpression()), !dbg !334
  call void @llvm.dbg.value(metadata i8* %64, metadata !305, metadata !DIExpression()), !dbg !335
  %68 = getelementptr inbounds i8, i8* %64, i64 20, !dbg !336
  %69 = icmp ugt i8* %68, %6, !dbg !338
  br i1 %69, label %112, label %70, !dbg !339

; <label>:70:                                     ; preds = %67
  %71 = bitcast i8* %64 to i16*, !dbg !340
  %72 = load i16, i16* %71, align 4, !dbg !340, !tbaa !341
  %73 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 2, i64 0, !dbg !343
  store i16 %72, i16* %73, align 4, !dbg !344, !tbaa !345
  %74 = getelementptr inbounds i8, i8* %64, i64 2, !dbg !346
  %75 = bitcast i8* %74 to i16*, !dbg !346
  %76 = load i16, i16* %75, align 2, !dbg !346, !tbaa !347
  %77 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 2, i64 1, !dbg !348
  store i16 %76, i16* %77, align 2, !dbg !349, !tbaa !345
  %78 = getelementptr inbounds i8, i8* %64, i64 4, !dbg !350
  %79 = bitcast i8* %78 to i32*, !dbg !350
  %80 = load i32, i32* %79, align 4, !dbg !350, !tbaa !351
  %81 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 7, !dbg !352
  store i32 %80, i32* %81, align 4, !dbg !353, !tbaa !354
  %82 = add nuw nsw i32 %62, 20, !dbg !355
  call void @llvm.dbg.value(metadata i32 %82, metadata !149, metadata !DIExpression()), !dbg !203
  br label %98, !dbg !356

; <label>:83:                                     ; preds = %66
  call void @llvm.dbg.value(metadata %struct.packet_meta* %2, metadata !125, metadata !DIExpression()), !dbg !202
  call void @llvm.dbg.value(metadata i8* %10, metadata !357, metadata !DIExpression()), !dbg !372
  call void @llvm.dbg.value(metadata i64 %63, metadata !360, metadata !DIExpression()), !dbg !377
  call void @llvm.dbg.value(metadata i8* %6, metadata !361, metadata !DIExpression()), !dbg !378
  call void @llvm.dbg.value(metadata %struct.packet_meta* %2, metadata !362, metadata !DIExpression()), !dbg !379
  call void @llvm.dbg.value(metadata i8* %64, metadata !363, metadata !DIExpression()), !dbg !380
  %84 = getelementptr inbounds i8, i8* %64, i64 8, !dbg !381
  %85 = icmp ugt i8* %84, %6, !dbg !383
  br i1 %85, label %112, label %86, !dbg !384

; <label>:86:                                     ; preds = %83
  %87 = bitcast i8* %64 to i16*, !dbg !385
  %88 = load i16, i16* %87, align 2, !dbg !385, !tbaa !386
  %89 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 2, i64 0, !dbg !388
  store i16 %88, i16* %89, align 4, !dbg !389, !tbaa !345
  %90 = getelementptr inbounds i8, i8* %64, i64 2, !dbg !390
  %91 = bitcast i8* %90 to i16*, !dbg !390
  %92 = load i16, i16* %91, align 2, !dbg !390, !tbaa !391
  %93 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 2, i64 1, !dbg !392
  store i16 %92, i16* %93, align 2, !dbg !393, !tbaa !345
  %94 = add nuw nsw i32 %62, 8, !dbg !394
  call void @llvm.dbg.value(metadata i32 %94, metadata !149, metadata !DIExpression()), !dbg !203
  br label %98, !dbg !395

; <label>:95:                                     ; preds = %66
  %96 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 2, i64 0, !dbg !396
  store i16 0, i16* %96, align 4, !dbg !398, !tbaa !345
  %97 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 2, i64 1, !dbg !399
  store i16 0, i16* %97, align 2, !dbg !400, !tbaa !345
  br label %98

; <label>:98:                                     ; preds = %86, %95, %70
  %99 = phi i32 [ %82, %70 ], [ %94, %86 ], [ %62, %95 ]
  call void @llvm.dbg.value(metadata i32 %99, metadata !149, metadata !DIExpression()), !dbg !203
  %100 = sub nsw i64 %5, %9, !dbg !401
  %101 = trunc i64 %100 to i16, !dbg !402
  %102 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 6, !dbg !403
  store i16 %101, i16* %102, align 2, !dbg !404, !tbaa !405
  %103 = zext i32 %99 to i64, !dbg !406
  %104 = sub nsw i64 %100, %103, !dbg !407
  %105 = trunc i64 %104 to i16, !dbg !408
  %106 = getelementptr inbounds %struct.packet_meta, %struct.packet_meta* %2, i64 0, i32 5, !dbg !409
  store i16 %105, i16* %106, align 4, !dbg !410, !tbaa !411
  %107 = bitcast %struct.xdp_md* %0 to i8*, !dbg !412
  %108 = shl i64 %100, 32, !dbg !413
  %109 = and i64 %108, 281470681743360, !dbg !413
  %110 = or i64 %109, 4294967295, !dbg !414
  %111 = call i32 inttoptr (i64 25 to i32 (i8*, i8*, i64, i8*, i64)*)(i8* %107, i8* bitcast (%struct.bpf_map_def* @packet_map to i8*), i64 %110, i8* nonnull %26, i64 48) #3, !dbg !415
  br label %112, !dbg !416

; <label>:112:                                    ; preds = %32, %83, %67, %45, %60, %98
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %26) #3, !dbg !417
  br label %113

; <label>:113:                                    ; preds = %13, %21, %1, %112
  %114 = phi i32 [ 2, %112 ], [ 1, %1 ], [ 1, %21 ], [ 1, %13 ]
  ret i32 %114, !dbg !417
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #1

; Function Attrs: nounwind readnone speculatable
declare i16 @llvm.bswap.i16(i16) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #1

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind readnone speculatable }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!95, !96, !97}
!llvm.ident = !{!98}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "packet_map", scope: !2, file: !3, line: 16, type: !87, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !42, globals: !73)
!3 = !DIFile(filename: "xdppacket_kern.c", directory: "/home/minglei/photon/xdppacket")
!4 = !{!5, !13}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, size: 32, elements: !7)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/home/minglei/photon/xdppacket")
!7 = !{!8, !9, !10, !11, !12}
!8 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!9 = !DIEnumerator(name: "XDP_DROP", value: 1)
!10 = !DIEnumerator(name: "XDP_PASS", value: 2)
!11 = !DIEnumerator(name: "XDP_TX", value: 3)
!12 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!13 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !14, line: 28, size: 32, elements: !15)
!14 = !DIFile(filename: "/usr/include/linux/in.h", directory: "/home/minglei/photon/xdppacket")
!15 = !{!16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41}
!16 = !DIEnumerator(name: "IPPROTO_IP", value: 0)
!17 = !DIEnumerator(name: "IPPROTO_ICMP", value: 1)
!18 = !DIEnumerator(name: "IPPROTO_IGMP", value: 2)
!19 = !DIEnumerator(name: "IPPROTO_IPIP", value: 4)
!20 = !DIEnumerator(name: "IPPROTO_TCP", value: 6)
!21 = !DIEnumerator(name: "IPPROTO_EGP", value: 8)
!22 = !DIEnumerator(name: "IPPROTO_PUP", value: 12)
!23 = !DIEnumerator(name: "IPPROTO_UDP", value: 17)
!24 = !DIEnumerator(name: "IPPROTO_IDP", value: 22)
!25 = !DIEnumerator(name: "IPPROTO_TP", value: 29)
!26 = !DIEnumerator(name: "IPPROTO_DCCP", value: 33)
!27 = !DIEnumerator(name: "IPPROTO_IPV6", value: 41)
!28 = !DIEnumerator(name: "IPPROTO_RSVP", value: 46)
!29 = !DIEnumerator(name: "IPPROTO_GRE", value: 47)
!30 = !DIEnumerator(name: "IPPROTO_ESP", value: 50)
!31 = !DIEnumerator(name: "IPPROTO_AH", value: 51)
!32 = !DIEnumerator(name: "IPPROTO_MTP", value: 92)
!33 = !DIEnumerator(name: "IPPROTO_BEETPH", value: 94)
!34 = !DIEnumerator(name: "IPPROTO_ENCAP", value: 98)
!35 = !DIEnumerator(name: "IPPROTO_PIM", value: 103)
!36 = !DIEnumerator(name: "IPPROTO_COMP", value: 108)
!37 = !DIEnumerator(name: "IPPROTO_SCTP", value: 132)
!38 = !DIEnumerator(name: "IPPROTO_UDPLITE", value: 136)
!39 = !DIEnumerator(name: "IPPROTO_MPLS", value: 137)
!40 = !DIEnumerator(name: "IPPROTO_RAW", value: 255)
!41 = !DIEnumerator(name: "IPPROTO_MAX", value: 256)
!42 = !{!43, !44, !45, !48, !50}
!43 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!44 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!45 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !46, line: 31, baseType: !47)
!46 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "/home/minglei/photon/xdppacket")
!47 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!48 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !46, line: 24, baseType: !49)
!49 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!50 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !51, size: 64)
!51 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !52, line: 86, size: 160, elements: !53)
!52 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "/home/minglei/photon/xdppacket")
!53 = !{!54, !57, !58, !59, !62, !63, !64, !65, !66, !68, !72}
!54 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !51, file: !52, line: 88, baseType: !55, size: 4, flags: DIFlagBitField, extraData: i64 0)
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !46, line: 21, baseType: !56)
!56 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!57 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !51, file: !52, line: 89, baseType: !55, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!58 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !51, file: !52, line: 96, baseType: !55, size: 8, offset: 8)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !51, file: !52, line: 97, baseType: !60, size: 16, offset: 16)
!60 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !61, line: 25, baseType: !48)
!61 = !DIFile(filename: "/usr/include/linux/types.h", directory: "/home/minglei/photon/xdppacket")
!62 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !51, file: !52, line: 98, baseType: !60, size: 16, offset: 32)
!63 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !51, file: !52, line: 99, baseType: !60, size: 16, offset: 48)
!64 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !51, file: !52, line: 100, baseType: !55, size: 8, offset: 64)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !51, file: !52, line: 101, baseType: !55, size: 8, offset: 72)
!66 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !51, file: !52, line: 102, baseType: !67, size: 16, offset: 80)
!67 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !61, line: 31, baseType: !48)
!68 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !51, file: !52, line: 103, baseType: !69, size: 32, offset: 96)
!69 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !61, line: 27, baseType: !70)
!70 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !46, line: 27, baseType: !71)
!71 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !51, file: !52, line: 104, baseType: !69, size: 32, offset: 128)
!73 = !{!0, !74, !80}
!74 = !DIGlobalVariableExpression(var: !75, expr: !DIExpression())
!75 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 167, type: !76, isLocal: false, isDefinition: true)
!76 = !DICompositeType(tag: DW_TAG_array_type, baseType: !77, size: 32, elements: !78)
!77 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!78 = !{!79}
!79 = !DISubrange(count: 4)
!80 = !DIGlobalVariableExpression(var: !81, expr: !DIExpression())
!81 = distinct !DIGlobalVariable(name: "bpf_perf_event_output", scope: !2, file: !82, line: 666, type: !83, isLocal: true, isDefinition: true)
!82 = !DIFile(filename: "../libbpf/src//root/usr/include/bpf/bpf_helper_defs.h", directory: "/home/minglei/photon/xdppacket")
!83 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !84, size: 64)
!84 = !DISubroutineType(types: !85)
!85 = !{!86, !43, !43, !45, !43, !45}
!86 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!87 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !88, line: 33, size: 160, elements: !89)
!88 = !DIFile(filename: "../libbpf/src//root/usr/include/bpf/bpf_helpers.h", directory: "/home/minglei/photon/xdppacket")
!89 = !{!90, !91, !92, !93, !94}
!90 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !87, file: !88, line: 34, baseType: !71, size: 32)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !87, file: !88, line: 35, baseType: !71, size: 32, offset: 32)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !87, file: !88, line: 36, baseType: !71, size: 32, offset: 64)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !87, file: !88, line: 37, baseType: !71, size: 32, offset: 96)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !87, file: !88, line: 38, baseType: !71, size: 32, offset: 128)
!95 = !{i32 2, !"Dwarf Version", i32 4}
!96 = !{i32 2, !"Debug Info Version", i32 3}
!97 = !{i32 1, !"wchar_size", i32 4}
!98 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!99 = distinct !DISubprogram(name: "xdp_packet_prog", scope: !3, file: !3, line: 112, type: !100, isLocal: false, isDefinition: true, scopeLine: 113, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !110)
!100 = !DISubroutineType(types: !101)
!101 = !{!86, !102}
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 64)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !104)
!104 = !{!105, !106, !107, !108, !109}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !103, file: !6, line: 2857, baseType: !70, size: 32)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !103, file: !6, line: 2858, baseType: !70, size: 32, offset: 32)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !103, file: !6, line: 2859, baseType: !70, size: 32, offset: 64)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !103, file: !6, line: 2861, baseType: !70, size: 32, offset: 96)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !103, file: !6, line: 2862, baseType: !70, size: 32, offset: 128)
!110 = !{!111, !112, !113, !114, !125, !149}
!111 = !DILocalVariable(name: "ctx", arg: 1, scope: !99, file: !3, line: 112, type: !102)
!112 = !DILocalVariable(name: "data_end", scope: !99, file: !3, line: 114, type: !43)
!113 = !DILocalVariable(name: "data", scope: !99, file: !3, line: 115, type: !43)
!114 = !DILocalVariable(name: "eth", scope: !99, file: !3, line: 120, type: !115)
!115 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !116, size: 64)
!116 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !117, line: 159, size: 112, elements: !118)
!117 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "/home/minglei/photon/xdppacket")
!118 = !{!119, !123, !124}
!119 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !116, file: !117, line: 160, baseType: !120, size: 48)
!120 = !DICompositeType(tag: DW_TAG_array_type, baseType: !56, size: 48, elements: !121)
!121 = !{!122}
!122 = !DISubrange(count: 6)
!123 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !116, file: !117, line: 161, baseType: !120, size: 48, offset: 48)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !116, file: !117, line: 162, baseType: !60, size: 16, offset: 96)
!125 = !DILocalVariable(name: "pkt", scope: !99, file: !3, line: 121, type: !126)
!126 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "packet_meta", file: !127, line: 14, size: 384, elements: !128)
!127 = !DIFile(filename: "./xdppacket_common.h", directory: "/home/minglei/photon/xdppacket")
!128 = !{!129, !135, !140, !144, !145, !146, !147, !148}
!129 = !DIDerivedType(tag: DW_TAG_member, scope: !126, file: !127, line: 15, baseType: !130, size: 128)
!130 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !126, file: !127, line: 15, size: 128, elements: !131)
!131 = !{!132, !133}
!132 = !DIDerivedType(tag: DW_TAG_member, name: "src", scope: !130, file: !127, line: 16, baseType: !69, size: 32)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "srcv6", scope: !130, file: !127, line: 17, baseType: !134, size: 128)
!134 = !DICompositeType(tag: DW_TAG_array_type, baseType: !69, size: 128, elements: !78)
!135 = !DIDerivedType(tag: DW_TAG_member, scope: !126, file: !127, line: 19, baseType: !136, size: 128, offset: 128)
!136 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !126, file: !127, line: 19, size: 128, elements: !137)
!137 = !{!138, !139}
!138 = !DIDerivedType(tag: DW_TAG_member, name: "dst", scope: !136, file: !127, line: 20, baseType: !69, size: 32)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "dstv6", scope: !136, file: !127, line: 21, baseType: !134, size: 128)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "port16", scope: !126, file: !127, line: 23, baseType: !141, size: 32, offset: 256)
!141 = !DICompositeType(tag: DW_TAG_array_type, baseType: !48, size: 32, elements: !142)
!142 = !{!143}
!143 = !DISubrange(count: 2)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "l3_proto", scope: !126, file: !127, line: 24, baseType: !48, size: 16, offset: 288)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "l4_proto", scope: !126, file: !127, line: 25, baseType: !48, size: 16, offset: 304)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "data_len", scope: !126, file: !127, line: 26, baseType: !48, size: 16, offset: 320)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "pkt_len", scope: !126, file: !127, line: 27, baseType: !48, size: 16, offset: 336)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !126, file: !127, line: 28, baseType: !70, size: 32, offset: 352)
!149 = !DILocalVariable(name: "off", scope: !99, file: !3, line: 122, type: !70)
!150 = !DILocation(line: 112, column: 36, scope: !99)
!151 = !DILocation(line: 114, column: 41, scope: !99)
!152 = !{!153, !154, i64 4}
!153 = !{!"xdp_md", !154, i64 0, !154, i64 4, !154, i64 8, !154, i64 12, !154, i64 16}
!154 = !{!"int", !155, i64 0}
!155 = !{!"omnipotent char", !156, i64 0}
!156 = !{!"Simple C/C++ TBAA"}
!157 = !DILocation(line: 114, column: 30, scope: !99)
!158 = !DILocation(line: 114, column: 22, scope: !99)
!159 = !DILocation(line: 114, column: 11, scope: !99)
!160 = !DILocation(line: 115, column: 37, scope: !99)
!161 = !{!153, !154, i64 0}
!162 = !DILocation(line: 115, column: 26, scope: !99)
!163 = !DILocation(line: 115, column: 18, scope: !99)
!164 = !DILocation(line: 115, column: 11, scope: !99)
!165 = !DILocalVariable(name: "data_begin", arg: 1, scope: !166, file: !3, line: 89, type: !43)
!166 = distinct !DISubprogram(name: "is_TCP", scope: !3, file: !3, line: 89, type: !167, isLocal: true, isDefinition: true, scopeLine: 90, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !170)
!167 = !DISubroutineType(types: !168)
!168 = !{!169, !43, !43}
!169 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!170 = !{!165, !171, !172, !173}
!171 = !DILocalVariable(name: "data_end", arg: 2, scope: !166, file: !3, line: 89, type: !43)
!172 = !DILocalVariable(name: "eth", scope: !166, file: !3, line: 91, type: !115)
!173 = !DILocalVariable(name: "iph", scope: !174, file: !3, line: 100, type: !50)
!174 = distinct !DILexicalBlock(scope: !175, file: !3, line: 99, column: 5)
!175 = distinct !DILexicalBlock(scope: !166, file: !3, line: 98, column: 9)
!176 = !DILocation(line: 89, column: 26, scope: !166, inlinedAt: !177)
!177 = distinct !DILocation(line: 117, column: 10, scope: !178)
!178 = distinct !DILexicalBlock(scope: !99, file: !3, line: 117, column: 9)
!179 = !DILocation(line: 89, column: 44, scope: !166, inlinedAt: !177)
!180 = !DILocation(line: 91, column: 20, scope: !166, inlinedAt: !177)
!181 = !DILocation(line: 94, column: 22, scope: !182, inlinedAt: !177)
!182 = distinct !DILexicalBlock(scope: !166, file: !3, line: 94, column: 9)
!183 = !DILocation(line: 94, column: 27, scope: !182, inlinedAt: !177)
!184 = !DILocation(line: 94, column: 9, scope: !166, inlinedAt: !177)
!185 = !DILocation(line: 98, column: 14, scope: !175, inlinedAt: !177)
!186 = !{!187, !188, i64 12}
!187 = !{!"ethhdr", !155, i64 0, !155, i64 6, !188, i64 12}
!188 = !{!"short", !155, i64 0}
!189 = !DILocation(line: 98, column: 22, scope: !175, inlinedAt: !177)
!190 = !DILocation(line: 101, column: 26, scope: !191, inlinedAt: !177)
!191 = distinct !DILexicalBlock(scope: !174, file: !3, line: 101, column: 13)
!192 = !DILocation(line: 101, column: 31, scope: !191, inlinedAt: !177)
!193 = !DILocation(line: 98, column: 9, scope: !166, inlinedAt: !177)
!194 = !DILocation(line: 100, column: 23, scope: !174, inlinedAt: !177)
!195 = !DILocation(line: 104, column: 17, scope: !196, inlinedAt: !177)
!196 = distinct !DILexicalBlock(scope: !174, file: !3, line: 104, column: 12)
!197 = !{!198, !155, i64 9}
!198 = !{!"iphdr", !155, i64 0, !155, i64 0, !155, i64 1, !188, i64 2, !188, i64 4, !188, i64 6, !155, i64 8, !155, i64 9, !188, i64 10, !154, i64 12, !154, i64 16}
!199 = !DILocation(line: 104, column: 26, scope: !196, inlinedAt: !177)
!200 = !DILocation(line: 120, column: 20, scope: !99)
!201 = !DILocation(line: 121, column: 5, scope: !99)
!202 = !DILocation(line: 121, column: 24, scope: !99)
!203 = !DILocation(line: 122, column: 8, scope: !99)
!204 = !DILocation(line: 120, column: 26, scope: !99)
!205 = !DILocation(line: 129, column: 17, scope: !99)
!206 = !DILocation(line: 129, column: 6, scope: !99)
!207 = !DILocation(line: 129, column: 15, scope: !99)
!208 = !{!209, !188, i64 36}
!209 = !{!"packet_meta", !155, i64 0, !155, i64 16, !155, i64 32, !188, i64 36, !188, i64 38, !188, i64 40, !188, i64 42, !154, i64 44}
!210 = !DILocation(line: 131, column: 6, scope: !99)
!211 = !DILocalVariable(name: "off", arg: 2, scope: !212, file: !3, line: 53, type: !45)
!212 = distinct !DISubprogram(name: "parse_ip4", scope: !3, file: !3, line: 53, type: !213, isLocal: true, isDefinition: true, scopeLine: 55, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !216)
!213 = !DISubroutineType(types: !214)
!214 = !{!169, !43, !45, !43, !215}
!215 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !126, size: 64)
!216 = !{!217, !211, !218, !219, !220}
!217 = !DILocalVariable(name: "data", arg: 1, scope: !212, file: !3, line: 53, type: !43)
!218 = !DILocalVariable(name: "data_end", arg: 3, scope: !212, file: !3, line: 53, type: !43)
!219 = !DILocalVariable(name: "pkt", arg: 4, scope: !212, file: !3, line: 54, type: !215)
!220 = !DILocalVariable(name: "iph", scope: !212, file: !3, line: 56, type: !50)
!221 = !DILocation(line: 53, column: 57, scope: !212, inlinedAt: !222)
!222 = distinct !DILocation(line: 132, column: 8, scope: !223)
!223 = distinct !DILexicalBlock(scope: !224, file: !3, line: 132, column: 7)
!224 = distinct !DILexicalBlock(scope: !225, file: !3, line: 131, column: 32)
!225 = distinct !DILexicalBlock(scope: !99, file: !3, line: 131, column: 6)
!226 = !DILocation(line: 62, column: 11, scope: !227, inlinedAt: !222)
!227 = distinct !DILexicalBlock(scope: !212, file: !3, line: 62, column: 6)
!228 = !DILocation(line: 62, column: 15, scope: !227, inlinedAt: !222)
!229 = !DILocation(line: 62, column: 6, scope: !212, inlinedAt: !222)
!230 = !DILocation(line: 65, column: 18, scope: !212, inlinedAt: !222)
!231 = !{!198, !154, i64 12}
!232 = !DILocation(line: 65, column: 7, scope: !212, inlinedAt: !222)
!233 = !DILocation(line: 65, column: 11, scope: !212, inlinedAt: !222)
!234 = !{!155, !155, i64 0}
!235 = !DILocation(line: 66, column: 18, scope: !212, inlinedAt: !222)
!236 = !{!198, !154, i64 16}
!237 = !DILocation(line: 66, column: 7, scope: !212, inlinedAt: !222)
!238 = !DILocation(line: 66, column: 11, scope: !212, inlinedAt: !222)
!239 = !DILocation(line: 132, column: 7, scope: !224)
!240 = !DILocalVariable(name: "off", arg: 2, scope: !241, file: !3, line: 72, type: !45)
!241 = distinct !DISubprogram(name: "parse_ip6", scope: !3, file: !3, line: 72, type: !213, isLocal: true, isDefinition: true, scopeLine: 74, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !242)
!242 = !{!243, !240, !244, !245, !246}
!243 = !DILocalVariable(name: "data", arg: 1, scope: !241, file: !3, line: 72, type: !43)
!244 = !DILocalVariable(name: "data_end", arg: 3, scope: !241, file: !3, line: 72, type: !43)
!245 = !DILocalVariable(name: "pkt", arg: 4, scope: !241, file: !3, line: 73, type: !215)
!246 = !DILocalVariable(name: "ip6h", scope: !241, file: !3, line: 75, type: !247)
!247 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !248, size: 64)
!248 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ipv6hdr", file: !249, line: 116, size: 320, elements: !250)
!249 = !DIFile(filename: "/usr/include/linux/ipv6.h", directory: "/home/minglei/photon/xdppacket")
!250 = !{!251, !252, !253, !257, !258, !259, !260, !276}
!251 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !248, file: !249, line: 118, baseType: !55, size: 4, flags: DIFlagBitField, extraData: i64 0)
!252 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !248, file: !249, line: 119, baseType: !55, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!253 = !DIDerivedType(tag: DW_TAG_member, name: "flow_lbl", scope: !248, file: !249, line: 126, baseType: !254, size: 24, offset: 8)
!254 = !DICompositeType(tag: DW_TAG_array_type, baseType: !55, size: 24, elements: !255)
!255 = !{!256}
!256 = !DISubrange(count: 3)
!257 = !DIDerivedType(tag: DW_TAG_member, name: "payload_len", scope: !248, file: !249, line: 128, baseType: !60, size: 16, offset: 32)
!258 = !DIDerivedType(tag: DW_TAG_member, name: "nexthdr", scope: !248, file: !249, line: 129, baseType: !55, size: 8, offset: 48)
!259 = !DIDerivedType(tag: DW_TAG_member, name: "hop_limit", scope: !248, file: !249, line: 130, baseType: !55, size: 8, offset: 56)
!260 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !248, file: !249, line: 132, baseType: !261, size: 128, offset: 64)
!261 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in6_addr", file: !262, line: 33, size: 128, elements: !263)
!262 = !DIFile(filename: "/usr/include/linux/in6.h", directory: "/home/minglei/photon/xdppacket")
!263 = !{!264}
!264 = !DIDerivedType(tag: DW_TAG_member, name: "in6_u", scope: !261, file: !262, line: 40, baseType: !265, size: 128)
!265 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !261, file: !262, line: 34, size: 128, elements: !266)
!266 = !{!267, !271, !275}
!267 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr8", scope: !265, file: !262, line: 35, baseType: !268, size: 128)
!268 = !DICompositeType(tag: DW_TAG_array_type, baseType: !55, size: 128, elements: !269)
!269 = !{!270}
!270 = !DISubrange(count: 16)
!271 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr16", scope: !265, file: !262, line: 37, baseType: !272, size: 128)
!272 = !DICompositeType(tag: DW_TAG_array_type, baseType: !60, size: 128, elements: !273)
!273 = !{!274}
!274 = !DISubrange(count: 8)
!275 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr32", scope: !265, file: !262, line: 38, baseType: !134, size: 128)
!276 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !248, file: !249, line: 133, baseType: !261, size: 128, offset: 192)
!277 = !DILocation(line: 72, column: 57, scope: !241, inlinedAt: !278)
!278 = distinct !DILocation(line: 136, column: 8, scope: !279)
!279 = distinct !DILexicalBlock(scope: !280, file: !3, line: 136, column: 7)
!280 = distinct !DILexicalBlock(scope: !281, file: !3, line: 135, column: 41)
!281 = distinct !DILexicalBlock(scope: !225, file: !3, line: 135, column: 13)
!282 = !DILocation(line: 75, column: 18, scope: !241, inlinedAt: !278)
!283 = !DILocation(line: 78, column: 11, scope: !284, inlinedAt: !278)
!284 = distinct !DILexicalBlock(scope: !241, file: !3, line: 78, column: 6)
!285 = !DILocation(line: 78, column: 15, scope: !284, inlinedAt: !278)
!286 = !DILocation(line: 78, column: 6, scope: !241, inlinedAt: !278)
!287 = !DILocation(line: 81, column: 27, scope: !241, inlinedAt: !278)
!288 = !DILocation(line: 81, column: 2, scope: !241, inlinedAt: !278)
!289 = !DILocation(line: 82, column: 2, scope: !241, inlinedAt: !278)
!290 = !DILocation(line: 82, column: 27, scope: !241, inlinedAt: !278)
!291 = !DILocation(line: 83, column: 24, scope: !241, inlinedAt: !278)
!292 = !DILocation(line: 136, column: 7, scope: !280)
!293 = !{!209, !188, i64 38}
!294 = !DILocation(line: 141, column: 11, scope: !295)
!295 = distinct !DILexicalBlock(scope: !99, file: !3, line: 141, column: 6)
!296 = !DILocation(line: 141, column: 17, scope: !295)
!297 = !DILocation(line: 141, column: 6, scope: !99)
!298 = !DILocation(line: 145, column: 6, scope: !99)
!299 = !DILocalVariable(name: "data", arg: 1, scope: !300, file: !3, line: 37, type: !43)
!300 = distinct !DISubprogram(name: "parse_tcp", scope: !3, file: !3, line: 37, type: !213, isLocal: true, isDefinition: true, scopeLine: 39, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !301)
!301 = !{!299, !302, !303, !304, !305}
!302 = !DILocalVariable(name: "off", arg: 2, scope: !300, file: !3, line: 37, type: !45)
!303 = !DILocalVariable(name: "data_end", arg: 3, scope: !300, file: !3, line: 37, type: !43)
!304 = !DILocalVariable(name: "pkt", arg: 4, scope: !300, file: !3, line: 38, type: !215)
!305 = !DILocalVariable(name: "tcp", scope: !300, file: !3, line: 40, type: !306)
!306 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !307, size: 64)
!307 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tcphdr", file: !308, line: 25, size: 160, elements: !309)
!308 = !DIFile(filename: "/usr/include/linux/tcp.h", directory: "/home/minglei/photon/xdppacket")
!309 = !{!310, !311, !312, !313, !314, !315, !316, !317, !318, !319, !320, !321, !322, !323, !324, !325, !326}
!310 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !307, file: !308, line: 26, baseType: !60, size: 16)
!311 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !307, file: !308, line: 27, baseType: !60, size: 16, offset: 16)
!312 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !307, file: !308, line: 28, baseType: !69, size: 32, offset: 32)
!313 = !DIDerivedType(tag: DW_TAG_member, name: "ack_seq", scope: !307, file: !308, line: 29, baseType: !69, size: 32, offset: 64)
!314 = !DIDerivedType(tag: DW_TAG_member, name: "res1", scope: !307, file: !308, line: 31, baseType: !48, size: 4, offset: 96, flags: DIFlagBitField, extraData: i64 96)
!315 = !DIDerivedType(tag: DW_TAG_member, name: "doff", scope: !307, file: !308, line: 32, baseType: !48, size: 4, offset: 100, flags: DIFlagBitField, extraData: i64 96)
!316 = !DIDerivedType(tag: DW_TAG_member, name: "fin", scope: !307, file: !308, line: 33, baseType: !48, size: 1, offset: 104, flags: DIFlagBitField, extraData: i64 96)
!317 = !DIDerivedType(tag: DW_TAG_member, name: "syn", scope: !307, file: !308, line: 34, baseType: !48, size: 1, offset: 105, flags: DIFlagBitField, extraData: i64 96)
!318 = !DIDerivedType(tag: DW_TAG_member, name: "rst", scope: !307, file: !308, line: 35, baseType: !48, size: 1, offset: 106, flags: DIFlagBitField, extraData: i64 96)
!319 = !DIDerivedType(tag: DW_TAG_member, name: "psh", scope: !307, file: !308, line: 36, baseType: !48, size: 1, offset: 107, flags: DIFlagBitField, extraData: i64 96)
!320 = !DIDerivedType(tag: DW_TAG_member, name: "ack", scope: !307, file: !308, line: 37, baseType: !48, size: 1, offset: 108, flags: DIFlagBitField, extraData: i64 96)
!321 = !DIDerivedType(tag: DW_TAG_member, name: "urg", scope: !307, file: !308, line: 38, baseType: !48, size: 1, offset: 109, flags: DIFlagBitField, extraData: i64 96)
!322 = !DIDerivedType(tag: DW_TAG_member, name: "ece", scope: !307, file: !308, line: 39, baseType: !48, size: 1, offset: 110, flags: DIFlagBitField, extraData: i64 96)
!323 = !DIDerivedType(tag: DW_TAG_member, name: "cwr", scope: !307, file: !308, line: 40, baseType: !48, size: 1, offset: 111, flags: DIFlagBitField, extraData: i64 96)
!324 = !DIDerivedType(tag: DW_TAG_member, name: "window", scope: !307, file: !308, line: 55, baseType: !60, size: 16, offset: 112)
!325 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !307, file: !308, line: 56, baseType: !67, size: 16, offset: 128)
!326 = !DIDerivedType(tag: DW_TAG_member, name: "urg_ptr", scope: !307, file: !308, line: 57, baseType: !60, size: 16, offset: 144)
!327 = !DILocation(line: 37, column: 45, scope: !300, inlinedAt: !328)
!328 = distinct !DILocation(line: 146, column: 8, scope: !329)
!329 = distinct !DILexicalBlock(scope: !330, file: !3, line: 146, column: 7)
!330 = distinct !DILexicalBlock(scope: !331, file: !3, line: 145, column: 35)
!331 = distinct !DILexicalBlock(scope: !99, file: !3, line: 145, column: 6)
!332 = !DILocation(line: 37, column: 57, scope: !300, inlinedAt: !328)
!333 = !DILocation(line: 37, column: 68, scope: !300, inlinedAt: !328)
!334 = !DILocation(line: 38, column: 31, scope: !300, inlinedAt: !328)
!335 = !DILocation(line: 40, column: 17, scope: !300, inlinedAt: !328)
!336 = !DILocation(line: 43, column: 10, scope: !337, inlinedAt: !328)
!337 = distinct !DILexicalBlock(scope: !300, file: !3, line: 43, column: 6)
!338 = !DILocation(line: 43, column: 14, scope: !337, inlinedAt: !328)
!339 = !DILocation(line: 43, column: 6, scope: !300, inlinedAt: !328)
!340 = !DILocation(line: 46, column: 24, scope: !300, inlinedAt: !328)
!341 = !{!342, !188, i64 0}
!342 = !{!"tcphdr", !188, i64 0, !188, i64 2, !154, i64 4, !154, i64 8, !188, i64 12, !188, i64 12, !188, i64 13, !188, i64 13, !188, i64 13, !188, i64 13, !188, i64 13, !188, i64 13, !188, i64 13, !188, i64 13, !188, i64 14, !188, i64 16, !188, i64 18}
!343 = !DILocation(line: 46, column: 2, scope: !300, inlinedAt: !328)
!344 = !DILocation(line: 46, column: 17, scope: !300, inlinedAt: !328)
!345 = !{!188, !188, i64 0}
!346 = !DILocation(line: 47, column: 24, scope: !300, inlinedAt: !328)
!347 = !{!342, !188, i64 2}
!348 = !DILocation(line: 47, column: 2, scope: !300, inlinedAt: !328)
!349 = !DILocation(line: 47, column: 17, scope: !300, inlinedAt: !328)
!350 = !DILocation(line: 48, column: 18, scope: !300, inlinedAt: !328)
!351 = !{!342, !154, i64 4}
!352 = !DILocation(line: 48, column: 7, scope: !300, inlinedAt: !328)
!353 = !DILocation(line: 48, column: 11, scope: !300, inlinedAt: !328)
!354 = !{!209, !154, i64 44}
!355 = !DILocation(line: 148, column: 7, scope: !330)
!356 = !DILocation(line: 149, column: 2, scope: !330)
!357 = !DILocalVariable(name: "data", arg: 1, scope: !358, file: !3, line: 23, type: !43)
!358 = distinct !DISubprogram(name: "parse_udp", scope: !3, file: !3, line: 23, type: !213, isLocal: true, isDefinition: true, scopeLine: 25, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !359)
!359 = !{!357, !360, !361, !362, !363}
!360 = !DILocalVariable(name: "off", arg: 2, scope: !358, file: !3, line: 23, type: !45)
!361 = !DILocalVariable(name: "data_end", arg: 3, scope: !358, file: !3, line: 23, type: !43)
!362 = !DILocalVariable(name: "pkt", arg: 4, scope: !358, file: !3, line: 24, type: !215)
!363 = !DILocalVariable(name: "udp", scope: !358, file: !3, line: 26, type: !364)
!364 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !365, size: 64)
!365 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "udphdr", file: !366, line: 23, size: 64, elements: !367)
!366 = !DIFile(filename: "/usr/include/linux/udp.h", directory: "/home/minglei/photon/xdppacket")
!367 = !{!368, !369, !370, !371}
!368 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !365, file: !366, line: 24, baseType: !60, size: 16)
!369 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !365, file: !366, line: 25, baseType: !60, size: 16, offset: 16)
!370 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !365, file: !366, line: 26, baseType: !60, size: 16, offset: 32)
!371 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !365, file: !366, line: 27, baseType: !67, size: 16, offset: 48)
!372 = !DILocation(line: 23, column: 45, scope: !358, inlinedAt: !373)
!373 = distinct !DILocation(line: 150, column: 8, scope: !374)
!374 = distinct !DILexicalBlock(scope: !375, file: !3, line: 150, column: 7)
!375 = distinct !DILexicalBlock(scope: !376, file: !3, line: 149, column: 42)
!376 = distinct !DILexicalBlock(scope: !331, file: !3, line: 149, column: 13)
!377 = !DILocation(line: 23, column: 57, scope: !358, inlinedAt: !373)
!378 = !DILocation(line: 23, column: 68, scope: !358, inlinedAt: !373)
!379 = !DILocation(line: 24, column: 31, scope: !358, inlinedAt: !373)
!380 = !DILocation(line: 26, column: 17, scope: !358, inlinedAt: !373)
!381 = !DILocation(line: 29, column: 10, scope: !382, inlinedAt: !373)
!382 = distinct !DILexicalBlock(scope: !358, file: !3, line: 29, column: 6)
!383 = !DILocation(line: 29, column: 14, scope: !382, inlinedAt: !373)
!384 = !DILocation(line: 29, column: 6, scope: !358, inlinedAt: !373)
!385 = !DILocation(line: 32, column: 24, scope: !358, inlinedAt: !373)
!386 = !{!387, !188, i64 0}
!387 = !{!"udphdr", !188, i64 0, !188, i64 2, !188, i64 4, !188, i64 6}
!388 = !DILocation(line: 32, column: 2, scope: !358, inlinedAt: !373)
!389 = !DILocation(line: 32, column: 17, scope: !358, inlinedAt: !373)
!390 = !DILocation(line: 33, column: 24, scope: !358, inlinedAt: !373)
!391 = !{!387, !188, i64 2}
!392 = !DILocation(line: 33, column: 2, scope: !358, inlinedAt: !373)
!393 = !DILocation(line: 33, column: 17, scope: !358, inlinedAt: !373)
!394 = !DILocation(line: 152, column: 7, scope: !375)
!395 = !DILocation(line: 153, column: 2, scope: !375)
!396 = !DILocation(line: 154, column: 3, scope: !397)
!397 = distinct !DILexicalBlock(scope: !376, file: !3, line: 153, column: 9)
!398 = !DILocation(line: 154, column: 17, scope: !397)
!399 = !DILocation(line: 155, column: 3, scope: !397)
!400 = !DILocation(line: 155, column: 17, scope: !397)
!401 = !DILocation(line: 158, column: 25, scope: !99)
!402 = !DILocation(line: 158, column: 16, scope: !99)
!403 = !DILocation(line: 158, column: 6, scope: !99)
!404 = !DILocation(line: 158, column: 14, scope: !99)
!405 = !{!209, !188, i64 42}
!406 = !DILocation(line: 159, column: 35, scope: !99)
!407 = !DILocation(line: 159, column: 33, scope: !99)
!408 = !DILocation(line: 159, column: 17, scope: !99)
!409 = !DILocation(line: 159, column: 6, scope: !99)
!410 = !DILocation(line: 159, column: 15, scope: !99)
!411 = !{!209, !188, i64 40}
!412 = !DILocation(line: 161, column: 24, scope: !99)
!413 = !DILocation(line: 162, column: 29, scope: !99)
!414 = !DILocation(line: 162, column: 35, scope: !99)
!415 = !DILocation(line: 161, column: 2, scope: !99)
!416 = !DILocation(line: 164, column: 2, scope: !99)
!417 = !DILocation(line: 165, column: 1, scope: !99)
