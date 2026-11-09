
builds/runtime-fix3-v2-7.2.11-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

000000000001a820 <vpu_component_bind>:
   1a820:	f3 0f 1e fa          	endbr64
   1a824:	e8 00 00 00 00       	call   1a829 <vpu_component_bind+0x9>
			1a825: R_X86_64_PLT32	__fentry__-0x4
   1a829:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
   1a830:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
   1a835:	48 89 54 24 28       	mov    %rdx,0x28(%rsp)
   1a83a:	48 89 9c 24 80 00 00 	mov    %rbx,0x80(%rsp)
   1a841:	00 
   1a842:	48 89 f3             	mov    %rsi,%rbx
   1a845:	48 89 ac 24 88 00 00 	mov    %rbp,0x88(%rsp)
   1a84c:	00 
   1a84d:	4c 89 b4 24 a0 00 00 	mov    %r14,0xa0(%rsp)
   1a854:	00 
   1a855:	4c 89 a4 24 90 00 00 	mov    %r12,0x90(%rsp)
   1a85c:	00 
   1a85d:	4c 89 bc 24 a8 00 00 	mov    %r15,0xa8(%rsp)
   1a864:	00 
   1a865:	65 48 8b 05 00 00 00 	mov    %gs:0x0(%rip),%rax        # 1a86d <vpu_component_bind+0x4d>
   1a86c:	00 
			1a869: R_X86_64_PC32	__ref_stack_chk_guard-0x4
   1a86d:	48 89 44 24 78       	mov    %rax,0x78(%rsp)
   1a872:	48 8b 42 40          	mov    0x40(%rdx),%rax
   1a876:	c7 44 24 54 00 00 00 	movl   $0x0,0x54(%rsp)
   1a87d:	00 
   1a87e:	48 c7 44 24 58 00 00 	movq   $0x0,0x58(%rsp)
   1a885:	00 00 
   1a887:	48 c7 44 24 60 00 00 	movq   $0x0,0x60(%rsp)
   1a88e:	00 00 
   1a890:	48 c7 44 24 68 00 00 	movq   $0x0,0x68(%rsp)
   1a897:	00 00 
   1a899:	48 c7 44 24 70 00 00 	movq   $0x0,0x70(%rsp)
   1a8a0:	00 00 
   1a8a2:	48 89 04 24          	mov    %rax,(%rsp)
   1a8a6:	e8 00 00 00 00       	call   1a8ab <vpu_component_bind+0x8b>
			1a8a7: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a8ab:	89 44 24 30          	mov    %eax,0x30(%rsp)
   1a8af:	41 89 c6             	mov    %eax,%r14d
   1a8b2:	e8 00 00 00 00       	call   1a8b7 <vpu_component_bind+0x97>
			1a8b3: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a8b7:	89 44 24 34          	mov    %eax,0x34(%rsp)
   1a8bb:	e8 00 00 00 00       	call   1a8c0 <vpu_component_bind+0xa0>
			1a8bc: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a8c0:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1a8c3: R_X86_64_32S	.rodata+0x381ec
   1a8c7:	89 c5                	mov    %eax,%ebp
   1a8c9:	83 f8 ff             	cmp    $0xffffffff,%eax
   1a8cc:	74 15                	je     1a8e3 <vpu_component_bind+0xc3>
   1a8ce:	45 85 f6             	test   %r14d,%r14d
   1a8d1:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1a8d4: R_X86_64_32S	.rodata+0x381f8
   1a8d8:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
			1a8db: R_X86_64_32S	.rodata+0x381f3
   1a8df:	48 0f 44 f0          	cmove  %rax,%rsi
   1a8e3:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1a8e6: R_X86_64_32S	.rodata+0x381fe
   1a8ea:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1a8ed: R_X86_64_32S	.rodata+0x54b50
   1a8f1:	e8 00 00 00 00       	call   1a8f6 <vpu_component_bind+0xd6>
			1a8f2: R_X86_64_PLT32	os_printk-0x4
   1a8f6:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1a8fb:	bf 38 89 15 00       	mov    $0x158938,%edi
   1a900:	e8 00 00 00 00       	call   1a905 <vpu_component_bind+0xe5>
			1a901: R_X86_64_PLT32	__kmalloc_large_noprof-0x4
   1a905:	49 89 c7             	mov    %rax,%r15
   1a908:	48 85 c0             	test   %rax,%rax
   1a90b:	0f 84 e3 10 00 00    	je     1b9f4 <vpu_component_bind+0x11d4>
   1a911:	c7 80 04 04 00 00 00 	movl   $0x0,0x404(%rax)
   1a918:	00 00 00 
   1a91b:	48 8b 43 40          	mov    0x40(%rbx),%rax
   1a91f:	83 7c 24 34 01       	cmpl   $0x1,0x34(%rsp)
   1a924:	49 89 87 e8 03 00 00 	mov    %rax,0x3e8(%r15)
   1a92b:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1a930:	41 0f 94 c4          	sete   %r12b
   1a934:	49 89 87 f0 03 00 00 	mov    %rax,0x3f0(%r15)
   1a93b:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   1a940:	49 89 87 f8 03 00 00 	mov    %rax,0x3f8(%r15)
   1a947:	48 8b 04 24          	mov    (%rsp),%rax
   1a94b:	4c 89 78 28          	mov    %r15,0x28(%rax)
   1a94f:	e8 00 00 00 00       	call   1a954 <vpu_component_bind+0x134>
			1a950: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   1a954:	49 8b bf e8 03 00 00 	mov    0x3e8(%r15),%rdi
   1a95b:	41 c7 87 28 89 15 00 	movl   $0x1,0x158928(%r15)
   1a962:	01 00 00 00 
   1a966:	41 89 87 00 04 00 00 	mov    %eax,0x400(%r15)
   1a96d:	e8 00 00 00 00       	call   1a972 <vpu_component_bind+0x152>
			1a96e: R_X86_64_PLT32	os_dev_is_pci-0x4
   1a972:	84 c0                	test   %al,%al
   1a974:	49 8b 87 e8 03 00 00 	mov    0x3e8(%r15),%rax
   1a97b:	0f 85 45 05 00 00    	jne    1aec6 <vpu_component_bind+0x6a6>
   1a981:	41 c6 87 10 04 00 00 	movb   $0x1,0x410(%r15)
   1a988:	01 
   1a989:	49 c7 87 e0 03 00 00 	movq   $0x0,0x3e0(%r15)
   1a990:	00 00 00 00 
   1a994:	4c 8b 70 78          	mov    0x78(%rax),%r14
   1a998:	4d 85 f6             	test   %r14,%r14
   1a99b:	0f 84 ef 0e 00 00    	je     1b890 <vpu_component_bind+0x1070>
   1a9a1:	41 0f b6 d4          	movzbl %r12b,%edx
   1a9a5:	4c 89 fe             	mov    %r15,%rsi
   1a9a8:	bf 00 0a 00 00       	mov    $0xa00,%edi
   1a9ad:	e8 00 00 00 00       	call   1a9b2 <vpu_component_bind+0x192>
			1a9ae: R_X86_64_PLT32	vpu_init_conf-0x4
   1a9b2:	85 c0                	test   %eax,%eax
   1a9b4:	0f 85 57 06 00 00    	jne    1b011 <vpu_component_bind+0x7f1>
   1a9ba:	4c 89 ac 24 98 00 00 	mov    %r13,0x98(%rsp)
   1a9c1:	00 
   1a9c2:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
   1a9c9:	00 00 
   1a9cb:	41 8b 47 0c          	mov    0xc(%r15),%eax
   1a9cf:	4d 8b af e0 03 00 00 	mov    0x3e0(%r15),%r13
   1a9d6:	89 44 24 40          	mov    %eax,0x40(%rsp)
   1a9da:	4d 85 ed             	test   %r13,%r13
   1a9dd:	0f 84 7f 01 00 00    	je     1ab62 <vpu_component_bind+0x342>
   1a9e3:	66 41 81 7d 3c d5 1e 	cmpw   $0x1ed5,0x3c(%r13)
   1a9ea:	0f 85 72 01 00 00    	jne    1ab62 <vpu_component_bind+0x342>
   1a9f0:	66 41 81 7d 3e 02 01 	cmpw   $0x102,0x3e(%r13)
   1a9f7:	0f 85 65 01 00 00    	jne    1ab62 <vpu_component_bind+0x342>
   1a9fd:	41 83 bf 00 04 00 00 	cmpl   $0x1,0x400(%r15)
   1aa04:	01 
   1aa05:	0f 84 57 01 00 00    	je     1ab62 <vpu_component_bind+0x342>
   1aa0b:	41 8b 8e b0 02 00 00 	mov    0x2b0(%r14),%ecx
   1aa12:	85 c9                	test   %ecx,%ecx
   1aa14:	0f 84 aa 0f 00 00    	je     1b9c4 <vpu_component_bind+0x11a4>
   1aa1a:	31 db                	xor    %ebx,%ebx
   1aa1c:	49 c7 c4 ff ff ff ff 	mov    $0xffffffffffffffff,%r12
   1aa23:	49 8b bc de b8 02 00 	mov    0x2b8(%r14,%rbx,8),%rdi
   1aa2a:	00 
   1aa2b:	48 85 ff             	test   %rdi,%rdi
   1aa2e:	74 33                	je     1aa63 <vpu_component_bind+0x243>
   1aa30:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1aa33: R_X86_64_32S	.rodata+0x38207
   1aa37:	be 00 02 00 00       	mov    $0x200,%esi
   1aa3c:	e8 00 00 00 00       	call   1aa41 <vpu_component_bind+0x221>
			1aa3d: R_X86_64_PLT32	platform_get_resource_byname-0x4
   1aa41:	48 85 c0             	test   %rax,%rax
   1aa44:	74 1d                	je     1aa63 <vpu_component_bind+0x243>
   1aa46:	48 8b 00             	mov    (%rax),%rax
   1aa49:	49 8b 95 08 04 00 00 	mov    0x408(%r13),%rdx
   1aa50:	48 39 d0             	cmp    %rdx,%rax
   1aa53:	0f 82 dc 0e 00 00    	jb     1b935 <vpu_component_bind+0x1115>
   1aa59:	48 29 d0             	sub    %rdx,%rax
   1aa5c:	49 39 c4             	cmp    %rax,%r12
   1aa5f:	4c 0f 47 e0          	cmova  %rax,%r12
   1aa63:	48 83 c3 01          	add    $0x1,%rbx
   1aa67:	41 3b 9e b0 02 00 00 	cmp    0x2b0(%r14),%ebx
   1aa6e:	72 b3                	jb     1aa23 <vpu_component_bind+0x203>
   1aa70:	49 8b 85 10 04 00 00 	mov    0x410(%r13),%rax
   1aa77:	48 85 c0             	test   %rax,%rax
   1aa7a:	0f 85 34 0f 00 00    	jne    1b9b4 <vpu_component_bind+0x1194>
   1aa80:	41 8b 57 04          	mov    0x4(%r15),%edx
   1aa84:	85 d2                	test   %edx,%edx
   1aa86:	0f 85 51 0f 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aa8c:	41 81 7f 08 00 80 10 	cmpl   $0x108000,0x8(%r15)
   1aa93:	00 
   1aa94:	0f 85 43 0f 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aa9a:	41 81 7f 0c 00 f0 00 	cmpl   $0xf000,0xc(%r15)
   1aaa1:	00 
   1aaa2:	0f 85 35 0f 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aaa8:	41 83 7f 7c 03       	cmpl   $0x3,0x7c(%r15)
   1aaad:	0f 85 2a 0f 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aab3:	41 81 7f 70 00 d0 00 	cmpl   $0xd000,0x70(%r15)
   1aaba:	00 
   1aabb:	0f 85 1c 0f 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aac1:	45 8b 6f 74          	mov    0x74(%r15),%r13d
   1aac5:	45 85 ed             	test   %r13d,%r13d
   1aac8:	0f 85 0f 0f 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aace:	41 81 bf 80 00 00 00 	cmpl   $0x9800,0x80(%r15)
   1aad5:	00 98 00 00 
   1aad9:	0f 85 fe 0e 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aadf:	41 81 bf 84 00 00 00 	cmpl   $0x5170,0x84(%r15)
   1aae6:	70 51 00 00 
   1aaea:	0f 85 ed 0e 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1aaf0:	41 81 bf 88 00 00 00 	cmpl   $0x6270,0x88(%r15)
   1aaf7:	70 62 00 00 
   1aafb:	0f 85 dc 0e 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1ab01:	41 81 7f 10 00 40 00 	cmpl   $0x4000,0x10(%r15)
   1ab08:	00 
   1ab09:	0f 85 ce 0e 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1ab0f:	41 81 7f 14 00 40 00 	cmpl   $0x4000,0x14(%r15)
   1ab16:	00 
   1ab17:	0f 85 c0 0e 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1ab1d:	41 81 7f 18 00 40 00 	cmpl   $0x4000,0x18(%r15)
   1ab24:	00 
   1ab25:	0f 85 b2 0e 00 00    	jne    1b9dd <vpu_component_bind+0x11bd>
   1ab2b:	48 3d ff 5f 11 00    	cmp    $0x115fff,%rax
   1ab31:	0f 86 fe 0d 00 00    	jbe    1b935 <vpu_component_bind+0x1115>
   1ab37:	49 81 fc 00 60 11 00 	cmp    $0x116000,%r12
   1ab3e:	0f 85 f1 0d 00 00    	jne    1b935 <vpu_component_bind+0x1115>
   1ab44:	ba 00 e0 00 00       	mov    $0xe000,%edx
   1ab49:	be 00 80 10 00       	mov    $0x108000,%esi
   1ab4e:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1ab51: R_X86_64_32S	.rodata+0x54bc0
   1ab55:	e8 00 00 00 00       	call   1ab5a <vpu_component_bind+0x33a>
			1ab56: R_X86_64_PLT32	os_printk-0x4
   1ab5a:	c7 44 24 40 00 e0 00 	movl   $0xe000,0x40(%rsp)
   1ab61:	00 
   1ab62:	e8 00 00 00 00       	call   1ab67 <vpu_component_bind+0x347>
			1ab63: R_X86_64_PLT32	os_create_timer_list-0x4
   1ab67:	49 89 87 08 88 15 00 	mov    %rax,0x158808(%r15)
   1ab6e:	48 85 c0             	test   %rax,%rax
   1ab71:	0f 84 88 0e 00 00    	je     1b9ff <vpu_component_bind+0x11df>
   1ab77:	e8 00 00 00 00       	call   1ab7c <vpu_component_bind+0x35c>
			1ab78: R_X86_64_PLT32	os_create_timer_list-0x4
   1ab7c:	49 89 87 10 88 15 00 	mov    %rax,0x158810(%r15)
   1ab83:	48 85 c0             	test   %rax,%rax
   1ab86:	0f 84 73 0e 00 00    	je     1b9ff <vpu_component_bind+0x11df>
   1ab8c:	49 8d 87 98 86 15 00 	lea    0x158698(%r15),%rax
   1ab93:	4d 8d af c8 86 15 00 	lea    0x1586c8(%r15),%r13
   1ab9a:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
   1ab9f:	4d 8d a7 f8 86 15 00 	lea    0x1586f8(%r15),%r12
   1aba6:	48 89 c3             	mov    %rax,%rbx
   1aba9:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1abb0 <vpu_component_bind+0x390>
			1abac: R_X86_64_PC32	kmalloc_caches+0x24
   1abb0:	ba 18 00 00 00       	mov    $0x18,%edx
   1abb5:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1abba:	e8 00 00 00 00       	call   1abbf <vpu_component_bind+0x39f>
			1abbb: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1abbf:	48 89 03             	mov    %rax,(%rbx)
   1abc2:	48 85 c0             	test   %rax,%rax
   1abc5:	0f 84 1e 04 00 00    	je     1afe9 <vpu_component_bind+0x7c9>
   1abcb:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
   1abd2:	ba 18 00 00 00       	mov    $0x18,%edx
   1abd7:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1abdc:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
   1abe3:	00 
   1abe4:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
   1abeb:	00 
   1abec:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1abf3 <vpu_component_bind+0x3d3>
			1abef: R_X86_64_PC32	kmalloc_caches+0x24
   1abf3:	e8 00 00 00 00       	call   1abf8 <vpu_component_bind+0x3d8>
			1abf4: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1abf8:	48 89 83 38 01 00 00 	mov    %rax,0x138(%rbx)
   1abff:	48 85 c0             	test   %rax,%rax
   1ac02:	0f 84 e1 03 00 00    	je     1afe9 <vpu_component_bind+0x7c9>
   1ac08:	48 89 c7             	mov    %rax,%rdi
   1ac0b:	48 83 c3 08          	add    $0x8,%rbx
   1ac0f:	e8 00 00 00 00       	call   1ac14 <vpu_component_bind+0x3f4>
			1ac10: R_X86_64_PLT32	mutex_init_generic-0x4
   1ac14:	4d 89 6d 00          	mov    %r13,0x0(%r13)
   1ac18:	4d 89 6d 08          	mov    %r13,0x8(%r13)
   1ac1c:	49 83 c5 10          	add    $0x10,%r13
   1ac20:	4d 39 e5             	cmp    %r12,%r13
   1ac23:	75 84                	jne    1aba9 <vpu_component_bind+0x389>
   1ac25:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
   1ac2a:	49 8d b7 20 88 15 00 	lea    0x158820(%r15),%rsi
   1ac31:	e8 00 00 00 00       	call   1ac36 <vpu_component_bind+0x416>
			1ac32: R_X86_64_PLT32	vpu_mmu_context_create-0x4
   1ac36:	89 44 24 44          	mov    %eax,0x44(%rsp)
   1ac3a:	85 c0                	test   %eax,%eax
   1ac3c:	0f 85 73 03 00 00    	jne    1afb5 <vpu_component_bind+0x795>
   1ac42:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ac49 <vpu_component_bind+0x429>
			1ac45: R_X86_64_PC32	kmalloc_caches+0x14
   1ac49:	ba 04 00 00 00       	mov    $0x4,%edx
   1ac4e:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ac53:	e8 00 00 00 00       	call   1ac58 <vpu_component_bind+0x438>
			1ac54: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ac58:	49 89 87 60 05 00 00 	mov    %rax,0x560(%r15)
   1ac5f:	48 85 c0             	test   %rax,%rax
   1ac62:	0f 84 31 03 00 00    	je     1af99 <vpu_component_bind+0x779>
   1ac68:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1ac6e:	ba 04 00 00 00       	mov    $0x4,%edx
   1ac73:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ac78:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ac7f <vpu_component_bind+0x45f>
			1ac7b: R_X86_64_PC32	kmalloc_caches+0x14
   1ac7f:	e8 00 00 00 00       	call   1ac84 <vpu_component_bind+0x464>
			1ac80: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ac84:	49 89 87 f8 26 00 00 	mov    %rax,0x26f8(%r15)
   1ac8b:	48 85 c0             	test   %rax,%rax
   1ac8e:	0f 84 f9 02 00 00    	je     1af8d <vpu_component_bind+0x76d>
   1ac94:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1ac9a:	ba 18 00 00 00       	mov    $0x18,%edx
   1ac9f:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1aca4:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1acab <vpu_component_bind+0x48b>
			1aca7: R_X86_64_PC32	kmalloc_caches+0x24
   1acab:	e8 00 00 00 00       	call   1acb0 <vpu_component_bind+0x490>
			1acac: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1acb0:	49 89 87 08 04 00 00 	mov    %rax,0x408(%r15)
   1acb7:	48 85 c0             	test   %rax,%rax
   1acba:	0f 84 c1 02 00 00    	je     1af81 <vpu_component_bind+0x761>
   1acc0:	48 89 c7             	mov    %rax,%rdi
   1acc3:	e8 00 00 00 00       	call   1acc8 <vpu_component_bind+0x4a8>
			1acc4: R_X86_64_PLT32	mutex_init_generic-0x4
   1acc8:	ba 18 00 00 00       	mov    $0x18,%edx
   1accd:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1acd2:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1acd9 <vpu_component_bind+0x4b9>
			1acd5: R_X86_64_PC32	kmalloc_caches+0x24
   1acd9:	e8 00 00 00 00       	call   1acde <vpu_component_bind+0x4be>
			1acda: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1acde:	49 89 87 30 89 15 00 	mov    %rax,0x158930(%r15)
   1ace5:	48 85 c0             	test   %rax,%rax
   1ace8:	0f 84 87 02 00 00    	je     1af75 <vpu_component_bind+0x755>
   1acee:	48 89 c7             	mov    %rax,%rdi
   1acf1:	e8 00 00 00 00       	call   1acf6 <vpu_component_bind+0x4d6>
			1acf2: R_X86_64_PLT32	mutex_init_generic-0x4
   1acf6:	ba 04 00 00 00       	mov    $0x4,%edx
   1acfb:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ad00:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ad07 <vpu_component_bind+0x4e7>
			1ad03: R_X86_64_PC32	kmalloc_caches+0x14
   1ad07:	e8 00 00 00 00       	call   1ad0c <vpu_component_bind+0x4ec>
			1ad08: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ad0c:	49 89 87 68 05 00 00 	mov    %rax,0x568(%r15)
   1ad13:	48 85 c0             	test   %rax,%rax
   1ad16:	0f 84 4d 02 00 00    	je     1af69 <vpu_component_bind+0x749>
   1ad1c:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1ad22:	45 8b 67 7c          	mov    0x7c(%r15),%r12d
   1ad26:	83 fd ff             	cmp    $0xffffffff,%ebp
   1ad29:	0f 94 44 24 17       	sete   0x17(%rsp)
   1ad2e:	0f b6 4c 24 17       	movzbl 0x17(%rsp),%ecx
   1ad33:	45 85 e4             	test   %r12d,%r12d
   1ad36:	0f 84 45 03 00 00    	je     1b081 <vpu_component_bind+0x861>
   1ad3c:	80 f9 01             	cmp    $0x1,%cl
   1ad3f:	4d 8d a7 00 95 00 00 	lea    0x9500(%r15),%r12
   1ad46:	19 db                	sbb    %ebx,%ebx
   1ad48:	45 31 ed             	xor    %r13d,%r13d
   1ad4b:	83 e3 fd             	and    $0xfffffffd,%ebx
   1ad4e:	83 c3 04             	add    $0x4,%ebx
   1ad51:	eb 44                	jmp    1ad97 <vpu_component_bind+0x577>
   1ad53:	3d 7b 62 00 00       	cmp    $0x627b,%eax
   1ad58:	0f 84 b8 00 00 00    	je     1ae16 <vpu_component_bind+0x5f6>
   1ad5e:	41 8b 47 04          	mov    0x4(%r15),%eax
   1ad62:	83 e8 06             	sub    $0x6,%eax
   1ad65:	83 f8 01             	cmp    $0x1,%eax
   1ad68:	77 18                	ja     1ad82 <vpu_component_bind+0x562>
   1ad6a:	41 c7 84 24 74 ac ff 	movl   $0x1,-0x538c(%r12)
   1ad71:	ff 01 00 00 00 
   1ad76:	49 c7 84 24 78 ac ff 	movq   $0x0,-0x5388(%r12)
   1ad7d:	ff 00 00 00 00 
   1ad82:	49 83 c5 01          	add    $0x1,%r13
   1ad86:	49 81 c4 f8 e3 00 00 	add    $0xe3f8,%r12
   1ad8d:	45 3b 6f 7c          	cmp    0x7c(%r15),%r13d
   1ad91:	0f 83 ea 02 00 00    	jae    1b081 <vpu_component_bind+0x861>
   1ad97:	41 89 5c 24 20       	mov    %ebx,0x20(%r12)
   1ad9c:	ba 18 00 00 00       	mov    $0x18,%edx
   1ada1:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ada6:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1adad <vpu_component_bind+0x58d>
			1ada9: R_X86_64_PC32	kmalloc_caches+0x24
   1adad:	e8 00 00 00 00       	call   1adb2 <vpu_component_bind+0x592>
			1adae: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1adb2:	49 89 84 24 d0 b6 ff 	mov    %rax,-0x4930(%r12)
   1adb9:	ff 
   1adba:	48 85 c0             	test   %rax,%rax
   1adbd:	0f 84 91 00 00 00    	je     1ae54 <vpu_component_bind+0x634>
   1adc3:	48 89 c7             	mov    %rax,%rdi
   1adc6:	e8 00 00 00 00       	call   1adcb <vpu_component_bind+0x5ab>
			1adc7: R_X86_64_PLT32	mutex_init_generic-0x4
   1adcb:	ba 18 00 00 00       	mov    $0x18,%edx
   1add0:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1add5:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1addc <vpu_component_bind+0x5bc>
			1add8: R_X86_64_PC32	kmalloc_caches+0x24
   1addc:	e8 00 00 00 00       	call   1ade1 <vpu_component_bind+0x5c1>
			1addd: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ade1:	49 89 84 24 c8 b6 ff 	mov    %rax,-0x4938(%r12)
   1ade8:	ff 
   1ade9:	48 85 c0             	test   %rax,%rax
   1adec:	74 66                	je     1ae54 <vpu_component_bind+0x634>
   1adee:	48 89 c7             	mov    %rax,%rdi
   1adf1:	e8 00 00 00 00       	call   1adf6 <vpu_component_bind+0x5d6>
			1adf2: R_X86_64_PLT32	mutex_init_generic-0x4
   1adf6:	43 8b 84 af 80 00 00 	mov    0x80(%r15,%r13,4),%eax
   1adfd:	00 
   1adfe:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1ae03:	0f 94 c2             	sete   %dl
   1ae06:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1ae0b:	0f 94 c1             	sete   %cl
   1ae0e:	08 ca                	or     %cl,%dl
   1ae10:	0f 84 3d ff ff ff    	je     1ad53 <vpu_component_bind+0x533>
   1ae16:	49 8d ac 24 00 fc ff 	lea    -0x400(%r12),%rbp
   1ae1d:	ff 
   1ae1e:	eb 15                	jmp    1ae35 <vpu_component_bind+0x615>
   1ae20:	48 89 c7             	mov    %rax,%rdi
   1ae23:	48 83 c5 08          	add    $0x8,%rbp
   1ae27:	e8 00 00 00 00       	call   1ae2c <vpu_component_bind+0x60c>
			1ae28: R_X86_64_PLT32	mutex_init_generic-0x4
   1ae2c:	4c 39 e5             	cmp    %r12,%rbp
   1ae2f:	0f 84 29 ff ff ff    	je     1ad5e <vpu_component_bind+0x53e>
   1ae35:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1ae3c <vpu_component_bind+0x61c>
			1ae38: R_X86_64_PC32	kmalloc_caches+0x24
   1ae3c:	ba 18 00 00 00       	mov    $0x18,%edx
   1ae41:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1ae46:	e8 00 00 00 00       	call   1ae4b <vpu_component_bind+0x62b>
			1ae47: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1ae4b:	48 89 45 00          	mov    %rax,0x0(%rbp)
   1ae4f:	48 85 c0             	test   %rax,%rax
   1ae52:	75 cc                	jne    1ae20 <vpu_component_bind+0x600>
   1ae54:	41 8b 47 7c          	mov    0x7c(%r15),%eax
   1ae58:	85 c0                	test   %eax,%eax
   1ae5a:	0f 84 f1 00 00 00    	je     1af51 <vpu_component_bind+0x731>
   1ae60:	49 8d af 00 95 00 00 	lea    0x9500(%r15),%rbp
   1ae67:	45 31 e4             	xor    %r12d,%r12d
   1ae6a:	eb 1f                	jmp    1ae8b <vpu_component_bind+0x66b>
   1ae6c:	3d 7b 62 00 00       	cmp    $0x627b,%eax
   1ae71:	74 34                	je     1aea7 <vpu_component_bind+0x687>
   1ae73:	41 8b 47 7c          	mov    0x7c(%r15),%eax
   1ae77:	49 83 c4 01          	add    $0x1,%r12
   1ae7b:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1ae82:	41 39 c4             	cmp    %eax,%r12d
   1ae85:	0f 83 8b 00 00 00    	jae    1af16 <vpu_component_bind+0x6f6>
   1ae8b:	43 8b 84 a7 80 00 00 	mov    0x80(%r15,%r12,4),%eax
   1ae92:	00 
   1ae93:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1ae98:	0f 94 c2             	sete   %dl
   1ae9b:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1aea0:	0f 94 c1             	sete   %cl
   1aea3:	08 ca                	or     %cl,%dl
   1aea5:	74 c5                	je     1ae6c <vpu_component_bind+0x64c>
   1aea7:	48 8d 9d 00 fc ff ff 	lea    -0x400(%rbp),%rbx
   1aeae:	48 8b 3b             	mov    (%rbx),%rdi
   1aeb1:	48 85 ff             	test   %rdi,%rdi
   1aeb4:	74 05                	je     1aebb <vpu_component_bind+0x69b>
   1aeb6:	e8 00 00 00 00       	call   1aebb <vpu_component_bind+0x69b>
			1aeb7: R_X86_64_PLT32	kfree-0x4
   1aebb:	48 83 c3 08          	add    $0x8,%rbx
   1aebf:	48 39 dd             	cmp    %rbx,%rbp
   1aec2:	75 ea                	jne    1aeae <vpu_component_bind+0x68e>
   1aec4:	eb ad                	jmp    1ae73 <vpu_component_bind+0x653>
   1aec6:	48 8d 88 30 ff ff ff 	lea    -0xd0(%rax),%rcx
   1aecd:	41 c6 87 10 04 00 00 	movb   $0x0,0x410(%r15)
   1aed4:	00 
   1aed5:	49 89 8f e0 03 00 00 	mov    %rcx,0x3e0(%r15)
   1aedc:	4c 8b 70 78          	mov    0x78(%rax),%r14
   1aee0:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
   1aee5:	4d 85 f6             	test   %r14,%r14
   1aee8:	0f 84 a2 09 00 00    	je     1b890 <vpu_component_bind+0x1070>
   1aeee:	0f b7 b8 6e ff ff ff 	movzwl -0x92(%rax),%edi
   1aef5:	41 0f b6 d4          	movzbl %r12b,%edx
   1aef9:	4c 89 fe             	mov    %r15,%rsi
   1aefc:	e8 00 00 00 00       	call   1af01 <vpu_component_bind+0x6e1>
			1aefd: R_X86_64_PLT32	vpu_init_conf-0x4
   1af01:	85 c0                	test   %eax,%eax
   1af03:	0f 85 08 01 00 00    	jne    1b011 <vpu_component_bind+0x7f1>
   1af09:	4c 89 ac 24 98 00 00 	mov    %r13,0x98(%rsp)
   1af10:	00 
   1af11:	e9 b5 fa ff ff       	jmp    1a9cb <vpu_component_bind+0x1ab>
   1af16:	85 c0                	test   %eax,%eax
   1af18:	74 37                	je     1af51 <vpu_component_bind+0x731>
   1af1a:	8b 5c 24 44          	mov    0x44(%rsp),%ebx
   1af1e:	49 8d af c8 4b 00 00 	lea    0x4bc8(%r15),%rbp
   1af25:	48 8b 7d 00          	mov    0x0(%rbp),%rdi
   1af29:	48 85 ff             	test   %rdi,%rdi
   1af2c:	74 05                	je     1af33 <vpu_component_bind+0x713>
   1af2e:	e8 00 00 00 00       	call   1af33 <vpu_component_bind+0x713>
			1af2f: R_X86_64_PLT32	kfree-0x4
   1af33:	48 8b 7d 08          	mov    0x8(%rbp),%rdi
   1af37:	48 85 ff             	test   %rdi,%rdi
   1af3a:	74 05                	je     1af41 <vpu_component_bind+0x721>
   1af3c:	e8 00 00 00 00       	call   1af41 <vpu_component_bind+0x721>
			1af3d: R_X86_64_PLT32	kfree-0x4
   1af41:	83 c3 01             	add    $0x1,%ebx
   1af44:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1af4b:	41 3b 5f 7c          	cmp    0x7c(%r15),%ebx
   1af4f:	72 d4                	jb     1af25 <vpu_component_bind+0x705>
   1af51:	49 8b bf 18 88 15 00 	mov    0x158818(%r15),%rdi
   1af58:	e8 00 00 00 00       	call   1af5d <vpu_component_bind+0x73d>
			1af59: R_X86_64_PLT32	os_kfree-0x4
   1af5d:	49 8b bf 68 05 00 00 	mov    0x568(%r15),%rdi
   1af64:	e8 00 00 00 00       	call   1af69 <vpu_component_bind+0x749>
			1af65: R_X86_64_PLT32	kfree-0x4
   1af69:	49 8b bf 30 89 15 00 	mov    0x158930(%r15),%rdi
   1af70:	e8 00 00 00 00       	call   1af75 <vpu_component_bind+0x755>
			1af71: R_X86_64_PLT32	kfree-0x4
   1af75:	49 8b bf 08 04 00 00 	mov    0x408(%r15),%rdi
   1af7c:	e8 00 00 00 00       	call   1af81 <vpu_component_bind+0x761>
			1af7d: R_X86_64_PLT32	kfree-0x4
   1af81:	49 8b bf f8 26 00 00 	mov    0x26f8(%r15),%rdi
   1af88:	e8 00 00 00 00       	call   1af8d <vpu_component_bind+0x76d>
			1af89: R_X86_64_PLT32	kfree-0x4
   1af8d:	49 8b bf 60 05 00 00 	mov    0x560(%r15),%rdi
   1af94:	e8 00 00 00 00       	call   1af99 <vpu_component_bind+0x779>
			1af95: R_X86_64_PLT32	kfree-0x4
   1af99:	49 8b bf 20 88 15 00 	mov    0x158820(%r15),%rdi
   1afa0:	48 85 ff             	test   %rdi,%rdi
   1afa3:	74 10                	je     1afb5 <vpu_component_bind+0x795>
   1afa5:	e8 00 00 00 00       	call   1afaa <vpu_component_bind+0x78a>
			1afa6: R_X86_64_PLT32	vpu_mmu_context_destroy-0x4
   1afaa:	49 c7 87 20 88 15 00 	movq   $0x0,0x158820(%r15)
   1afb1:	00 00 00 00 
   1afb5:	48 8b 6c 24 38       	mov    0x38(%rsp),%rbp
   1afba:	49 8d 9f b0 86 15 00 	lea    0x1586b0(%r15),%rbx
   1afc1:	48 8b bd 38 01 00 00 	mov    0x138(%rbp),%rdi
   1afc8:	48 85 ff             	test   %rdi,%rdi
   1afcb:	74 05                	je     1afd2 <vpu_component_bind+0x7b2>
   1afcd:	e8 00 00 00 00       	call   1afd2 <vpu_component_bind+0x7b2>
			1afce: R_X86_64_PLT32	kfree-0x4
   1afd2:	48 8b 7d 00          	mov    0x0(%rbp),%rdi
   1afd6:	48 85 ff             	test   %rdi,%rdi
   1afd9:	74 05                	je     1afe0 <vpu_component_bind+0x7c0>
   1afdb:	e8 00 00 00 00       	call   1afe0 <vpu_component_bind+0x7c0>
			1afdc: R_X86_64_PLT32	kfree-0x4
   1afe0:	48 83 c5 08          	add    $0x8,%rbp
   1afe4:	48 39 dd             	cmp    %rbx,%rbp
   1afe7:	75 d8                	jne    1afc1 <vpu_component_bind+0x7a1>
   1afe9:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1aff0:	e8 00 00 00 00       	call   1aff5 <vpu_component_bind+0x7d5>
			1aff1: R_X86_64_PLT32	kfree-0x4
   1aff5:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1affc:	e8 00 00 00 00       	call   1b001 <vpu_component_bind+0x7e1>
			1affd: R_X86_64_PLT32	kfree-0x4
   1b001:	4c 89 ff             	mov    %r15,%rdi
   1b004:	e8 00 00 00 00       	call   1b009 <vpu_component_bind+0x7e9>
			1b005: R_X86_64_PLT32	vpu_deinit_conf-0x4
   1b009:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1b010:	00 
   1b011:	48 8b 04 24          	mov    (%rsp),%rax
   1b015:	4c 89 ff             	mov    %r15,%rdi
   1b018:	41 bc ed ff ff ff    	mov    $0xffffffed,%r12d
   1b01e:	48 c7 40 28 00 00 00 	movq   $0x0,0x28(%rax)
   1b025:	00 
   1b026:	e8 00 00 00 00       	call   1b02b <vpu_component_bind+0x80b>
			1b027: R_X86_64_PLT32	kfree-0x4
   1b02b:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b02e: R_X86_64_32S	.rodata+0x38240
   1b032:	e8 00 00 00 00       	call   1b037 <vpu_component_bind+0x817>
			1b033: R_X86_64_PLT32	os_printk-0x4
   1b037:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
   1b03c:	65 48 2b 05 00 00 00 	sub    %gs:0x0(%rip),%rax        # 1b044 <vpu_component_bind+0x824>
   1b043:	00 
			1b040: R_X86_64_PC32	__ref_stack_chk_guard-0x4
   1b044:	0f 85 c2 09 00 00    	jne    1ba0c <vpu_component_bind+0x11ec>
   1b04a:	44 89 e0             	mov    %r12d,%eax
   1b04d:	48 8b 9c 24 80 00 00 	mov    0x80(%rsp),%rbx
   1b054:	00 
   1b055:	48 8b ac 24 88 00 00 	mov    0x88(%rsp),%rbp
   1b05c:	00 
   1b05d:	4c 8b a4 24 90 00 00 	mov    0x90(%rsp),%r12
   1b064:	00 
   1b065:	4c 8b b4 24 a0 00 00 	mov    0xa0(%rsp),%r14
   1b06c:	00 
   1b06d:	4c 8b bc 24 a8 00 00 	mov    0xa8(%rsp),%r15
   1b074:	00 
   1b075:	48 81 c4 b0 00 00 00 	add    $0xb0,%rsp
   1b07c:	e9 00 00 00 00       	jmp    1b081 <vpu_component_bind+0x861>
			1b07d: R_X86_64_PLT32	__x86_return_thunk-0x4
   1b081:	4c 89 f7             	mov    %r14,%rdi
   1b084:	4d 8d a6 b8 03 00 00 	lea    0x3b8(%r14),%r12
   1b08b:	49 8d ae b8 04 00 00 	lea    0x4b8(%r14),%rbp
   1b092:	45 31 ed             	xor    %r13d,%r13d
   1b095:	e8 00 00 00 00       	call   1b09a <vpu_component_bind+0x87a>
			1b096: R_X86_64_PLT32	mtgpu_get_primary_core_count-0x4
   1b09a:	48 8b 1c 24          	mov    (%rsp),%rbx
   1b09e:	41 89 87 74 25 00 00 	mov    %eax,0x2574(%r15)
   1b0a5:	41 0f b6 86 44 0b 00 	movzbl 0xb44(%r14),%eax
   1b0ac:	00 
   1b0ad:	41 89 87 58 05 00 00 	mov    %eax,0x558(%r15)
   1b0b4:	49 8b 04 24          	mov    (%r12),%rax
   1b0b8:	48 85 c0             	test   %rax,%rax
   1b0bb:	74 3a                	je     1b0f7 <vpu_component_bind+0x8d7>
   1b0bd:	48 8d 78 10          	lea    0x10(%rax),%rdi
   1b0c1:	e8 00 00 00 00       	call   1b0c6 <vpu_component_bind+0x8a6>
			1b0c2: R_X86_64_PLT32	os_dev_get_drvdata-0x4
   1b0c6:	49 63 d5             	movslq %r13d,%rdx
   1b0c9:	49 89 84 d7 78 25 00 	mov    %rax,0x2578(%r15,%rdx,8)
   1b0d0:	00 
   1b0d1:	48 85 c0             	test   %rax,%rax
   1b0d4:	0f 84 c7 01 00 00    	je     1b2a1 <vpu_component_bind+0xa81>
   1b0da:	41 0f b6 8c 16 24 0b 	movzbl 0xb24(%r14,%rdx,1),%ecx
   1b0e1:	00 00 
   1b0e3:	41 83 c5 01          	add    $0x1,%r13d
   1b0e7:	41 89 8c 97 78 26 00 	mov    %ecx,0x2678(%r15,%rdx,4)
   1b0ee:	00 
   1b0ef:	48 8b 58 40          	mov    0x40(%rax),%rbx
   1b0f3:	4c 89 7b 28          	mov    %r15,0x28(%rbx)
   1b0f7:	49 83 c4 08          	add    $0x8,%r12
   1b0fb:	4c 39 e5             	cmp    %r12,%rbp
   1b0fe:	75 b4                	jne    1b0b4 <vpu_component_bind+0x894>
   1b100:	48 89 1c 24          	mov    %rbx,(%rsp)
   1b104:	45 39 af 74 25 00 00 	cmp    %r13d,0x2574(%r15)
   1b10b:	0f 85 43 fd ff ff    	jne    1ae54 <vpu_component_bind+0x634>
   1b111:	49 8b bf e8 03 00 00 	mov    0x3e8(%r15),%rdi
   1b118:	48 8d 74 24 54       	lea    0x54(%rsp),%rsi
   1b11d:	e8 00 00 00 00       	call   1b122 <vpu_component_bind+0x902>
			1b11e: R_X86_64_PLT32	mtgpu_smc_get_vpu_core_info-0x4
   1b122:	85 c0                	test   %eax,%eax
   1b124:	0f 85 90 04 00 00    	jne    1b5ba <vpu_component_bind+0xd9a>
   1b12a:	41 8b 6f 7c          	mov    0x7c(%r15),%ebp
   1b12e:	85 ed                	test   %ebp,%ebp
   1b130:	0f 84 b1 08 00 00    	je     1b9e7 <vpu_component_bind+0x11c7>
   1b136:	4c 89 74 24 48       	mov    %r14,0x48(%rsp)
   1b13b:	4d 8d af 50 27 00 00 	lea    0x2750(%r15),%r13
   1b142:	31 db                	xor    %ebx,%ebx
   1b144:	31 ed                	xor    %ebp,%ebp
   1b146:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%rsp)
   1b14d:	00 
   1b14e:	4c 8b 74 24 28       	mov    0x28(%rsp),%r14
   1b153:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%rsp)
   1b15a:	00 
   1b15b:	e9 80 00 00 00       	jmp    1b1e0 <vpu_component_bind+0x9c0>
   1b160:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1b165:	0f 84 b4 00 00 00    	je     1b21f <vpu_component_bind+0x9ff>
   1b16b:	3d 7b 62 00 00       	cmp    $0x627b,%eax
   1b170:	0f 84 a9 00 00 00    	je     1b21f <vpu_component_bind+0x9ff>
   1b176:	3d 00 98 00 00       	cmp    $0x9800,%eax
   1b17b:	0f 84 12 04 00 00    	je     1b593 <vpu_component_bind+0xd73>
   1b181:	3d 00 12 00 00       	cmp    $0x1200,%eax
   1b186:	0f 84 f9 07 00 00    	je     1b985 <vpu_component_bind+0x1165>
   1b18c:	3d 50 a3 00 00       	cmp    $0xa350,%eax
   1b191:	0f 84 c4 07 00 00    	je     1b95b <vpu_component_bind+0x113b>
   1b197:	45 89 65 00          	mov    %r12d,0x0(%r13)
   1b19b:	48 83 c5 01          	add    $0x1,%rbp
   1b19f:	49 81 c5 f8 e3 00 00 	add    $0xe3f8,%r13
   1b1a6:	4d 89 bd 90 48 ff ff 	mov    %r15,-0xb770(%r13)
   1b1ad:	41 c6 85 28 36 ff ff 	movb   $0x0,-0xc9d8(%r13)
   1b1b4:	00 
   1b1b5:	41 c7 85 18 1c ff ff 	movl   $0x0,-0xe3e8(%r13)
   1b1bc:	00 00 00 00 
   1b1c0:	41 c7 85 b8 89 ff ff 	movl   $0x0,-0x7648(%r13)
   1b1c7:	00 00 00 00 
   1b1cb:	41 c7 85 c0 89 ff ff 	movl   $0x0,-0x7640(%r13)
   1b1d2:	00 00 00 00 
   1b1d6:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b1da:	0f 83 ca 00 00 00    	jae    1b2aa <vpu_component_bind+0xa8a>
   1b1e0:	41 8b 84 af 80 00 00 	mov    0x80(%r15,%rbp,4),%eax
   1b1e7:	00 
   1b1e8:	41 89 ec             	mov    %ebp,%r12d
   1b1eb:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1b1f0:	0f 85 6a ff ff ff    	jne    1b160 <vpu_component_bind+0x940>
   1b1f6:	8b 44 24 54          	mov    0x54(%rsp),%eax
   1b1fa:	0f a3 d8             	bt     %ebx,%eax
   1b1fd:	73 76                	jae    1b275 <vpu_component_bind+0xa55>
   1b1ff:	89 da                	mov    %ebx,%edx
   1b201:	89 ee                	mov    %ebp,%esi
   1b203:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b206: R_X86_64_32S	.rodata+0x54c08
   1b20a:	e8 00 00 00 00       	call   1b20f <vpu_component_bind+0x9ef>
			1b20b: R_X86_64_PLT32	os_printk-0x4
   1b20f:	41 c7 45 08 00 00 00 	movl   $0x0,0x8(%r13)
   1b216:	00 
   1b217:	83 c3 01             	add    $0x1,%ebx
   1b21a:	e9 78 ff ff ff       	jmp    1b197 <vpu_component_bind+0x977>
   1b21f:	8b 4c 24 54          	mov    0x54(%rsp),%ecx
   1b223:	8b 54 24 0c          	mov    0xc(%rsp),%edx
   1b227:	0f a3 d1             	bt     %edx,%ecx
   1b22a:	73 21                	jae    1b24d <vpu_component_bind+0xa2d>
   1b22c:	44 89 e6             	mov    %r12d,%esi
   1b22f:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b232: R_X86_64_32S	.rodata+0x54c68
   1b236:	e8 00 00 00 00       	call   1b23b <vpu_component_bind+0xa1b>
			1b237: R_X86_64_PLT32	os_printk-0x4
   1b23b:	41 c7 45 08 00 00 00 	movl   $0x0,0x8(%r13)
   1b242:	00 
   1b243:	83 44 24 0c 01       	addl   $0x1,0xc(%rsp)
   1b248:	e9 4a ff ff ff       	jmp    1b197 <vpu_component_bind+0x977>
   1b24d:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b254:	00 
   1b255:	8b 54 24 0c          	mov    0xc(%rsp),%edx
   1b259:	44 89 e6             	mov    %r12d,%esi
   1b25c:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b25f: R_X86_64_32S	.rodata+0x54c98
   1b263:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b26a:	41 89 45 14          	mov    %eax,0x14(%r13)
   1b26e:	e8 00 00 00 00       	call   1b273 <vpu_component_bind+0xa53>
			1b26f: R_X86_64_PLT32	os_printk-0x4
   1b273:	eb ce                	jmp    1b243 <vpu_component_bind+0xa23>
   1b275:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b27c:	00 
   1b27d:	89 da                	mov    %ebx,%edx
   1b27f:	89 ee                	mov    %ebp,%esi
   1b281:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b284: R_X86_64_32S	.rodata+0x54c38
   1b288:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b28f:	41 c7 45 14 70 51 00 	movl   $0x5170,0x14(%r13)
   1b296:	00 
   1b297:	e8 00 00 00 00       	call   1b29c <vpu_component_bind+0xa7c>
			1b298: R_X86_64_PLT32	os_printk-0x4
   1b29c:	e9 76 ff ff ff       	jmp    1b217 <vpu_component_bind+0x9f7>
   1b2a1:	48 89 1c 24          	mov    %rbx,(%rsp)
   1b2a5:	e9 aa fb ff ff       	jmp    1ae54 <vpu_component_bind+0x634>
   1b2aa:	4c 8b 74 24 48       	mov    0x48(%rsp),%r14
   1b2af:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1b2b6 <vpu_component_bind+0xa96>
			1b2b2: R_X86_64_PC32	kmalloc_caches+0x24
   1b2b6:	ba 18 00 00 00       	mov    $0x18,%edx
   1b2bb:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1b2c0:	e8 00 00 00 00       	call   1b2c5 <vpu_component_bind+0xaa5>
			1b2c1: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1b2c5:	49 89 87 18 88 15 00 	mov    %rax,0x158818(%r15)
   1b2cc:	48 85 c0             	test   %rax,%rax
   1b2cf:	0f 84 7f fb ff ff    	je     1ae54 <vpu_component_bind+0x634>
   1b2d5:	8b 5c 24 30          	mov    0x30(%rsp),%ebx
   1b2d9:	8b 4c 24 10          	mov    0x10(%rsp),%ecx
   1b2dd:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1b2e3:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
   1b2ea:	00 
   1b2eb:	85 db                	test   %ebx,%ebx
   1b2ed:	89 48 04             	mov    %ecx,0x4(%rax)
   1b2f0:	41 0f 94 c5          	sete   %r13b
   1b2f4:	44 0a 6c 24 17       	or     0x17(%rsp),%r13b
   1b2f9:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
   1b300:	00 
   1b301:	44 88 6c 24 0c       	mov    %r13b,0xc(%rsp)
   1b306:	74 6d                	je     1b375 <vpu_component_bind+0xb55>
   1b308:	8b 74 24 40          	mov    0x40(%rsp),%esi
   1b30c:	41 8b 7f 08          	mov    0x8(%r15),%edi
   1b310:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b317:	00 
   1b318:	75 0c                	jne    1b326 <vpu_component_bind+0xb06>
   1b31a:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   1b31f:	48 03 b8 08 04 00 00 	add    0x408(%rax),%rdi
   1b326:	e8 00 00 00 00       	call   1b32b <vpu_component_bind+0xb0b>
			1b327: R_X86_64_PLT32	ioremap-0x4
   1b32b:	49 89 87 40 27 00 00 	mov    %rax,0x2740(%r15)
   1b332:	48 85 c0             	test   %rax,%rax
   1b335:	0f 84 19 fb ff ff    	je     1ae54 <vpu_component_bind+0x634>
   1b33b:	41 8b 57 7c          	mov    0x7c(%r15),%edx
   1b33f:	85 d2                	test   %edx,%edx
   1b341:	74 32                	je     1b375 <vpu_component_bind+0xb55>
   1b343:	49 8d 3c 97          	lea    (%r15,%rdx,4),%rdi
   1b347:	49 8d b7 68 27 00 00 	lea    0x2768(%r15),%rsi
   1b34e:	4c 89 fa             	mov    %r15,%rdx
   1b351:	31 c9                	xor    %ecx,%ecx
   1b353:	4c 8d 04 08          	lea    (%rax,%rcx,1),%r8
   1b357:	48 83 c2 04          	add    $0x4,%rdx
   1b35b:	48 81 c6 f8 e3 00 00 	add    $0xe3f8,%rsi
   1b362:	4c 89 86 08 1c ff ff 	mov    %r8,-0xe3f8(%rsi)
   1b369:	44 8b 42 0c          	mov    0xc(%rdx),%r8d
   1b36d:	4c 01 c1             	add    %r8,%rcx
   1b370:	48 39 d7             	cmp    %rdx,%rdi
   1b373:	75 de                	jne    1b353 <vpu_component_bind+0xb33>
   1b375:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b37c:	00 
   1b37d:	0f 84 73 02 00 00    	je     1b5f6 <vpu_component_bind+0xdd6>
   1b383:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 1b38a <vpu_component_bind+0xb6a>
			1b385: R_X86_64_PC32	enable_reserved_memory-0x5
   1b38a:	49 c7 87 48 27 00 00 	movq   $0x0,0x2748(%r15)
   1b391:	00 00 00 00 
   1b395:	0f 84 dd 04 00 00    	je     1b878 <vpu_component_bind+0x1058>
   1b39b:	41 c7 87 58 05 00 00 	movl   $0x1,0x558(%r15)
   1b3a2:	01 00 00 00 
   1b3a6:	45 8b 5f 7c          	mov    0x7c(%r15),%r11d
   1b3aa:	45 85 db             	test   %r11d,%r11d
   1b3ad:	74 6c                	je     1b41b <vpu_component_bind+0xbfb>
   1b3af:	49 8d af 74 41 00 00 	lea    0x4174(%r15),%rbp
   1b3b6:	31 db                	xor    %ebx,%ebx
   1b3b8:	b8 01 00 00 00       	mov    $0x1,%eax
   1b3bd:	49 bc 00 00 00 00 ff 	movabs $0xff00000000,%r12
   1b3c4:	00 00 00 
   1b3c7:	eb 0e                	jmp    1b3d7 <vpu_component_bind+0xbb7>
   1b3c9:	41 8b 87 58 05 00 00 	mov    0x558(%r15),%eax
   1b3d0:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1b3d7:	83 e8 01             	sub    $0x1,%eax
   1b3da:	89 da                	mov    %ebx,%edx
   1b3dc:	89 de                	mov    %ebx,%esi
   1b3de:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b3e1: R_X86_64_32S	.rodata+0x54d18
   1b3e5:	48 98                	cltq
   1b3e7:	83 c3 01             	add    $0x1,%ebx
   1b3ea:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
   1b3ee:	48 8d 44 c2 34       	lea    0x34(%rdx,%rax,8),%rax
   1b3f3:	41 8b 44 87 10       	mov    0x10(%r15,%rax,4),%eax
   1b3f8:	89 45 00             	mov    %eax,0x0(%rbp)
   1b3fb:	49 8b 86 d0 00 00 00 	mov    0xd0(%r14),%rax
   1b402:	4c 21 e0             	and    %r12,%rax
   1b405:	48 89 45 04          	mov    %rax,0x4(%rbp)
   1b409:	48 c1 e8 20          	shr    $0x20,%rax
   1b40d:	48 89 c2             	mov    %rax,%rdx
   1b410:	e8 00 00 00 00       	call   1b415 <vpu_component_bind+0xbf5>
			1b411: R_X86_64_PLT32	os_printk-0x4
   1b415:	41 3b 5f 7c          	cmp    0x7c(%r15),%ebx
   1b419:	72 ae                	jb     1b3c9 <vpu_component_bind+0xba9>
   1b41b:	41 c7 87 24 89 15 00 	movl   $0xff,0x158924(%r15)
   1b422:	ff 00 00 00 
   1b426:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1b42b:	48 8d 68 f0          	lea    -0x10(%rax),%rbp
   1b42f:	83 7c 24 34 01       	cmpl   $0x1,0x34(%rsp)
   1b434:	0f 84 31 04 00 00    	je     1b86b <vpu_component_bind+0x104b>
   1b43a:	48 89 ee             	mov    %rbp,%rsi
   1b43d:	4c 89 ff             	mov    %r15,%rdi
   1b440:	e8 00 00 00 00       	call   1b445 <vpu_component_bind+0xc25>
			1b441: R_X86_64_PLT32	vpu_init_irq-0x4
   1b445:	85 c0                	test   %eax,%eax
   1b447:	0f 85 07 fa ff ff    	jne    1ae54 <vpu_component_bind+0x634>
   1b44d:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1b452:	be 80 00 00 00       	mov    $0x80,%esi
   1b457:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b45a: R_X86_64_32S	pvr_drm_ioctls
   1b45e:	4c 89 78 78          	mov    %r15,0x78(%rax)
   1b462:	e8 00 00 00 00       	call   1b467 <vpu_component_bind+0xc47>
			1b463: R_X86_64_PLT32	vpu_fill_drm_ioctls-0x4
   1b467:	41 89 c4             	mov    %eax,%r12d
   1b46a:	85 c0                	test   %eax,%eax
   1b46c:	0f 85 e2 f9 ff ff    	jne    1ae54 <vpu_component_bind+0x634>
   1b472:	41 83 7f 04 02       	cmpl   $0x2,0x4(%r15)
   1b477:	0f 84 61 04 00 00    	je     1b8de <vpu_component_bind+0x10be>
   1b47d:	44 8b 44 24 30       	mov    0x30(%rsp),%r8d
   1b482:	48 8d 6c 24 58       	lea    0x58(%rsp),%rbp
   1b487:	45 85 c0             	test   %r8d,%r8d
   1b48a:	0f 84 11 04 00 00    	je     1b8a1 <vpu_component_bind+0x1081>
   1b490:	e8 00 00 00 00       	call   1b495 <vpu_component_bind+0xc75>
			1b491: R_X86_64_PLT32	get_vinfo_fops-0x4
   1b495:	49 89 c5             	mov    %rax,%r13
   1b498:	e8 00 00 00 00       	call   1b49d <vpu_component_bind+0xc7d>
			1b499: R_X86_64_PLT32	get_fwinfo_fops-0x4
   1b49d:	49 89 c6             	mov    %rax,%r14
   1b4a0:	e8 00 00 00 00       	call   1b4a5 <vpu_component_bind+0xc85>
			1b4a1: R_X86_64_PLT32	get_vpulog_fops-0x4
   1b4a5:	41 8b 17             	mov    (%r15),%edx
   1b4a8:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b4ab: R_X86_64_32S	.rodata+0x38220
   1b4af:	48 89 ef             	mov    %rbp,%rdi
   1b4b2:	48 89 c3             	mov    %rax,%rbx
   1b4b5:	e8 00 00 00 00       	call   1b4ba <vpu_component_bind+0xc9a>
			1b4b6: R_X86_64_PLT32	sprintf-0x4
   1b4ba:	31 f6                	xor    %esi,%esi
   1b4bc:	48 89 ef             	mov    %rbp,%rdi
   1b4bf:	e8 00 00 00 00       	call   1b4c4 <vpu_component_bind+0xca4>
			1b4c0: R_X86_64_PLT32	debugfs_create_dir-0x4
   1b4c4:	49 89 87 00 88 15 00 	mov    %rax,0x158800(%r15)
   1b4cb:	48 85 c0             	test   %rax,%rax
   1b4ce:	0f 84 4a 01 00 00    	je     1b61e <vpu_component_bind+0xdfe>
   1b4d4:	4d 89 e9             	mov    %r13,%r9
   1b4d7:	45 31 c0             	xor    %r8d,%r8d
   1b4da:	4c 89 f9             	mov    %r15,%rcx
   1b4dd:	48 89 c2             	mov    %rax,%rdx
   1b4e0:	be b6 01 00 00       	mov    $0x1b6,%esi
   1b4e5:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b4e8: R_X86_64_32S	.rodata+0x38228
   1b4ec:	e8 00 00 00 00       	call   1b4f1 <vpu_component_bind+0xcd1>
			1b4ed: R_X86_64_PLT32	debugfs_create_file_full-0x4
   1b4f1:	4d 89 f1             	mov    %r14,%r9
   1b4f4:	45 31 c0             	xor    %r8d,%r8d
   1b4f7:	4c 89 f9             	mov    %r15,%rcx
   1b4fa:	49 8b 97 00 88 15 00 	mov    0x158800(%r15),%rdx
   1b501:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b504: R_X86_64_32S	.rodata+0x3822d
   1b508:	be 24 01 00 00       	mov    $0x124,%esi
   1b50d:	e8 00 00 00 00       	call   1b512 <vpu_component_bind+0xcf2>
			1b50e: R_X86_64_PLT32	debugfs_create_file_full-0x4
   1b512:	41 8b 7f 7c          	mov    0x7c(%r15),%edi
   1b516:	85 ff                	test   %edi,%edi
   1b518:	0f 84 00 01 00 00    	je     1b61e <vpu_component_bind+0xdfe>
   1b51e:	4d 8d b7 50 27 00 00 	lea    0x2750(%r15),%r14
   1b525:	45 31 ed             	xor    %r13d,%r13d
   1b528:	eb 1c                	jmp    1b546 <vpu_component_bind+0xd26>
   1b52a:	3d 50 a3 00 00       	cmp    $0xa350,%eax
   1b52f:	74 43                	je     1b574 <vpu_component_bind+0xd54>
   1b531:	49 83 c5 01          	add    $0x1,%r13
   1b535:	49 81 c6 f8 e3 00 00 	add    $0xe3f8,%r14
   1b53c:	45 3b 6f 7c          	cmp    0x7c(%r15),%r13d
   1b540:	0f 83 d8 00 00 00    	jae    1b61e <vpu_component_bind+0xdfe>
   1b546:	44 89 ea             	mov    %r13d,%edx
   1b549:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b54c: R_X86_64_32S	.rodata+0x38230
   1b550:	48 89 ef             	mov    %rbp,%rdi
   1b553:	e8 00 00 00 00       	call   1b558 <vpu_component_bind+0xd38>
			1b554: R_X86_64_PLT32	sprintf-0x4
   1b558:	43 8b 84 af 80 00 00 	mov    0x80(%r15,%r13,4),%eax
   1b55f:	00 
   1b560:	3d 70 51 00 00       	cmp    $0x5170,%eax
   1b565:	0f 94 c2             	sete   %dl
   1b568:	3d 70 62 00 00       	cmp    $0x6270,%eax
   1b56d:	0f 94 c1             	sete   %cl
   1b570:	08 ca                	or     %cl,%dl
   1b572:	74 b6                	je     1b52a <vpu_component_bind+0xd0a>
   1b574:	49 8b 97 00 88 15 00 	mov    0x158800(%r15),%rdx
   1b57b:	49 89 d9             	mov    %rbx,%r9
   1b57e:	45 31 c0             	xor    %r8d,%r8d
   1b581:	4c 89 f1             	mov    %r14,%rcx
   1b584:	be 24 01 00 00       	mov    $0x124,%esi
   1b589:	48 89 ef             	mov    %rbp,%rdi
   1b58c:	e8 00 00 00 00       	call   1b591 <vpu_component_bind+0xd71>
			1b58d: R_X86_64_PLT32	debugfs_create_file_full-0x4
   1b591:	eb 9e                	jmp    1b531 <vpu_component_bind+0xd11>
   1b593:	f6 44 24 55 40       	testb  $0x40,0x55(%rsp)
   1b598:	74 2d                	je     1b5c7 <vpu_component_bind+0xda7>
   1b59a:	ba 0e 00 00 00       	mov    $0xe,%edx
   1b59f:	89 ee                	mov    %ebp,%esi
   1b5a1:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b5a4: R_X86_64_32S	.rodata+0x54c08
   1b5a8:	e8 00 00 00 00       	call   1b5ad <vpu_component_bind+0xd8d>
			1b5a9: R_X86_64_PLT32	os_printk-0x4
   1b5ad:	41 c7 45 08 00 00 00 	movl   $0x0,0x8(%r13)
   1b5b4:	00 
   1b5b5:	e9 dd fb ff ff       	jmp    1b197 <vpu_component_bind+0x977>
   1b5ba:	c7 44 24 54 00 00 00 	movl   $0x0,0x54(%rsp)
   1b5c1:	00 
   1b5c2:	e9 63 fb ff ff       	jmp    1b12a <vpu_component_bind+0x90a>
   1b5c7:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b5ce:	00 
   1b5cf:	ba 0e 00 00 00       	mov    $0xe,%edx
   1b5d4:	89 ee                	mov    %ebp,%esi
   1b5d6:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b5d9: R_X86_64_32S	.rodata+0x54c38
   1b5dd:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b5e4:	41 c7 45 14 00 98 00 	movl   $0x9800,0x14(%r13)
   1b5eb:	00 
   1b5ec:	e8 00 00 00 00       	call   1b5f1 <vpu_component_bind+0xdd1>
			1b5ed: R_X86_64_PLT32	os_printk-0x4
   1b5f1:	e9 a1 fb ff ff       	jmp    1b197 <vpu_component_bind+0x977>
   1b5f6:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   1b5fb:	4c 89 ff             	mov    %r15,%rdi
   1b5fe:	48 8b 80 88 04 00 00 	mov    0x488(%rax),%rax
   1b605:	49 89 87 48 27 00 00 	mov    %rax,0x2748(%r15)
   1b60c:	e8 00 00 00 00       	call   1b611 <vpu_component_bind+0xdf1>
			1b60d: R_X86_64_PLT32	vpu_init_mpc-0x4
   1b611:	85 c0                	test   %eax,%eax
   1b613:	0f 84 02 fe ff ff    	je     1b41b <vpu_component_bind+0xbfb>
   1b619:	e9 36 f8 ff ff       	jmp    1ae54 <vpu_component_bind+0x634>
   1b61e:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1b625:	4c 89 fe             	mov    %r15,%rsi
   1b628:	e8 00 00 00 00       	call   1b62d <vpu_component_bind+0xe0d>
			1b629: R_X86_64_PLT32	os_set_timer_list_drvdata-0x4
   1b62d:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1b634:	31 c9                	xor    %ecx,%ecx
   1b636:	31 d2                	xor    %edx,%edx
   1b638:	45 31 c0             	xor    %r8d,%r8d
   1b63b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b63e: R_X86_64_32S	vpu_util_monitor
   1b642:	e8 00 00 00 00       	call   1b647 <vpu_component_bind+0xe27>
			1b643: R_X86_64_PLT32	timer_init_key-0x4
   1b647:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 1b64e <vpu_component_bind+0xe2e>
			1b64a: R_X86_64_PC32	jiffies-0x4
   1b64e:	49 8b bf 08 88 15 00 	mov    0x158808(%r15),%rdi
   1b655:	48 81 c6 2c 01 00 00 	add    $0x12c,%rsi
   1b65c:	e8 00 00 00 00       	call   1b661 <vpu_component_bind+0xe41>
			1b65d: R_X86_64_PLT32	mod_timer-0x4
   1b661:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1b668:	4c 89 fe             	mov    %r15,%rsi
   1b66b:	e8 00 00 00 00       	call   1b670 <vpu_component_bind+0xe50>
			1b66c: R_X86_64_PLT32	os_set_timer_list_drvdata-0x4
   1b670:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1b677:	31 c9                	xor    %ecx,%ecx
   1b679:	31 d2                	xor    %edx,%edx
   1b67b:	45 31 c0             	xor    %r8d,%r8d
   1b67e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b681: R_X86_64_32S	vpu_stat_monitor
   1b685:	e8 00 00 00 00       	call   1b68a <vpu_component_bind+0xe6a>
			1b686: R_X86_64_PLT32	timer_init_key-0x4
   1b68a:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 1b691 <vpu_component_bind+0xe71>
			1b68d: R_X86_64_PC32	jiffies-0x4
   1b691:	49 8b bf 10 88 15 00 	mov    0x158810(%r15),%rdi
   1b698:	48 81 c6 e8 03 00 00 	add    $0x3e8,%rsi
   1b69f:	e8 00 00 00 00       	call   1b6a4 <vpu_component_bind+0xe84>
			1b6a0: R_X86_64_PLT32	mod_timer-0x4
   1b6a4:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b6ab:	00 
   1b6ac:	0f 85 71 01 00 00    	jne    1b823 <vpu_component_bind+0x1003>
   1b6b2:	be 01 00 00 00       	mov    $0x1,%esi
   1b6b7:	4c 89 ff             	mov    %r15,%rdi
   1b6ba:	e8 00 00 00 00       	call   1b6bf <vpu_component_bind+0xe9f>
			1b6bb: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b6bf:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b6c6:	00 
   1b6c7:	0f 85 39 01 00 00    	jne    1b806 <vpu_component_bind+0xfe6>
   1b6cd:	80 7c 24 0c 00       	cmpb   $0x0,0xc(%rsp)
   1b6d2:	0f 84 81 01 00 00    	je     1b859 <vpu_component_bind+0x1039>
   1b6d8:	41 8b 77 7c          	mov    0x7c(%r15),%esi
   1b6dc:	31 ed                	xor    %ebp,%ebp
   1b6de:	85 f6                	test   %esi,%esi
   1b6e0:	74 26                	je     1b708 <vpu_component_bind+0xee8>
   1b6e2:	89 ee                	mov    %ebp,%esi
   1b6e4:	4c 89 ff             	mov    %r15,%rdi
   1b6e7:	e8 00 00 00 00       	call   1b6ec <vpu_component_bind+0xecc>
			1b6e8: R_X86_64_PLT32	vpu_get_clk-0x4
   1b6ec:	48 89 c2             	mov    %rax,%rdx
   1b6ef:	48 69 c5 f8 e3 00 00 	imul   $0xe3f8,%rbp,%rax
   1b6f6:	48 83 c5 01          	add    $0x1,%rbp
   1b6fa:	49 89 94 07 f0 53 00 	mov    %rdx,0x53f0(%r15,%rax,1)
   1b701:	00 
   1b702:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b706:	72 da                	jb     1b6e2 <vpu_component_bind+0xec2>
   1b708:	be ff ff ff ff       	mov    $0xffffffff,%esi
   1b70d:	4c 89 ff             	mov    %r15,%rdi
   1b710:	e8 00 00 00 00       	call   1b715 <vpu_component_bind+0xef5>
			1b711: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b715:	41 8b 4f 7c          	mov    0x7c(%r15),%ecx
   1b719:	85 c9                	test   %ecx,%ecx
   1b71b:	0f 84 0f 01 00 00    	je     1b830 <vpu_component_bind+0x1010>
   1b721:	31 ed                	xor    %ebp,%ebp
   1b723:	eb 0a                	jmp    1b72f <vpu_component_bind+0xf0f>
   1b725:	48 83 c5 01          	add    $0x1,%rbp
   1b729:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b72d:	73 22                	jae    1b751 <vpu_component_bind+0xf31>
   1b72f:	41 81 bc af 80 00 00 	cmpl   $0x6270,0x80(%r15,%rbp,4)
   1b736:	00 70 62 00 00 
   1b73b:	75 e8                	jne    1b725 <vpu_component_bind+0xf05>
   1b73d:	89 ee                	mov    %ebp,%esi
   1b73f:	4c 89 ff             	mov    %r15,%rdi
   1b742:	48 83 c5 01          	add    $0x1,%rbp
   1b746:	e8 00 00 00 00       	call   1b74b <vpu_component_bind+0xf2b>
			1b747: R_X86_64_PLT32	vpu_slice_mode_config-0x4
   1b74b:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b74f:	72 de                	jb     1b72f <vpu_component_bind+0xf0f>
   1b751:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b758:	00 
   1b759:	0f 85 db 00 00 00    	jne    1b83a <vpu_component_bind+0x101a>
   1b75f:	41 8b 57 7c          	mov    0x7c(%r15),%edx
   1b763:	85 d2                	test   %edx,%edx
   1b765:	0f 84 8e 00 00 00    	je     1b7f9 <vpu_component_bind+0xfd9>
   1b76b:	4c 89 fd             	mov    %r15,%rbp
   1b76e:	45 31 ed             	xor    %r13d,%r13d
   1b771:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1b778 <vpu_component_bind+0xf58>
			1b774: R_X86_64_PC32	kmalloc_caches+0x44
   1b778:	ba 00 02 00 00       	mov    $0x200,%edx
   1b77d:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1b782:	e8 00 00 00 00       	call   1b787 <vpu_component_bind+0xf67>
			1b783: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1b787:	48 89 85 40 05 01 00 	mov    %rax,0x10540(%rbp)
   1b78e:	48 85 c0             	test   %rax,%rax
   1b791:	0f 84 bd f6 ff ff    	je     1ae54 <vpu_component_bind+0x634>
   1b797:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   1b79d:	b8 04 00 00 00       	mov    $0x4,%eax
   1b7a2:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   1b7a9:	00 
   1b7aa:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b7b1:	00 00 00 00 
   1b7b5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b7bc:	00 00 00 00 
   1b7c0:	48 8b 95 40 05 01 00 	mov    0x10540(%rbp),%rdx
   1b7c7:	48 01 c2             	add    %rax,%rdx
   1b7ca:	48 89 94 45 40 05 01 	mov    %rdx,0x10540(%rbp,%rax,2)
   1b7d1:	00 
   1b7d2:	48 83 c0 04          	add    $0x4,%rax
   1b7d6:	c7 02 00 00 00 00    	movl   $0x0,(%rdx)
   1b7dc:	48 3d 00 02 00 00    	cmp    $0x200,%rax
   1b7e2:	75 dc                	jne    1b7c0 <vpu_component_bind+0xfa0>
   1b7e4:	41 83 c5 01          	add    $0x1,%r13d
   1b7e8:	48 81 c5 f8 e3 00 00 	add    $0xe3f8,%rbp
   1b7ef:	45 3b 6f 7c          	cmp    0x7c(%r15),%r13d
   1b7f3:	0f 82 78 ff ff ff    	jb     1b771 <vpu_component_bind+0xf51>
   1b7f9:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1b800:	00 
   1b801:	e9 31 f8 ff ff       	jmp    1b037 <vpu_component_bind+0x817>
   1b806:	be ff ff ff ff       	mov    $0xffffffff,%esi
   1b80b:	4c 89 ff             	mov    %r15,%rdi
   1b80e:	e8 00 00 00 00       	call   1b813 <vpu_component_bind+0xff3>
			1b80f: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b813:	80 7c 24 0c 00       	cmpb   $0x0,0xc(%rsp)
   1b818:	0f 84 33 ff ff ff    	je     1b751 <vpu_component_bind+0xf31>
   1b81e:	e9 f2 fe ff ff       	jmp    1b715 <vpu_component_bind+0xef5>
   1b823:	4c 89 ff             	mov    %r15,%rdi
   1b826:	e8 00 00 00 00       	call   1b82b <vpu_component_bind+0x100b>
			1b827: R_X86_64_PLT32	vpu_dvfs_init-0x4
   1b82b:	e9 82 fe ff ff       	jmp    1b6b2 <vpu_component_bind+0xe92>
   1b830:	41 80 bf 10 04 00 00 	cmpb   $0x0,0x410(%r15)
   1b837:	00 
   1b838:	74 bf                	je     1b7f9 <vpu_component_bind+0xfd9>
   1b83a:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			1b83d: R_X86_64_32S	.rodata+0x3823a
   1b841:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b844: R_X86_64_32S	__this_module
   1b848:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b84b: R_X86_64_32S	.data+0x29a0
   1b84f:	e8 00 00 00 00       	call   1b854 <vpu_component_bind+0x1034>
			1b850: R_X86_64_PLT32	__platform_driver_register-0x4
   1b854:	e9 06 ff ff ff       	jmp    1b75f <vpu_component_bind+0xf3f>
   1b859:	be ff ff ff ff       	mov    $0xffffffff,%esi
   1b85e:	4c 89 ff             	mov    %r15,%rdi
   1b861:	e8 00 00 00 00       	call   1b866 <vpu_component_bind+0x1046>
			1b862: R_X86_64_PLT32	vpu_report_power_state-0x4
   1b866:	e9 e6 fe ff ff       	jmp    1b751 <vpu_component_bind+0xf31>
   1b86b:	4c 89 ff             	mov    %r15,%rdi
   1b86e:	e8 00 00 00 00       	call   1b873 <vpu_component_bind+0x1053>
			1b86f: R_X86_64_PLT32	vpu_init_guest_mem-0x4
   1b873:	e9 c2 fb ff ff       	jmp    1b43a <vpu_component_bind+0xc1a>
   1b878:	41 c7 87 58 05 00 00 	movl   $0x2,0x558(%r15)
   1b87f:	02 00 00 00 
   1b883:	4c 89 ff             	mov    %r15,%rdi
   1b886:	e8 00 00 00 00       	call   1b88b <vpu_component_bind+0x106b>
			1b887: R_X86_64_PLT32	vpu_smmu_init-0x4
   1b88b:	e9 8b fb ff ff       	jmp    1b41b <vpu_component_bind+0xbfb>
   1b890:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b893: R_X86_64_32S	.rodata+0x54b70
   1b897:	e8 00 00 00 00       	call   1b89c <vpu_component_bind+0x107c>
			1b898: R_X86_64_PLT32	os_printk-0x4
   1b89c:	e9 70 f7 ff ff       	jmp    1b011 <vpu_component_bind+0x7f1>
   1b8a1:	41 8b 17             	mov    (%r15),%edx
   1b8a4:	48 89 ef             	mov    %rbp,%rdi
   1b8a7:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1b8aa: R_X86_64_32S	.rodata+0x38212
   1b8ae:	e8 00 00 00 00       	call   1b8b3 <vpu_component_bind+0x1093>
			1b8af: R_X86_64_PLT32	sprintf-0x4
   1b8b3:	48 89 e9             	mov    %rbp,%rcx
   1b8b6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
   1b8bb:	4c 89 fe             	mov    %r15,%rsi
   1b8be:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b8c1: R_X86_64_32S	vpu_host_thread1
   1b8c5:	e8 00 00 00 00       	call   1b8ca <vpu_component_bind+0x10aa>
			1b8c6: R_X86_64_PLT32	kthread_create_on_node-0x4
   1b8ca:	49 89 87 b0 86 15 00 	mov    %rax,0x1586b0(%r15)
   1b8d1:	48 89 c7             	mov    %rax,%rdi
   1b8d4:	e8 00 00 00 00       	call   1b8d9 <vpu_component_bind+0x10b9>
			1b8d5: R_X86_64_PLT32	wake_up_process-0x4
   1b8d9:	e9 b2 fb ff ff       	jmp    1b490 <vpu_component_bind+0xc70>
   1b8de:	44 8b 54 24 30       	mov    0x30(%rsp),%r10d
   1b8e3:	45 85 d2             	test   %r10d,%r10d
   1b8e6:	0f 84 e4 00 00 00    	je     1b9d0 <vpu_component_bind+0x11b0>
   1b8ec:	48 8d 6c 24 58       	lea    0x58(%rsp),%rbp
   1b8f1:	83 7c 24 34 01       	cmpl   $0x1,0x34(%rsp)
   1b8f6:	0f 85 94 fb ff ff    	jne    1b490 <vpu_component_bind+0xc70>
   1b8fc:	45 8b 4f 7c          	mov    0x7c(%r15),%r9d
   1b900:	31 ed                	xor    %ebp,%ebp
   1b902:	45 85 c9             	test   %r9d,%r9d
   1b905:	74 24                	je     1b92b <vpu_component_bind+0x110b>
   1b907:	41 81 bc af 80 00 00 	cmpl   $0x9800,0x80(%r15,%rbp,4)
   1b90e:	00 00 98 00 00 
   1b913:	74 0c                	je     1b921 <vpu_component_bind+0x1101>
   1b915:	31 d2                	xor    %edx,%edx
   1b917:	89 ee                	mov    %ebp,%esi
   1b919:	4c 89 ff             	mov    %r15,%rdi
   1b91c:	e8 00 00 00 00       	call   1b921 <vpu_component_bind+0x1101>
			1b91d: R_X86_64_PLT32	vpu_load_firmware-0x4
   1b921:	48 83 c5 01          	add    $0x1,%rbp
   1b925:	41 3b 6f 7c          	cmp    0x7c(%r15),%ebp
   1b929:	72 dc                	jb     1b907 <vpu_component_bind+0x10e7>
   1b92b:	48 8d 6c 24 58       	lea    0x58(%rsp),%rbp
   1b930:	e9 5b fb ff ff       	jmp    1b490 <vpu_component_bind+0xc70>
   1b935:	be de ff ff ff       	mov    $0xffffffde,%esi
   1b93a:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b93d: R_X86_64_32S	.rodata+0x54b90
   1b941:	e8 00 00 00 00       	call   1b946 <vpu_component_bind+0x1126>
			1b942: R_X86_64_PLT32	os_printk-0x4
   1b946:	4c 89 ff             	mov    %r15,%rdi
   1b949:	e8 00 00 00 00       	call   1b94e <vpu_component_bind+0x112e>
			1b94a: R_X86_64_PLT32	vpu_deinit_conf-0x4
   1b94e:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1b955:	00 
   1b956:	e9 b6 f6 ff ff       	jmp    1b011 <vpu_component_bind+0x7f1>
   1b95b:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b962:	89 ee                	mov    %ebp,%esi
   1b964:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b967: R_X86_64_32S	.rodata+0x54cf0
   1b96b:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b972:	00 
   1b973:	41 c7 45 14 50 a3 00 	movl   $0xa350,0x14(%r13)
   1b97a:	00 
   1b97b:	e8 00 00 00 00       	call   1b980 <vpu_component_bind+0x1160>
			1b97c: R_X86_64_PLT32	os_printk-0x4
   1b980:	e9 12 f8 ff ff       	jmp    1b197 <vpu_component_bind+0x977>
   1b985:	4d 89 b5 30 1a 00 00 	mov    %r14,0x1a30(%r13)
   1b98c:	89 ee                	mov    %ebp,%esi
   1b98e:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			1b991: R_X86_64_32S	.rodata+0x54cc8
   1b995:	41 c7 45 08 01 00 00 	movl   $0x1,0x8(%r13)
   1b99c:	00 
   1b99d:	41 c7 45 14 00 12 00 	movl   $0x1200,0x14(%r13)
   1b9a4:	00 
   1b9a5:	83 44 24 10 01       	addl   $0x1,0x10(%rsp)
   1b9aa:	e8 00 00 00 00       	call   1b9af <vpu_component_bind+0x118f>
			1b9ab: R_X86_64_PLT32	os_printk-0x4
   1b9af:	e9 e3 f7 ff ff       	jmp    1b197 <vpu_component_bind+0x977>
   1b9b4:	48 83 c0 01          	add    $0x1,%rax
   1b9b8:	49 2b 85 08 04 00 00 	sub    0x408(%r13),%rax
   1b9bf:	e9 bc f0 ff ff       	jmp    1aa80 <vpu_component_bind+0x260>
   1b9c4:	49 c7 c4 ff ff ff ff 	mov    $0xffffffffffffffff,%r12
   1b9cb:	e9 a0 f0 ff ff       	jmp    1aa70 <vpu_component_bind+0x250>
   1b9d0:	4c 89 ff             	mov    %r15,%rdi
   1b9d3:	e8 00 00 00 00       	call   1b9d8 <vpu_component_bind+0x11b8>
			1b9d4: R_X86_64_PLT32	vpu_set_vm_core-0x4
   1b9d8:	e9 1f ff ff ff       	jmp    1b8fc <vpu_component_bind+0x10dc>
   1b9dd:	be ea ff ff ff       	mov    $0xffffffea,%esi
   1b9e2:	e9 53 ff ff ff       	jmp    1b93a <vpu_component_bind+0x111a>
   1b9e7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%rsp)
   1b9ee:	00 
   1b9ef:	e9 bb f8 ff ff       	jmp    1b2af <vpu_component_bind+0xa8f>
   1b9f4:	41 bc f4 ff ff ff    	mov    $0xfffffff4,%r12d
   1b9fa:	e9 38 f6 ff ff       	jmp    1b037 <vpu_component_bind+0x817>
   1b9ff:	4c 8b ac 24 98 00 00 	mov    0x98(%rsp),%r13
   1ba06:	00 
   1ba07:	e9 05 f6 ff ff       	jmp    1b011 <vpu_component_bind+0x7f1>
   1ba0c:	4c 89 ac 24 98 00 00 	mov    %r13,0x98(%rsp)
   1ba13:	00 
   1ba14:	e8 00 00 00 00       	call   1ba19 <vpu_component_bind+0x11f9>
			1ba15: R_X86_64_PLT32	__stack_chk_fail-0x4

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
