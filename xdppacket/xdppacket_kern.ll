; ModuleID = 'xdppacket_kern.c'
source_filename = "xdppacket_kern.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.packet_metadata = type { %union.anon, %union.anon.0, [2 x i16], i16, i16, i16, i16, i32 }
%union.anon = type { [4 x i32] }
%union.anon.0 = type { [4 x i32] }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }

@packet_map = global %struct.bpf_map_def { i32 4, i32 4, i32 4, i32 128, i32 0 }, section "maps", align 4, !dbg !0
@_license = global [4 x i8] c"GPL\00", section "license", align 1, !dbg !74
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @packet_map to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @process_packet to i8*)], section "llvm.metadata"

; Function Attrs: nounwind uwtable
define i32 @process_packet(%struct.xdp_md*) #0 section "xdp_packet" !dbg !99 {
  %2 = alloca %struct.packet_metadata, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !111, metadata !DIExpression()), !dbg !152
  %3 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !153
  %4 = load i32, i32* %3, align 4, !dbg !153, !tbaa !154
  %5 = zext i32 %4 to i64, !dbg !159
  %6 = inttoptr i64 %5 to i8*, !dbg !160
  call void @llvm.dbg.value(metadata i8* %6, metadata !112, metadata !DIExpression()), !dbg !161
  %7 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !162
  %8 = load i32, i32* %7, align 4, !dbg !162, !tbaa !163
  %9 = zext i32 %8 to i64, !dbg !164
  %10 = inttoptr i64 %9 to i8*, !dbg !165
  call void @llvm.dbg.value(metadata i8* %10, metadata !113, metadata !DIExpression()), !dbg !166
  call void @llvm.dbg.value(metadata i8* %10, metadata !167, metadata !DIExpression()), !dbg !179
  call void @llvm.dbg.value(metadata i8* %6, metadata !174, metadata !DIExpression()), !dbg !182
  call void @llvm.dbg.value(metadata i8* %10, metadata !175, metadata !DIExpression()), !dbg !183
  %11 = getelementptr i8, i8* %10, i64 14, !dbg !184
  %12 = icmp ugt i8* %11, %6, !dbg !186
  br i1 %12, label %107, label %13, !dbg !187

; <label>:13:                                     ; preds = %1
  %14 = getelementptr inbounds i8, i8* %10, i64 12, !dbg !188
  %15 = bitcast i8* %14 to i16*, !dbg !188
  %16 = load i16, i16* %15, align 1, !dbg !188, !tbaa !189
  %17 = icmp ne i16 %16, 8, !dbg !192
  %18 = getelementptr inbounds i8, i8* %10, i64 34, !dbg !193
  %19 = icmp ugt i8* %18, %6, !dbg !195
  %20 = or i1 %19, %17, !dbg !196
  call void @llvm.dbg.value(metadata i8* %11, metadata !176, metadata !DIExpression()), !dbg !197
  br i1 %20, label %107, label %21, !dbg !196

; <label>:21:                                     ; preds = %13
  %22 = getelementptr inbounds i8, i8* %10, i64 23, !dbg !198
  %23 = load i8, i8* %22, align 1, !dbg !198, !tbaa !200
  %24 = icmp eq i8 %23, 6, !dbg !202
  br i1 %24, label %25, label %107

; <label>:25:                                     ; preds = %21
  call void @llvm.dbg.value(metadata %struct.ethhdr* %27, metadata !114, metadata !DIExpression()), !dbg !203
  %26 = bitcast %struct.packet_metadata* %2 to i8*, !dbg !204
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %26) #3, !dbg !204
  call void @llvm.memset.p0i8.i64(i8* nonnull %26, i8 0, i64 48, i32 4, i1 false), !dbg !205
  call void @llvm.dbg.value(metadata i64 4294967295, metadata !151, metadata !DIExpression()), !dbg !206
  call void @llvm.dbg.value(metadata i32 14, metadata !149, metadata !DIExpression()), !dbg !207
  %27 = inttoptr i64 %9 to %struct.ethhdr*, !dbg !208
  %28 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %27, i64 0, i32 2, !dbg !209
  %29 = load i16, i16* %28, align 1, !dbg !209, !tbaa !189
  %30 = tail call i16 @llvm.bswap.i16(i16 %29), !dbg !209
  %31 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 3, !dbg !210
  store i16 %30, i16* %31, align 4, !dbg !211, !tbaa !212
  switch i16 %29, label %60 [
    i16 8, label %32
    i16 -8826, label %45
  ], !dbg !214

; <label>:32:                                     ; preds = %25
  call void @llvm.dbg.value(metadata %struct.packet_metadata* %2, metadata !125, metadata !DIExpression()), !dbg !205
  call void @llvm.dbg.value(metadata i64 14, metadata !215, metadata !DIExpression()), !dbg !225
  %33 = load i8, i8* %11, align 4, !dbg !230
  %34 = and i8 %33, 15, !dbg !230
  %35 = icmp eq i8 %34, 5, !dbg !232
  br i1 %35, label %36, label %106, !dbg !233

