
work/mtgpu-3.1.0/objs/x86_64/mtgpu_core.o_binary:     file format elf64-x86-64


Disassembly of section .text:

00000000000976f0 <mtgpu_interrupt_exit>:
   976f0:	f3 0f 1e fa          	endbr64
   976f4:	e8 00 00 00 00       	call   976f9 <mtgpu_interrupt_exit+0x9>
			976f5: R_X86_64_PLT32	__fentry__-0x4
   976f9:	55                   	push   %rbp
   976fa:	48 89 e5             	mov    %rsp,%rbp
   976fd:	41 56                	push   %r14
   976ff:	41 55                	push   %r13
   97701:	41 54                	push   %r12
   97703:	53                   	push   %rbx
   97704:	4c 8b a7 80 06 00 00 	mov    0x680(%rdi),%r12
   9770b:	48 89 fb             	mov    %rdi,%rbx
   9770e:	49 8b 7c 24 38       	mov    0x38(%r12),%rdi
   97713:	48 85 ff             	test   %rdi,%rdi
   97716:	74 0f                	je     97727 <mtgpu_interrupt_exit+0x37>
   97718:	e8 00 00 00 00       	call   9771d <mtgpu_interrupt_exit+0x2d>
			97719: R_X86_64_PLT32	os_del_timer_sync-0x4
   9771d:	49 8b 7c 24 38       	mov    0x38(%r12),%rdi
   97722:	e8 00 00 00 00       	call   97727 <mtgpu_interrupt_exit+0x37>
			97723: R_X86_64_PLT32	os_destroy_timer-0x4
   97727:	e8 00 00 00 00       	call   9772c <mtgpu_interrupt_exit+0x3c>
			97728: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   9772c:	83 f8 01             	cmp    $0x1,%eax
   9772f:	74 10                	je     97741 <mtgpu_interrupt_exit+0x51>
   97731:	48 8b 83 f0 05 00 00 	mov    0x5f0(%rbx),%rax
   97738:	48 89 df             	mov    %rbx,%rdi
   9773b:	48 8b 40 20          	mov    0x20(%rax),%rax
   9773f:	ff d0                	call   *%rax
   97741:	48 89 df             	mov    %rbx,%rdi
   97744:	45 31 ed             	xor    %r13d,%r13d
   97747:	e8 e4 f3 ff ff       	call   96b30 <mtgpu_free_irq>
   9774c:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
   97751:	e8 00 00 00 00       	call   97756 <mtgpu_interrupt_exit+0x66>
			97752: R_X86_64_PLT32	os_kfree-0x4
   97756:	4c 8b b3 80 06 00 00 	mov    0x680(%rbx),%r14
   9775d:	41 8b 46 08          	mov    0x8(%r14),%eax
   97761:	85 c0                	test   %eax,%eax
   97763:	75 14                	jne    97779 <mtgpu_interrupt_exit+0x89>
   97765:	eb 3a                	jmp    977a1 <mtgpu_interrupt_exit+0xb1>
   97767:	44 89 ee             	mov    %r13d,%esi
   9776a:	e8 00 00 00 00       	call   9776f <mtgpu_interrupt_exit+0x7f>
			9776b: R_X86_64_PLT32	mtgpu_unregister_interrupt-0x4
   9776f:	41 83 c5 01          	add    $0x1,%r13d
   97773:	45 39 6e 08          	cmp    %r13d,0x8(%r14)
   97777:	76 28                	jbe    977a1 <mtgpu_interrupt_exit+0xb1>
   97779:	49 8b 56 18          	mov    0x18(%r14),%rdx
   9777d:	49 63 c5             	movslq %r13d,%rax
   97780:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
   97784:	48 85 c0             	test   %rax,%rax
   97787:	74 e6                	je     9776f <mtgpu_interrupt_exit+0x7f>
   97789:	80 78 10 00          	cmpb   $0x0,0x10(%rax)
   9778d:	48 8b 3b             	mov    (%rbx),%rdi
   97790:	74 d5                	je     97767 <mtgpu_interrupt_exit+0x77>
   97792:	31 d2                	xor    %edx,%edx
   97794:	44 89 ee             	mov    %r13d,%esi
   97797:	e8 84 ef ff ff       	call   96720 <mtgpu_int_enable>
   9779c:	48 8b 3b             	mov    (%rbx),%rdi
   9779f:	eb c6                	jmp    97767 <mtgpu_interrupt_exit+0x77>
   977a1:	49 8b 7c 24 18       	mov    0x18(%r12),%rdi
   977a6:	e8 00 00 00 00       	call   977ab <mtgpu_interrupt_exit+0xbb>
			977a7: R_X86_64_PLT32	os_kfree-0x4
   977ab:	49 8b 7c 24 30       	mov    0x30(%r12),%rdi
   977b0:	e8 00 00 00 00       	call   977b5 <mtgpu_interrupt_exit+0xc5>
			977b1: R_X86_64_PLT32	os_spin_lock_destroy-0x4
   977b5:	49 8b 7c 24 28       	mov    0x28(%r12),%rdi
   977ba:	e8 00 00 00 00       	call   977bf <mtgpu_interrupt_exit+0xcf>
			977bb: R_X86_64_PLT32	os_spin_lock_destroy-0x4
   977bf:	4c 89 e7             	mov    %r12,%rdi
   977c2:	e8 00 00 00 00       	call   977c7 <mtgpu_interrupt_exit+0xd7>
			977c3: R_X86_64_PLT32	os_kfree-0x4
   977c7:	5b                   	pop    %rbx
   977c8:	41 5c                	pop    %r12
   977ca:	41 5d                	pop    %r13
   977cc:	41 5e                	pop    %r14
   977ce:	5d                   	pop    %rbp
   977cf:	c3                   	ret
