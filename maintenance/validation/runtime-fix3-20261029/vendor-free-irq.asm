
work/mtgpu-3.1.0/objs/x86_64/mtgpu_core.o_binary:     file format elf64-x86-64


Disassembly of section .text:

0000000000096b30 <mtgpu_free_irq>:
   96b30:	e8 00 00 00 00       	call   96b35 <mtgpu_free_irq+0x5>
			96b31: R_X86_64_PLT32	__fentry__-0x4
   96b35:	55                   	push   %rbp
   96b36:	48 89 e5             	mov    %rsp,%rbp
   96b39:	41 56                	push   %r14
   96b3b:	41 55                	push   %r13
   96b3d:	41 54                	push   %r12
   96b3f:	49 89 fc             	mov    %rdi,%r12
   96b42:	53                   	push   %rbx
   96b43:	48 8b 9f 80 06 00 00 	mov    0x680(%rdi),%rbx
   96b4a:	48 8b 3f             	mov    (%rdi),%rdi
   96b4d:	e8 00 00 00 00       	call   96b52 <mtgpu_free_irq+0x22>
			96b4e: R_X86_64_PLT32	os_to_pci_dev-0x4
   96b52:	8b 73 04             	mov    0x4(%rbx),%esi
   96b55:	85 f6                	test   %esi,%esi
   96b57:	75 11                	jne    96b6a <mtgpu_free_irq+0x3a>
   96b59:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 96b5f <mtgpu_free_irq+0x2f>
			96b5b: R_X86_64_PC32	os_value+0x524
   96b5f:	f7 d8                	neg    %eax
   96b61:	5b                   	pop    %rbx
   96b62:	41 5c                	pop    %r12
   96b64:	41 5d                	pop    %r13
   96b66:	41 5e                	pop    %r14
   96b68:	5d                   	pop    %rbp
   96b69:	c3                   	ret
   96b6a:	49 8b 3c 24          	mov    (%r12),%rdi
   96b6e:	49 89 c6             	mov    %rax,%r14
   96b71:	e8 00 00 00 00       	call   96b76 <mtgpu_free_irq+0x46>
			96b72: R_X86_64_PLT32	os_dev_is_pci-0x4
   96b76:	84 c0                	test   %al,%al
   96b78:	0f 84 a6 00 00 00    	je     96c24 <mtgpu_free_irq+0xf4>
   96b7e:	8b 03                	mov    (%rbx),%eax
   96b80:	48 3b 05 00 00 00 00 	cmp    0x0(%rip),%rax        # 96b87 <mtgpu_free_irq+0x57>
			96b83: R_X86_64_PC32	os_value-0x4
   96b87:	0f 84 e2 00 00 00    	je     96c6f <mtgpu_free_irq+0x13f>
   96b8d:	8b 53 04             	mov    0x4(%rbx),%edx
   96b90:	45 31 e4             	xor    %r12d,%r12d
   96b93:	85 d2                	test   %edx,%edx
   96b95:	74 35                	je     96bcc <mtgpu_free_irq+0x9c>
   96b97:	44 89 e6             	mov    %r12d,%esi
   96b9a:	4c 89 f7             	mov    %r14,%rdi
   96b9d:	4d 63 ec             	movslq %r12d,%r13
   96ba0:	e8 00 00 00 00       	call   96ba5 <mtgpu_free_irq+0x75>
			96ba1: R_X86_64_PLT32	os_pci_irq_vector-0x4
   96ba5:	44 89 e6             	mov    %r12d,%esi
   96ba8:	4c 89 f7             	mov    %r14,%rdi
   96bab:	49 c1 e5 05          	shl    $0x5,%r13
   96baf:	4c 03 6b 20          	add    0x20(%rbx),%r13
   96bb3:	41 83 c4 01          	add    $0x1,%r12d
   96bb7:	e8 00 00 00 00       	call   96bbc <mtgpu_free_irq+0x8c>
			96bb8: R_X86_64_PLT32	os_pci_irq_vector-0x4
   96bbc:	4c 89 ee             	mov    %r13,%rsi
   96bbf:	89 c7                	mov    %eax,%edi
   96bc1:	e8 00 00 00 00       	call   96bc6 <mtgpu_free_irq+0x96>
			96bc2: R_X86_64_PLT32	os_free_irq-0x4
   96bc6:	44 39 63 04          	cmp    %r12d,0x4(%rbx)
   96bca:	77 cb                	ja     96b97 <mtgpu_free_irq+0x67>
   96bcc:	4c 89 f7             	mov    %r14,%rdi
   96bcf:	e8 00 00 00 00       	call   96bd4 <mtgpu_free_irq+0xa4>
			96bd0: R_X86_64_PLT32	os_pci_free_irq_vectors-0x4
   96bd4:	48 8b 7b 20          	mov    0x20(%rbx),%rdi
   96bd8:	e8 00 00 00 00       	call   96bdd <mtgpu_free_irq+0xad>
			96bd9: R_X86_64_PLT32	os_kfree-0x4
   96bdd:	8b 43 04             	mov    0x4(%rbx),%eax
   96be0:	45 31 e4             	xor    %r12d,%r12d
   96be3:	85 c0                	test   %eax,%eax
   96be5:	74 2b                	je     96c12 <mtgpu_free_irq+0xe2>
   96be7:	48 8b 43 18          	mov    0x18(%rbx),%rax
   96beb:	4d 63 ec             	movslq %r12d,%r13
   96bee:	4a 8b 3c e8          	mov    (%rax,%r13,8),%rdi
   96bf2:	48 85 ff             	test   %rdi,%rdi
   96bf5:	74 11                	je     96c08 <mtgpu_free_irq+0xd8>
   96bf7:	e8 00 00 00 00       	call   96bfc <mtgpu_free_irq+0xcc>
			96bf8: R_X86_64_PLT32	os_kfree-0x4
   96bfc:	48 8b 43 18          	mov    0x18(%rbx),%rax
   96c00:	4a c7 04 e8 00 00 00 	movq   $0x0,(%rax,%r13,8)
   96c07:	00 
   96c08:	41 83 c4 01          	add    $0x1,%r12d
   96c0c:	44 39 63 04          	cmp    %r12d,0x4(%rbx)
   96c10:	77 d5                	ja     96be7 <mtgpu_free_irq+0xb7>
   96c12:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%rbx)
   96c19:	31 c0                	xor    %eax,%eax
   96c1b:	5b                   	pop    %rbx
   96c1c:	41 5c                	pop    %r12
   96c1e:	41 5d                	pop    %r13
   96c20:	41 5e                	pop    %r14
   96c22:	5d                   	pop    %rbp
   96c23:	c3                   	ret
   96c24:	4d 8b a4 24 80 06 00 	mov    0x680(%r12),%r12
   96c2b:	00 
   96c2c:	41 8b 4c 24 04       	mov    0x4(%r12),%ecx
   96c31:	85 c9                	test   %ecx,%ecx
   96c33:	74 20                	je     96c55 <mtgpu_free_irq+0x125>
   96c35:	31 db                	xor    %ebx,%ebx
   96c37:	48 63 f3             	movslq %ebx,%rsi
   96c3a:	83 c3 01             	add    $0x1,%ebx
   96c3d:	48 c1 e6 05          	shl    $0x5,%rsi
   96c41:	49 03 74 24 20       	add    0x20(%r12),%rsi
   96c46:	8b 7e 04             	mov    0x4(%rsi),%edi
   96c49:	e8 00 00 00 00       	call   96c4e <mtgpu_free_irq+0x11e>
			96c4a: R_X86_64_PLT32	os_free_irq-0x4
   96c4e:	41 39 5c 24 04       	cmp    %ebx,0x4(%r12)
   96c53:	77 e2                	ja     96c37 <mtgpu_free_irq+0x107>
   96c55:	49 8b 7c 24 20       	mov    0x20(%r12),%rdi
   96c5a:	e8 00 00 00 00       	call   96c5f <mtgpu_free_irq+0x12f>
			96c5b: R_X86_64_PLT32	os_kfree-0x4
   96c5f:	31 c0                	xor    %eax,%eax
   96c61:	41 c7 44 24 04 00 00 	movl   $0x0,0x4(%r12)
   96c68:	00 00 
   96c6a:	e9 f2 fe ff ff       	jmp    96b61 <mtgpu_free_irq+0x31>
   96c6f:	4c 8b 63 20          	mov    0x20(%rbx),%r12
   96c73:	4c 89 f7             	mov    %r14,%rdi
   96c76:	e8 00 00 00 00       	call   96c7b <mtgpu_free_irq+0x14b>
			96c77: R_X86_64_PLT32	os_get_pci_irq-0x4
   96c7b:	89 c7                	mov    %eax,%edi
   96c7d:	4c 89 e6             	mov    %r12,%rsi
   96c80:	e8 00 00 00 00       	call   96c85 <mtgpu_free_irq+0x155>
			96c81: R_X86_64_PLT32	os_free_irq-0x4
   96c85:	e9 53 ff ff ff       	jmp    96bdd <mtgpu_free_irq+0xad>