; <label>:36:                                     ; preds = %32
  %37 = getelementptr inbounds i8, i8* %10, i64 26, !dbg !234
  %38 = bitcast i8* %37 to i32*, !dbg !234
  %39 = load i32, i32* %38, align 4, !dbg !234, !tbaa !235
  %40 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 0, i32 0, i64 0, !dbg !236
  store i32 %39, i32* %40, align 4, !dbg !237, !tbaa !238
  %41 = getelementptr inbounds i8, i8* %10, i64 30, !dbg !239
  %42 = bitcast i8* %41 to i32*, !dbg !239
  %43 = load i32, i32* %42, align 4, !dbg !239, !tbaa !240
  %44 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 1, i32 0, i64 0, !dbg !241
  store i32 %43, i32* %44, align 4, !dbg !242, !tbaa !238
  br label %54, !dbg !243

; <label>:45:                                     ; preds = %25
  call void @llvm.dbg.value(metadata %struct.packet_metadata* %2, metadata !125, metadata !DIExpression()), !dbg !205
  call void @llvm.dbg.value(metadata i64 14, metadata !244, metadata !DIExpression()) #3, !dbg !281
  call void @llvm.dbg.value(metadata i8* %10, metadata !250, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)) #3, !dbg !286
  %46 = getelementptr inbounds i8, i8* %10, i64 54, !dbg !287
  %47 = icmp ugt i8* %46, %6, !dbg !289
  br i1 %47, label %106, label %48, !dbg !290

; <label>:48:                                     ; preds = %45
  %49 = getelementptr inbounds i8, i8* %10, i64 22, !dbg !291
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull %26, i8* nonnull %49, i64 16, i32 4, i1 false) #3, !dbg !292
  %50 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 1, i32 0, i64 0, !dbg !293
  %51 = bitcast i32* %50 to i8*, !dbg !293
  %52 = getelementptr inbounds i8, i8* %10, i64 38, !dbg !294
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull %51, i8* nonnull %52, i64 16, i32 4, i1 false) #3, !dbg !293
  %53 = getelementptr inbounds i8, i8* %10, i64 20, !dbg !295
  br label %54, !dbg !296

; <label>:54:                                     ; preds = %36, %48
  %55 = phi i8* [ %22, %36 ], [ %53, %48 ]
  %56 = phi i32 [ 34, %36 ], [ 54, %48 ]
  %57 = load i8, i8* %55, align 1, !tbaa !238
  %58 = zext i8 %57 to i16
  %59 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 4
  store i16 %58, i16* %59, align 2, !tbaa !297
  br label %60, !dbg !298

; <label>:60:                                     ; preds = %54, %25
  %61 = phi i16 [ 0, %25 ], [ %58, %54 ]
  %62 = phi i32 [ 14, %25 ], [ %56, %54 ]
  call void @llvm.dbg.value(metadata i32 %62, metadata !149, metadata !DIExpression()), !dbg !207
  %63 = zext i32 %62 to i64, !dbg !298
  %64 = getelementptr i8, i8* %10, i64 %63, !dbg !298
  %65 = icmp ugt i8* %64, %6, !dbg !300
  br i1 %65, label %106, label %66, !dbg !301

; <label>:66:                                     ; preds = %60
  %67 = icmp eq i16 %61, 6, !dbg !302
  br i1 %67, label %68, label %88, !dbg !304

; <label>:68:                                     ; preds = %66
  call void @llvm.dbg.value(metadata %struct.packet_metadata* %2, metadata !125, metadata !DIExpression()), !dbg !205
  call void @llvm.dbg.value(metadata i8* %10, metadata !305, metadata !DIExpression()), !dbg !333
  call void @llvm.dbg.value(metadata i64 %63, metadata !308, metadata !DIExpression()), !dbg !337
  call void @llvm.dbg.value(metadata i8* %6, metadata !309, metadata !DIExpression()), !dbg !338
  call void @llvm.dbg.value(metadata %struct.packet_metadata* %2, metadata !310, metadata !DIExpression()), !dbg !339
  call void @llvm.dbg.value(metadata i8* %64, metadata !311, metadata !DIExpression()), !dbg !340
  %69 = getelementptr inbounds i8, i8* %64, i64 20, !dbg !341
  %70 = icmp ugt i8* %69, %6, !dbg !343
  br i1 %70, label %106, label %71, !dbg !344

