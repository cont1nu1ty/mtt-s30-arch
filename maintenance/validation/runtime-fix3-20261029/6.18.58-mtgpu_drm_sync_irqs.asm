
builds/runtime-fix3-v2-6.18.58-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

0000000000012bd0 <mtgpu_drm_sync_irqs>:
   12bd0:	f3 0f 1e fa          	endbr64
   12bd4:	e8 00 00 00 00       	call   12bd9 <mtgpu_drm_sync_irqs+0x9>
			12bd5: R_X86_64_PLT32	__fentry__-0x4
   12bd9:	48 8b 47 78          	mov    0x78(%rdi),%rax
   12bdd:	48 85 c0             	test   %rax,%rax
   12be0:	74 5c                	je     12c3e <mtgpu_drm_sync_irqs+0x6e>
   12be2:	48 83 ec 10          	sub    $0x10,%rsp
   12be6:	48 89 6c 24 08       	mov    %rbp,0x8(%rsp)
   12beb:	48 8b a8 80 06 00 00 	mov    0x680(%rax),%rbp
   12bf2:	48 85 ed             	test   %rbp,%rbp
   12bf5:	74 39                	je     12c30 <mtgpu_drm_sync_irqs+0x60>
   12bf7:	48 8b 45 20          	mov    0x20(%rbp),%rax
   12bfb:	48 85 c0             	test   %rax,%rax
   12bfe:	74 30                	je     12c30 <mtgpu_drm_sync_irqs+0x60>
   12c00:	8b 55 04             	mov    0x4(%rbp),%edx
   12c03:	85 d2                	test   %edx,%edx
   12c05:	74 29                	je     12c30 <mtgpu_drm_sync_irqs+0x60>
   12c07:	48 89 1c 24          	mov    %rbx,(%rsp)
   12c0b:	31 db                	xor    %ebx,%ebx
   12c0d:	eb 04                	jmp    12c13 <mtgpu_drm_sync_irqs+0x43>
   12c0f:	48 8b 45 20          	mov    0x20(%rbp),%rax
   12c13:	48 89 da             	mov    %rbx,%rdx
   12c16:	48 83 c3 01          	add    $0x1,%rbx
   12c1a:	48 c1 e2 05          	shl    $0x5,%rdx
   12c1e:	8b 7c 10 04          	mov    0x4(%rax,%rdx,1),%edi
   12c22:	e8 00 00 00 00       	call   12c27 <mtgpu_drm_sync_irqs+0x57>
			12c23: R_X86_64_PLT32	synchronize_irq-0x4
   12c27:	3b 5d 04             	cmp    0x4(%rbp),%ebx
   12c2a:	72 e3                	jb     12c0f <mtgpu_drm_sync_irqs+0x3f>
   12c2c:	48 8b 1c 24          	mov    (%rsp),%rbx
   12c30:	48 8b 6c 24 08       	mov    0x8(%rsp),%rbp
   12c35:	48 83 c4 10          	add    $0x10,%rsp
   12c39:	e9 00 00 00 00       	jmp    12c3e <mtgpu_drm_sync_irqs+0x6e>
			12c3a: R_X86_64_PLT32	__x86_return_thunk-0x4
   12c3e:	e9 00 00 00 00       	jmp    12c43 <mtgpu_drm_sync_irqs+0x73>
			12c3f: R_X86_64_PLT32	__x86_return_thunk-0x4

Disassembly of section .text.unlikely:

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
