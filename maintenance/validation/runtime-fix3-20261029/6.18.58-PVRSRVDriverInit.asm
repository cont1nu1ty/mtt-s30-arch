
builds/runtime-fix3-v2-6.18.58-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

000000000001c070 <PVRSRVDriverInit>:
   1c070:	f3 0f 1e fa          	endbr64
   1c074:	e8 00 00 00 00       	call   1c079 <PVRSRVDriverInit+0x9>
			1c075: R_X86_64_PLT32	__fentry__-0x4
   1c079:	48 83 ec 08          	sub    $0x8,%rsp
   1c07d:	e8 00 00 00 00       	call   1c082 <PVRSRVDriverInit+0x12>
			1c07e: R_X86_64_PLT32	PVROSFuncInit-0x4
   1c082:	85 c0                	test   %eax,%eax
   1c084:	0f 85 9e 00 00 00    	jne    1c128 <PVRSRVDriverInit+0xb8>
   1c08a:	e8 00 00 00 00       	call   1c08f <PVRSRVDriverInit+0x1f>
			1c08b: R_X86_64_PLT32	PVRSRVCommonDriverInit-0x4
   1c08f:	85 c0                	test   %eax,%eax
   1c091:	0f 85 98 00 00 00    	jne    1c12f <PVRSRVDriverInit+0xbf>
   1c097:	e8 00 00 00 00       	call   1c09c <PVRSRVDriverInit+0x2c>
			1c098: R_X86_64_PLT32	pvr_sync_register_functions-0x4
   1c09c:	85 c0                	test   %eax,%eax
   1c09e:	0f 85 95 00 00 00    	jne    1c139 <PVRSRVDriverInit+0xc9>
   1c0a4:	e8 00 00 00 00       	call   1c0a9 <PVRSRVDriverInit+0x39>
			1c0a5: R_X86_64_PLT32	pvr_sync_init-0x4
   1c0a9:	89 c1                	mov    %eax,%ecx
   1c0ab:	85 c0                	test   %eax,%eax
   1c0ad:	74 0b                	je     1c0ba <PVRSRVDriverInit+0x4a>
   1c0af:	89 c8                	mov    %ecx,%eax
   1c0b1:	48 83 c4 08          	add    $0x8,%rsp
   1c0b5:	e9 00 00 00 00       	jmp    1c0ba <PVRSRVDriverInit+0x4a>
			1c0b6: R_X86_64_PLT32	__x86_return_thunk-0x4
   1c0ba:	e8 00 00 00 00       	call   1c0bf <PVRSRVDriverInit+0x4f>
			1c0bb: R_X86_64_PLT32	mtgpu_sync_init-0x4
   1c0bf:	89 c1                	mov    %eax,%ecx
   1c0c1:	85 c0                	test   %eax,%eax
   1c0c3:	75 ea                	jne    1c0af <PVRSRVDriverInit+0x3f>
   1c0c5:	e8 00 00 00 00       	call   1c0ca <PVRSRVDriverInit+0x5a>
			1c0c6: R_X86_64_PLT32	mtgpu_sched_fence_slab_init-0x4
   1c0ca:	89 c1                	mov    %eax,%ecx
   1c0cc:	85 c0                	test   %eax,%eax
   1c0ce:	75 df                	jne    1c0af <PVRSRVDriverInit+0x3f>
   1c0d0:	e8 00 00 00 00       	call   1c0d5 <PVRSRVDriverInit+0x65>
			1c0d1: R_X86_64_PLT32	mtgpu_buffer_fence_ops_init-0x4
   1c0d5:	89 c1                	mov    %eax,%ecx
   1c0d7:	85 c0                	test   %eax,%eax
   1c0d9:	75 d4                	jne    1c0af <PVRSRVDriverInit+0x3f>
   1c0db:	89 44 24 04          	mov    %eax,0x4(%rsp)
   1c0df:	e8 00 00 00 00       	call   1c0e4 <PVRSRVDriverInit+0x74>
			1c0e0: R_X86_64_PLT32	pvr_apphint_init-0x4
   1c0e4:	e8 00 00 00 00       	call   1c0e9 <PVRSRVDriverInit+0x79>
			1c0e5: R_X86_64_PLT32	PVRGpuTraceSupportInit-0x4
   1c0e9:	85 c0                	test   %eax,%eax
   1c0eb:	75 3b                	jne    1c128 <PVRSRVDriverInit+0xb8>
   1c0ed:	e8 00 00 00 00       	call   1c0f2 <PVRSRVDriverInit+0x82>
			1c0ee: R_X86_64_PLT32	PVRDebugFsRegister-0x4
   1c0f2:	85 c0                	test   %eax,%eax
   1c0f4:	75 32                	jne    1c128 <PVRSRVDriverInit+0xb8>
   1c0f6:	31 ff                	xor    %edi,%edi
   1c0f8:	e8 00 00 00 00       	call   1c0fd <PVRSRVDriverInit+0x8d>
			1c0f9: R_X86_64_PLT32	PVRGpuTraceInitAppHintCallbacks-0x4
   1c0fd:	31 d2                	xor    %edx,%edx
   1c0ff:	be 00 01 00 00       	mov    $0x100,%esi
   1c104:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1c107: R_X86_64_32S	.rodata.str1.1+0xdf0
   1c10b:	e8 00 00 00 00       	call   1c110 <PVRSRVDriverInit+0xa0>
			1c10c: R_X86_64_PLT32	alloc_workqueue_noprof-0x4
   1c110:	8b 4c 24 04          	mov    0x4(%rsp),%ecx
   1c114:	48 85 c0             	test   %rax,%rax
   1c117:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 1c11e <PVRSRVDriverInit+0xae>
			1c11a: R_X86_64_PC32	mtgpu_wq-0x4
   1c11e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
   1c123:	0f 44 c8             	cmove  %eax,%ecx
   1c126:	eb 87                	jmp    1c0af <PVRSRVDriverInit+0x3f>
   1c128:	b9 f4 ff ff ff       	mov    $0xfffffff4,%ecx
   1c12d:	eb 80                	jmp    1c0af <PVRSRVDriverInit+0x3f>
   1c12f:	b9 ed ff ff ff       	mov    $0xffffffed,%ecx
   1c134:	e9 76 ff ff ff       	jmp    1c0af <PVRSRVDriverInit+0x3f>
   1c139:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
   1c13e:	e9 6c ff ff ff       	jmp    1c0af <PVRSRVDriverInit+0x3f>

Disassembly of section .text.unlikely:

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