; <label>:71:                                     ; preds = %68
  %72 = bitcast i8* %64 to i16*, !dbg !345
  %73 = load i16, i16* %72, align 4, !dbg !345, !tbaa !346
  %74 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 2, i64 0, !dbg !348
  store i16 %73, i16* %74, align 4, !dbg !349, !tbaa !350
  %75 = getelementptr inbounds i8, i8* %64, i64 2, !dbg !351
  %76 = bitcast i8* %75 to i16*, !dbg !351
  %77 = load i16, i16* %76, align 2, !dbg !351, !tbaa !352
  %78 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 2, i64 1, !dbg !353
  store i16 %77, i16* %78, align 2, !dbg !354, !tbaa !350
  %79 = getelementptr inbounds i8, i8* %64, i64 4, !dbg !355
  %80 = bitcast i8* %79 to i32*, !dbg !355
  %81 = load i32, i32* %80, align 4, !dbg !355, !tbaa !356
  %82 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 7, !dbg !357
  store i32 %81, i32* %82, align 4, !dbg !358, !tbaa !359
  %83 = load i16, i16* %76, align 2, !dbg !360, !tbaa !352
  %84 = icmp eq i16 %83, 20736, !dbg !362
  br i1 %84, label %85, label %106, !dbg !363

; <label>:85:                                     ; preds = %71
  %86 = add nuw nsw i32 %62, 20, !dbg !364
  call void @llvm.dbg.value(metadata i32 %86, metadata !149, metadata !DIExpression()), !dbg !207
  %87 = zext i32 %86 to i64, !dbg !365
  br label %88, !dbg !366

; <label>:88:                                     ; preds = %85, %66
  %89 = phi i64 [ %87, %85 ], [ %63, %66 ], !dbg !365
  %90 = sub nsw i64 %5, %9, !dbg !367
  %91 = trunc i64 %90 to i16, !dbg !368
  %92 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 6, !dbg !369
  store i16 %91, i16* %92, align 2, !dbg !370, !tbaa !371
  %93 = sub nsw i64 %90, %89, !dbg !372
  %94 = trunc i64 %93 to i16, !dbg !373
  %95 = getelementptr inbounds %struct.packet_metadata, %struct.packet_metadata* %2, i64 0, i32 5, !dbg !374
  store i16 %94, i16* %95, align 4, !dbg !375, !tbaa !376
  %96 = and i64 %93, 65535, !dbg !377
  %97 = icmp ult i64 %96, 7, !dbg !377
  br i1 %97, label %106, label %98, !dbg !379

; <label>:98:                                     ; preds = %88
  %99 = and i64 %90, 65535, !dbg !380
  %100 = icmp ult i64 %99, 1024, !dbg !380
  %101 = select i1 %100, i64 %99, i64 1024, !dbg !380
  %102 = shl nuw nsw i64 %101, 32, !dbg !381
  %103 = or i64 %102, 4294967295, !dbg !382
  call void @llvm.dbg.value(metadata i64 %103, metadata !151, metadata !DIExpression()), !dbg !206
  %104 = bitcast %struct.xdp_md* %0 to i8*, !dbg !383
  %105 = call i32 inttoptr (i64 25 to i32 (i8*, i8*, i64, i8*, i64)*)(i8* %104, i8* bitcast (%struct.bpf_map_def* @packet_map to i8*), i64 %103, i8* nonnull %26, i64 48) #3, !dbg !384
  br label %106, !dbg !385

; <label>:106:                                    ; preds = %68, %32, %45, %88, %71, %60, %98
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %26) #3, !dbg !386
  br label %107

