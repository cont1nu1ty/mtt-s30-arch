
builds/runtime-fix3-v2-6.18.58-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

000000000001a760 <vpu_component_bind>:
   1a760:	f3 0f 1e fa          	endbr64
   1a764:	e8 00 00 00 00       	call   1a769 <vpu_component_bind+0x9>
			1a765: R_X86_64_PLT32	__fentry__-0x4
   1a769:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
   1a770:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
   1a775:	48 89 54 24 28       	mov    %rdx,0x28(%rsp)
   1a77a:	48 89 9c 24 80 00 00 	mov    %rbx,0x80(%rsp)
   1a781:	00 
   1a782:	48 89 f3             	mov    %rsi,%rbx
   1a785:	4c 89 a4 24 90 00 00 	mov    %r12,0x90(%rsp)
   1a78c:	00 
   1a78d:	4c 89 b4 24 a0 00 00 	mov    %r14,0xa0(%rsp)
   1a794:	00 
   1a795:	4c 89 bc 24 a8 00 00 	mov    %r15,0xa8(%rsp)
   1a79c:	00 
   1a79d:	65 48 8b 05 00 00 00 	mov    %gs:0x0(%rip),%rax        # 1a7a5 <vpu_component_bind+0x45>
   1a7a4:	00 
			1a7a1: R_X86_64_PC32	__ref_stack_chk_guard-0x4
   1a7a5:	48 89 44 24 78       	mov    %rax,0x78(%rsp)
   1a7aa:	48 8b 42 40          	mov    0x40(%rdx),%rax
   1a7ae:	c7 44 24 54 00 00 00 	movl   $0x0,0x54(%rsp)
   1a7b5:	00 
   1a7b6:	48 c7 44 24 58 00 00 	movq   $0x0,0x58(%rsp)
   1a7bd:	00 00 
   1a7bf:	48 c7 44 24 60 00 00 	movq   $0x0,0x60(%rsp)
   1a7c6:	00 00 
   1a7c8:	48 c7 44 24 68 00 00 	movq   $0x0,0x68(%rsp)
   1a7cf:	00 00 
   1a7d1:	48 c7 44 24 70 00 00 	movq   $0x0,0x70(%rsp)
   1a7d8:	00 00 
   1a7da:	48 89 04 24          	mov    %rax,(%rsp)
   1a7de:	e8 00 00 00 00       	call   1a7e3 <vpu_component_bind+0x83>
			1a7df: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a7e3:	89 44 24 30          	mov    %eax,0x30(%rsp)
   1a7e7:	41 89 c6             	mov    %eax,%r14d
   1a7ea:	e8 00 00 00 00       	call   1a7ef <vpu_component_bind+0x8f>
			1a7eb: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a7ef:	89 44 24 34          	mov    %eax,0x34(%rsp)
   1a7f3:	e8 00 00 00 00       	call   1a7f8 <vpu_component_bind+0x98>
			1a7f4: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a7f8:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1a7fb: R_X86_64_32S	.rodata.str1.1+0xcd7
   1a7ff:	41 89 c4             	mov    %eax,%r12d
   1a802:	83 f8 ff             	cmp    $0xffffffff,%eax
   1a805:	74 15                	je     1a81c <vpu_component_bind+0xbc>
   1a807:	45 85 f6             	test   %r14d,%r14d
   1a80a:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1a80d: R_X86_64_32S	.rodata.str1.1+0xce3
   1a811:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
			1a814: R_X86_64_32S	.rodata.str1.1+0xcde
   1a818:	48 0f 44 f0          	cmove  %rax,%rsi
   1a81c:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1a81f: R_X86_64_32S	.rodata.str1.1+0xce9
   1a823:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1a826: R_X86_64_32S	.rodata.str1.8+0x2208
   1a82a:	e8 00 00 00 00       	call   1a82f <vpu_component_bind+0xcf>
			1a82b: R_X86_64_PLT32	os_printk-0x4
   1a82f:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1a834:	bf 38 89 15 00       	mov    $0x158938,%edi
   1a839:	e8 00 00 00 00       	call   1a83e <vpu_component_bind+0xde>
			1a83a: R_X86_64_PLT32	__kmalloc_large_noprof-0x4
   1a83e:	49 89 c7             	mov    %rax,%r15
   1a841:	48 85 c0             	test   %rax,%rax
   1a844:	0f 84 6b 11 00 00    	je     1b9b5 <vpu_component_bind+0x1255>
   1a84a:	48 89 ac 24 88 00 00 	mov    %rbp,0x88(%rsp)
   1a851:	00 
   1a852:	83 7c 24 34 01       	cmpl   $0x1,0x34(%rsp)
   1a857:	c7 80 04 04 00 00 00 	movl   $0x0,0x404(%rax)
   1a85e:	00 00 00 
   1a861:	48 8b 43 40          	mov    0x40(%rbx),%rax
   1a865:	40 0f 94 c5          	sete   %bpl
   1a869:	49 89 87 e8 03 00 00 	mov    %rax,0x3e8(%r15)
   1a870:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1a875:	49 89 87 f0 03 00 00 	mov    %rax,0x3f0(%r15)
   1a87c:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   1a881:	49 89 87 f8 03 00 00 	mov    %rax,0x3f8(%r15)
   1a888:	48 8b 04 24          	mov    (%rsp),%rax
   1a88c:	4c 89 78 28          	mov    %r15,0x28(%rax)
   1a890:	e8 00 00 00 00       	call   1a895 <vpu_component_bind+0x135>
			1a891: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a895:	49 8b bf e8 03 00 00 	mov    0x3e8(%r15),%rdi
   1a89c:	41 c7 87 28 89 15 00 	movl   $0x1,0x158928(%r15)
   1a8a3:	01 00 00 00 
   1a8a7:	41 89 87 00 04 00 00 	mov    %eax,0x400(%r15)
   1a8ae:	e8 00 00 00 00       	call   1a8b3 <vpu_component_bind+0x153>
			1a8af: R_X86_64_PLT32	os_dev_is_pci-0x4
   1a8b3:	84 c0                	test   %al,%al
   1a8b5:	49 8b 87 e8 03 00 00 	mov    0x3e8(%r15),%rax
   1a8bc:	0f 85 a6 05 00 00    	jne    1ae68 <vpu_component_bind+0x708>
   1a8c2:	41 c6 87 10 04 00 00 	movb   $0x1,0x410(%r15)
   1a8c9:	01 
   1a8ca:	49 c7 87 e0 03 00 00 	movq   $0x0,0x3e0(%r15)
   1a8d1:	00 00 00 00 
   1a8d5:	4c 8b 70 78          	mov    0x78(%rax),%r14
   1a8d9:	4d 85 f6             	test   %r14,%r14
   1a8dc:	0f 84 6f 0f 00 00    	je     1b851 <vpu_component_bind+0x10f1>
   1a8e2:	40 0f b6 d5          	movzbl %bpl,%edx
   1a8e6:	4c 89 fe             	mov    %r15,%rsi
   1a8e9:	bf 00 0a 00 00       	mov    $0xa00,%edi
   1a8ee:	e8 00 00 00 00       	call   1a8f3 <vpu_component_bind+0x193>
			1a8ef: R_X86_64_PLT32	vpu_init_conf-0x4
   1a8f3:	85 c0                	test   %eax,%eax
   1a8f5:	0f 85 b8 06 00 00    	jne    1afb3 <vpu_component_bind+0x853>
   1a8fb:	4c 89 ac 24 98 00 00 	mov    %r13,0x98(%rsp)
   1a902:	00 
   1a903:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
   1a90a:	00 00 
   1a90c:	41 8b 47 0c          	mov    0xc(%r15),%eax
   1a910:	4d 8b af e0 03 00 00 	mov    0x3e0(%r15),%r13
   1a917:	89 44 24 40          	mov    %eax,0x40(%rsp)
   1a91b:	4d 85 ed             	test   %r13,%r13
   1a91e:	0f 84 7f 01 00 00    	je     1aaa3 <vpu_component_bind+0x343>
   1a924:	66 41 81 7d 3c d5 1e 	cmpw   $0x1ed5,0x3c(%r13)
   1a92b:	0f 85 72 01 00 00    	jne    1aaa3 <vpu_component_bind+0x343>
   1a931:	66 41 81 7d 3e 02 01 	cmpw   $0x102,0x3e(%r13)
   1a938:	0f 85 65 01 00 00    	jne    1aaa3 <vpu_component_bind+0x343>
   1a93e:	41 83 bf 00 04 00 00 	cmpl   $0x1,0x400(%r15)
   1a945:	01 
   1a946:	0f 84 57 01 00 00    	je     1aaa3 <vpu_component_bind+0x343>
   1a94c:	41 8b 8e b0 02 00 00 	mov    0x2b0(%r14),%ecx
   1a953:	85 c9                	test   %ecx,%ecx
   1a955:	0f 84 2a 10 00 00    	je     1b985 <vpu_component_bind+0x1225>
   1a95b:	31 db                	xor    %ebx,%ebx
   1a95d:	48 c7 c5 ff ff ff ff 	mov    $0xffffffffffffffff,%rbp
   1a964:	49 8b bc de b8 02 00 	mov    0x2b8(%r14,%rbx,8),%rdi
   1a96b:	00 
   1a96c:	48 85 ff             	test   %rdi,%rdi
   1a96f:	74 33                	je     1a9a4 <vpu_component_bind+0x244>
   1a971:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1a974: R_X86_64_32S	.rodata.str1.1+0xcf2
   1a978:	be 00 02 00 00       	mov    $0x200,%esi
   1a97d:	e8 00 00 00 00       	call   1a982 <vpu_component_bind+0x222>
			1a97e: R_X86_64_PLT32	platform_get_resource_byname-0x4
   1a982:	48 85 c0             	test   %rax,%rax
   1a985:	74 1d                	je     1a9a4 <vpu_component_bind+0x244>
   1a987:	48 8b 00             	mov    (%rax),%rax
   1a98a:	49 8b 95 e0 03 00 00 	mov    0x3e0(%r13),%rdx
   1a991:	48 39 d0             	cmp    %rdx,%rax
   1a994:	0f 82 5c 0f 00 00    	jb     1b8f6 <vpu_component_bind+0x1196>
   1a99a:	48 29 d0             	sub    %rdx,%rax
   1a99d:	48 39 c5             	cmp    %rax,%rbp
   1a9a0:	48 0f 47 e8          	cmova  %rax,%rbp
   1a9a4:	48 83 c3 01          	add    $0x1,%rbx
   1a9a8:	41 3b 9e b0 02 00 00 	cmp    0x2b0(%r14),%ebx
   1a9af:	72 b3                	jb     1a964 <vpu_component_bind+0x204>
   1a9b1:	49 8b 85 e8 03 00 00 	mov    0x3e8(%r13),%rax
   1a9b8:	48 85 c0             	test   %rax,%rax
   1a9bb:	0f 85 b4 0f 00 00    	jne    1b975 <vpu_component_bind+0x1215>
   1a9c1:	41 8b 57 04          	mov    0x4(%r15),%edx
   1a9c5:	85 d2                	test   %edx,%edx
   1a9c7:	0f 85 d1 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1a9cd:	41 81 7f 08 00 80 10 	cmpl   $0x108000,0x8(%r15)
   1a9d4:	00 
   1a9d5:	0f 85 c3 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1a9db:	41 81 7f 0c 00 f0 00 	cmpl   $0xf000,0xc(%r15)
   1a9e2:	00 
   1a9e3:	0f 85 b5 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1a9e9:	41 83 7f 7c 03       	cmpl   $0x3,0x7c(%r15)
   1a9ee:	0f 85 aa 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1a9f4:	41 81 7f 70 00 d0 00 	cmpl   $0xd000,0x70(%r15)
   1a9fb:	00 
   1a9fc:	0f 85 9c 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa02:	45 8b 6f 74          	mov    0x74(%r15),%r13d
   1aa06:	45 85 ed             	test   %r13d,%r13d
   1aa09:	0f 85 8f 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa0f:	41 81 bf 80 00 00 00 	cmpl   $0x9800,0x80(%r15)
   1aa16:	00 98 00 00 
   1aa1a:	0f 85 7e 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa20:	41 81 bf 84 00 00 00 	cmpl   $0x5170,0x84(%r15)
   1aa27:	70 51 00 00 
   1aa2b:	0f 85 6d 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa31:	41 81 bf 88 00 00 00 	cmpl   $0x6270,0x88(%r15)
   1aa38:	70 62 00 00 
   1aa3c:	0f 85 5c 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa42:	41 81 7f 10 00 40 00 	cmpl   $0x4000,0x10(%r15)
   1aa49:	00 
   1aa4a:	0f 85 4e 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa50:	41 81 7f 14 00 40 00 	cmpl   $0x4000,0x14(%r15)
   1aa57:	00 
   1aa58:	0f 85 40 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa5e:	41 81 7f 18 00 40 00 	cmpl   $0x4000,0x18(%r15)
   1aa65:	00 
   1aa66:	0f 85 32 0f 00 00    	jne    1b99e <vpu_component_bind+0x123e>
   1aa6c:	48 3d ff 5f 11 00    	cmp    $0x115fff,%rax
   1aa72:	0f 86 7e 0e 00 00    	jbe    1b8f6 <vpu_component_bind+0x1196>
   1aa78:	48 81 fd 00 60 11 00 	cmp    $0x116000,%rbp
   1aa7f:	0f 85 71 0e 00 00    	jne    1b8f6 <vpu_component_bind+0x1196>
   1aa85:	ba 00 e0 00 00       	mov    $0xe000,%edx
   1aa8a:	be 00 80 10 00       	mov    $0x108000,%esi
   1aa8f:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1aa92: R_X86_64_32S	.rodata.str1.8+0x2278
   1aa96:	e8 00 00 00 00       	call   1aa9b <vpu_component_bind+0x33b>
			1aa97: R_X86_64_PLT32	os_printk-0x4
   1aa9b:	c7 44 24 40 00 e0 00 	movl   $0xe000,0x40(%rsp)
   1aaa2:	00 
   1aaa3:	e8 00 00 00 00       	call   1aaa8 <vpu_component_bind+0x348>
			1aaa4: R_X86_64_PLT32	os_create_timer_list-0x4
   1aaa8:	49 89 87 08 88 15 00 	mov    %rax,0x158808(%r15)
   1aaaf:	48 85 c0             	test   %rax,%rax
   1aab2:	0f 84 08 0f 00 00    	je     1b9c0 <vpu_component_bind+0x1260>
   1aab8:	e8 00 00 00 00       	call   1aabd <vpu_component_bind+0x35d>
			1aab9: R_X86_64_PLT32	os_create_timer_list-0x4
   1aabd:	49 89 87 10 88 15 00 	mov    %rax,0x158810(%r15)
   1aac4:	48 85 c0             	test   %rax,%rax
   1aac7:	0f 84 f3 0e 00 00    	je     1b9c0 <vpu_component_bind+0x1260>
   1aacd:	49 8d 87 98 86 15 00 	lea    0x158698(%r15),%rax
   1aad4:	4d 8d af c8 86 15 00 	lea    0x1586c8(%r15),%r13
   1aadb:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
   1aae0:	49 8d af f8 86 15 00 	lea    0x1586f8(%r15),%rbp
   1aae7:	48 89 c3             	mov    %rax,%rbx
   1aaea:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1aaf1 <vpu_component_bind+0x391>
			1aaed: R_X86_64_PC32	kmalloc_caches+0x24
   1aaf1:	ba 20 00 00 00       	mov    $0x20,%edx
   1aaf6:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1aafb:	e8 00 00 00 00       	call   1ab00 <vpu_component_bind+0x3a0>
			1aafc: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ab00:	48 89 03             	mov    %rax,(%rbx)
   1ab03:	48 85 c0             	test   %rax,%rax
   1ab06:	0f 84 7f 04 00 00    	je     1af8b <vpu_component_bind+0x82b>
   1ab0c:	48 8d 50 08          	lea    0x8(%rax),%rdx
   1ab10:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
   1ab17:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ab1c:	48 89 50 08          	mov    %rdx,0x8(%rax)
   1ab20:	48 89 50 10          	mov    %rdx,0x10(%rax)
   1ab24:	ba 20 00 00 00       	mov    $0x20,%edx
   1ab29:	48 c7 40 18 00 00 00 	movq   $0x0,0x18(%rax)
   1ab30:	00 
   1ab31:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ab38 <vpu_component_bind+0x3d8>
			1ab34: R_X86_64_PC32	kmalloc_caches+0x24
   1ab38:	e8 00 00 00 00       	call   1ab3d <vpu_component_bind+0x3dd>
			1ab39: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ab3d:	48 89 83 38 01 00 00 	mov    %rax,0x138(%rbx)
   1ab44:	48 85 c0             	test   %rax,%rax
   1ab47:	0f 84 3e 04 00 00    	je     1af8b <vpu_component_bind+0x82b>
   1ab4d:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1ab50: R_X86_64_32S	.bss+0xb4
   1ab54:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1ab57: R_X86_64_32S	.rodata.str1.1+0xcfd
   1ab5b:	48 89 c7             	mov    %rax,%rdi
   1ab5e:	48 83 c3 08          	add    $0x8,%rbx
   1ab62:	e8 00 00 00 00       	call   1ab67 <vpu_component_bind+0x407>
			1ab63: R_X86_64_PLT32	__mutex_init-0x4
   1ab67:	4d 89 6d 00          	mov    %r13,0x0(%r13)
   1ab6b:	4d 89 6d 08          	mov    %r13,0x8(%r13)
   1ab6f:	49 83 c5 10          	add    $0x10,%r13
   1ab73:	49 39 ed             	cmp    %rbp,%r13
   1ab76:	0f 85 6e ff ff ff    	jne    1aaea <vpu_component_bind+0x38a>
   1ab7c:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
   1ab81:	49 8d b7 20 88 15 00 	lea    0x158820(%r15),%rsi
   1ab88:	e8 00 00 00 00       	call   1ab8d <vpu_component_bind+0x42d>
			1ab89: R_X86_64_PLT32	vpu_mmu_context_create-0x4
   1ab8d:	89 44 24 44          	mov    %eax,0x44(%rsp)
   1ab91:	85 c0                	test   %eax,%eax
   1ab93:	0f 85 be 03 00 00    	jne    1af57 <vpu_component_bind+0x7f7>
   1ab99:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1aba0 <vpu_component_bind+0x440>
			1ab9c: R_X86_64_PC32	kmalloc_caches+0x14
   1aba0:	ba 04 00 00 00       	mov    $0x4,%edx
   1aba5:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1abaa:	e8 00 00 00 00       	call   1abaf <vpu_component_bind+0x44f>
			1abab: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1abaf:	49 89 87 60 05 00 00 	mov    %rax,0x560(%r15)
   1abb6:	48 85 c0             	test   %rax,%rax
   1abb9:	0f 84 7c 03 00 00    	je     1af3b <vpu_component_bind+0x7db>
   1abbf:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1abc5:	ba 04 00 00 00       	mov    $0x4,%edx
   1abca:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1abcf:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1abd6 <vpu_component_bind+0x476>
			1abd2: R_X86_64_PC32	kmalloc_caches+0x14
   1abd6:	e8 00 00 00 00       	call   1abdb <vpu_component_bind+0x47b>
			1abd7: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1abdb:	49 89 87 f8 26 00 00 	mov    %rax,0x26f8(%r15)
   1abe2:	48 85 c0             	test   %rax,%rax
   1abe5:	0f 84 44 03 00 00    	je     1af2f <vpu_component_bind+0x7cf>
   1abeb:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1abf1:	ba 20 00 00 00       	mov    $0x20,%edx
   1abf6:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1abfb:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ac02 <vpu_component_bind+0x4a2>
			1abfe: R_X86_64_PC32	kmalloc_caches+0x24
   1ac02:	e8 00 00 00 00       	call   1ac07 <vpu_component_bind+0x4a7>
			1ac03: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ac07:	49 89 87 08 04 00 00 	mov    %rax,0x408(%r15)
   1ac0e:	48 85 c0             	test   %rax,%rax
   1ac11:	0f 84 0c 03 00 00    	je     1af23 <vpu_component_bind+0x7c3>
   1ac17:	48 89 c7             	mov    %rax,%rdi
   1ac1a:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1ac1d: R_X86_64_32S	.bss+0xb4
   1ac21:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1ac24: R_X86_64_32S	.rodata.str1.1+0xd0f
   1ac28:	e8 00 00 00 00       	call   1ac2d <vpu_component_bind+0x4cd>
			1ac29: R_X86_64_PLT32	__mutex_init-0x4
   1ac2d:	ba 20 00 00 00       	mov    $0x20,%edx
   1ac32:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ac37:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ac3e <vpu_component_bind+0x4de>
			1ac3a: R_X86_64_PC32	kmalloc_caches+0x24
   1ac3e:	e8 00 00 00 00       	call   1ac43 <vpu_component_bind+0x4e3>
			1ac3f: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ac43:	49 89 87 30 89 15 00 	mov    %rax,0x158930(%r15)
   1ac4a:	48 85 c0             	test   %rax,%rax
   1ac4d:	0f 84 c4 02 00 00    	je     1af17 <vpu_component_bind+0x7b7>
   1ac53:	48 89 c7             	mov    %rax,%rdi
   1ac56:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1ac59: R_X86_64_32S	.bss+0xb4
   1ac5d:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1ac60: R_X86_64_32S	.rodata.str1.1+0xd23
   1ac64:	e8 00 00 00 00       	call   1ac69 <vpu_component_bind+0x509>
			1ac65: R_X86_64_PLT32	__mutex_init-0x4
   1ac69:	ba 04 00 00 00       	mov    $0x4,%edx
   1ac6e:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ac73:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ac7a <vpu_component_bind+0x51a>
			1ac76: R_X86_64_PC32	kmalloc_caches+0x14
   1ac7a:	e8 00 00 00 00       	call   1ac7f <vpu_component_bind+0x51f>
			1ac7b: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ac7f:	49 89 87 68 05 00 00 	mov    %rax,0x568(%r15)
   1ac86:	48 85 c0             	test   %rax,%rax
   1ac89:	0f 84 7c 02 00 00    	je     1af0b <vpu_component_bind+0x7ab>
   1ac8f:	41 83 fc ff          	cmp    $0xffffffff,%r12d
   1ac93:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1ac99:	45 8b 67 7c          	mov    0x7c(%r15),%r12d
   1ac9d:	0f 94 44 24 17       	sete   0x17(%rsp)
   1aca2:	0f b6 4c 24 17       	movzbl 0x17(%rsp),%ecx
   1aca7:	45 85 e4             	test   %r12d,%r12d
   1acaa:	0f 84 73 03 00 00    	je     1b023 <vpu_component_bind+0x8c3>
   1acb0:	80 f9 01             	cmp    $0x1,%cl
   1acb3:	4d 8d a7 00 95 00 00 	lea    0x9500(%r15),%r12
   1acba:	19 db                	sbb    %ebx,%ebx
   1acbc:	45 31 ed             	xor    %r13d,%r13d
   1acbf:	83 e3 fd             	and    $0xfffffffd,%ebx
   1acc2:	83 c3 04             	add    $0x4,%ebx
   1acc5:	eb 44                	jmp    1ad0b <vpu_component_bind+0x5ab>
   1acc7:	3d 7b 62 00 00       	cmp    $0x627b,%eax
   1accc:	0f 84 d8 00 00 00    	je     1adaa <vpu_component_bind+0x64a>
   1acd2:	41 8b 47 04          	mov    0x4(%r15),%eax
   1acd6:	83 e8 06             	sub    $0x6,%eax
   1acd9:	83 f8 01             	cmp    $0x1,%eax
   1acdc:	77 18                	ja     1acf6 <vpu_component_bind+0x596>
   1acde:	41 c7 84 24 74 ac ff 	movl   $0x1,-0x538c(%r12)
   1ace5:	ff 01 00 00 00 
   1acea:	49 c7 84 24 78 ac ff 	movq   $0x0,-0x5388(%r12)
   1acf1:	ff 00 00 00 00 
   1acf6:	49 83 c5 01          	add    $0x1,%r13
   1acfa:	49 81 c4 f8 e3 00 00 	add    $0xe3f8,%r12
   1ad01:	45 3b 6f 7c          	cmp    0x7c(%r15),%r13d
   1ad05:	0f 83 18 03 00 00    	jae    1b023 <vpu_component_bind+0x8c3>
   1ad0b:	41 89 5c 24 20       	mov    %ebx,0x20(%r12)
   1ad10:	ba 20 00 00 00       	mov    $0x20,%edx
   1ad15:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ad1a:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ad21 <vpu_component_bind+0x5c1>
			1ad1d: R_X86_64_PC32	kmalloc_caches+0x24
   1ad21:	e8 00 00 00 00       	call   1ad26 <vpu_component_bind+0x5c6>
			1ad22: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ad26:	49 89 84 24 d0 b6 ff 	mov    %rax,-0x4930(%r12)
   1ad2d:	ff 
   1ad2e:	48 85 c0             	test   %rax,%rax
   1ad31:	0f 84 bf 00 00 00    	je     1adf6 <vpu_component_bind+0x696>
   1ad37:	48 89 c7             	mov    %rax,%rdi
   1ad3a:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1ad3d: R_X86_64_32S	.bss+0xb4
   1ad41:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1ad44: R_X86_64_32S	.rodata.str1.1+0xd34
   1ad48:	e8 00 00 00 00       	call   1ad4d <vpu_component_bind+0x5ed>
			1ad49: R_X86_64_PLT32	__mutex_init-0x4
   1ad4d:	ba 20 00 00 00       	mov    $0x20,%edx
   1ad52:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ad57:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ad5e <vpu_component_bind+0x5fe>
			1ad5a: R_X86_64_PC32	kmalloc_caches+0x24
   1ad5e:	e8 00 00 00 00       	call   1ad63 <vpu_component_bind+0x603>
			1ad5f: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ad63:	49 89 84 24 c8 b6 ff 	mov    %rax,-0x4938(%r12)
   1ad6a:	ff 
   1ad6b:	48 85 c0             	test   %rax,%rax
   1ad6e:	0f 84 82 00 00 00    	je     1adf6 <vpu_component_bind+0x696>
   1ad74:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1ad77: R_X86_64_32S	.bss+0xb4
   1ad7b:	48 89 c7             	mov    %rax,%rdi
   1ad7e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1ad81: R_X86_64_32S	.rodata.str1.1+0xd4c
   1ad85:	e8 00 00 00 00       	call   1ad8a <vpu_component_bind+0x62a>
			1ad86: R_X86_64_PLT32	__mutex_init-0x4
   1ad8a:	43 8b 84 af 80 00 00 	mov    0x80(%r15,%r13,4),%eax
   1ad91:	00 
   1ad92:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1ad97:	0f 94 c2             	sete   %dl
   1ad9a:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1ad9f:	0f 94 c1             	sete   %cl
   1ada2:	08 ca                	or     %cl,%dl
   1ada4:	0f 84 1d ff ff ff    	je     1acc7 <vpu_component_bind+0x567>
   1adaa:	49 8d ac 24 00 fc ff 	lea    -0x400(%r12),%rbp
   1adb1:	ff 
   1adb2:	eb 23                	jmp    1add7 <vpu_component_bind+0x677>
   1adb4:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1adb7: R_X86_64_32S	.bss+0xb4
   1adbb:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1adbe: R_X86_64_32S	.rodata.str1.1+0xd64
   1adc2:	48 89 c7             	mov    %rax,%rdi
   1adc5:	48 83 c5 08          	add    $0x8,%rbp
   1adc9:	e8 00 00 00 00       	call   1adce <vpu_component_bind+0x66e>
			1adca: R_X86_64_PLT32	__mutex_init-0x4
   1adce:	4c 39 e5             	cmp    %r12,%rbp
   1add1:	0f 84 fb fe ff ff    	je     1acd2 <vpu_component_bind+0x572>
   1add7:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1adde <vpu_component_bind+0x67e>
			1adda: R_X86_64_PC32	kmalloc_caches+0x24
   1adde:	ba 20 00 00 00       	mov    $0x20,%edx
   1ade3:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ade8:	e8 00 00 00 00       	call   1aded <vpu_component_bind+0x68d>
			1ade9: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1aded:	48 89 45 00          	mov    %rax,0x0(%rbp)
   1adf1:	48 85 c0             	test   %rax,%rax
   1adf4:	75 be                	jne    1adb4 <vpu_component_bind+0x654>
   1adf6:	41 8b 47 7c          	mov    0x7c(%r15),%eax
   1adfa:	85 c0                	test   %eax,%eax
   1adfc:	0f 84 f1 00 00 00    	je     1aef3 <vpu_component_bind+0x793>
   1ae02:	49 8d af 00 95 00 00 	lea    0x9500(%r15),%rbp
   1ae09:	45 31 e4             	xor    %r12d,%r12d
   1ae0c:	eb 1f                	jmp    1ae2d <vpu_component_bind+0x6cd>
   1ae0e:	3d 7b 62 00 00       	cmp    $0x627b,%eax
   1ae13:	74 34                	je     1ae49 <vpu_component_bind+0x6e9>
   1ae15:	41 8b 47 7c          	mov    0x7c(%r15),%eax
   1ae19:	49 83 c4 01          	add    $0x1,%r12
   1ae1d:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1ae24:	41 39 c4             	cmp    %eax,%r12d
   1ae27:	0f 83 8b 00 00 00    	jae    1aeb8 <vpu_component_bind+0x758>
   1ae2d:	43 8b 84 a7 80 00 00 	mov    0x80(%r15,%r12,4),%eax
   1ae34:	00 
   1ae35:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1ae3a:	0f 94 c2             	sete   %dl
   1ae3d:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1ae42:	0f 94 c1             	sete   %cl
   1ae45:	08 ca                	or     %cl,%dl
   1ae47:	74 c5                	je     1ae0e <vpu_component_bind+0x6ae>
   1ae49:	48 8d 9d 00 fc ff ff 	lea    -0x400(%rbp),%rbx
   1ae50:	48 8b 3b             	mov    (%rbx),%rdi
   1ae53:	48 85 ff             	test   %rdi,%rdi
   1ae56:	74 05                	je     1ae5d <vpu_component_bind+0x6fd>
   1ae58:	e8 00 00 00 00       	call   1ae5d <vpu_component_bind+0x6fd>
			1ae59: R_X86_64_PLT32	kfree-0x4
   1ae5d:	48 83 c3 08          	add    $0x8,%rbx
   1ae61:	48 39 dd             	cmp    %rbx,%rbp
   1ae64:	75 ea                	jne    1ae50 <vpu_component_bind+0x6f0>
   1ae66:	eb ad                	jmp    1ae15 <vpu_component_bind+0x6b5>
   1ae68:	48 8d 88 38 ff ff ff 	lea    -0xc8(%rax),%rcx
   1ae6f:	41 c6 87 10 04 00 00 	movb   $0x0,0x410(%r15)
   1ae76:	00 
   1ae77:	49 89 8f e0 03 00 00 	mov    %rcx,0x3e0(%r15)
   1ae7e:	4c 8b 70 78          	mov    0x78(%rax),%r14
   1ae82:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
   1ae87:	4d 85 f6             	test   %r14,%r14
   1ae8a:	0f 84 c1 09 00 00    	je     1b851 <vpu_component_bind+0x10f1>
   1ae90:	0f b7 b8 76 ff ff ff 	movzwl -0x8a(%rax),%edi
   1ae97:	40 0f b6 d5          	movzbl %bpl,%edx
   1ae9b:	4c 89 fe             	mov    %r15,%rsi
   1ae9e:	e8 00 00 00 00       	call   1aea3 <vpu_component_bind+0x743>
			1ae9f: R_X86_64_PLT32	vpu_init_conf-0x4
   1aea3:	85 c0                	test   %eax,%eax
   1aea5:	0f 85 08 01 00 00    	jne    1afb3 <vpu_component_bind+0x853>
   1aeab:	4c 89 ac 24 98 00 00 	mov    %r13,0x98(%rsp)
   1aeb2:	00 
   1aeb3:	e9 54 fa ff ff       	jmp    1a90c <vpu_component_bind+0x1ac>
   1aeb8:	85 c0                	test   %eax,%eax
   1aeba:	74 37                	je     1aef3 <vpu_component_bind+0x793>
   1aebc:	8b 5c 24 44          	mov    0x44(%rsp),%ebx
   1aec0:	49 8d af c8 4b 00 00 	lea    0x4bc8(%r15),%rbp
   1aec7:	48 8b 7d 00          	mov    0x0(%rbp),%rdi
   1aecb:	48 85 ff             	test   %rdi,%rdi
   1aece:	74 05                	je     1aed5 <vpu_component_bind+0x775>
   1aed0:	e8 00 00 00 00       	call   1aed5 <vpu_component_bind+0x775>
			1aed1: R_X86_64_PLT32	kfree-0x4
   1aed5:	48 8b 7d 08          	mov    0x8(%rbp),%rdi
   1aed9:	48 85 ff             	test   %rdi,%rdi
   1aedc:	74 05                	je     1aee3 <vpu_component_bind+0x783>
   1aede:	e8 00 00 00 00       	call   1aee3 <vpu_component_bind+0x783>
			1aedf: R_X86_64_PLT32	kfree-0x4
   1aee3:	83 c3 01             	add    $0x1,%ebx
   1aee6:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1aeed:	41 3b 5f 7c          	cmp    0x7c(%r15),%ebx
   1aef1:	72 d4                	jb     1aec7 <vpu_component_bind+0x767>
   1aef3:	49 8b bf 18 88 15 00 	mov    0x158818(%r15),%rdi
   1aefa:	e8 00 00 00 00       	call   1aeff <vpu_component_bind+0x79f>
			1aefb: R_X86_64_PLT32	os_kfree-0x4
   1aeff:	49 8b bf 68 05 00 00 	mov    0x568(%r15),%rdi
   1af06:	e8 00 00 00 00       	call   1af0b <vpu_component_bind+0x7ab>
			1af07: R_X86_64_PLT32	kfree-0x4
   1af0b:	49 8b bf 30 89 15 00 	mov    0x158930(%r15),%rdi
   1af12:	e8 00 00 00 00       	call   1af17 <vpu_component_bind+0x7b7>
			1af13: R_X86_64_PLT32	kfree-0x4
   1af17:	49 8b bf 08 04 00 00 	mov    0x408(%r15),%rdi
   1af1e:	e8 00 00 00 00       	call   1af23 <vpu_component_bind+0x7c3>
			1af1f: R_X86_64_PLT32	kfree-0x4
   1af23:	49 8b bf f8 26 00 00 	mov    0x26f8(%r15),%rdi
   1af2a:	e8 00 00 00 00       	call   1af2f <vpu_component_bind+0x7cf>
			1af2b: R_X86_64_PLT32	kfree-0x4
   1af2f:	49 8b bf 60 05 00 00 	mov    0x560(%r15),%rdi
   1af36:	e8 00 00 00 00       	call   1af3b <vpu_component_bind+0x7db>
			1af37: R_X86_64_PLT32	kfree-0x4
   1af3b:	49 8b bf 20 88 15 00 	mov    0x158820(%r15),%rdi
   1af42:	48 85 ff             	test   %rdi,%rdi
   1af45:	74 10                	je     1af57 <vpu_component_bind+0x7f7>
   1af47:	e8 00 00 00 00       	call   1af4c <vpu_component_bind+0x7ec>
			1af48: R_X86_64_PLT32	vpu_mmu_context_destroy-0x4
   1af4c:	49 c7 87 20 88 15 00 	movq   $0x0,0x158820(%r15)
   1af53:	00 00 00 00 
   1af57:	48 8b 6c 24 38       	mov    0x38(%rsp),%rbp
   1af5c:	49 8d 9f b0 86 15 00 	lea    0x1586b0(%r15),%rbx
   1af63:	48 8b bd 38 01 00 00 	mov    0x138(%rbp),%rdi
   1af6a:	48 85 ff             	test   %rdi,%rdi
   1af6d:	74 05                	je     1af74 <vpu_component_bind+0x814>
   1af6f:	e8 00 00 00 00       	call   1af74 <vpu_component_bind+0x814>
			1af70: R_X86_64_PLT32	kfree-0x4
   1af74:	48 8b 7d 00          	mov    0x0(%rbp),%rdi
   1af78:	48 85 ff             	test   %rdi,%rdi
   1af7b:	74 05                	je     1af82 <vpu_component_bind+0x822>
   1af7d:	e8 00 00 00 00       	call   1af82 <vpu_component_bind+0x822>
			1af7e: R_X86_64_PLT32	kfree-0x4
   1af82:	48 83 c5 08          	add    $0x8,%rbp
   1af86:	48 39 dd             	cmp    %rbx,%rbp
   1af89:	75 d8                	jne    1af63 <vpu_component_bind+0x803>
   1af8b:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1af92:	e8 00 00 00 00       	call   1af97 <vpu_component_bind+0x837>
			1af93: R_X86_64_PLT32	kfree-0x4
   1af97:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1af9e:	e8 00 00 00 00       	call   1afa3 <vpu_component_bind+0x843>
			1af9f: R_X86_64_PLT32	kfree-0x4
   1afa3:	4c 89 ff             	mov    %r15,%rdi
   1afa6:	e8 00 00 00 00       	call   1afab <vpu_component_bind+0x84b>
			1afa7: R_X86_64_PLT32	vpu_deinit_conf-0x4
   1afab:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1afb2:	00 
   1afb3:	48 8b 04 24          	mov    (%rsp),%rax
   1afb7:	4c 89 ff             	mov    %r15,%rdi
   1afba:	41 bc ed ff ff ff    	mov    $0xffffffed,%r12d
   1afc0:	48 c7 40 28 00 00 00 	movq   $0x0,0x28(%rax)
   1afc7:	00 
   1afc8:	e8 00 00 00 00       	call   1afcd <vpu_component_bind+0x86d>
			1afc9: R_X86_64_PLT32	kfree-0x4
   1afcd:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1afd0: R_X86_64_32S	.rodata.str1.1+0xda7
   1afd4:	e8 00 00 00 00       	call   1afd9 <vpu_component_bind+0x879>
			1afd5: R_X86_64_PLT32	os_printk-0x4
   1afd9:	48 8b ac 24 88 00 00 	mov    0x88(%rsp),%rbp
   1afe0:	00 
   1afe1:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
   1afe6:	65 48 2b 05 00 00 00 	sub    %gs:0x0(%rip),%rax        # 1afee <vpu_component_bind+0x88e>
   1afed:	00 
			1afea: R_X86_64_PC32	__ref_stack_chk_guard-0x4
   1afee:	0f 85 d9 09 00 00    	jne    1b9cd <vpu_component_bind+0x126d>
   1aff4:	44 89 e0             	mov    %r12d,%eax
   1aff7:	48 8b 9c 24 80 00 00 	mov    0x80(%rsp),%rbx
   1affe:	00 
   1afff:	4c 8b a4 24 90 00 00 	mov    0x90(%rsp),%r12
   1b006:	00 
   1b007:	4c 8b b4 24 a0 00 00 	mov    0xa0(%rsp),%r14
   1b00e:	00 
   1b00f:	4c 8b bc 24 a8 00 00 	mov    0xa8(%rsp),%r15
   1b016:	00 
   1b017:	48 81 c4 b0 00 00 00 	add    $0xb0,%rsp
   1b01e:	e9 00 00 00 00       	jmp    1b023 <vpu_component_bind+0x8c3>
			1b01f: R_X86_64_PLT32	__x86_return_thunk-0x4
   1b023:	4c 89 f7             	mov    %r14,%rdi
   1b026:	4d 8d a6 b8 03 00 00 	lea    0x3b8(%r14),%r12
   1b02d:	49 8d ae b8 04 00 00 	lea    0x4b8(%r14),%rbp
   1b034:	45 31 ed             	xor    %r13d,%r13d
   1b037:	e8 00 00 00 00       	call   1b03c <vpu_component_bind+0x8dc>
			1b038: R_X86_64_PLT32	mtgpu_get_primary_core_count-0x4
   1b03c:	48 8b 1c 24          	mov    (%rsp),%rbx
   1b040:	41 89 87 74 25 00 00 	mov    %eax,0x2574(%r15)
   1b047:	41 0f b6 86 44 0b 00 	movzbl 0xb44(%r14),%eax
   1b04e:	00 
   1b04f:	41 89 87 58 05 00 00 	mov    %eax,0x558(%r15)
   1b056:	49 8b 04 24          	mov    (%r12),%rax
   1b05a:	48 85 c0             	test   %rax,%rax
   1b05d:	74 3a                	je     1b099 <vpu_component_bind+0x939>
   1b05f:	48 8d 78 10          	lea    0x10(%rax),%rdi
   1b063:	e8 00 00 00 00       	call   1b068 <vpu_component_bind+0x908>
			1b064: R_X86_64_PLT32	os_dev_get_drvdata-0x4
   1b068:	49 63 d5             	movslq %r13d,%rdx
   1b06b:	49 89 84 d7 78 25 00 	mov    %rax,0x2578(%r15,%rdx,8)
   1b072:	00 
   1b073:	48 85 c0             	test   %rax,%rax
   1b076:	0f 84 c7 01 00 00    	je     1b243 <vpu_component_bind+0xae3>
   1b07c:	41 0f b6 8c 16 24 0b 	movzbl 0xb24(%r14,%rdx,1),%ecx
   1b083:	00 00 
   1b085:	41 83 c5 01          	add    $0x1,%r13d
   1b089:	41 89 8c 97 78 26 00 	mov    %ecx,0x2678(%r15,%rdx,4)
   1b090:	00 
   1b091:	48 8b 58 40          	mov    0x40(%rax),%rbx
   1b095:	4c 89 7b 28          	mov    %r15,0x28(%rbx)
   1b099:	49 83 c4 08          	add    $0x8,%r12
   1b09d:	4c 39 e5             	cmp    %r12,%rbp
   1b0a0:	75 b4                	jne    1b056 <vpu_component_bind+0x8f6>
   1b0a2:	48 89 1c 24          	mov    %rbx,(%rsp)
   1b0a6:	45 39 af 74 25 00 00 	cmp    %r13d,0x2574(%r15)
   1b0ad:	0f 85 43 fd ff ff    	jne    1adf6 <vpu_component_bind+0x696>
   1b0b3:	49 8b bf e8 03 00 00 	mov    0x3e8(%r15),%rdi
   1b0ba:	48 8d 74 24 54       	lea    0x54(%rsp),%rsi
   1b0bf:	e8 00 00 00 00       	call   1b0c4 <vpu_component_bind+0x964>
			1b0c0: R_X86_64_PLT32	mtgpu_smc_get_vpu_core_info-0x4
   1b0c4:	85 c0                	test   %eax,%eax
   1b0c6:	0f 85 94 04 00 00    	jne    1b560 <vpu_component_bind+0xe00>
   1b0cc:	41 8b 6f 7c          	mov    0x7c(%r15),%ebp
   1b0d0:	85 ed                	test   %ebp,%ebp
   1b0d2:	0f 84 d0 08 00 00    	je     1b9a8 <vpu_component_bind+0x1248>
   1b0d8:	4c 89 74 24 48       	mov    %r14,0x48(%rsp)
   1b0dd:	4d 8d af 50 27 00 00 	lea    0x2750(%r15),%r13
   1b0e4:	31 db                	xor    %ebx,%ebx
   1b0e6:	31 ed                	xor    %ebp,%ebp
   1b0e8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%rsp)
   1b0ef:	00 
   1b0f0:	4c 8b 74 24 28       	mov    0x28(%rsp),%r14
   1b0f5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%rsp)
   1b0fc:	00 
   1b0fd:	e9 80 00 00 00       	jmp    1b182 <vpu_component_bind+0xa22>
   1b102:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1b107:	0f 84 b4 00 00 00    	je     1b1c1 <vpu_component_bind+0xa61>
   1b10d:	3d 7b 62 00 00       	cmp    $0x627b,%eax
   1b112:	0f 84 a9 00 00 00    	je     1b1c1 <vpu_component_bind+0xa61>
   1b118:	3d 00 98 00 00       	cmp    $0x9800,%eax
   1b11d:	0f 84 16 04 00 00    	je     1b539 <vpu_component_bind+0xdd9>
   1b123:	3d 00 12 00 00       	cmp    $0x1200,%eax
   1b128:	0f 84 18 08 00 00    	je     1b946 <vpu_component_bind+0x11e6>
   1b12e:	3d 50 a3 00 00       	cmp    $0xa350,%eax
   1b133:	0f 84 e3 07 00 00    	je     1b91c <vpu_component_bind+0x11bc>
   1b139:	45 89 65 00          	mov    %r12d,0x0(%r13)
   1b13d:	48 83 c5 01          	add    $0x1,%rbp
   1b141:	49 81 c5 f8 e3 00 00 	add    $0xe3f8,%r13
   1b148:	4d 89 bd 90 48 ff ff 	mov    %r15,-0xb770(%r13)
   1b14f:	41 c6 85 28 36 ff ff 	movb   $0x0,-0xc9d8(%r13)
   1b156:	00 
   1b157:	41 c7 85 18 1c ff ff 	movl   $0x0,-0xe3e8(%r13)
   1b15e:	00 00 00 00 
   1b162:	41 c7 85 b8 89 ff ff 	movl   $0x0,-0x7648(%r13)
   1b169:	00 00 00 00 
   1b16d:	41 c7 85 c0 89 ff ff 	movl   $0x0,-0x7640(%r13)
   1b174:	00 00 00 00 
   1b178:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b17c:	0f 83 ca 00 00 00    	jae    1b24c <vpu_component_bind+0xaec>
   1b182:	41 8b 84 af 80 00 00 	mov    0x80(%r15,%rbp,4),%eax
   1b189:	00 
   1b18a:	41 89 ec             	mov    %ebp,%r12d
   1b18d:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1b192:	0f 85 6a ff ff ff    	jne    1b102 <vpu_component_bind+0x9a2>
   1b198:	8b 44 24 54          	mov    0x54(%rsp),%eax
   1b19c:	0f a3 d8             	bt     %ebx,%eax
   1b19f:	73 76                	jae    1b217 <vpu_component_bind+0xab7>
   1b1a1:	89 da                	mov    %ebx,%edx
   1b1a3:	89 ee                	mov    %ebp,%esi
   1b1a5:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b1a8: R_X86_64_32S	.rodata.str1.8+0x22c0
   1b1ac:	e8 00 00 00 00       	call   1b1b1 <vpu_component_bind+0xa51>
			1b1ad: R_X86_64_PLT32	os_printk-0x4
   1b1b1:	41 c7 45 08 00 00 00 	movl   $0x0,0x8(%r13)
   1b1b8:	00 
   1b1b9:	83 c3 01             	add    $0x1,%ebx
   1b1bc:	e9 78 ff ff ff       	jmp    1b139 <vpu_component_bind+0x9d9>
   1b1c1:	8b 4c 24 54          	mov    0x54(%rsp),%ecx
   1b1c5:	8b 54 24 0c          	mov    0xc(%rsp),%edx
   1b1c9:	0f a3 d1             	bt     %edx,%ecx
   1b1cc:	73 21                	jae    1b1ef <vpu_component_bind+0xa8f>
   1b1ce:	44 89 e6             	mov    %r12d,%esi
   1b1d1:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b1d4: R_X86_64_32S	.rodata.str1.8+0x2320
   1b1d8:	e8 00 00 00 00       	call   1b1dd <vpu_component_bind+0xa7d>
			1b1d9: R_X86_64_PLT32	os_printk-0x4
   1b1dd:	41 c7 45 08 00 00 00 	movl   $0x0,0x8(%r13)
   1b1e4:	00 
   1b1e5:	83 44 24 0c 01       	addl   $0x1,0xc(%rsp)
   1b1ea:	e9 4a ff ff ff       	jmp    1b139 <vpu_component_bind+0x9d9>
   1b1ef:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b1f6:	00 
   1b1f7:	8b 54 24 0c          	mov    0xc(%rsp),%edx
   1b1fb:	44 89 e6             	mov    %r12d,%esi
   1b1fe:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b201: R_X86_64_32S	.rodata.str1.8+0x2350
   1b205:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b20c:	41 89 45 14          	mov    %eax,0x14(%r13)
   1b210:	e8 00 00 00 00       	call   1b215 <vpu_component_bind+0xab5>
			1b211: R_X86_64_PLT32	os_printk-0x4
   1b215:	eb ce                	jmp    1b1e5 <vpu_component_bind+0xa85>
   1b217:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b21e:	00 
   1b21f:	89 da                	mov    %ebx,%edx
   1b221:	89 ee                	mov    %ebp,%esi
   1b223:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b226: R_X86_64_32S	.rodata.str1.8+0x22f0
   1b22a:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b231:	41 c7 45 14 70 51 00 	movl   $0x5170,0x14(%r13)
   1b238:	00 
   1b239:	e8 00 00 00 00       	call   1b23e <vpu_component_bind+0xade>
			1b23a: R_X86_64_PLT32	os_printk-0x4
   1b23e:	e9 76 ff ff ff       	jmp    1b1b9 <vpu_component_bind+0xa59>
   1b243:	48 89 1c 24          	mov    %rbx,(%rsp)
   1b247:	e9 aa fb ff ff       	jmp    1adf6 <vpu_component_bind+0x696>
   1b24c:	4c 8b 74 24 48       	mov    0x48(%rsp),%r14
   1b251:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1b258 <vpu_component_bind+0xaf8>
			1b254: R_X86_64_PC32	kmalloc_caches+0x24
   1b258:	ba 20 00 00 00       	mov    $0x20,%edx
   1b25d:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1b262:	e8 00 00 00 00       	call   1b267 <vpu_component_bind+0xb07>
			1b263: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1b267:	49 89 87 18 88 15 00 	mov    %rax,0x158818(%r15)
   1b26e:	48 85 c0             	test   %rax,%rax
   1b271:	0f 84 7f fb ff ff    	je     1adf6 <vpu_component_bind+0x696>
   1b277:	8b 5c 24 30          	mov    0x30(%rsp),%ebx
   1b27b:	8b 4c 24 10          	mov    0x10(%rsp),%ecx
   1b27f:	48 8d 50 08          	lea    0x8(%rax),%rdx
   1b283:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1b289:	48 89 50 08          	mov    %rdx,0x8(%rax)
   1b28d:	85 db                	test   %ebx,%ebx
   1b28f:	89 48 04             	mov    %ecx,0x4(%rax)
   1b292:	41 0f 94 c5          	sete   %r13b
   1b296:	44 0a 6c 24 17       	or     0x17(%rsp),%r13b
   1b29b:	48 89 50 10          	mov    %rdx,0x10(%rax)
   1b29f:	48 c7 40 18 00 00 00 	movq   $0x0,0x18(%rax)
   1b2a6:	00 
   1b2a7:	44 88 6c 24 0c       	mov    %r13b,0xc(%rsp)
   1b2ac:	74 6d                	je     1b31b <vpu_component_bind+0xbbb>
   1b2ae:	8b 74 24 40          	mov    0x40(%rsp),%esi
   1b2b2:	41 8b 7f 08          	mov    0x8(%r15),%edi
   1b2b6:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b2bd:	00 
   1b2be:	75 0c                	jne    1b2cc <vpu_component_bind+0xb6c>
   1b2c0:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   1b2c5:	48 03 b8 e0 03 00 00 	add    0x3e0(%rax),%rdi
   1b2cc:	e8 00 00 00 00       	call   1b2d1 <vpu_component_bind+0xb71>
			1b2cd: R_X86_64_PLT32	ioremap-0x4
   1b2d1:	49 89 87 40 27 00 00 	mov    %rax,0x2740(%r15)
   1b2d8:	48 85 c0             	test   %rax,%rax
   1b2db:	0f 84 15 fb ff ff    	je     1adf6 <vpu_component_bind+0x696>
   1b2e1:	41 8b 57 7c          	mov    0x7c(%r15),%edx
   1b2e5:	85 d2                	test   %edx,%edx
   1b2e7:	74 32                	je     1b31b <vpu_component_bind+0xbbb>
   1b2e9:	49 8d 3c 97          	lea    (%r15,%rdx,4),%rdi
   1b2ed:	49 8d b7 68 27 00 00 	lea    0x2768(%r15),%rsi
   1b2f4:	4c 89 fa             	mov    %r15,%rdx
   1b2f7:	31 c9                	xor    %ecx,%ecx
   1b2f9:	4c 8d 04 08          	lea    (%rax,%rcx,1),%r8
   1b2fd:	48 83 c2 04          	add    $0x4,%rdx
   1b301:	48 81 c6 f8 e3 00 00 	add    $0xe3f8,%rsi
   1b308:	4c 89 86 08 1c ff ff 	mov    %r8,-0xe3f8(%rsi)
   1b30f:	44 8b 42 0c          	mov    0xc(%rdx),%r8d
   1b313:	4c 01 c1             	add    %r8,%rcx
   1b316:	48 39 d7             	cmp    %rdx,%rdi
   1b319:	75 de                	jne    1b2f9 <vpu_component_bind+0xb99>
   1b31b:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b322:	00 
   1b323:	0f 84 73 02 00 00    	je     1b59c <vpu_component_bind+0xe3c>
   1b329:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 1b330 <vpu_component_bind+0xbd0>
			1b32b: R_X86_64_PC32	enable_reserved_memory-0x5
   1b330:	49 c7 87 48 27 00 00 	movq   $0x0,0x2748(%r15)
   1b337:	00 00 00 00 
   1b33b:	0f 84 f8 04 00 00    	je     1b839 <vpu_component_bind+0x10d9>
   1b341:	41 c7 87 58 05 00 00 	movl   $0x1,0x558(%r15)
   1b348:	01 00 00 00 
   1b34c:	45 8b 5f 7c          	mov    0x7c(%r15),%r11d
   1b350:	45 85 db             	test   %r11d,%r11d
   1b353:	74 6c                	je     1b3c1 <vpu_component_bind+0xc61>
   1b355:	49 8d af 74 41 00 00 	lea    0x4174(%r15),%rbp
   1b35c:	31 db                	xor    %ebx,%ebx
   1b35e:	b8 01 00 00 00       	mov    $0x1,%eax
   1b363:	49 bc 00 00 00 00 ff 	movabs $0xff00000000,%r12
   1b36a:	00 00 00 
   1b36d:	eb 0e                	jmp    1b37d <vpu_component_bind+0xc1d>
   1b36f:	41 8b 87 58 05 00 00 	mov    0x558(%r15),%eax
   1b376:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1b37d:	83 e8 01             	sub    $0x1,%eax
   1b380:	89 da                	mov    %ebx,%edx
   1b382:	89 de                	mov    %ebx,%esi
   1b384:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b387: R_X86_64_32S	.rodata.str1.8+0x23d0
   1b38b:	48 98                	cltq
   1b38d:	83 c3 01             	add    $0x1,%ebx
   1b390:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
   1b394:	48 8d 44 c2 34       	lea    0x34(%rdx,%rax,8),%rax
   1b399:	41 8b 44 87 10       	mov    0x10(%r15,%rax,4),%eax
   1b39e:	89 45 00             	mov    %eax,0x0(%rbp)
   1b3a1:	49 8b 86 d0 00 00 00 	mov    0xd0(%r14),%rax
   1b3a8:	4c 21 e0             	and    %r12,%rax
   1b3ab:	48 89 45 04          	mov    %rax,0x4(%rbp)
   1b3af:	48 c1 e8 20          	shr    $0x20,%rax
   1b3b3:	48 89 c2             	mov    %rax,%rdx
   1b3b6:	e8 00 00 00 00       	call   1b3bb <vpu_component_bind+0xc5b>
			1b3b7: R_X86_64_PLT32	os_printk-0x4
   1b3bb:	41 3b 5f 7c          	cmp    0x7c(%r15),%ebx
   1b3bf:	72 ae                	jb     1b36f <vpu_component_bind+0xc0f>
   1b3c1:	41 c7 87 24 89 15 00 	movl   $0xff,0x158924(%r15)
   1b3c8:	ff 00 00 00 
   1b3cc:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1b3d1:	48 8d 68 f0          	lea    -0x10(%rax),%rbp
   1b3d5:	83 7c 24 34 01       	cmpl   $0x1,0x34(%rsp)
   1b3da:	0f 84 4c 04 00 00    	je     1b82c <vpu_component_bind+0x10cc>
   1b3e0:	48 89 ee             	mov    %rbp,%rsi
   1b3e3:	4c 89 ff             	mov    %r15,%rdi
   1b3e6:	e8 00 00 00 00       	call   1b3eb <vpu_component_bind+0xc8b>
			1b3e7: R_X86_64_PLT32	vpu_init_irq-0x4
   1b3eb:	85 c0                	test   %eax,%eax
   1b3ed:	0f 85 03 fa ff ff    	jne    1adf6 <vpu_component_bind+0x696>
   1b3f3:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1b3f8:	be 80 00 00 00       	mov    $0x80,%esi
   1b3fd:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b400: R_X86_64_32S	pvr_drm_ioctls
   1b404:	4c 89 78 78          	mov    %r15,0x78(%rax)
   1b408:	e8 00 00 00 00       	call   1b40d <vpu_component_bind+0xcad>
			1b409: R_X86_64_PLT32	vpu_fill_drm_ioctls-0x4
   1b40d:	41 89 c4             	mov    %eax,%r12d
   1b410:	85 c0                	test   %eax,%eax
   1b412:	0f 85 de f9 ff ff    	jne    1adf6 <vpu_component_bind+0x696>
   1b418:	41 83 7f 04 02       	cmpl   $0x2,0x4(%r15)
   1b41d:	0f 84 7c 04 00 00    	je     1b89f <vpu_component_bind+0x113f>
   1b423:	44 8b 44 24 30       	mov    0x30(%rsp),%r8d
   1b428:	48 8d 6c 24 58       	lea    0x58(%rsp),%rbp
   1b42d:	45 85 c0             	test   %r8d,%r8d
   1b430:	0f 84 2c 04 00 00    	je     1b862 <vpu_component_bind+0x1102>
   1b436:	e8 00 00 00 00       	call   1b43b <vpu_component_bind+0xcdb>
			1b437: R_X86_64_PLT32	get_vinfo_fops-0x4
   1b43b:	49 89 c5             	mov    %rax,%r13
   1b43e:	e8 00 00 00 00       	call   1b443 <vpu_component_bind+0xce3>
			1b43f: R_X86_64_PLT32	get_fwinfo_fops-0x4
   1b443:	49 89 c6             	mov    %rax,%r14
   1b446:	e8 00 00 00 00       	call   1b44b <vpu_component_bind+0xceb>
			1b447: R_X86_64_PLT32	get_vpulog_fops-0x4
   1b44b:	41 8b 17             	mov    (%r15),%edx
   1b44e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b451: R_X86_64_32S	.rodata.str1.1+0xd8d
   1b455:	48 89 ef             	mov    %rbp,%rdi
   1b458:	48 89 c3             	mov    %rax,%rbx
   1b45b:	e8 00 00 00 00       	call   1b460 <vpu_component_bind+0xd00>
			1b45c: R_X86_64_PLT32	sprintf-0x4
   1b460:	31 f6                	xor    %esi,%esi
   1b462:	48 89 ef             	mov    %rbp,%rdi
   1b465:	e8 00 00 00 00       	call   1b46a <vpu_component_bind+0xd0a>
			1b466: R_X86_64_PLT32	debugfs_create_dir-0x4
   1b46a:	49 89 87 00 88 15 00 	mov    %rax,0x158800(%r15)
   1b471:	48 85 c0             	test   %rax,%rax
   1b474:	0f 84 4a 01 00 00    	je     1b5c4 <vpu_component_bind+0xe64>
   1b47a:	4d 89 e9             	mov    %r13,%r9
   1b47d:	45 31 c0             	xor    %r8d,%r8d
   1b480:	4c 89 f9             	mov    %r15,%rcx
   1b483:	48 89 c2             	mov    %rax,%rdx
   1b486:	be b6 01 00 00       	mov    $0x1b6,%esi
   1b48b:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b48e: R_X86_64_32S	.rodata.str1.1+0xd95
   1b492:	e8 00 00 00 00       	call   1b497 <vpu_component_bind+0xd37>
			1b493: R_X86_64_PLT32	debugfs_create_file_full-0x4
   1b497:	4d 89 f1             	mov    %r14,%r9
   1b49a:	45 31 c0             	xor    %r8d,%r8d
   1b49d:	4c 89 f9             	mov    %r15,%rcx
   1b4a0:	49 8b 97 00 88 15 00 	mov    0x158800(%r15),%rdx
   1b4a7:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b4aa: R_X86_64_32S	.rodata.str1.1+0xd9a
   1b4ae:	be 24 01 00 00       	mov    $0x124,%esi
   1b4b3:	e8 00 00 00 00       	call   1b4b8 <vpu_component_bind+0xd58>
			1b4b4: R_X86_64_PLT32	debugfs_create_file_full-0x4
   1b4b8:	41 8b 7f 7c          	mov    0x7c(%r15),%edi
   1b4bc:	85 ff                	test   %edi,%edi
   1b4be:	0f 84 00 01 00 00    	je     1b5c4 <vpu_component_bind+0xe64>
   1b4c4:	4d 8d b7 50 27 00 00 	lea    0x2750(%r15),%r14
   1b4cb:	45 31 ed             	xor    %r13d,%r13d
   1b4ce:	eb 1c                	jmp    1b4ec <vpu_component_bind+0xd8c>
   1b4d0:	3d 50 a3 00 00       	cmp    $0xa350,%eax
   1b4d5:	74 43                	je     1b51a <vpu_component_bind+0xdba>
   1b4d7:	49 83 c5 01          	add    $0x1,%r13
   1b4db:	49 81 c6 f8 e3 00 00 	add    $0xe3f8,%r14
   1b4e2:	45 3b 6f 7c          	cmp    0x7c(%r15),%r13d
   1b4e6:	0f 83 d8 00 00 00    	jae    1b5c4 <vpu_component_bind+0xe64>
   1b4ec:	44 89 ea             	mov    %r13d,%edx
   1b4ef:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b4f2: R_X86_64_32S	.rodata.str1.1+0xd9d
   1b4f6:	48 89 ef             	mov    %rbp,%rdi
   1b4f9:	e8 00 00 00 00       	call   1b4fe <vpu_component_bind+0xd9e>
			1b4fa: R_X86_64_PLT32	sprintf-0x4
   1b4fe:	43 8b 84 af 80 00 00 	mov    0x80(%r15,%r13,4),%eax
   1b505:	00 
   1b506:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1b50b:	0f 94 c2             	sete   %dl
   1b50e:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1b513:	0f 94 c1             	sete   %cl
   1b516:	08 ca                	or     %cl,%dl
   1b518:	74 b6                	je     1b4d0 <vpu_component_bind+0xd70>
   1b51a:	49 8b 97 00 88 15 00 	mov    0x158800(%r15),%rdx
   1b521:	49 89 d9             	mov    %rbx,%r9
   1b524:	45 31 c0             	xor    %r8d,%r8d
   1b527:	4c 89 f1             	mov    %r14,%rcx
   1b52a:	be 24 01 00 00       	mov    $0x124,%esi
   1b52f:	48 89 ef             	mov    %rbp,%rdi
   1b532:	e8 00 00 00 00       	call   1b537 <vpu_component_bind+0xdd7>
			1b533: R_X86_64_PLT32	debugfs_create_file_full-0x4
   1b537:	eb 9e                	jmp    1b4d7 <vpu_component_bind+0xd77>
   1b539:	f6 44 24 55 40       	testb  $0x40,0x55(%rsp)
   1b53e:	74 2d                	je     1b56d <vpu_component_bind+0xe0d>
   1b540:	ba 0e 00 00 00       	mov    $0xe,%edx
   1b545:	89 ee                	mov    %ebp,%esi
   1b547:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b54a: R_X86_64_32S	.rodata.str1.8+0x22c0
   1b54e:	e8 00 00 00 00       	call   1b553 <vpu_component_bind+0xdf3>
			1b54f: R_X86_64_PLT32	os_printk-0x4
   1b553:	41 c7 45 08 00 00 00 	movl   $0x0,0x8(%r13)
   1b55a:	00 
   1b55b:	e9 d9 fb ff ff       	jmp    1b139 <vpu_component_bind+0x9d9>
   1b560:	c7 44 24 54 00 00 00 	movl   $0x0,0x54(%rsp)
   1b567:	00 
   1b568:	e9 5f fb ff ff       	jmp    1b0cc <vpu_component_bind+0x96c>
   1b56d:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b574:	00 
   1b575:	ba 0e 00 00 00       	mov    $0xe,%edx
   1b57a:	89 ee                	mov    %ebp,%esi
   1b57c:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b57f: R_X86_64_32S	.rodata.str1.8+0x22f0
   1b583:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b58a:	41 c7 45 14 00 98 00 	movl   $0x9800,0x14(%r13)
   1b591:	00 
   1b592:	e8 00 00 00 00       	call   1b597 <vpu_component_bind+0xe37>
			1b593: R_X86_64_PLT32	os_printk-0x4
   1b597:	e9 9d fb ff ff       	jmp    1b139 <vpu_component_bind+0x9d9>
   1b59c:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   1b5a1:	4c 89 ff             	mov    %r15,%rdi
   1b5a4:	48 8b 80 60 04 00 00 	mov    0x460(%rax),%rax
   1b5ab:	49 89 87 48 27 00 00 	mov    %rax,0x2748(%r15)
   1b5b2:	e8 00 00 00 00       	call   1b5b7 <vpu_component_bind+0xe57>
			1b5b3: R_X86_64_PLT32	vpu_init_mpc-0x4
   1b5b7:	85 c0                	test   %eax,%eax
   1b5b9:	0f 84 02 fe ff ff    	je     1b3c1 <vpu_component_bind+0xc61>
   1b5bf:	e9 32 f8 ff ff       	jmp    1adf6 <vpu_component_bind+0x696>
   1b5c4:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1b5cb:	4c 89 fe             	mov    %r15,%rsi
   1b5ce:	e8 00 00 00 00       	call   1b5d3 <vpu_component_bind+0xe73>
			1b5cf: R_X86_64_PLT32	os_set_timer_list_drvdata-0x4
   1b5d3:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1b5da:	31 c9                	xor    %ecx,%ecx
   1b5dc:	31 d2                	xor    %edx,%edx
   1b5de:	45 31 c0             	xor    %r8d,%r8d
   1b5e1:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b5e4: R_X86_64_32S	vpu_util_monitor
   1b5e8:	e8 00 00 00 00       	call   1b5ed <vpu_component_bind+0xe8d>
			1b5e9: R_X86_64_PLT32	timer_init_key-0x4
   1b5ed:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 1b5f4 <vpu_component_bind+0xe94>
			1b5f0: R_X86_64_PC32	jiffies-0x4
   1b5f4:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1b5fb:	48 83 c6 5a          	add    $0x5a,%rsi
   1b5ff:	e8 00 00 00 00       	call   1b604 <vpu_component_bind+0xea4>
			1b600: R_X86_64_PLT32	mod_timer-0x4
   1b604:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1b60b:	4c 89 fe             	mov    %r15,%rsi
   1b60e:	e8 00 00 00 00       	call   1b613 <vpu_component_bind+0xeb3>
			1b60f: R_X86_64_PLT32	os_set_timer_list_drvdata-0x4
   1b613:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1b61a:	31 c9                	xor    %ecx,%ecx
   1b61c:	31 d2                	xor    %edx,%edx
   1b61e:	45 31 c0             	xor    %r8d,%r8d
   1b621:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b624: R_X86_64_32S	vpu_stat_monitor
   1b628:	e8 00 00 00 00       	call   1b62d <vpu_component_bind+0xecd>
			1b629: R_X86_64_PLT32	timer_init_key-0x4
   1b62d:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 1b634 <vpu_component_bind+0xed4>
			1b630: R_X86_64_PC32	jiffies-0x4
   1b634:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1b63b:	48 81 c6 2c 01 00 00 	add    $0x12c,%rsi
   1b642:	e8 00 00 00 00       	call   1b647 <vpu_component_bind+0xee7>
			1b643: R_X86_64_PLT32	mod_timer-0x4
   1b647:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b64e:	00 
   1b64f:	0f 85 96 01 00 00    	jne    1b7eb <vpu_component_bind+0x108b>
   1b655:	be 01 00 00 00       	mov    $0x1,%esi
   1b65a:	4c 89 ff             	mov    %r15,%rdi
   1b65d:	e8 00 00 00 00       	call   1b662 <vpu_component_bind+0xf02>
			1b65e: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b662:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b669:	00 
   1b66a:	0f 85 5e 01 00 00    	jne    1b7ce <vpu_component_bind+0x106e>
   1b670:	80 7c 24 0c 00       	cmpb   $0x0,0xc(%rsp)
   1b675:	0f 84 9f 01 00 00    	je     1b81a <vpu_component_bind+0x10ba>
   1b67b:	41 8b 77 7c          	mov    0x7c(%r15),%esi
   1b67f:	31 ed                	xor    %ebp,%ebp
   1b681:	85 f6                	test   %esi,%esi
   1b683:	74 26                	je     1b6ab <vpu_component_bind+0xf4b>
   1b685:	89 ee                	mov    %ebp,%esi
   1b687:	4c 89 ff             	mov    %r15,%rdi
   1b68a:	e8 00 00 00 00       	call   1b68f <vpu_component_bind+0xf2f>
			1b68b: R_X86_64_PLT32	vpu_get_clk-0x4
   1b68f:	48 89 c2             	mov    %rax,%rdx
   1b692:	48 69 c5 f8 e3 00 00 	imul   $0xe3f8,%rbp,%rax
   1b699:	48 83 c5 01          	add    $0x1,%rbp
   1b69d:	49 89 94 07 f0 53 00 	mov    %rdx,0x53f0(%r15,%rax,1)
   1b6a4:	00 
   1b6a5:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b6a9:	72 da                	jb     1b685 <vpu_component_bind+0xf25>
   1b6ab:	be ff ff ff ff       	mov    $0xffffffff,%esi
   1b6b0:	4c 89 ff             	mov    %r15,%rdi
   1b6b3:	e8 00 00 00 00       	call   1b6b8 <vpu_component_bind+0xf58>
			1b6b4: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b6b8:	41 8b 4f 7c          	mov    0x7c(%r15),%ecx
   1b6bc:	85 c9                	test   %ecx,%ecx
   1b6be:	0f 84 34 01 00 00    	je     1b7f8 <vpu_component_bind+0x1098>
   1b6c4:	31 ed                	xor    %ebp,%ebp
   1b6c6:	eb 0a                	jmp    1b6d2 <vpu_component_bind+0xf72>
   1b6c8:	48 83 c5 01          	add    $0x1,%rbp
   1b6cc:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b6d0:	73 22                	jae    1b6f4 <vpu_component_bind+0xf94>
   1b6d2:	41 81 bc af 80 00 00 	cmpl   $0x6270,0x80(%r15,%rbp,4)
   1b6d9:	00 70 62 00 00 
   1b6de:	75 e8                	jne    1b6c8 <vpu_component_bind+0xf68>
   1b6e0:	89 ee                	mov    %ebp,%esi
   1b6e2:	4c 89 ff             	mov    %r15,%rdi
   1b6e5:	48 83 c5 01          	add    $0x1,%rbp
   1b6e9:	e8 00 00 00 00       	call   1b6ee <vpu_component_bind+0xf8e>
			1b6ea: R_X86_64_PLT32	vpu_slice_mode_config-0x4
   1b6ee:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b6f2:	72 de                	jb     1b6d2 <vpu_component_bind+0xf72>
   1b6f4:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b6fb:	00 
   1b6fc:	0f 85 00 01 00 00    	jne    1b802 <vpu_component_bind+0x10a2>
   1b702:	41 8b 57 7c          	mov    0x7c(%r15),%edx
   1b706:	85 d2                	test   %edx,%edx
   1b708:	0f 84 ab 00 00 00    	je     1b7b9 <vpu_component_bind+0x1059>
   1b70e:	4c 89 fd             	mov    %r15,%rbp
   1b711:	45 31 ed             	xor    %r13d,%r13d
   1b714:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1b71b <vpu_component_bind+0xfbb>
			1b717: R_X86_64_PC32	kmalloc_caches+0x44
   1b71b:	ba 00 02 00 00       	mov    $0x200,%edx
   1b720:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1b725:	e8 00 00 00 00       	call   1b72a <vpu_component_bind+0xfca>
			1b726: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1b72a:	48 89 85 40 05 01 00 	mov    %rax,0x10540(%rbp)
   1b731:	48 85 c0             	test   %rax,%rax
   1b734:	0f 84 bc f6 ff ff    	je     1adf6 <vpu_component_bind+0x696>
   1b73a:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1b740:	b8 04 00 00 00       	mov    $0x4,%eax
   1b745:	0f 1f 40 00          	nopl   0x0(%rax)
   1b749:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b750:	00 00 00 00 
   1b754:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b75b:	00 00 00 00 
   1b75f:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b766:	00 00 00 00 
   1b76a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b771:	00 00 00 00 
   1b775:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b77c:	00 00 00 00 
   1b780:	48 8b 95 40 05 01 00 	mov    0x10540(%rbp),%rdx
   1b787:	48 01 c2             	add    %rax,%rdx
   1b78a:	48 89 94 45 40 05 01 	mov    %rdx,0x10540(%rbp,%rax,2)
   1b791:	00 
   1b792:	48 83 c0 04          	add    $0x4,%rax
   1b796:	c7 02 00 00 00 00    	movl   $0x0,(%rdx)
   1b79c:	48 3d 00 02 00 00    	cmp    $0x200,%rax
   1b7a2:	75 dc                	jne    1b780 <vpu_component_bind+0x1020>
   1b7a4:	41 83 c5 01          	add    $0x1,%r13d
   1b7a8:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1b7af:	45 3b 6f 7c          	cmp    0x7c(%r15),%r13d
   1b7b3:	0f 82 5b ff ff ff    	jb     1b714 <vpu_component_bind+0xfb4>
   1b7b9:	48 8b ac 24 88 00 00 	mov    0x88(%rsp),%rbp
   1b7c0:	00 
   1b7c1:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1b7c8:	00 
   1b7c9:	e9 13 f8 ff ff       	jmp    1afe1 <vpu_component_bind+0x881>
   1b7ce:	be ff ff ff ff       	mov    $0xffffffff,%esi
   1b7d3:	4c 89 ff             	mov    %r15,%rdi
   1b7d6:	e8 00 00 00 00       	call   1b7db <vpu_component_bind+0x107b>
			1b7d7: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b7db:	80 7c 24 0c 00       	cmpb   $0x0,0xc(%rsp)
   1b7e0:	0f 84 0e ff ff ff    	je     1b6f4 <vpu_component_bind+0xf94>
   1b7e6:	e9 cd fe ff ff       	jmp    1b6b8 <vpu_component_bind+0xf58>
   1b7eb:	4c 89 ff             	mov    %r15,%rdi
   1b7ee:	e8 00 00 00 00       	call   1b7f3 <vpu_component_bind+0x1093>
			1b7ef: R_X86_64_PLT32	vpu_dvfs_init-0x4
   1b7f3:	e9 5d fe ff ff       	jmp    1b655 <vpu_component_bind+0xef5>
   1b7f8:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b7ff:	00 
   1b800:	74 b7                	je     1b7b9 <vpu_component_bind+0x1059>
   1b802:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b805: R_X86_64_32S	__this_module
   1b809:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b80c: R_X86_64_32S	.data+0x29c0
   1b810:	e8 00 00 00 00       	call   1b815 <vpu_component_bind+0x10b5>
			1b811: R_X86_64_PLT32	__platform_driver_register-0x4
   1b815:	e9 e8 fe ff ff       	jmp    1b702 <vpu_component_bind+0xfa2>
   1b81a:	be ff ff ff ff       	mov    $0xffffffff,%esi
   1b81f:	4c 89 ff             	mov    %r15,%rdi
   1b822:	e8 00 00 00 00       	call   1b827 <vpu_component_bind+0x10c7>
			1b823: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b827:	e9 c8 fe ff ff       	jmp    1b6f4 <vpu_component_bind+0xf94>
   1b82c:	4c 89 ff             	mov    %r15,%rdi
   1b82f:	e8 00 00 00 00       	call   1b834 <vpu_component_bind+0x10d4>
			1b830: R_X86_64_PLT32	vpu_init_guest_mem-0x4
   1b834:	e9 a7 fb ff ff       	jmp    1b3e0 <vpu_component_bind+0xc80>
   1b839:	41 c7 87 58 05 00 00 	movl   $0x2,0x558(%r15)
   1b840:	02 00 00 00 
   1b844:	4c 89 ff             	mov    %r15,%rdi
   1b847:	e8 00 00 00 00       	call   1b84c <vpu_component_bind+0x10ec>
			1b848: R_X86_64_PLT32	vpu_smmu_init-0x4
   1b84c:	e9 70 fb ff ff       	jmp    1b3c1 <vpu_component_bind+0xc61>
   1b851:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b854: R_X86_64_32S	.rodata.str1.8+0x2228
   1b858:	e8 00 00 00 00       	call   1b85d <vpu_component_bind+0x10fd>
			1b859: R_X86_64_PLT32	os_printk-0x4
   1b85d:	e9 51 f7 ff ff       	jmp    1afb3 <vpu_component_bind+0x853>
   1b862:	41 8b 17             	mov    (%r15),%edx
   1b865:	48 89 ef             	mov    %rbp,%rdi
   1b868:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b86b: R_X86_64_32S	.rodata.str1.1+0xd7f
   1b86f:	e8 00 00 00 00       	call   1b874 <vpu_component_bind+0x1114>
			1b870: R_X86_64_PLT32	sprintf-0x4
   1b874:	48 89 e9             	mov    %rbp,%rcx
   1b877:	ba ff ff ff ff       	mov    $0xffffffff,%edx
   1b87c:	4c 89 fe             	mov    %r15,%rsi
   1b87f:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b882: R_X86_64_32S	vpu_host_thread1
   1b886:	e8 00 00 00 00       	call   1b88b <vpu_component_bind+0x112b>
			1b887: R_X86_64_PLT32	kthread_create_on_node-0x4
   1b88b:	49 89 87 b0 86 15 00 	mov    %rax,0x1586b0(%r15)
   1b892:	48 89 c7             	mov    %rax,%rdi
   1b895:	e8 00 00 00 00       	call   1b89a <vpu_component_bind+0x113a>
			1b896: R_X86_64_PLT32	wake_up_process-0x4
   1b89a:	e9 97 fb ff ff       	jmp    1b436 <vpu_component_bind+0xcd6>
   1b89f:	44 8b 54 24 30       	mov    0x30(%rsp),%r10d
   1b8a4:	45 85 d2             	test   %r10d,%r10d
   1b8a7:	0f 84 e4 00 00 00    	je     1b991 <vpu_component_bind+0x1231>
   1b8ad:	48 8d 6c 24 58       	lea    0x58(%rsp),%rbp
   1b8b2:	83 7c 24 34 01       	cmpl   $0x1,0x34(%rsp)
   1b8b7:	0f 85 79 fb ff ff    	jne    1b436 <vpu_component_bind+0xcd6>
   1b8bd:	45 8b 4f 7c          	mov    0x7c(%r15),%r9d
   1b8c1:	31 ed                	xor    %ebp,%ebp
   1b8c3:	45 85 c9             	test   %r9d,%r9d
   1b8c6:	74 24                	je     1b8ec <vpu_component_bind+0x118c>
   1b8c8:	41 81 bc af 80 00 00 	cmpl   $0x9800,0x80(%r15,%rbp,4)
   1b8cf:	00 00 98 00 00 
   1b8d4:	74 0c                	je     1b8e2 <vpu_component_bind+0x1182>
   1b8d6:	31 d2                	xor    %edx,%edx
   1b8d8:	89 ee                	mov    %ebp,%esi
   1b8da:	4c 89 ff             	mov    %r15,%rdi
   1b8dd:	e8 00 00 00 00       	call   1b8e2 <vpu_component_bind+0x1182>
			1b8de: R_X86_64_PLT32	vpu_load_firmware-0x4
   1b8e2:	48 83 c5 01          	add    $0x1,%rbp
   1b8e6:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b8ea:	72 dc                	jb     1b8c8 <vpu_component_bind+0x1168>
   1b8ec:	48 8d 6c 24 58       	lea    0x58(%rsp),%rbp
   1b8f1:	e9 40 fb ff ff       	jmp    1b436 <vpu_component_bind+0xcd6>
   1b8f6:	be de ff ff ff       	mov    $0xffffffde,%esi
   1b8fb:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b8fe: R_X86_64_32S	.rodata.str1.8+0x2248
   1b902:	e8 00 00 00 00       	call   1b907 <vpu_component_bind+0x11a7>
			1b903: R_X86_64_PLT32	os_printk-0x4
   1b907:	4c 89 ff             	mov    %r15,%rdi
   1b90a:	e8 00 00 00 00       	call   1b90f <vpu_component_bind+0x11af>
			1b90b: R_X86_64_PLT32	vpu_deinit_conf-0x4
   1b90f:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1b916:	00 
   1b917:	e9 97 f6 ff ff       	jmp    1afb3 <vpu_component_bind+0x853>
   1b91c:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b923:	89 ee                	mov    %ebp,%esi
   1b925:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b928: R_X86_64_32S	.rodata.str1.8+0x23a8
   1b92c:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b933:	00 
   1b934:	41 c7 45 14 50 a3 00 	movl   $0xa350,0x14(%r13)
   1b93b:	00 
   1b93c:	e8 00 00 00 00       	call   1b941 <vpu_component_bind+0x11e1>
			1b93d: R_X86_64_PLT32	os_printk-0x4
   1b941:	e9 f3 f7 ff ff       	jmp    1b139 <vpu_component_bind+0x9d9>
   1b946:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b94d:	89 ee                	mov    %ebp,%esi
   1b94f:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b952: R_X86_64_32S	.rodata.str1.8+0x2380
   1b956:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b95d:	00 
   1b95e:	41 c7 45 14 00 12 00 	movl   $0x1200,0x14(%r13)
   1b965:	00 
   1b966:	83 44 24 10 01       	addl   $0x1,0x10(%rsp)
   1b96b:	e8 00 00 00 00       	call   1b970 <vpu_component_bind+0x1210>
			1b96c: R_X86_64_PLT32	os_printk-0x4
   1b970:	e9 c4 f7 ff ff       	jmp    1b139 <vpu_component_bind+0x9d9>
   1b975:	48 83 c0 01          	add    $0x1,%rax
   1b979:	49 2b 85 e0 03 00 00 	sub    0x3e0(%r13),%rax
   1b980:	e9 3c f0 ff ff       	jmp    1a9c1 <vpu_component_bind+0x261>
   1b985:	48 c7 c5 ff ff ff ff 	mov    $0xffffffffffffffff,%rbp
   1b98c:	e9 20 f0 ff ff       	jmp    1a9b1 <vpu_component_bind+0x251>
   1b991:	4c 89 ff             	mov    %r15,%rdi
   1b994:	e8 00 00 00 00       	call   1b999 <vpu_component_bind+0x1239>
			1b995: R_X86_64_PLT32	vpu_set_vm_core-0x4
   1b999:	e9 1f ff ff ff       	jmp    1b8bd <vpu_component_bind+0x115d>
   1b99e:	be ea ff ff ff       	mov    $0xffffffea,%esi
   1b9a3:	e9 53 ff ff ff       	jmp    1b8fb <vpu_component_bind+0x119b>
   1b9a8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%rsp)
   1b9af:	00 
   1b9b0:	e9 9c f8 ff ff       	jmp    1b251 <vpu_component_bind+0xaf1>
   1b9b5:	41 bc f4 ff ff ff    	mov    $0xfffffff4,%r12d
   1b9bb:	e9 21 f6 ff ff       	jmp    1afe1 <vpu_component_bind+0x881>
   1b9c0:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1b9c7:	00 
   1b9c8:	e9 e6 f5 ff ff       	jmp    1afb3 <vpu_component_bind+0x853>
   1b9cd:	48 89 ac 24 88 00 00 	mov    %rbp,0x88(%rsp)
   1b9d4:	00 
   1b9d5:	4c 89 ac 24 98 00 00 	mov    %r13,0x98(%rsp)
   1b9dc:	00 
   1b9dd:	e8 00 00 00 00       	call   1b9e2 <vpu_component_bind+0x1282>
			1b9de: R_X86_64_PLT32	__stack_chk_fail-0x4

Disassembly of section .text.unlikely:

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
