
builds/runtime-fix3-v2-7.2.11-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

0000000000012c30 <mtgpu_drm_sync_irqs>:
   12c30:	f3 0f 1e fa          	endbr64
   12c34:	e8 00 00 00 00       	call   12c39 <mtgpu_drm_sync_irqs+0x9>
			12c35: R_X86_64_PLT32	__fentry__-0x4
   12c39:	48 8b 47 78          	mov    0x78(%rdi),%rax
   12c3d:	48 85 c0             	test   %rax,%rax
   12c40:	74 5c                	je     12c9e <mtgpu_drm_sync_irqs+0x6e>
   12c42:	48 83 ec 10          	sub    $0x10,%rsp
   12c46:	48 89 6c 24 08       	mov    %rbp,0x8(%rsp)
   12c4b:	48 8b a8 80 06 00 00 	mov    0x680(%rax),%rbp
   12c52:	48 85 ed             	test   %rbp,%rbp
   12c55:	74 39                	je     12c90 <mtgpu_drm_sync_irqs+0x60>
   12c57:	48 8b 45 20          	mov    0x20(%rbp),%rax
   12c5b:	48 85 c0             	test   %rax,%rax
   12c5e:	74 30                	je     12c90 <mtgpu_drm_sync_irqs+0x60>
   12c60:	8b 55 04             	mov    0x4(%rbp),%edx
   12c63:	85 d2                	test   %edx,%edx
   12c65:	74 29                	je     12c90 <mtgpu_drm_sync_irqs+0x60>
   12c67:	48 89 1c 24          	mov    %rbx,(%rsp)
   12c6b:	31 db                	xor    %ebx,%ebx
   12c6d:	eb 04                	jmp    12c73 <mtgpu_drm_sync_irqs+0x43>
   12c6f:	48 8b 45 20          	mov    0x20(%rbp),%rax
   12c73:	48 89 da             	mov    %rbx,%rdx
   12c76:	48 83 c3 01          	add    $0x1,%rbx
   12c7a:	48 c1 e2 05          	shl    $0x5,%rdx
   12c7e:	8b 7c 10 04          	mov    0x4(%rax,%rdx,1),%edi
   12c82:	e8 00 00 00 00       	call   12c87 <mtgpu_drm_sync_irqs+0x57>
			12c83: R_X86_64_PLT32	synchronize_irq-0x4
   12c87:	3b 5d 04             	cmp    0x4(%rbp),%ebx
   12c8a:	72 e3                	jb     12c6f <mtgpu_drm_sync_irqs+0x3f>
   12c8c:	48 8b 1c 24          	mov    (%rsp),%rbx
   12c90:	48 8b 6c 24 08       	mov    0x8(%rsp),%rbp
   12c95:	48 83 c4 10          	add    $0x10,%rsp
   12c99:	e9 00 00 00 00       	jmp    12c9e <mtgpu_drm_sync_irqs+0x6e>
			12c9a: R_X86_64_PLT32	__x86_return_thunk-0x4
   12c9e:	e9 00 00 00 00       	jmp    12ca3 <mtgpu_drm_sync_irqs+0x73>
			12c9f: R_X86_64_PLT32	__x86_return_thunk-0x4

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