; <label>:107:                                    ; preds = %13, %21, %1, %106
  %108 = phi i32 [ 2, %106 ], [ 1, %1 ], [ 1, %21 ], [ 1, %13 ]
  ret i32 %108, !dbg !386
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
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2844, size: 32, elements: !7)
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
!75 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 80, type: !76, isLocal: false, isDefinition: true)
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
!99 = distinct !DISubprogram(name: "process_packet", scope: !3, file: !3, line: 24, type: !100, isLocal: false, isDefinition: true, scopeLine: 25, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !110)
!100 = !DISubroutineType(types: !101)
!101 = !{!86, !102}
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 64)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2855, size: 160, elements: !104)
!104 = !{!105, !106, !107, !108, !109}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !103, file: !6, line: 2856, baseType: !70, size: 32)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !103, file: !6, line: 2857, baseType: !70, size: 32, offset: 32)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !103, file: !6, line: 2858, baseType: !70, size: 32, offset: 64)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !103, file: !6, line: 2860, baseType: !70, size: 32, offset: 96)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !103, file: !6, line: 2861, baseType: !70, size: 32, offset: 128)
!110 = !{!111, !112, !113, !114, !125, !149, !150, !151}
!111 = !DILocalVariable(name: "ctx", arg: 1, scope: !99, file: !3, line: 24, type: !102)
!112 = !DILocalVariable(name: "data_end", scope: !99, file: !3, line: 26, type: !43)
!113 = !DILocalVariable(name: "data", scope: !99, file: !3, line: 27, type: !43)
!114 = !DILocalVariable(name: "eth", scope: !99, file: !3, line: 33, type: !115)
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
!125 = !DILocalVariable(name: "metadata", scope: !99, file: !3, line: 34, type: !126)
!126 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "packet_metadata", file: !127, line: 12, size: 384, elements: !128)
!127 = !DIFile(filename: "./xdppacket_common.h", directory: "/home/minglei/photon/xdppacket")
!128 = !{!129, !135, !140, !144, !145, !146, !147, !148}
!129 = !DIDerivedType(tag: DW_TAG_member, scope: !126, file: !127, line: 13, baseType: !130, size: 128)
!130 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !126, file: !127, line: 13, size: 128, elements: !131)
!131 = !{!132, !133}
!132 = !DIDerivedType(tag: DW_TAG_member, name: "src", scope: !130, file: !127, line: 14, baseType: !69, size: 32)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "srcv6", scope: !130, file: !127, line: 15, baseType: !134, size: 128)
!134 = !DICompositeType(tag: DW_TAG_array_type, baseType: !69, size: 128, elements: !78)
!135 = !DIDerivedType(tag: DW_TAG_member, scope: !126, file: !127, line: 17, baseType: !136, size: 128, offset: 128)
!136 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !126, file: !127, line: 17, size: 128, elements: !137)
!137 = !{!138, !139}
!138 = !DIDerivedType(tag: DW_TAG_member, name: "dst", scope: !136, file: !127, line: 18, baseType: !69, size: 32)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "dstv6", scope: !136, file: !127, line: 19, baseType: !134, size: 128)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "port16", scope: !126, file: !127, line: 21, baseType: !141, size: 32, offset: 256)
!141 = !DICompositeType(tag: DW_TAG_array_type, baseType: !48, size: 32, elements: !142)
!142 = !{!143}
!143 = !DISubrange(count: 2)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "l3_proto", scope: !126, file: !127, line: 22, baseType: !48, size: 16, offset: 288)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "l4_proto", scope: !126, file: !127, line: 23, baseType: !48, size: 16, offset: 304)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "data_len", scope: !126, file: !127, line: 24, baseType: !48, size: 16, offset: 320)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "pkt_len", scope: !126, file: !127, line: 25, baseType: !48, size: 16, offset: 336)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !126, file: !127, line: 26, baseType: !70, size: 32, offset: 352)
!149 = !DILocalVariable(name: "offset", scope: !99, file: !3, line: 35, type: !70)
!150 = !DILocalVariable(name: "packet_len", scope: !99, file: !3, line: 36, type: !70)
!151 = !DILocalVariable(name: "flags", scope: !99, file: !3, line: 37, type: !45)
!152 = !DILocation(line: 24, column: 35, scope: !99)
!153 = !DILocation(line: 26, column: 41, scope: !99)
!154 = !{!155, !156, i64 4}
!155 = !{!"xdp_md", !156, i64 0, !156, i64 4, !156, i64 8, !156, i64 12, !156, i64 16}
!156 = !{!"int", !157, i64 0}
!157 = !{!"omnipotent char", !158, i64 0}
!158 = !{!"Simple C/C++ TBAA"}
!159 = !DILocation(line: 26, column: 30, scope: !99)
!160 = !DILocation(line: 26, column: 22, scope: !99)
!161 = !DILocation(line: 26, column: 11, scope: !99)
!162 = !DILocation(line: 27, column: 37, scope: !99)
!163 = !{!155, !156, i64 0}
!164 = !DILocation(line: 27, column: 26, scope: !99)
!165 = !DILocation(line: 27, column: 18, scope: !99)
!166 = !DILocation(line: 27, column: 11, scope: !99)
!167 = !DILocalVariable(name: "data_begin", arg: 1, scope: !168, file: !169, line: 59, type: !43)
!168 = distinct !DISubprogram(name: "is_TCP", scope: !169, file: !169, line: 59, type: !170, isLocal: true, isDefinition: true, scopeLine: 60, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !173)
!169 = !DIFile(filename: "./xdppacket_helpers.h", directory: "/home/minglei/photon/xdppacket")
!170 = !DISubroutineType(types: !171)
!171 = !{!172, !43, !43}
!172 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!173 = !{!167, !174, !175, !176}
!174 = !DILocalVariable(name: "data_end", arg: 2, scope: !168, file: !169, line: 59, type: !43)
!175 = !DILocalVariable(name: "eth", scope: !168, file: !169, line: 61, type: !115)
!176 = !DILocalVariable(name: "iph", scope: !177, file: !169, line: 70, type: !50)
!177 = distinct !DILexicalBlock(scope: !178, file: !169, line: 69, column: 5)
!178 = distinct !DILexicalBlock(scope: !168, file: !169, line: 68, column: 9)
!179 = !DILocation(line: 59, column: 26, scope: !168, inlinedAt: !180)
!180 = distinct !DILocation(line: 30, column: 6, scope: !181)
!181 = distinct !DILexicalBlock(scope: !99, file: !3, line: 30, column: 5)
!182 = !DILocation(line: 59, column: 44, scope: !168, inlinedAt: !180)
!183 = !DILocation(line: 61, column: 20, scope: !168, inlinedAt: !180)
!184 = !DILocation(line: 64, column: 22, scope: !185, inlinedAt: !180)
!185 = distinct !DILexicalBlock(scope: !168, file: !169, line: 64, column: 9)
!186 = !DILocation(line: 64, column: 27, scope: !185, inlinedAt: !180)
!187 = !DILocation(line: 64, column: 9, scope: !168, inlinedAt: !180)
!188 = !DILocation(line: 68, column: 14, scope: !178, inlinedAt: !180)
!189 = !{!190, !191, i64 12}
!190 = !{!"ethhdr", !157, i64 0, !157, i64 6, !191, i64 12}
!191 = !{!"short", !157, i64 0}
!192 = !DILocation(line: 68, column: 22, scope: !178, inlinedAt: !180)
!193 = !DILocation(line: 71, column: 26, scope: !194, inlinedAt: !180)
!194 = distinct !DILexicalBlock(scope: !177, file: !169, line: 71, column: 13)
!195 = !DILocation(line: 71, column: 31, scope: !194, inlinedAt: !180)
!196 = !DILocation(line: 68, column: 9, scope: !168, inlinedAt: !180)
!197 = !DILocation(line: 70, column: 23, scope: !177, inlinedAt: !180)
!198 = !DILocation(line: 74, column: 17, scope: !199, inlinedAt: !180)
!199 = distinct !DILexicalBlock(scope: !177, file: !169, line: 74, column: 12)
!200 = !{!201, !157, i64 9}
!201 = !{!"iphdr", !157, i64 0, !157, i64 0, !157, i64 1, !191, i64 2, !191, i64 4, !191, i64 6, !157, i64 8, !157, i64 9, !191, i64 10, !156, i64 12, !156, i64 16}
!202 = !DILocation(line: 74, column: 26, scope: !199, inlinedAt: !180)
!203 = !DILocation(line: 33, column: 20, scope: !99)
!204 = !DILocation(line: 34, column: 5, scope: !99)
!205 = !DILocation(line: 34, column: 28, scope: !99)
!206 = !DILocation(line: 37, column: 8, scope: !99)
!207 = !DILocation(line: 35, column: 8, scope: !99)
!208 = !DILocation(line: 33, column: 26, scope: !99)
!209 = !DILocation(line: 43, column: 22, scope: !99)
!210 = !DILocation(line: 43, column: 11, scope: !99)
!211 = !DILocation(line: 43, column: 20, scope: !99)
!212 = !{!213, !191, i64 36}
!213 = !{!"packet_metadata", !157, i64 0, !157, i64 16, !157, i64 32, !191, i64 36, !191, i64 38, !191, i64 40, !191, i64 42, !156, i64 44}
!214 = !DILocation(line: 45, column: 6, scope: !99)
!215 = !DILocalVariable(name: "offset", arg: 2, scope: !216, file: !169, line: 23, type: !45)
!216 = distinct !DISubprogram(name: "parse_ip4", scope: !169, file: !169, line: 23, type: !217, isLocal: true, isDefinition: true, scopeLine: 25, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !220)
!217 = !DISubroutineType(types: !218)
!218 = !{!172, !43, !45, !43, !219}
!219 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !126, size: 64)
!220 = !{!221, !215, !222, !223, !224}
!221 = !DILocalVariable(name: "data", arg: 1, scope: !216, file: !169, line: 23, type: !43)
!222 = !DILocalVariable(name: "data_end", arg: 3, scope: !216, file: !169, line: 23, type: !43)
!223 = !DILocalVariable(name: "metadata", arg: 4, scope: !216, file: !169, line: 24, type: !219)
!224 = !DILocalVariable(name: "iph", scope: !216, file: !169, line: 26, type: !50)
!225 = !DILocation(line: 23, column: 57, scope: !216, inlinedAt: !226)
!226 = distinct !DILocation(line: 46, column: 8, scope: !227)
!227 = distinct !DILexicalBlock(scope: !228, file: !3, line: 46, column: 7)
!228 = distinct !DILexicalBlock(scope: !229, file: !3, line: 45, column: 37)
!229 = distinct !DILexicalBlock(scope: !99, file: !3, line: 45, column: 6)
!230 = !DILocation(line: 32, column: 11, scope: !231, inlinedAt: !226)
!231 = distinct !DILexicalBlock(scope: !216, file: !169, line: 32, column: 6)
!232 = !DILocation(line: 32, column: 15, scope: !231, inlinedAt: !226)
!233 = !DILocation(line: 32, column: 6, scope: !216, inlinedAt: !226)
!234 = !DILocation(line: 35, column: 23, scope: !216, inlinedAt: !226)
!235 = !{!201, !156, i64 12}
!236 = !DILocation(line: 35, column: 12, scope: !216, inlinedAt: !226)
!237 = !DILocation(line: 35, column: 16, scope: !216, inlinedAt: !226)
!238 = !{!157, !157, i64 0}
!239 = !DILocation(line: 36, column: 23, scope: !216, inlinedAt: !226)
!240 = !{!201, !156, i64 16}
!241 = !DILocation(line: 36, column: 12, scope: !216, inlinedAt: !226)
!242 = !DILocation(line: 36, column: 16, scope: !216, inlinedAt: !226)
!243 = !DILocation(line: 46, column: 7, scope: !228)
!244 = !DILocalVariable(name: "offset", arg: 2, scope: !245, file: !169, line: 42, type: !45)
!245 = distinct !DISubprogram(name: "parse_ip6", scope: !169, file: !169, line: 42, type: !217, isLocal: true, isDefinition: true, scopeLine: 44, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !246)
!246 = !{!247, !244, !248, !249, !250}
!247 = !DILocalVariable(name: "data", arg: 1, scope: !245, file: !169, line: 42, type: !43)
!248 = !DILocalVariable(name: "data_end", arg: 3, scope: !245, file: !169, line: 42, type: !43)
!249 = !DILocalVariable(name: "metadata", arg: 4, scope: !245, file: !169, line: 43, type: !219)
!250 = !DILocalVariable(name: "ip6h", scope: !245, file: !169, line: 45, type: !251)
!251 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !252, size: 64)
!252 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ipv6hdr", file: !253, line: 116, size: 320, elements: !254)
!253 = !DIFile(filename: "/usr/include/linux/ipv6.h", directory: "/home/minglei/photon/xdppacket")
!254 = !{!255, !256, !257, !261, !262, !263, !264, !280}
!255 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !252, file: !253, line: 118, baseType: !55, size: 4, flags: DIFlagBitField, extraData: i64 0)
!256 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !252, file: !253, line: 119, baseType: !55, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!257 = !DIDerivedType(tag: DW_TAG_member, name: "flow_lbl", scope: !252, file: !253, line: 126, baseType: !258, size: 24, offset: 8)
!258 = !DICompositeType(tag: DW_TAG_array_type, baseType: !55, size: 24, elements: !259)
!259 = !{!260}
!260 = !DISubrange(count: 3)
!261 = !DIDerivedType(tag: DW_TAG_member, name: "payload_len", scope: !252, file: !253, line: 128, baseType: !60, size: 16, offset: 32)
!262 = !DIDerivedType(tag: DW_TAG_member, name: "nexthdr", scope: !252, file: !253, line: 129, baseType: !55, size: 8, offset: 48)
!263 = !DIDerivedType(tag: DW_TAG_member, name: "hop_limit", scope: !252, file: !253, line: 130, baseType: !55, size: 8, offset: 56)
!264 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !252, file: !253, line: 132, baseType: !265, size: 128, offset: 64)
!265 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in6_addr", file: !266, line: 33, size: 128, elements: !267)
!266 = !DIFile(filename: "/usr/include/linux/in6.h", directory: "/home/minglei/photon/xdppacket")
!267 = !{!268}
!268 = !DIDerivedType(tag: DW_TAG_member, name: "in6_u", scope: !265, file: !266, line: 40, baseType: !269, size: 128)
!269 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !265, file: !266, line: 34, size: 128, elements: !270)
!270 = !{!271, !275, !279}
!271 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr8", scope: !269, file: !266, line: 35, baseType: !272, size: 128)
!272 = !DICompositeType(tag: DW_TAG_array_type, baseType: !55, size: 128, elements: !273)
!273 = !{!274}
!274 = !DISubrange(count: 16)
!275 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr16", scope: !269, file: !266, line: 37, baseType: !276, size: 128)
!276 = !DICompositeType(tag: DW_TAG_array_type, baseType: !60, size: 128, elements: !277)
!277 = !{!278}
!278 = !DISubrange(count: 8)
!279 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr32", scope: !269, file: !266, line: 38, baseType: !134, size: 128)
!280 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !252, file: !253, line: 133, baseType: !265, size: 128, offset: 192)
!281 = !DILocation(line: 42, column: 57, scope: !245, inlinedAt: !282)
!282 = distinct !DILocation(line: 50, column: 8, scope: !283)
!283 = distinct !DILexicalBlock(scope: !284, file: !3, line: 50, column: 7)
!284 = distinct !DILexicalBlock(scope: !285, file: !3, line: 49, column: 46)
!285 = distinct !DILexicalBlock(scope: !229, file: !3, line: 49, column: 13)
!286 = !DILocation(line: 45, column: 18, scope: !245, inlinedAt: !282)
!287 = !DILocation(line: 48, column: 11, scope: !288, inlinedAt: !282)
!288 = distinct !DILexicalBlock(scope: !245, file: !169, line: 48, column: 6)
!289 = !DILocation(line: 48, column: 15, scope: !288, inlinedAt: !282)
!290 = !DILocation(line: 48, column: 6, scope: !245, inlinedAt: !282)
!291 = !DILocation(line: 51, column: 32, scope: !245, inlinedAt: !282)
!292 = !DILocation(line: 51, column: 2, scope: !245, inlinedAt: !282)
!293 = !DILocation(line: 52, column: 2, scope: !245, inlinedAt: !282)
!294 = !DILocation(line: 52, column: 32, scope: !245, inlinedAt: !282)
!295 = !DILocation(line: 53, column: 29, scope: !245, inlinedAt: !282)
!296 = !DILocation(line: 50, column: 7, scope: !284)
!297 = !{!213, !191, i64 38}
!298 = !DILocation(line: 55, column: 11, scope: !299)
!299 = distinct !DILexicalBlock(scope: !99, file: !3, line: 55, column: 6)
!300 = !DILocation(line: 55, column: 20, scope: !299)
!301 = !DILocation(line: 55, column: 6, scope: !99)
!302 = !DILocation(line: 58, column: 24, scope: !303)
!303 = distinct !DILexicalBlock(scope: !99, file: !3, line: 58, column: 6)
!304 = !DILocation(line: 58, column: 6, scope: !99)
!305 = !DILocalVariable(name: "data", arg: 1, scope: !306, file: !169, line: 3, type: !43)
!306 = distinct !DISubprogram(name: "parse_tcp", scope: !169, file: !169, line: 3, type: !217, isLocal: true, isDefinition: true, scopeLine: 5, flags: DIFlagPrototyped, isOptimized: true, unit: !2, variables: !307)
!307 = !{!305, !308, !309, !310, !311}
!308 = !DILocalVariable(name: "offset", arg: 2, scope: !306, file: !169, line: 3, type: !45)
!309 = !DILocalVariable(name: "data_end", arg: 3, scope: !306, file: !169, line: 3, type: !43)
!310 = !DILocalVariable(name: "metadata", arg: 4, scope: !306, file: !169, line: 4, type: !219)
!311 = !DILocalVariable(name: "tcp", scope: !306, file: !169, line: 6, type: !312)
!312 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !313, size: 64)
!313 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tcphdr", file: !314, line: 25, size: 160, elements: !315)
!314 = !DIFile(filename: "/usr/include/linux/tcp.h", directory: "/home/minglei/photon/xdppacket")
!315 = !{!316, !317, !318, !319, !320, !321, !322, !323, !324, !325, !326, !327, !328, !329, !330, !331, !332}
!316 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !313, file: !314, line: 26, baseType: !60, size: 16)
!317 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !313, file: !314, line: 27, baseType: !60, size: 16, offset: 16)
!318 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !313, file: !314, line: 28, baseType: !69, size: 32, offset: 32)
!319 = !DIDerivedType(tag: DW_TAG_member, name: "ack_seq", scope: !313, file: !314, line: 29, baseType: !69, size: 32, offset: 64)
!320 = !DIDerivedType(tag: DW_TAG_member, name: "res1", scope: !313, file: !314, line: 31, baseType: !48, size: 4, offset: 96, flags: DIFlagBitField, extraData: i64 96)
!321 = !DIDerivedType(tag: DW_TAG_member, name: "doff", scope: !313, file: !314, line: 32, baseType: !48, size: 4, offset: 100, flags: DIFlagBitField, extraData: i64 96)
!322 = !DIDerivedType(tag: DW_TAG_member, name: "fin", scope: !313, file: !314, line: 33, baseType: !48, size: 1, offset: 104, flags: DIFlagBitField, extraData: i64 96)
!323 = !DIDerivedType(tag: DW_TAG_member, name: "syn", scope: !313, file: !314, line: 34, baseType: !48, size: 1, offset: 105, flags: DIFlagBitField, extraData: i64 96)
!324 = !DIDerivedType(tag: DW_TAG_member, name: "rst", scope: !313, file: !314, line: 35, baseType: !48, size: 1, offset: 106, flags: DIFlagBitField, extraData: i64 96)
!325 = !DIDerivedType(tag: DW_TAG_member, name: "psh", scope: !313, file: !314, line: 36, baseType: !48, size: 1, offset: 107, flags: DIFlagBitField, extraData: i64 96)
!326 = !DIDerivedType(tag: DW_TAG_member, name: "ack", scope: !313, file: !314, line: 37, baseType: !48, size: 1, offset: 108, flags: DIFlagBitField, extraData: i64 96)
!327 = !DIDerivedType(tag: DW_TAG_member, name: "urg", scope: !313, file: !314, line: 38, baseType: !48, size: 1, offset: 109, flags: DIFlagBitField, extraData: i64 96)
!328 = !DIDerivedType(tag: DW_TAG_member, name: "ece", scope: !313, file: !314, line: 39, baseType: !48, size: 1, offset: 110, flags: DIFlagBitField, extraData: i64 96)
!329 = !DIDerivedType(tag: DW_TAG_member, name: "cwr", scope: !313, file: !314, line: 40, baseType: !48, size: 1, offset: 111, flags: DIFlagBitField, extraData: i64 96)
!330 = !DIDerivedType(tag: DW_TAG_member, name: "window", scope: !313, file: !314, line: 55, baseType: !60, size: 16, offset: 112)
!331 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !313, file: !314, line: 56, baseType: !67, size: 16, offset: 128)
!332 = !DIDerivedType(tag: DW_TAG_member, name: "urg_ptr", scope: !313, file: !314, line: 57, baseType: !60, size: 16, offset: 144)
!333 = !DILocation(line: 3, column: 45, scope: !306, inlinedAt: !334)
!334 = distinct !DILocation(line: 59, column: 8, scope: !335)
!335 = distinct !DILexicalBlock(scope: !336, file: !3, line: 59, column: 7)
!336 = distinct !DILexicalBlock(scope: !303, file: !3, line: 58, column: 40)
!337 = !DILocation(line: 3, column: 57, scope: !306, inlinedAt: !334)
!338 = !DILocation(line: 3, column: 71, scope: !306, inlinedAt: !334)
!339 = !DILocation(line: 4, column: 35, scope: !306, inlinedAt: !334)
!340 = !DILocation(line: 6, column: 17, scope: !306, inlinedAt: !334)
!341 = !DILocation(line: 9, column: 10, scope: !342, inlinedAt: !334)
!342 = distinct !DILexicalBlock(scope: !306, file: !169, line: 9, column: 6)
!343 = !DILocation(line: 9, column: 14, scope: !342, inlinedAt: !334)
!344 = !DILocation(line: 9, column: 6, scope: !306, inlinedAt: !334)
!345 = !DILocation(line: 12, column: 29, scope: !306, inlinedAt: !334)
!346 = !{!347, !191, i64 0}
!347 = !{!"tcphdr", !191, i64 0, !191, i64 2, !156, i64 4, !156, i64 8, !191, i64 12, !191, i64 12, !191, i64 13, !191, i64 13, !191, i64 13, !191, i64 13, !191, i64 13, !191, i64 13, !191, i64 13, !191, i64 13, !191, i64 14, !191, i64 16, !191, i64 18}
!348 = !DILocation(line: 12, column: 2, scope: !306, inlinedAt: !334)
!349 = !DILocation(line: 12, column: 22, scope: !306, inlinedAt: !334)
!350 = !{!191, !191, i64 0}
!351 = !DILocation(line: 13, column: 29, scope: !306, inlinedAt: !334)
!352 = !{!347, !191, i64 2}
!353 = !DILocation(line: 13, column: 2, scope: !306, inlinedAt: !334)
!354 = !DILocation(line: 13, column: 22, scope: !306, inlinedAt: !334)
!355 = !DILocation(line: 14, column: 23, scope: !306, inlinedAt: !334)
!356 = !{!347, !156, i64 4}
!357 = !DILocation(line: 14, column: 12, scope: !306, inlinedAt: !334)
!358 = !DILocation(line: 14, column: 16, scope: !306, inlinedAt: !334)
!359 = !{!213, !156, i64 44}
!360 = !DILocation(line: 16, column: 14, scope: !361, inlinedAt: !334)
!361 = distinct !DILexicalBlock(scope: !306, file: !169, line: 16, column: 9)
!362 = !DILocation(line: 16, column: 19, scope: !361, inlinedAt: !334)
!363 = !DILocation(line: 59, column: 7, scope: !336)
!364 = !DILocation(line: 61, column: 10, scope: !336)
!365 = !DILocation(line: 65, column: 40, scope: !99)
!366 = !DILocation(line: 62, column: 2, scope: !336)
!367 = !DILocation(line: 64, column: 30, scope: !99)
!368 = !DILocation(line: 64, column: 21, scope: !99)
!369 = !DILocation(line: 64, column: 11, scope: !99)
!370 = !DILocation(line: 64, column: 19, scope: !99)
!371 = !{!213, !191, i64 42}
!372 = !DILocation(line: 65, column: 38, scope: !99)
!373 = !DILocation(line: 65, column: 22, scope: !99)
!374 = !DILocation(line: 65, column: 11, scope: !99)
!375 = !DILocation(line: 65, column: 20, scope: !99)
!376 = !{!213, !191, i64 40}
!377 = !DILocation(line: 68, column: 23, scope: !378)
!378 = distinct !DILexicalBlock(scope: !99, file: !3, line: 68, column: 5)
!379 = !DILocation(line: 68, column: 5, scope: !99)
!380 = !DILocation(line: 72, column: 15, scope: !99)
!381 = !DILocation(line: 73, column: 29, scope: !99)
!382 = !DILocation(line: 73, column: 8, scope: !99)
!383 = !DILocation(line: 75, column: 24, scope: !99)
!384 = !DILocation(line: 75, column: 2, scope: !99)
!385 = !DILocation(line: 77, column: 2, scope: !99)
!386 = !DILocation(line: 78, column: 1, scope: !99)
