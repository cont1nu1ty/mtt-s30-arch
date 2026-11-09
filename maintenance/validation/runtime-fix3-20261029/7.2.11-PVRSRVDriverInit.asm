
builds/runtime-fix3-v2-7.2.11-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

000000000001c090 <PVRSRVDriverInit>:
   1c090:	f3 0f 1e fa          	endbr64
   1c094:	e8 00 00 00 00       	call   1c099 <PVRSRVDriverInit+0x9>
			1c095: R_X86_64_PLT32	__fentry__-0x4
   1c099:	48 83 ec 08          	sub    $0x8,%rsp
   1c09d:	e8 00 00 00 00       	call   1c0a2 <PVRSRVDriverInit+0x12>
			1c09e: R_X86_64_PLT32	PVROSFuncInit-0x4
   1c0a2:	85 c0                	test   %eax,%eax
   1c0a4:	0f 85 9e 00 00 00    	jne    1c148 <PVRSRVDriverInit+0xb8>
   1c0aa:	e8 00 00 00 00       	call   1c0af <PVRSRVDriverInit+0x1f>
			1c0ab: R_X86_64_PLT32	PVRSRVCommonDriverInit-0x4
   1c0af:	85 c0                	test   %eax,%eax
   1c0b1:	0f 85 98 00 00 00    	jne    1c14f <PVRSRVDriverInit+0xbf>
   1c0b7:	e8 00 00 00 00       	call   1c0bc <PVRSRVDriverInit+0x2c>
			1c0b8: R_X86_64_PLT32	pvr_sync_register_functions-0x4
   1c0bc:	85 c0                	test   %eax,%eax
   1c0be:	0f 85 95 00 00 00    	jne    1c159 <PVRSRVDriverInit+0xc9>
   1c0c4:	e8 00 00 00 00       	call   1c0c9 <PVRSRVDriverInit+0x39>
			1c0c5: R_X86_64_PLT32	pvr_sync_init-0x4
   1c0c9:	89 c1                	mov    %eax,%ecx
   1c0cb:	85 c0                	test   %eax,%eax
   1c0cd:	74 0b                	je     1c0da <PVRSRVDriverInit+0x4a>
   1c0cf:	89 c8                	mov    %ecx,%eax
   1c0d1:	48 83 c4 08          	add    $0x8,%rsp
   1c0d5:	e9 00 00 00 00       	jmp    1c0da <PVRSRVDriverInit+0x4a>
			1c0d6: R_X86_64_PLT32	__x86_return_thunk-0x4
   1c0da:	e8 00 00 00 00       	call   1c0df <PVRSRVDriverInit+0x4f>
			1c0db: R_X86_64_PLT32	mtgpu_sync_init-0x4
   1c0df:	89 c1                	mov    %eax,%ecx
   1c0e1:	85 c0                	test   %eax,%eax
   1c0e3:	75 ea                	jne    1c0cf <PVRSRVDriverInit+0x3f>
   1c0e5:	e8 00 00 00 00       	call   1c0ea <PVRSRVDriverInit+0x5a>
			1c0e6: R_X86_64_PLT32	mtgpu_sched_fence_slab_init-0x4
   1c0ea:	89 c1                	mov    %eax,%ecx
   1c0ec:	85 c0                	test   %eax,%eax
   1c0ee:	75 df                	jne    1c0cf <PVRSRVDriverInit+0x3f>
   1c0f0:	e8 00 00 00 00       	call   1c0f5 <PVRSRVDriverInit+0x65>
			1c0f1: R_X86_64_PLT32	mtgpu_buffer_fence_ops_init-0x4
   1c0f5:	89 c1                	mov    %eax,%ecx
   1c0f7:	85 c0                	test   %eax,%eax
   1c0f9:	75 d4                	jne    1c0cf <PVRSRVDriverInit+0x3f>
   1c0fb:	89 44 24 04          	mov    %eax,0x4(%rsp)
   1c0ff:	e8 00 00 00 00       	call   1c104 <PVRSRVDriverInit+0x74>
			1c100: R_X86_64_PLT32	pvr_apphint_init-0x4
   1c104:	e8 00 00 00 00       	call   1c109 <PVRSRVDriverInit+0x79>
			1c105: R_X86_64_PLT32	PVRGpuTraceSupportInit-0x4
   1c109:	85 c0                	test   %eax,%eax
   1c10b:	75 3b                	jne    1c148 <PVRSRVDriverInit+0xb8>
   1c10d:	e8 00 00 00 00       	call   1c112 <PVRSRVDriverInit+0x82>
			1c10e: R_X86_64_PLT32	PVRDebugFsRegister-0x4
   1c112:	85 c0                	test   %eax,%eax
   1c114:	75 32                	jne    1c148 <PVRSRVDriverInit+0xb8>
   1c116:	31 ff                	xor    %edi,%edi
   1c118:	e8 00 00 00 00       	call   1c11d <PVRSRVDriverInit+0x8d>
			1c119: R_X86_64_PLT32	PVRGpuTraceInitAppHintCallbacks-0x4
   1c11d:	31 d2                	xor    %edx,%edx
   1c11f:	be 00 01 00 00       	mov    $0x100,%esi
   1c124:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1c127: R_X86_64_32S	.rodata+0x38289
   1c12b:	e8 00 00 00 00       	call   1c130 <PVRSRVDriverInit+0xa0>
			1c12c: R_X86_64_PLT32	alloc_workqueue_noprof-0x4
   1c130:	8b 4c 24 04          	mov    0x4(%rsp),%ecx
   1c134:	48 85 c0             	test   %rax,%rax
   1c137:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 1c13e <PVRSRVDriverInit+0xae>
			1c13a: R_X86_64_PC32	mtgpu_wq-0x4
   1c13e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
   1c143:	0f 44 c8             	cmove  %eax,%ecx
   1c146:	eb 87                	jmp    1c0cf <PVRSRVDriverInit+0x3f>
   1c148:	b9 f4 ff ff ff       	mov    $0xfffffff4,%ecx
   1c14d:	eb 80                	jmp    1c0cf <PVRSRVDriverInit+0x3f>
   1c14f:	b9 ed ff ff ff       	mov    $0xffffffed,%ecx
   1c154:	e9 76 ff ff ff       	jmp    1c0cf <PVRSRVDriverInit+0x3f>
   1c159:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
   1c15e:	e9 6c ff ff ff       	jmp    1c0cf <PVRSRVDriverInit+0x3f>

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
