
builds/runtime-fix3-v2-6.18.58-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

00000000000104a0 <mtgpu_dispc_component_bind>:
   104a0:	f3 0f 1e fa          	endbr64
   104a4:	e8 00 00 00 00       	call   104a9 <mtgpu_dispc_component_bind+0x9>
			104a5: R_X86_64_PLT32	__fentry__-0x4
   104a9:	48 83 ec 50          	sub    $0x50,%rsp
   104ad:	be c0 0d 00 00       	mov    $0xdc0,%esi
   104b2:	4c 89 64 24 30       	mov    %r12,0x30(%rsp)
   104b7:	49 89 fc             	mov    %rdi,%r12
   104ba:	4c 89 7c 24 48       	mov    %r15,0x48(%rsp)
   104bf:	49 89 d7             	mov    %rdx,%r15
   104c2:	4c 89 6c 24 38       	mov    %r13,0x38(%rsp)
   104c7:	4c 8b 6f 70          	mov    0x70(%rdi),%r13
   104cb:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 104d2 <mtgpu_dispc_component_bind+0x32>
			104ce: R_X86_64_PC32	kmalloc_caches+0x3c
   104d2:	48 89 14 24          	mov    %rdx,(%rsp)
   104d6:	ba e8 00 00 00       	mov    $0xe8,%edx
   104db:	e8 00 00 00 00       	call   104e0 <mtgpu_dispc_component_bind+0x40>
			104dc: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   104e0:	48 85 c0             	test   %rax,%rax
   104e3:	0f 84 5a 0a 00 00    	je     10f43 <mtgpu_dispc_component_bind+0xaa3>
   104e9:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)
   104ee:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 104f5 <mtgpu_dispc_component_bind+0x55>
			104f1: R_X86_64_PC32	kmalloc_caches+0x54
   104f5:	ba 50 04 00 00       	mov    $0x450,%edx
   104fa:	48 89 c3             	mov    %rax,%rbx
   104fd:	4c 89 b8 e0 00 00 00 	mov    %r15,0xe0(%rax)
   10504:	be c0 0d 00 00       	mov    $0xdc0,%esi
   10509:	e8 00 00 00 00       	call   1050e <mtgpu_dispc_component_bind+0x6e>
			1050a: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1050e:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
   10515:	48 85 c0             	test   %rax,%rax
   10518:	0f 84 0a 0a 00 00    	je     10f28 <mtgpu_dispc_component_bind+0xa88>
   1051e:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 10525 <mtgpu_dispc_component_bind+0x85>
			10521: R_X86_64_PC32	kmalloc_caches+0x2c
   10525:	ba 30 00 00 00       	mov    $0x30,%edx
   1052a:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1052f:	e8 00 00 00 00       	call   10534 <mtgpu_dispc_component_bind+0x94>
			10530: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   10534:	48 89 43 50          	mov    %rax,0x50(%rbx)
   10538:	48 85 c0             	test   %rax,%rax
   1053b:	0f 84 cc 09 00 00    	je     10f0d <mtgpu_dispc_component_bind+0xa6d>
   10541:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 10548 <mtgpu_dispc_component_bind+0xa8>
			10544: R_X86_64_PC32	kmalloc_caches+0x24
   10548:	ba 18 00 00 00       	mov    $0x18,%edx
   1054d:	be c0 0d 00 00       	mov    $0xdc0,%esi
   10552:	e8 00 00 00 00       	call   10557 <mtgpu_dispc_component_bind+0xb7>
			10553: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   10557:	48 89 43 68          	mov    %rax,0x68(%rbx)
   1055b:	48 85 c0             	test   %rax,%rax
   1055e:	0f 84 8e 09 00 00    	je     10ef2 <mtgpu_dispc_component_bind+0xa52>
   10564:	48 89 6c 24 28       	mov    %rbp,0x28(%rsp)
   10569:	49 8d 6c 24 f0       	lea    -0x10(%r12),%rbp
   1056e:	be 00 02 00 00       	mov    $0x200,%esi
   10573:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10576: R_X86_64_32S	.rodata.str1.1+0x495
   1057a:	48 89 ef             	mov    %rbp,%rdi
   1057d:	e8 00 00 00 00       	call   10582 <mtgpu_dispc_component_bind+0xe2>
			1057e: R_X86_64_PLT32	platform_get_resource_byname-0x4
   10582:	48 85 c0             	test   %rax,%rax
   10585:	74 23                	je     105aa <mtgpu_dispc_component_bind+0x10a>
   10587:	48 8b 50 08          	mov    0x8(%rax),%rdx
   1058b:	48 8b 30             	mov    (%rax),%rsi
   1058e:	4c 89 e7             	mov    %r12,%rdi
   10591:	48 83 c2 01          	add    $0x1,%rdx
   10595:	48 29 f2             	sub    %rsi,%rdx
   10598:	e8 00 00 00 00       	call   1059d <mtgpu_dispc_component_bind+0xfd>
			10599: R_X86_64_PLT32	devm_ioremap-0x4
   1059d:	48 89 43 08          	mov    %rax,0x8(%rbx)
   105a1:	48 85 c0             	test   %rax,%rax
   105a4:	0f 84 a5 01 00 00    	je     1074f <mtgpu_dispc_component_bind+0x2af>
   105aa:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			105ad: R_X86_64_32S	.rodata.str1.1+0x4a0
   105b1:	be 00 02 00 00       	mov    $0x200,%esi
   105b6:	48 89 ef             	mov    %rbp,%rdi
   105b9:	e8 00 00 00 00       	call   105be <mtgpu_dispc_component_bind+0x11e>
			105ba: R_X86_64_PLT32	platform_get_resource_byname-0x4
   105be:	48 85 c0             	test   %rax,%rax
   105c1:	74 23                	je     105e6 <mtgpu_dispc_component_bind+0x146>
   105c3:	48 8b 50 08          	mov    0x8(%rax),%rdx
   105c7:	48 8b 30             	mov    (%rax),%rsi
   105ca:	4c 89 e7             	mov    %r12,%rdi
   105cd:	48 83 c2 01          	add    $0x1,%rdx
   105d1:	48 29 f2             	sub    %rsi,%rdx
   105d4:	e8 00 00 00 00       	call   105d9 <mtgpu_dispc_component_bind+0x139>
			105d5: R_X86_64_PLT32	devm_ioremap-0x4
   105d9:	48 89 43 10          	mov    %rax,0x10(%rbx)
   105dd:	48 85 c0             	test   %rax,%rax
   105e0:	0f 84 69 01 00 00    	je     1074f <mtgpu_dispc_component_bind+0x2af>
   105e6:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			105e9: R_X86_64_32S	.rodata.str1.1+0x4af
   105ed:	be 00 02 00 00       	mov    $0x200,%esi
   105f2:	48 89 ef             	mov    %rbp,%rdi
   105f5:	e8 00 00 00 00       	call   105fa <mtgpu_dispc_component_bind+0x15a>
			105f6: R_X86_64_PLT32	platform_get_resource_byname-0x4
   105fa:	48 85 c0             	test   %rax,%rax
   105fd:	74 23                	je     10622 <mtgpu_dispc_component_bind+0x182>
   105ff:	48 8b 50 08          	mov    0x8(%rax),%rdx
   10603:	48 8b 30             	mov    (%rax),%rsi
   10606:	4c 89 e7             	mov    %r12,%rdi
   10609:	48 83 c2 01          	add    $0x1,%rdx
   1060d:	48 29 f2             	sub    %rsi,%rdx
   10610:	e8 00 00 00 00       	call   10615 <mtgpu_dispc_component_bind+0x175>
			10611: R_X86_64_PLT32	devm_ioremap-0x4
   10615:	48 89 43 18          	mov    %rax,0x18(%rbx)
   10619:	48 85 c0             	test   %rax,%rax
   1061c:	0f 84 2d 01 00 00    	je     1074f <mtgpu_dispc_component_bind+0x2af>
   10622:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10625: R_X86_64_32S	.rodata.str1.1+0x4bf
   10629:	be 00 02 00 00       	mov    $0x200,%esi
   1062e:	48 89 ef             	mov    %rbp,%rdi
   10631:	e8 00 00 00 00       	call   10636 <mtgpu_dispc_component_bind+0x196>
			10632: R_X86_64_PLT32	platform_get_resource_byname-0x4
   10636:	48 85 c0             	test   %rax,%rax
   10639:	74 23                	je     1065e <mtgpu_dispc_component_bind+0x1be>
   1063b:	48 8b 50 08          	mov    0x8(%rax),%rdx
   1063f:	48 8b 30             	mov    (%rax),%rsi
   10642:	4c 89 e7             	mov    %r12,%rdi
   10645:	48 83 c2 01          	add    $0x1,%rdx
   10649:	48 29 f2             	sub    %rsi,%rdx
   1064c:	e8 00 00 00 00       	call   10651 <mtgpu_dispc_component_bind+0x1b1>
			1064d: R_X86_64_PLT32	devm_ioremap-0x4
   10651:	48 89 43 20          	mov    %rax,0x20(%rbx)
   10655:	48 85 c0             	test   %rax,%rax
   10658:	0f 84 f1 00 00 00    	je     1074f <mtgpu_dispc_component_bind+0x2af>
   1065e:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10661: R_X86_64_32S	.rodata.str1.1+0x4ce
   10665:	be 00 02 00 00       	mov    $0x200,%esi
   1066a:	48 89 ef             	mov    %rbp,%rdi
   1066d:	e8 00 00 00 00       	call   10672 <mtgpu_dispc_component_bind+0x1d2>
			1066e: R_X86_64_PLT32	platform_get_resource_byname-0x4
   10672:	48 85 c0             	test   %rax,%rax
   10675:	0f 84 2e 01 00 00    	je     107a9 <mtgpu_dispc_component_bind+0x309>
   1067b:	48 8b 50 08          	mov    0x8(%rax),%rdx
   1067f:	48 8b 30             	mov    (%rax),%rsi
   10682:	4c 89 e7             	mov    %r12,%rdi
   10685:	48 83 c2 01          	add    $0x1,%rdx
   10689:	48 29 f2             	sub    %rsi,%rdx
   1068c:	e8 00 00 00 00       	call   10691 <mtgpu_dispc_component_bind+0x1f1>
			1068d: R_X86_64_PLT32	devm_ioremap-0x4
   10691:	48 89 43 28          	mov    %rax,0x28(%rbx)
   10695:	48 85 c0             	test   %rax,%rax
   10698:	0f 84 b1 00 00 00    	je     1074f <mtgpu_dispc_component_bind+0x2af>
   1069e:	49 8b 45 10          	mov    0x10(%r13),%rax
   106a2:	31 d2                	xor    %edx,%edx
   106a4:	be 00 04 00 00       	mov    $0x400,%esi
   106a9:	48 89 ef             	mov    %rbp,%rdi
   106ac:	48 89 43 30          	mov    %rax,0x30(%rbx)
   106b0:	49 8b 45 18          	mov    0x18(%r13),%rax
   106b4:	89 43 38             	mov    %eax,0x38(%rbx)
   106b7:	49 8b 45 08          	mov    0x8(%r13),%rax
   106bb:	48 89 43 40          	mov    %rax,0x40(%rbx)
   106bf:	e8 00 00 00 00       	call   106c4 <mtgpu_dispc_component_bind+0x224>
			106c0: R_X86_64_PLT32	platform_get_resource-0x4
   106c4:	48 85 c0             	test   %rax,%rax
   106c7:	0f 84 37 03 00 00    	je     10a04 <mtgpu_dispc_component_bind+0x564>
   106cd:	48 8b 00             	mov    (%rax),%rax
   106d0:	48 8b 7b 68          	mov    0x68(%rbx),%rdi
   106d4:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			106d7: R_X86_64_32S	.bss+0xa4
   106db:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			106de: R_X86_64_32S	.rodata.str1.1+0x4d7
   106e2:	89 43 48             	mov    %eax,0x48(%rbx)
   106e5:	41 0f b6 45 00       	movzbl 0x0(%r13),%eax
   106ea:	4c 89 a3 a0 00 00 00 	mov    %r12,0xa0(%rbx)
   106f1:	89 43 4c             	mov    %eax,0x4c(%rbx)
   106f4:	49 89 5c 24 78       	mov    %rbx,0x78(%r12)
   106f9:	e8 00 00 00 00       	call   106fe <mtgpu_dispc_component_bind+0x25e>
			106fa: R_X86_64_PLT32	__init_waitqueue_head-0x4
   106fe:	41 0f b6 4d 20       	movzbl 0x20(%r13),%ecx
   10703:	80 f9 03             	cmp    $0x3,%cl
   10706:	0f 84 13 03 00 00    	je     10a1f <mtgpu_dispc_component_bind+0x57f>
   1070c:	0f 87 ba 00 00 00    	ja     107cc <mtgpu_dispc_component_bind+0x32c>
   10712:	80 f9 01             	cmp    $0x1,%cl
   10715:	0f 84 3d 03 00 00    	je     10a58 <mtgpu_dispc_component_bind+0x5b8>
   1071b:	80 f9 02             	cmp    $0x2,%cl
   1071e:	0f 85 0e 03 00 00    	jne    10a32 <mtgpu_dispc_component_bind+0x592>
   10724:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 1072b <mtgpu_dispc_component_bind+0x28b>
			10726: R_X86_64_PC32	fec_display_enable-0x5
   1072b:	0f 84 5e 04 00 00    	je     10b8f <mtgpu_dispc_component_bind+0x6ef>
   10731:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
			10734: R_X86_64_32S	mtgpu_dispc_fec
   10738:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			1073b: R_X86_64_32S	mtgpu_dispc_qy1
   1073f:	48 c7 05 00 00 00 00 	movq   $0x0,0x0(%rip)        # 1074a <mtgpu_dispc_component_bind+0x2aa>
   10746:	00 00 00 00 
			10742: R_X86_64_PC32	mtgpu_dispc_qy1-0x8
			10746: R_X86_64_32S	mtgpu_dispc_fec
   1074a:	e9 94 00 00 00       	jmp    107e3 <mtgpu_dispc_component_bind+0x343>
   1074f:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10754:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   1075a:	49 c7 44 24 78 00 00 	movq   $0x0,0x78(%r12)
   10761:	00 00 
   10763:	48 8b 7b 68          	mov    0x68(%rbx),%rdi
   10767:	e8 00 00 00 00       	call   1076c <mtgpu_dispc_component_bind+0x2cc>
			10768: R_X86_64_PLT32	kfree-0x4
   1076c:	48 8b 7b 50          	mov    0x50(%rbx),%rdi
   10770:	e8 00 00 00 00       	call   10775 <mtgpu_dispc_component_bind+0x2d5>
			10771: R_X86_64_PLT32	kfree-0x4
   10775:	48 8b bb 98 00 00 00 	mov    0x98(%rbx),%rdi
   1077c:	e8 00 00 00 00       	call   10781 <mtgpu_dispc_component_bind+0x2e1>
			1077d: R_X86_64_PLT32	kfree-0x4
   10781:	48 89 df             	mov    %rbx,%rdi
   10784:	e8 00 00 00 00       	call   10789 <mtgpu_dispc_component_bind+0x2e9>
			10785: R_X86_64_PLT32	kfree-0x4
   10789:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
   1078e:	44 89 f8             	mov    %r15d,%eax
   10791:	4c 8b 64 24 30       	mov    0x30(%rsp),%r12
   10796:	4c 8b 6c 24 38       	mov    0x38(%rsp),%r13
   1079b:	4c 8b 7c 24 48       	mov    0x48(%rsp),%r15
   107a0:	48 83 c4 50          	add    $0x50,%rsp
   107a4:	e9 00 00 00 00       	jmp    107a9 <mtgpu_dispc_component_bind+0x309>
			107a5: R_X86_64_PLT32	__x86_return_thunk-0x4
   107a9:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			107ac: R_X86_64_32S	.rodata.str1.8+0xde0
   107b0:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			107b3: R_X86_64_32S	.rodata.str1.1+0x448
   107b7:	4c 89 e7             	mov    %r12,%rdi
   107ba:	e8 00 00 00 00       	call   107bf <mtgpu_dispc_component_bind+0x31f>
			107bb: R_X86_64_PLT32	drm_dev_printk-0x4
   107bf:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   107c4:	41 bf fb ff ff ff    	mov    $0xfffffffb,%r15d
   107ca:	eb 8e                	jmp    1075a <mtgpu_dispc_component_bind+0x2ba>
   107cc:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 107d3 <mtgpu_dispc_component_bind+0x333>
			107cf: R_X86_64_PC32	mtgpu_dispc_ph1-0x4
   107d3:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			107d6: R_X86_64_32S	mtgpu_dispc_ph1
   107da:	80 f9 04             	cmp    $0x4,%cl
   107dd:	0f 85 4f 02 00 00    	jne    10a32 <mtgpu_dispc_component_bind+0x592>
   107e3:	48 89 83 88 00 00 00 	mov    %rax,0x88(%rbx)
   107ea:	48 85 c0             	test   %rax,%rax
   107ed:	0f 84 87 05 00 00    	je     10d7a <mtgpu_dispc_component_bind+0x8da>
   107f3:	48 8b 40 10          	mov    0x10(%rax),%rax
   107f7:	48 85 c0             	test   %rax,%rax
   107fa:	74 14                	je     10810 <mtgpu_dispc_component_bind+0x370>
   107fc:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10800:	e8 00 00 00 00       	call   10805 <mtgpu_dispc_component_bind+0x365>
			10801: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10805:	41 89 c7             	mov    %eax,%r15d
   10808:	85 c0                	test   %eax,%eax
   1080a:	0f 85 ea 01 00 00    	jne    109fa <mtgpu_dispc_component_bind+0x55a>
   10810:	41 80 7d 20 01       	cmpb   $0x1,0x20(%r13)
   10815:	0f 84 50 02 00 00    	je     10a6b <mtgpu_dispc_component_bind+0x5cb>
   1081b:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
   10822:	48 8b 40 08          	mov    0x8(%rax),%rax
   10826:	48 85 c0             	test   %rax,%rax
   10829:	74 09                	je     10834 <mtgpu_dispc_component_bind+0x394>
   1082b:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   1082f:	e8 00 00 00 00       	call   10834 <mtgpu_dispc_component_bind+0x394>
			10830: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10834:	4c 8b 5d 08          	mov    0x8(%rbp),%r11
   10838:	4c 89 9b 90 00 00 00 	mov    %r11,0x90(%rbx)
   1083f:	4d 85 db             	test   %r11,%r11
   10842:	0f 84 58 05 00 00    	je     10da0 <mtgpu_dispc_component_bind+0x900>
   10848:	49 8b 03             	mov    (%r11),%rax
   1084b:	48 85 c0             	test   %rax,%rax
   1084e:	74 09                	je     10859 <mtgpu_dispc_component_bind+0x3b9>
   10850:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10854:	e8 00 00 00 00       	call   10859 <mtgpu_dispc_component_bind+0x3b9>
			10855: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10859:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
   10860:	48 8b 40 68          	mov    0x68(%rax),%rax
   10864:	48 85 c0             	test   %rax,%rax
   10867:	0f 84 52 05 00 00    	je     10dbf <mtgpu_dispc_component_bind+0x91f>
   1086d:	4c 89 74 24 40       	mov    %r14,0x40(%rsp)
   10872:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10876:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
   1087d:	e8 00 00 00 00       	call   10882 <mtgpu_dispc_component_bind+0x3e2>
			1087e: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10882:	4c 8b b3 98 00 00 00 	mov    0x98(%rbx),%r14
   10889:	41 0f b6 06          	movzbl (%r14),%eax
   1088d:	84 c0                	test   %al,%al
   1088f:	0f 84 0d 03 00 00    	je     10ba2 <mtgpu_dispc_component_bind+0x702>
   10895:	48 8d 3c c5 00 00 00 	lea    0x0(,%rax,8),%rdi
   1089c:	00 
   1089d:	be c0 0d 00 00       	mov    $0xdc0,%esi
   108a2:	e8 00 00 00 00       	call   108a7 <mtgpu_dispc_component_bind+0x407>
			108a3: R_X86_64_PLT32	__kmalloc_noprof-0x4
   108a7:	49 89 c3             	mov    %rax,%r11
   108aa:	48 85 c0             	test   %rax,%rax
   108ad:	0f 84 e4 05 00 00    	je     10e97 <mtgpu_dispc_component_bind+0x9f7>
   108b3:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
   108ba:	80 38 00             	cmpb   $0x0,(%rax)
   108bd:	0f 84 a0 05 00 00    	je     10e63 <mtgpu_dispc_component_bind+0x9c3>
   108c3:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
   108c8:	49 83 c6 0c          	add    $0xc,%r14
   108cc:	45 31 ed             	xor    %r13d,%r13d
   108cf:	4d 89 df             	mov    %r11,%r15
   108d2:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
   108d9:	00 00 
   108db:	48 c7 44 24 10 00 00 	movq   $0x0,0x10(%rsp)
   108e2:	00 00 
   108e4:	eb 2e                	jmp    10914 <mtgpu_dispc_component_bind+0x474>
   108e6:	41 80 7e fc 02       	cmpb   $0x2,-0x4(%r14)
   108eb:	48 0f 45 6c 24 08    	cmovne 0x8(%rsp),%rbp
   108f1:	48 89 6c 24 08       	mov    %rbp,0x8(%rsp)
   108f6:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
   108fd:	41 83 c5 01          	add    $0x1,%r13d
   10901:	49 81 c6 10 01 00 00 	add    $0x110,%r14
   10908:	0f b6 00             	movzbl (%rax),%eax
   1090b:	44 39 e8             	cmp    %r13d,%eax
   1090e:	0f 8e 2f 03 00 00    	jle    10c43 <mtgpu_dispc_component_bind+0x7a3>
   10914:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1091b <mtgpu_dispc_component_bind+0x47b>
			10917: R_X86_64_PC32	kmalloc_caches+0x54
   1091b:	ba 48 05 00 00       	mov    $0x548,%edx
   10920:	be c0 0d 00 00       	mov    $0xdc0,%esi
   10925:	45 89 ec             	mov    %r13d,%r12d
   10928:	e8 00 00 00 00       	call   1092d <mtgpu_dispc_component_bind+0x48d>
			10929: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1092d:	48 89 c5             	mov    %rax,%rbp
   10930:	48 85 c0             	test   %rax,%rax
   10933:	0f 84 a3 05 00 00    	je     10edc <mtgpu_dispc_component_bind+0xa3c>
   10939:	8b 4b 4c             	mov    0x4c(%rbx),%ecx
   1093c:	45 0f b6 4e fd       	movzbl -0x3(%r14),%r9d
   10941:	6a 00                	push   $0x0
   10943:	ba 01 00 00 00       	mov    $0x1,%edx
   10948:	41 0f be 46 fc       	movsbl -0x4(%r14),%eax
   1094d:	4d 89 f0             	mov    %r14,%r8
   10950:	48 89 ee             	mov    %rbp,%rsi
   10953:	d3 e2                	shl    %cl,%edx
   10955:	48 c7 c1 00 00 00 00 	mov    $0x0,%rcx
			10958: R_X86_64_32S	.rodata+0x27c0
   1095c:	50                   	push   %rax
   1095d:	49 8d 86 84 00 00 00 	lea    0x84(%r14),%rax
   10964:	50                   	push   %rax
   10965:	48 8b 7c 24 18       	mov    0x18(%rsp),%rdi
   1096a:	e8 00 00 00 00       	call   1096f <mtgpu_dispc_component_bind+0x4cf>
			1096b: R_X86_64_PLT32	drm_universal_plane_init-0x4
   1096f:	48 83 c4 18          	add    $0x18,%rsp
   10973:	85 c0                	test   %eax,%eax
   10975:	0f 85 4d 02 00 00    	jne    10bc8 <mtgpu_dispc_component_bind+0x728>
   1097b:	44 89 e8             	mov    %r13d,%eax
   1097e:	be 07 00 00 00       	mov    $0x7,%esi
   10983:	48 89 ef             	mov    %rbp,%rdi
   10986:	48 c7 85 d0 04 00 00 	movq   $0x0,0x4d0(%rbp)
   1098d:	00 00 00 00 
			1098d: R_X86_64_32S	.rodata+0x2840
   10991:	49 89 2c c7          	mov    %rbp,(%r15,%rax,8)
   10995:	e8 00 00 00 00       	call   1099a <mtgpu_dispc_component_bind+0x4fa>
			10996: R_X86_64_PLT32	drm_plane_create_blend_mode_property-0x4
   1099a:	ba 01 00 00 00       	mov    $0x1,%edx
   1099f:	be 01 00 00 00       	mov    $0x1,%esi
   109a4:	48 89 ef             	mov    %rbp,%rdi
   109a7:	e8 00 00 00 00       	call   109ac <mtgpu_dispc_component_bind+0x50c>
			109a8: R_X86_64_PLT32	drm_plane_create_rotation_property-0x4
   109ac:	48 89 ef             	mov    %rbp,%rdi
   109af:	e8 00 00 00 00       	call   109b4 <mtgpu_dispc_component_bind+0x514>
			109b0: R_X86_64_PLT32	drm_plane_create_alpha_property-0x4
   109b4:	44 89 ee             	mov    %r13d,%esi
   109b7:	48 89 ef             	mov    %rbp,%rdi
   109ba:	e8 00 00 00 00       	call   109bf <mtgpu_dispc_component_bind+0x51f>
			109bb: R_X86_64_PLT32	drm_plane_create_zpos_immutable_property-0x4
   109bf:	41 8b b6 04 01 00 00 	mov    0x104(%r14),%esi
   109c6:	85 f6                	test   %esi,%esi
   109c8:	74 0b                	je     109d5 <mtgpu_dispc_component_bind+0x535>
   109ca:	41 8b 96 08 01 00 00 	mov    0x108(%r14),%edx
   109d1:	85 d2                	test   %edx,%edx
   109d3:	75 13                	jne    109e8 <mtgpu_dispc_component_bind+0x548>
   109d5:	45 85 ed             	test   %r13d,%r13d
   109d8:	0f 85 08 ff ff ff    	jne    108e6 <mtgpu_dispc_component_bind+0x446>
   109de:	48 89 6c 24 10       	mov    %rbp,0x10(%rsp)
   109e3:	e9 0e ff ff ff       	jmp    108f6 <mtgpu_dispc_component_bind+0x456>
   109e8:	45 31 c0             	xor    %r8d,%r8d
   109eb:	b9 01 00 00 00       	mov    $0x1,%ecx
   109f0:	48 89 ef             	mov    %rbp,%rdi
   109f3:	e8 00 00 00 00       	call   109f8 <mtgpu_dispc_component_bind+0x558>
			109f4: R_X86_64_PLT32	drm_plane_create_color_properties-0x4
   109f8:	eb db                	jmp    109d5 <mtgpu_dispc_component_bind+0x535>
   109fa:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   109ff:	e9 56 fd ff ff       	jmp    1075a <mtgpu_dispc_component_bind+0x2ba>
   10a04:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10a07: R_X86_64_32S	.rodata.str1.8+0xe08
   10a0b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10a0e: R_X86_64_32S	.rodata.str1.1+0x448
   10a12:	4c 89 e7             	mov    %r12,%rdi
   10a15:	e8 00 00 00 00       	call   10a1a <mtgpu_dispc_component_bind+0x57a>
			10a16: R_X86_64_PLT32	drm_dev_printk-0x4
   10a1a:	e9 a0 fd ff ff       	jmp    107bf <mtgpu_dispc_component_bind+0x31f>
   10a1f:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10a26 <mtgpu_dispc_component_bind+0x586>
			10a22: R_X86_64_PC32	mtgpu_dispc_qy2-0x4
   10a26:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10a29: R_X86_64_32S	mtgpu_dispc_qy2
   10a2d:	e9 b1 fd ff ff       	jmp    107e3 <mtgpu_dispc_component_bind+0x343>
   10a32:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10a35: R_X86_64_32S	.rodata.str1.8+0xe38
   10a39:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10a3c: R_X86_64_32S	.rodata.str1.1+0x448
   10a40:	4c 89 e7             	mov    %r12,%rdi
   10a43:	41 bf f4 fd ff ff    	mov    $0xfffffdf4,%r15d
   10a49:	e8 00 00 00 00       	call   10a4e <mtgpu_dispc_component_bind+0x5ae>
			10a4a: R_X86_64_PLT32	drm_dev_printk-0x4
   10a4e:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10a53:	e9 02 fd ff ff       	jmp    1075a <mtgpu_dispc_component_bind+0x2ba>
   10a58:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10a5f <mtgpu_dispc_component_bind+0x5bf>
			10a5b: R_X86_64_PC32	mtgpu_dispc_sudi-0x4
   10a5f:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10a62: R_X86_64_32S	mtgpu_dispc_sudi
   10a66:	e9 78 fd ff ff       	jmp    107e3 <mtgpu_dispc_component_bind+0x343>
   10a6b:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10a70:	48 8b 40 40          	mov    0x40(%rax),%rax
   10a74:	48 81 78 60 00 00 00 	cmpq   $0x0,0x60(%rax)
   10a7b:	00 
			10a78: R_X86_64_32S	pci_bus_type
   10a7c:	0f 85 99 fd ff ff    	jne    1081b <mtgpu_dispc_component_bind+0x37b>
   10a82:	66 81 b8 74 ff ff ff 	cmpw   $0x1ed5,-0x8c(%rax)
   10a89:	d5 1e 
   10a8b:	0f 85 8a fd ff ff    	jne    1081b <mtgpu_dispc_component_bind+0x37b>
   10a91:	66 81 b8 76 ff ff ff 	cmpw   $0x102,-0x8a(%rax)
   10a98:	02 01 
   10a9a:	0f 85 7b fd ff ff    	jne    1081b <mtgpu_dispc_component_bind+0x37b>
   10aa0:	4c 89 74 24 40       	mov    %r14,0x40(%rsp)
   10aa5:	4c 8b 73 08          	mov    0x8(%rbx),%r14
   10aa9:	4d 85 f6             	test   %r14,%r14
   10aac:	0f 84 b1 04 00 00    	je     10f63 <mtgpu_dispc_component_bind+0xac3>
   10ab2:	41 8b 06             	mov    (%r14),%eax
   10ab5:	83 f8 ff             	cmp    $0xffffffff,%eax
   10ab8:	0f 84 9a 04 00 00    	je     10f58 <mtgpu_dispc_component_bind+0xab8>
   10abe:	31 c9                	xor    %ecx,%ecx
   10ac0:	41 89 4e 1c          	mov    %ecx,0x1c(%r14)
   10ac4:	41 8b 4e 1c          	mov    0x1c(%r14),%ecx
   10ac8:	a8 01                	test   $0x1,%al
   10aca:	0f 84 ec 03 00 00    	je     10ebc <mtgpu_dispc_component_bind+0xa1c>
   10ad0:	4d 8d 7e 18          	lea    0x18(%r14),%r15
   10ad4:	b9 00 01 00 00       	mov    $0x100,%ecx
   10ad9:	41 89 0f             	mov    %ecx,(%r15)
   10adc:	41 8b 4e 18          	mov    0x18(%r14),%ecx
   10ae0:	83 e0 fe             	and    $0xfffffffe,%eax
   10ae3:	41 89 06             	mov    %eax,(%r14)
   10ae6:	41 8b 06             	mov    (%r14),%eax
   10ae9:	e8 00 00 00 00       	call   10aee <mtgpu_dispc_component_bind+0x64e>
			10aea: R_X86_64_PLT32	ktime_get-0x4
   10aee:	4c 8d a8 00 65 cd 1d 	lea    0x1dcd6500(%rax),%r13
   10af5:	e8 00 00 00 00       	call   10afa <mtgpu_dispc_component_bind+0x65a>
			10af6: R_X86_64_PLT32	__SCT__might_resched-0x4
   10afa:	eb 24                	jmp    10b20 <mtgpu_dispc_component_bind+0x680>
   10afc:	41 8b 07             	mov    (%r15),%eax
   10aff:	89 c1                	mov    %eax,%ecx
   10b01:	f6 c4 01             	test   $0x1,%ah
   10b04:	0f 85 9d 03 00 00    	jne    10ea7 <mtgpu_dispc_component_bind+0xa07>
   10b0a:	ba 02 00 00 00       	mov    $0x2,%edx
   10b0f:	be e8 03 00 00       	mov    $0x3e8,%esi
   10b14:	bf fb 00 00 00       	mov    $0xfb,%edi
   10b19:	e8 00 00 00 00       	call   10b1e <mtgpu_dispc_component_bind+0x67e>
			10b1a: R_X86_64_PLT32	usleep_range_state-0x4
   10b1e:	f3 90                	pause
   10b20:	e8 00 00 00 00       	call   10b25 <mtgpu_dispc_component_bind+0x685>
			10b21: R_X86_64_PLT32	ktime_get-0x4
   10b25:	49 39 c5             	cmp    %rax,%r13
   10b28:	7d d2                	jge    10afc <mtgpu_dispc_component_bind+0x65c>
   10b2a:	41 8b 46 18          	mov    0x18(%r14),%eax
   10b2e:	89 c1                	mov    %eax,%ecx
   10b30:	f6 c4 01             	test   $0x1,%ah
   10b33:	0f 85 6e 03 00 00    	jne    10ea7 <mtgpu_dispc_component_bind+0xa07>
   10b39:	41 bf 92 ff ff ff    	mov    $0xffffff92,%r15d
   10b3f:	44 89 f9             	mov    %r15d,%ecx
   10b42:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10b45: R_X86_64_32S	.rodata.str1.8+0xe68
   10b49:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10b4c: R_X86_64_32S	.rodata.str1.1+0x448
   10b50:	4c 89 e7             	mov    %r12,%rdi
   10b53:	e8 00 00 00 00       	call   10b58 <mtgpu_dispc_component_bind+0x6b8>
			10b54: R_X86_64_PLT32	drm_dev_printk-0x4
   10b58:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10b5d:	45 31 db             	xor    %r11d,%r11d
   10b60:	4c 89 df             	mov    %r11,%rdi
   10b63:	e8 00 00 00 00       	call   10b68 <mtgpu_dispc_component_bind+0x6c8>
			10b64: R_X86_64_PLT32	kfree-0x4
   10b68:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
   10b6f:	48 8b 40 18          	mov    0x18(%rax),%rax
   10b73:	48 85 c0             	test   %rax,%rax
   10b76:	0f 84 7e fe ff ff    	je     109fa <mtgpu_dispc_component_bind+0x55a>
   10b7c:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10b80:	e8 00 00 00 00       	call   10b85 <mtgpu_dispc_component_bind+0x6e5>
			10b81: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10b85:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10b8a:	e9 cb fb ff ff       	jmp    1075a <mtgpu_dispc_component_bind+0x2ba>
   10b8f:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10b96 <mtgpu_dispc_component_bind+0x6f6>
			10b92: R_X86_64_PC32	mtgpu_dispc_qy1-0x4
   10b96:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10b99: R_X86_64_32S	mtgpu_dispc_qy1
   10b9d:	e9 41 fc ff ff       	jmp    107e3 <mtgpu_dispc_component_bind+0x343>
   10ba2:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10ba5: R_X86_64_32S	.rodata.str1.8+0xf00
   10ba9:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10bac: R_X86_64_32S	.rodata.str1.1+0x448
   10bb0:	4c 89 e7             	mov    %r12,%rdi
   10bb3:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10bb9:	e8 00 00 00 00       	call   10bbe <mtgpu_dispc_component_bind+0x71e>
			10bba: R_X86_64_PLT32	drm_dev_printk-0x4
   10bbe:	45 31 db             	xor    %r11d,%r11d
   10bc1:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10bc6:	eb 98                	jmp    10b60 <mtgpu_dispc_component_bind+0x6c0>
   10bc8:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
   10bcd:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10bd0: R_X86_64_32S	.rodata.str1.8+0xf20
   10bd4:	4c 89 3c 24          	mov    %r15,(%rsp)
   10bd8:	41 89 c7             	mov    %eax,%r15d
   10bdb:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10bde: R_X86_64_32S	.rodata.str1.1+0x448
   10be2:	45 89 ee             	mov    %r13d,%r14d
   10be5:	4c 89 e7             	mov    %r12,%rdi
   10be8:	e8 00 00 00 00       	call   10bed <mtgpu_dispc_component_bind+0x74d>
			10be9: R_X86_64_PLT32	drm_dev_printk-0x4
   10bed:	48 89 ef             	mov    %rbp,%rdi
   10bf0:	e8 00 00 00 00       	call   10bf5 <mtgpu_dispc_component_bind+0x755>
			10bf1: R_X86_64_PLT32	kfree-0x4
   10bf5:	4c 8b 1c 24          	mov    (%rsp),%r11
   10bf9:	45 85 f6             	test   %r14d,%r14d
   10bfc:	0f 84 4c 03 00 00    	je     10f4e <mtgpu_dispc_component_bind+0xaae>
   10c02:	48 89 1c 24          	mov    %rbx,(%rsp)
   10c06:	41 8d 46 ff          	lea    -0x1(%r14),%eax
   10c0a:	4d 8d 6b f8          	lea    -0x8(%r11),%r13
   10c0e:	4d 89 de             	mov    %r11,%r14
   10c11:	49 8d 2c c3          	lea    (%r11,%rax,8),%rbp
   10c15:	48 8b 5d 00          	mov    0x0(%rbp),%rbx
   10c19:	48 83 ed 08          	sub    $0x8,%rbp
   10c1d:	48 89 df             	mov    %rbx,%rdi
   10c20:	e8 00 00 00 00       	call   10c25 <mtgpu_dispc_component_bind+0x785>
			10c21: R_X86_64_PLT32	drm_plane_cleanup-0x4
   10c25:	48 89 df             	mov    %rbx,%rdi
   10c28:	e8 00 00 00 00       	call   10c2d <mtgpu_dispc_component_bind+0x78d>
			10c29: R_X86_64_PLT32	kfree-0x4
   10c2d:	4c 39 ed             	cmp    %r13,%rbp
   10c30:	75 e3                	jne    10c15 <mtgpu_dispc_component_bind+0x775>
   10c32:	4d 89 f3             	mov    %r14,%r11
   10c35:	48 8b 1c 24          	mov    (%rsp),%rbx
   10c39:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10c3e:	e9 1d ff ff ff       	jmp    10b60 <mtgpu_dispc_component_bind+0x6c0>
   10c43:	45 8d 74 24 01       	lea    0x1(%r12),%r14d
   10c48:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
   10c4d:	4c 89 7c 24 18       	mov    %r15,0x18(%rsp)
   10c52:	e8 00 00 00 00       	call   10c57 <mtgpu_dispc_component_bind+0x7b7>
			10c53: R_X86_64_PLT32	os_create_drm_crtc-0x4
   10c57:	4c 8b 5c 24 18       	mov    0x18(%rsp),%r11
   10c5c:	48 85 c0             	test   %rax,%rax
   10c5f:	48 89 03             	mov    %rax,(%rbx)
   10c62:	48 89 c7             	mov    %rax,%rdi
   10c65:	0f 84 d1 01 00 00    	je     10e3c <mtgpu_dispc_component_bind+0x99c>
   10c6b:	48 89 de             	mov    %rbx,%rsi
   10c6e:	4c 89 5c 24 18       	mov    %r11,0x18(%rsp)
   10c73:	e8 00 00 00 00       	call   10c78 <mtgpu_dispc_component_bind+0x7d8>
			10c74: R_X86_64_PLT32	os_set_drm_crtc_drvdata-0x4
   10c78:	48 8b 33             	mov    (%rbx),%rsi
   10c7b:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
   10c80:	45 31 c9             	xor    %r9d,%r9d
   10c83:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
   10c88:	48 8b 3c 24          	mov    (%rsp),%rdi
   10c8c:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8
			10c8f: R_X86_64_32S	.rodata+0x2660
   10c93:	e8 00 00 00 00       	call   10c98 <mtgpu_dispc_component_bind+0x7f8>
			10c94: R_X86_64_PLT32	drm_crtc_init_with_planes-0x4
   10c98:	4c 8b 5c 24 18       	mov    0x18(%rsp),%r11
   10c9d:	85 c0                	test   %eax,%eax
   10c9f:	41 89 c7             	mov    %eax,%r15d
   10ca2:	4c 89 1c 24          	mov    %r11,(%rsp)
   10ca6:	0f 85 9b 01 00 00    	jne    10e47 <mtgpu_dispc_component_bind+0x9a7>
   10cac:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
   10cb3:	48 8b 3b             	mov    (%rbx),%rdi
   10cb6:	8b b0 48 04 00 00    	mov    0x448(%rax),%esi
   10cbc:	e8 00 00 00 00       	call   10cc1 <mtgpu_dispc_component_bind+0x821>
			10cbd: R_X86_64_PLT32	drm_mode_crtc_set_gamma_size-0x4
   10cc1:	48 8b 3b             	mov    (%rbx),%rdi
   10cc4:	31 d2                	xor    %edx,%edx
   10cc6:	31 f6                	xor    %esi,%esi
   10cc8:	48 8b 87 a8 01 00 00 	mov    0x1a8(%rdi),%rax
   10ccf:	48 89 43 78          	mov    %rax,0x78(%rbx)
   10cd3:	8b 8f a0 01 00 00    	mov    0x1a0(%rdi),%ecx
   10cd9:	89 8b 80 00 00 00    	mov    %ecx,0x80(%rbx)
   10cdf:	e8 00 00 00 00       	call   10ce4 <mtgpu_dispc_component_bind+0x844>
			10ce0: R_X86_64_PLT32	drm_crtc_enable_color_mgmt-0x4
   10ce4:	48 8b 03             	mov    (%rbx),%rax
   10ce7:	48 89 d9             	mov    %rbx,%rcx
   10cea:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8
			10ced: R_X86_64_32S	.rodata.str1.1+0x537
   10cf1:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10cf4: R_X86_64_32S	.text+0xf500
   10cf8:	48 c7 80 b0 01 00 00 	movq   $0x0,0x1b0(%rax)
   10cff:	00 00 00 00 
			10cff: R_X86_64_32S	.rodata+0x2720
   10d03:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10d08:	8b 73 48             	mov    0x48(%rbx),%esi
   10d0b:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10d0f:	e8 00 00 00 00       	call   10d14 <mtgpu_dispc_component_bind+0x874>
			10d10: R_X86_64_PLT32	mtgpu_register_interrupt-0x4
   10d14:	4c 8b 1c 24          	mov    (%rsp),%r11
   10d18:	85 c0                	test   %eax,%eax
   10d1a:	41 89 c7             	mov    %eax,%r15d
   10d1d:	0f 85 f4 00 00 00    	jne    10e17 <mtgpu_dispc_component_bind+0x977>
   10d23:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10d28:	8b 73 48             	mov    0x48(%rbx),%esi
   10d2b:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10d2f:	e8 00 00 00 00       	call   10d34 <mtgpu_dispc_component_bind+0x894>
			10d30: R_X86_64_PLT32	mtgpu_enable_interrupt-0x4
   10d34:	41 89 c7             	mov    %eax,%r15d
   10d37:	85 c0                	test   %eax,%eax
   10d39:	0f 85 a4 00 00 00    	jne    10de3 <mtgpu_dispc_component_bind+0x943>
   10d3f:	48 89 df             	mov    %rbx,%rdi
   10d42:	e8 00 00 00 00       	call   10d47 <mtgpu_dispc_component_bind+0x8a7>
			10d43: R_X86_64_PLT32	mtgpu_dispc_debugfs_create_files-0x4
   10d47:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10d4a: R_X86_64_32S	.rodata.str1.8+0xf40
   10d4e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10d51: R_X86_64_32S	.rodata.str1.1+0x44b
   10d55:	4c 89 e7             	mov    %r12,%rdi
   10d58:	e8 00 00 00 00       	call   10d5d <mtgpu_dispc_component_bind+0x8bd>
			10d59: R_X86_64_PLT32	drm_dev_printk-0x4
   10d5d:	48 8b 3c 24          	mov    (%rsp),%rdi
   10d61:	e8 00 00 00 00       	call   10d66 <mtgpu_dispc_component_bind+0x8c6>
			10d62: R_X86_64_PLT32	kfree-0x4
   10d66:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
   10d6b:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10d70:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10d75:	e9 14 fa ff ff       	jmp    1078e <mtgpu_dispc_component_bind+0x2ee>
   10d7a:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10d7d: R_X86_64_32S	.rodata.str1.1+0x4e8
   10d81:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10d84: R_X86_64_32S	.rodata.str1.1+0x448
   10d88:	4c 89 e7             	mov    %r12,%rdi
   10d8b:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10d91:	e8 00 00 00 00       	call   10d96 <mtgpu_dispc_component_bind+0x8f6>
			10d92: R_X86_64_PLT32	drm_dev_printk-0x4
   10d96:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10d9b:	e9 ba f9 ff ff       	jmp    1075a <mtgpu_dispc_component_bind+0x2ba>
   10da0:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			10da3: R_X86_64_32S	.rodata.str1.1+0x503
   10da7:	4c 89 1c 24          	mov    %r11,(%rsp)
   10dab:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10db1:	e8 00 00 00 00       	call   10db6 <mtgpu_dispc_component_bind+0x916>
			10db2: R_X86_64_PLT32	__drm_err-0x4
   10db6:	4c 8b 1c 24          	mov    (%rsp),%r11
   10dba:	e9 a1 fd ff ff       	jmp    10b60 <mtgpu_dispc_component_bind+0x6c0>
   10dbf:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10dc2: R_X86_64_32S	.rodata.str1.8+0xed0
   10dc6:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10dc9: R_X86_64_32S	.rodata.str1.1+0x448
   10dcd:	4c 89 e7             	mov    %r12,%rdi
   10dd0:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10dd6:	e8 00 00 00 00       	call   10ddb <mtgpu_dispc_component_bind+0x93b>
			10dd7: R_X86_64_PLT32	drm_dev_printk-0x4
   10ddb:	45 31 db             	xor    %r11d,%r11d
   10dde:	e9 7d fd ff ff       	jmp    10b60 <mtgpu_dispc_component_bind+0x6c0>
   10de3:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10de8:	8b 73 48             	mov    0x48(%rbx),%esi
   10deb:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10def:	e8 00 00 00 00       	call   10df4 <mtgpu_dispc_component_bind+0x954>
			10df0: R_X86_64_PLT32	mtgpu_disable_interrupt-0x4
   10df4:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10df9:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10dfd:	e8 00 00 00 00       	call   10e02 <mtgpu_dispc_component_bind+0x962>
			10dfe: R_X86_64_PLT32	mtgpu_drm_sync_irqs-0x4
   10e02:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10e07:	8b 73 48             	mov    0x48(%rbx),%esi
   10e0a:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10e0e:	e8 00 00 00 00       	call   10e13 <mtgpu_dispc_component_bind+0x973>
			10e0f: R_X86_64_PLT32	mtgpu_unregister_interrupt-0x4
   10e13:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e17:	48 8b 3b             	mov    (%rbx),%rdi
   10e1a:	4c 89 1c 24          	mov    %r11,(%rsp)
   10e1e:	e8 00 00 00 00       	call   10e23 <mtgpu_dispc_component_bind+0x983>
			10e1f: R_X86_64_PLT32	drm_crtc_cleanup-0x4
   10e23:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e27:	48 8b 3b             	mov    (%rbx),%rdi
   10e2a:	4c 89 1c 24          	mov    %r11,(%rsp)
   10e2e:	e8 00 00 00 00       	call   10e33 <mtgpu_dispc_component_bind+0x993>
			10e2f: R_X86_64_PLT32	os_destroy_drm_crtc-0x4
   10e33:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e37:	e9 bd fd ff ff       	jmp    10bf9 <mtgpu_dispc_component_bind+0x759>
   10e3c:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10e42:	e9 b2 fd ff ff       	jmp    10bf9 <mtgpu_dispc_component_bind+0x759>
   10e47:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10e4a: R_X86_64_32S	.rodata.str1.1+0x51a
   10e4e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10e51: R_X86_64_32S	.rodata.str1.1+0x448
   10e55:	4c 89 e7             	mov    %r12,%rdi
   10e58:	e8 00 00 00 00       	call   10e5d <mtgpu_dispc_component_bind+0x9bd>
			10e59: R_X86_64_PLT32	drm_dev_printk-0x4
   10e5d:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e61:	eb c4                	jmp    10e27 <mtgpu_dispc_component_bind+0x987>
   10e63:	4c 89 5c 24 08       	mov    %r11,0x8(%rsp)
   10e68:	e8 00 00 00 00       	call   10e6d <mtgpu_dispc_component_bind+0x9cd>
			10e69: R_X86_64_PLT32	os_create_drm_crtc-0x4
   10e6d:	4c 8b 5c 24 08       	mov    0x8(%rsp),%r11
   10e72:	48 85 c0             	test   %rax,%rax
   10e75:	48 89 03             	mov    %rax,(%rbx)
   10e78:	48 89 c7             	mov    %rax,%rdi
   10e7b:	74 1a                	je     10e97 <mtgpu_dispc_component_bind+0x9f7>
   10e7d:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
   10e84:	00 00 
   10e86:	45 31 f6             	xor    %r14d,%r14d
   10e89:	48 c7 44 24 10 00 00 	movq   $0x0,0x10(%rsp)
   10e90:	00 00 
   10e92:	e9 d4 fd ff ff       	jmp    10c6b <mtgpu_dispc_component_bind+0x7cb>
   10e97:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10e9c:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10ea2:	e9 b9 fc ff ff       	jmp    10b60 <mtgpu_dispc_component_bind+0x6c0>
   10ea7:	83 c1 01             	add    $0x1,%ecx
   10eaa:	0f 84 a8 00 00 00    	je     10f58 <mtgpu_dispc_component_bind+0xab8>
   10eb0:	b8 00 01 00 00       	mov    $0x100,%eax
   10eb5:	41 89 07             	mov    %eax,(%r15)
   10eb8:	41 8b 46 18          	mov    0x18(%r14),%eax
   10ebc:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10ebf: R_X86_64_32S	.rodata.str1.8+0xe98
   10ec3:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10ec6: R_X86_64_32S	.rodata.str1.1+0x44b
   10eca:	4c 89 e7             	mov    %r12,%rdi
   10ecd:	e8 00 00 00 00       	call   10ed2 <mtgpu_dispc_component_bind+0xa32>
			10ece: R_X86_64_PLT32	drm_dev_printk-0x4
   10ed2:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10ed7:	e9 3f f9 ff ff       	jmp    1081b <mtgpu_dispc_component_bind+0x37b>
   10edc:	4d 89 fb             	mov    %r15,%r11
   10edf:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
   10ee4:	45 89 ee             	mov    %r13d,%r14d
   10ee7:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10eed:	e9 07 fd ff ff       	jmp    10bf9 <mtgpu_dispc_component_bind+0x759>
   10ef2:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10ef5: R_X86_64_32S	.rodata.str1.8+0xdc0
   10ef9:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10efc: R_X86_64_32S	.rodata.str1.1+0x448
   10f00:	4c 89 e7             	mov    %r12,%rdi
   10f03:	e8 00 00 00 00       	call   10f08 <mtgpu_dispc_component_bind+0xa68>
			10f04: R_X86_64_PLT32	drm_dev_printk-0x4
   10f08:	e9 47 f8 ff ff       	jmp    10754 <mtgpu_dispc_component_bind+0x2b4>
   10f0d:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10f10: R_X86_64_32S	.rodata.str1.1+0x478
   10f14:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10f17: R_X86_64_32S	.rodata.str1.1+0x448
   10f1b:	4c 89 e7             	mov    %r12,%rdi
   10f1e:	e8 00 00 00 00       	call   10f23 <mtgpu_dispc_component_bind+0xa83>
			10f1f: R_X86_64_PLT32	drm_dev_printk-0x4
   10f23:	e9 2c f8 ff ff       	jmp    10754 <mtgpu_dispc_component_bind+0x2b4>
   10f28:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10f2b: R_X86_64_32S	.rodata.str1.8+0xd98
   10f2f:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10f32: R_X86_64_32S	.rodata.str1.1+0x448
   10f36:	4c 89 e7             	mov    %r12,%rdi
   10f39:	e8 00 00 00 00       	call   10f3e <mtgpu_dispc_component_bind+0xa9e>
			10f3a: R_X86_64_PLT32	drm_dev_printk-0x4
   10f3e:	e9 11 f8 ff ff       	jmp    10754 <mtgpu_dispc_component_bind+0x2b4>
   10f43:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10f49:	e9 40 f8 ff ff       	jmp    1078e <mtgpu_dispc_component_bind+0x2ee>
   10f4e:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10f53:	e9 08 fc ff ff       	jmp    10b60 <mtgpu_dispc_component_bind+0x6c0>
   10f58:	41 bf ed ff ff ff    	mov    $0xffffffed,%r15d
   10f5e:	e9 dc fb ff ff       	jmp    10b3f <mtgpu_dispc_component_bind+0x69f>
   10f63:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10f69:	e9 d1 fb ff ff       	jmp    10b3f <mtgpu_dispc_component_bind+0x69f>

Disassembly of section .text.unlikely:

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
