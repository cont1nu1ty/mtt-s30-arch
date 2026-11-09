
builds/runtime-fix3-v2-7.2.11-20261029/source/mtgpu.ko:     file format elf64-x86-64


Disassembly of section .text:

00000000000104e0 <mtgpu_dispc_component_bind>:
   104e0:	f3 0f 1e fa          	endbr64
   104e4:	e8 00 00 00 00       	call   104e9 <mtgpu_dispc_component_bind+0x9>
			104e5: R_X86_64_PLT32	__fentry__-0x4
   104e9:	48 83 ec 50          	sub    $0x50,%rsp
   104ed:	be c0 0d 00 00       	mov    $0xdc0,%esi
   104f2:	4c 89 64 24 30       	mov    %r12,0x30(%rsp)
   104f7:	49 89 fc             	mov    %rdi,%r12
   104fa:	4c 89 7c 24 48       	mov    %r15,0x48(%rsp)
   104ff:	49 89 d7             	mov    %rdx,%r15
   10502:	4c 89 6c 24 38       	mov    %r13,0x38(%rsp)
   10507:	4c 8b 6f 70          	mov    0x70(%rdi),%r13
   1050b:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 10512 <mtgpu_dispc_component_bind+0x32>
			1050e: R_X86_64_PC32	kmalloc_caches+0x3c
   10512:	48 89 14 24          	mov    %rdx,(%rsp)
   10516:	ba e8 00 00 00       	mov    $0xe8,%edx
   1051b:	e8 00 00 00 00       	call   10520 <mtgpu_dispc_component_bind+0x40>
			1051c: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   10520:	48 85 c0             	test   %rax,%rax
   10523:	0f 84 5a 0a 00 00    	je     10f83 <mtgpu_dispc_component_bind+0xaa3>
   10529:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)
   1052e:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 10535 <mtgpu_dispc_component_bind+0x55>
			10531: R_X86_64_PC32	kmalloc_caches+0x54
   10535:	ba 50 04 00 00       	mov    $0x450,%edx
   1053a:	48 89 c3             	mov    %rax,%rbx
   1053d:	4c 89 b8 e0 00 00 00 	mov    %r15,0xe0(%rax)
   10544:	be c0 0d 00 00       	mov    $0xdc0,%esi
   10549:	e8 00 00 00 00       	call   1054e <mtgpu_dispc_component_bind+0x6e>
			1054a: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1054e:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
   10555:	48 85 c0             	test   %rax,%rax
   10558:	0f 84 0a 0a 00 00    	je     10f68 <mtgpu_dispc_component_bind+0xa88>
   1055e:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 10565 <mtgpu_dispc_component_bind+0x85>
			10561: R_X86_64_PC32	kmalloc_caches+0x2c
   10565:	ba 30 00 00 00       	mov    $0x30,%edx
   1056a:	be c0 0d 00 00       	mov    $0xdc0,%esi
   1056f:	e8 00 00 00 00       	call   10574 <mtgpu_dispc_component_bind+0x94>
			10570: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   10574:	48 89 43 50          	mov    %rax,0x50(%rbx)
   10578:	48 85 c0             	test   %rax,%rax
   1057b:	0f 84 cc 09 00 00    	je     10f4d <mtgpu_dispc_component_bind+0xa6d>
   10581:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 10588 <mtgpu_dispc_component_bind+0xa8>
			10584: R_X86_64_PC32	kmalloc_caches+0x24
   10588:	ba 18 00 00 00       	mov    $0x18,%edx
   1058d:	be c0 0d 00 00       	mov    $0xdc0,%esi
   10592:	e8 00 00 00 00       	call   10597 <mtgpu_dispc_component_bind+0xb7>
			10593: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   10597:	48 89 43 68          	mov    %rax,0x68(%rbx)
   1059b:	48 85 c0             	test   %rax,%rax
   1059e:	0f 84 8e 09 00 00    	je     10f32 <mtgpu_dispc_component_bind+0xa52>
   105a4:	48 89 6c 24 28       	mov    %rbp,0x28(%rsp)
   105a9:	49 8d 6c 24 f0       	lea    -0x10(%r12),%rbp
   105ae:	be 00 02 00 00       	mov    $0x200,%esi
   105b3:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			105b6: R_X86_64_32S	.rodata+0x379da
   105ba:	48 89 ef             	mov    %rbp,%rdi
   105bd:	e8 00 00 00 00       	call   105c2 <mtgpu_dispc_component_bind+0xe2>
			105be: R_X86_64_PLT32	platform_get_resource_byname-0x4
   105c2:	48 85 c0             	test   %rax,%rax
   105c5:	74 23                	je     105ea <mtgpu_dispc_component_bind+0x10a>
   105c7:	48 8b 50 08          	mov    0x8(%rax),%rdx
   105cb:	48 8b 30             	mov    (%rax),%rsi
   105ce:	4c 89 e7             	mov    %r12,%rdi
   105d1:	48 83 c2 01          	add    $0x1,%rdx
   105d5:	48 29 f2             	sub    %rsi,%rdx
   105d8:	e8 00 00 00 00       	call   105dd <mtgpu_dispc_component_bind+0xfd>
			105d9: R_X86_64_PLT32	devm_ioremap-0x4
   105dd:	48 89 43 08          	mov    %rax,0x8(%rbx)
   105e1:	48 85 c0             	test   %rax,%rax
   105e4:	0f 84 a5 01 00 00    	je     1078f <mtgpu_dispc_component_bind+0x2af>
   105ea:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			105ed: R_X86_64_32S	.rodata+0x379e5
   105f1:	be 00 02 00 00       	mov    $0x200,%esi
   105f6:	48 89 ef             	mov    %rbp,%rdi
   105f9:	e8 00 00 00 00       	call   105fe <mtgpu_dispc_component_bind+0x11e>
			105fa: R_X86_64_PLT32	platform_get_resource_byname-0x4
   105fe:	48 85 c0             	test   %rax,%rax
   10601:	74 23                	je     10626 <mtgpu_dispc_component_bind+0x146>
   10603:	48 8b 50 08          	mov    0x8(%rax),%rdx
   10607:	48 8b 30             	mov    (%rax),%rsi
   1060a:	4c 89 e7             	mov    %r12,%rdi
   1060d:	48 83 c2 01          	add    $0x1,%rdx
   10611:	48 29 f2             	sub    %rsi,%rdx
   10614:	e8 00 00 00 00       	call   10619 <mtgpu_dispc_component_bind+0x139>
			10615: R_X86_64_PLT32	devm_ioremap-0x4
   10619:	48 89 43 10          	mov    %rax,0x10(%rbx)
   1061d:	48 85 c0             	test   %rax,%rax
   10620:	0f 84 69 01 00 00    	je     1078f <mtgpu_dispc_component_bind+0x2af>
   10626:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10629: R_X86_64_32S	.rodata+0x379f4
   1062d:	be 00 02 00 00       	mov    $0x200,%esi
   10632:	48 89 ef             	mov    %rbp,%rdi
   10635:	e8 00 00 00 00       	call   1063a <mtgpu_dispc_component_bind+0x15a>
			10636: R_X86_64_PLT32	platform_get_resource_byname-0x4
   1063a:	48 85 c0             	test   %rax,%rax
   1063d:	74 23                	je     10662 <mtgpu_dispc_component_bind+0x182>
   1063f:	48 8b 50 08          	mov    0x8(%rax),%rdx
   10643:	48 8b 30             	mov    (%rax),%rsi
   10646:	4c 89 e7             	mov    %r12,%rdi
   10649:	48 83 c2 01          	add    $0x1,%rdx
   1064d:	48 29 f2             	sub    %rsi,%rdx
   10650:	e8 00 00 00 00       	call   10655 <mtgpu_dispc_component_bind+0x175>
			10651: R_X86_64_PLT32	devm_ioremap-0x4
   10655:	48 89 43 18          	mov    %rax,0x18(%rbx)
   10659:	48 85 c0             	test   %rax,%rax
   1065c:	0f 84 2d 01 00 00    	je     1078f <mtgpu_dispc_component_bind+0x2af>
   10662:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10665: R_X86_64_32S	.rodata+0x37a04
   10669:	be 00 02 00 00       	mov    $0x200,%esi
   1066e:	48 89 ef             	mov    %rbp,%rdi
   10671:	e8 00 00 00 00       	call   10676 <mtgpu_dispc_component_bind+0x196>
			10672: R_X86_64_PLT32	platform_get_resource_byname-0x4
   10676:	48 85 c0             	test   %rax,%rax
   10679:	74 23                	je     1069e <mtgpu_dispc_component_bind+0x1be>
   1067b:	48 8b 50 08          	mov    0x8(%rax),%rdx
   1067f:	48 8b 30             	mov    (%rax),%rsi
   10682:	4c 89 e7             	mov    %r12,%rdi
   10685:	48 83 c2 01          	add    $0x1,%rdx
   10689:	48 29 f2             	sub    %rsi,%rdx
   1068c:	e8 00 00 00 00       	call   10691 <mtgpu_dispc_component_bind+0x1b1>
			1068d: R_X86_64_PLT32	devm_ioremap-0x4
   10691:	48 89 43 20          	mov    %rax,0x20(%rbx)
   10695:	48 85 c0             	test   %rax,%rax
   10698:	0f 84 f1 00 00 00    	je     1078f <mtgpu_dispc_component_bind+0x2af>
   1069e:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			106a1: R_X86_64_32S	.rodata+0x37a13
   106a5:	be 00 02 00 00       	mov    $0x200,%esi
   106aa:	48 89 ef             	mov    %rbp,%rdi
   106ad:	e8 00 00 00 00       	call   106b2 <mtgpu_dispc_component_bind+0x1d2>
			106ae: R_X86_64_PLT32	platform_get_resource_byname-0x4
   106b2:	48 85 c0             	test   %rax,%rax
   106b5:	0f 84 2e 01 00 00    	je     107e9 <mtgpu_dispc_component_bind+0x309>
   106bb:	48 8b 50 08          	mov    0x8(%rax),%rdx
   106bf:	48 8b 30             	mov    (%rax),%rsi
   106c2:	4c 89 e7             	mov    %r12,%rdi
   106c5:	48 83 c2 01          	add    $0x1,%rdx
   106c9:	48 29 f2             	sub    %rsi,%rdx
   106cc:	e8 00 00 00 00       	call   106d1 <mtgpu_dispc_component_bind+0x1f1>
			106cd: R_X86_64_PLT32	devm_ioremap-0x4
   106d1:	48 89 43 28          	mov    %rax,0x28(%rbx)
   106d5:	48 85 c0             	test   %rax,%rax
   106d8:	0f 84 b1 00 00 00    	je     1078f <mtgpu_dispc_component_bind+0x2af>
   106de:	49 8b 45 10          	mov    0x10(%r13),%rax
   106e2:	31 d2                	xor    %edx,%edx
   106e4:	be 00 04 00 00       	mov    $0x400,%esi
   106e9:	48 89 ef             	mov    %rbp,%rdi
   106ec:	48 89 43 30          	mov    %rax,0x30(%rbx)
   106f0:	49 8b 45 18          	mov    0x18(%r13),%rax
   106f4:	89 43 38             	mov    %eax,0x38(%rbx)
   106f7:	49 8b 45 08          	mov    0x8(%r13),%rax
   106fb:	48 89 43 40          	mov    %rax,0x40(%rbx)
   106ff:	e8 00 00 00 00       	call   10704 <mtgpu_dispc_component_bind+0x224>
			10700: R_X86_64_PLT32	platform_get_resource-0x4
   10704:	48 85 c0             	test   %rax,%rax
   10707:	0f 84 37 03 00 00    	je     10a44 <mtgpu_dispc_component_bind+0x564>
   1070d:	48 8b 00             	mov    (%rax),%rax
   10710:	48 8b 7b 68          	mov    0x68(%rbx),%rdi
   10714:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10717: R_X86_64_32S	.bss+0xcc
   1071b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			1071e: R_X86_64_32S	.rodata+0x37a1c
   10722:	89 43 48             	mov    %eax,0x48(%rbx)
   10725:	41 0f b6 45 00       	movzbl 0x0(%r13),%eax
   1072a:	4c 89 a3 a0 00 00 00 	mov    %r12,0xa0(%rbx)
   10731:	89 43 4c             	mov    %eax,0x4c(%rbx)
   10734:	49 89 5c 24 78       	mov    %rbx,0x78(%r12)
   10739:	e8 00 00 00 00       	call   1073e <mtgpu_dispc_component_bind+0x25e>
			1073a: R_X86_64_PLT32	__init_waitqueue_head-0x4
   1073e:	41 0f b6 4d 20       	movzbl 0x20(%r13),%ecx
   10743:	80 f9 03             	cmp    $0x3,%cl
   10746:	0f 84 13 03 00 00    	je     10a5f <mtgpu_dispc_component_bind+0x57f>
   1074c:	0f 87 ba 00 00 00    	ja     1080c <mtgpu_dispc_component_bind+0x32c>
   10752:	80 f9 01             	cmp    $0x1,%cl
   10755:	0f 84 3d 03 00 00    	je     10a98 <mtgpu_dispc_component_bind+0x5b8>
   1075b:	80 f9 02             	cmp    $0x2,%cl
   1075e:	0f 85 0e 03 00 00    	jne    10a72 <mtgpu_dispc_component_bind+0x592>
   10764:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 1076b <mtgpu_dispc_component_bind+0x28b>
			10766: R_X86_64_PC32	fec_display_enable-0x5
   1076b:	0f 84 5e 04 00 00    	je     10bcf <mtgpu_dispc_component_bind+0x6ef>
   10771:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
			10774: R_X86_64_32S	mtgpu_dispc_fec
   10778:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			1077b: R_X86_64_32S	mtgpu_dispc_qy1
   1077f:	48 c7 05 00 00 00 00 	movq   $0x0,0x0(%rip)        # 1078a <mtgpu_dispc_component_bind+0x2aa>
   10786:	00 00 00 00 
			10782: R_X86_64_PC32	mtgpu_dispc_qy1-0x8
			10786: R_X86_64_32S	mtgpu_dispc_fec
   1078a:	e9 94 00 00 00       	jmp    10823 <mtgpu_dispc_component_bind+0x343>
   1078f:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10794:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   1079a:	49 c7 44 24 78 00 00 	movq   $0x0,0x78(%r12)
   107a1:	00 00 
   107a3:	48 8b 7b 68          	mov    0x68(%rbx),%rdi
   107a7:	e8 00 00 00 00       	call   107ac <mtgpu_dispc_component_bind+0x2cc>
			107a8: R_X86_64_PLT32	kfree-0x4
   107ac:	48 8b 7b 50          	mov    0x50(%rbx),%rdi
   107b0:	e8 00 00 00 00       	call   107b5 <mtgpu_dispc_component_bind+0x2d5>
			107b1: R_X86_64_PLT32	kfree-0x4
   107b5:	48 8b bb 98 00 00 00 	mov    0x98(%rbx),%rdi
   107bc:	e8 00 00 00 00       	call   107c1 <mtgpu_dispc_component_bind+0x2e1>
			107bd: R_X86_64_PLT32	kfree-0x4
   107c1:	48 89 df             	mov    %rbx,%rdi
   107c4:	e8 00 00 00 00       	call   107c9 <mtgpu_dispc_component_bind+0x2e9>
			107c5: R_X86_64_PLT32	kfree-0x4
   107c9:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
   107ce:	44 89 f8             	mov    %r15d,%eax
   107d1:	4c 8b 64 24 30       	mov    0x30(%rsp),%r12
   107d6:	4c 8b 6c 24 38       	mov    0x38(%rsp),%r13
   107db:	4c 8b 7c 24 48       	mov    0x48(%rsp),%r15
   107e0:	48 83 c4 50          	add    $0x50,%rsp
   107e4:	e9 00 00 00 00       	jmp    107e9 <mtgpu_dispc_component_bind+0x309>
			107e5: R_X86_64_PLT32	__x86_return_thunk-0x4
   107e9:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			107ec: R_X86_64_32S	.rodata+0x536e8
   107f0:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			107f3: R_X86_64_32S	.rodata+0x3798d
   107f7:	4c 89 e7             	mov    %r12,%rdi
   107fa:	e8 00 00 00 00       	call   107ff <mtgpu_dispc_component_bind+0x31f>
			107fb: R_X86_64_PLT32	drm_dev_printk-0x4
   107ff:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10804:	41 bf fb ff ff ff    	mov    $0xfffffffb,%r15d
   1080a:	eb 8e                	jmp    1079a <mtgpu_dispc_component_bind+0x2ba>
   1080c:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10813 <mtgpu_dispc_component_bind+0x333>
			1080f: R_X86_64_PC32	mtgpu_dispc_ph1-0x4
   10813:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10816: R_X86_64_32S	mtgpu_dispc_ph1
   1081a:	80 f9 04             	cmp    $0x4,%cl
   1081d:	0f 85 4f 02 00 00    	jne    10a72 <mtgpu_dispc_component_bind+0x592>
   10823:	48 89 83 88 00 00 00 	mov    %rax,0x88(%rbx)
   1082a:	48 85 c0             	test   %rax,%rax
   1082d:	0f 84 87 05 00 00    	je     10dba <mtgpu_dispc_component_bind+0x8da>
   10833:	48 8b 40 10          	mov    0x10(%rax),%rax
   10837:	48 85 c0             	test   %rax,%rax
   1083a:	74 14                	je     10850 <mtgpu_dispc_component_bind+0x370>
   1083c:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10840:	e8 00 00 00 00       	call   10845 <mtgpu_dispc_component_bind+0x365>
			10841: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10845:	41 89 c7             	mov    %eax,%r15d
   10848:	85 c0                	test   %eax,%eax
   1084a:	0f 85 ea 01 00 00    	jne    10a3a <mtgpu_dispc_component_bind+0x55a>
   10850:	41 80 7d 20 01       	cmpb   $0x1,0x20(%r13)
   10855:	0f 84 50 02 00 00    	je     10aab <mtgpu_dispc_component_bind+0x5cb>
   1085b:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
   10862:	48 8b 40 08          	mov    0x8(%rax),%rax
   10866:	48 85 c0             	test   %rax,%rax
   10869:	74 09                	je     10874 <mtgpu_dispc_component_bind+0x394>
   1086b:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   1086f:	e8 00 00 00 00       	call   10874 <mtgpu_dispc_component_bind+0x394>
			10870: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10874:	4c 8b 5d 08          	mov    0x8(%rbp),%r11
   10878:	4c 89 9b 90 00 00 00 	mov    %r11,0x90(%rbx)
   1087f:	4d 85 db             	test   %r11,%r11
   10882:	0f 84 58 05 00 00    	je     10de0 <mtgpu_dispc_component_bind+0x900>
   10888:	49 8b 03             	mov    (%r11),%rax
   1088b:	48 85 c0             	test   %rax,%rax
   1088e:	74 09                	je     10899 <mtgpu_dispc_component_bind+0x3b9>
   10890:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10894:	e8 00 00 00 00       	call   10899 <mtgpu_dispc_component_bind+0x3b9>
			10895: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10899:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
   108a0:	48 8b 40 68          	mov    0x68(%rax),%rax
   108a4:	48 85 c0             	test   %rax,%rax
   108a7:	0f 84 52 05 00 00    	je     10dff <mtgpu_dispc_component_bind+0x91f>
   108ad:	4c 89 74 24 40       	mov    %r14,0x40(%rsp)
   108b2:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   108b6:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
   108bd:	e8 00 00 00 00       	call   108c2 <mtgpu_dispc_component_bind+0x3e2>
			108be: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   108c2:	4c 8b b3 98 00 00 00 	mov    0x98(%rbx),%r14
   108c9:	41 0f b6 06          	movzbl (%r14),%eax
   108cd:	84 c0                	test   %al,%al
   108cf:	0f 84 0d 03 00 00    	je     10be2 <mtgpu_dispc_component_bind+0x702>
   108d5:	48 8d 3c c5 00 00 00 	lea    0x0(,%rax,8),%rdi
   108dc:	00 
   108dd:	be c0 0d 00 00       	mov    $0xdc0,%esi
   108e2:	e8 00 00 00 00       	call   108e7 <mtgpu_dispc_component_bind+0x407>
			108e3: R_X86_64_PLT32	__kmalloc_noprof-0x4
   108e7:	49 89 c3             	mov    %rax,%r11
   108ea:	48 85 c0             	test   %rax,%rax
   108ed:	0f 84 e4 05 00 00    	je     10ed7 <mtgpu_dispc_component_bind+0x9f7>
   108f3:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
   108fa:	80 38 00             	cmpb   $0x0,(%rax)
   108fd:	0f 84 a0 05 00 00    	je     10ea3 <mtgpu_dispc_component_bind+0x9c3>
   10903:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
   10908:	49 83 c6 0c          	add    $0xc,%r14
   1090c:	45 31 ed             	xor    %r13d,%r13d
   1090f:	4d 89 df             	mov    %r11,%r15
   10912:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
   10919:	00 00 
   1091b:	48 c7 44 24 10 00 00 	movq   $0x0,0x10(%rsp)
   10922:	00 00 
   10924:	eb 2e                	jmp    10954 <mtgpu_dispc_component_bind+0x474>
   10926:	41 80 7e fc 02       	cmpb   $0x2,-0x4(%r14)
   1092b:	48 0f 45 6c 24 08    	cmovne 0x8(%rsp),%rbp
   10931:	48 89 6c 24 08       	mov    %rbp,0x8(%rsp)
   10936:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
   1093d:	41 83 c5 01          	add    $0x1,%r13d
   10941:	49 81 c6 10 01 00 00 	add    $0x110,%r14
   10948:	0f b6 00             	movzbl (%rax),%eax
   1094b:	44 39 e8             	cmp    %r13d,%eax
   1094e:	0f 8e 2f 03 00 00    	jle    10c83 <mtgpu_dispc_component_bind+0x7a3>
   10954:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 1095b <mtgpu_dispc_component_bind+0x47b>
			10957: R_X86_64_PC32	kmalloc_caches+0x54
   1095b:	ba 48 05 00 00       	mov    $0x548,%edx
   10960:	be c0 0d 00 00       	mov    $0xdc0,%esi
   10965:	45 89 ec             	mov    %r13d,%r12d
   10968:	e8 00 00 00 00       	call   1096d <mtgpu_dispc_component_bind+0x48d>
			10969: R_X86_64_PLT32	__kmalloc_cache_noprof-0x4
   1096d:	48 89 c5             	mov    %rax,%rbp
   10970:	48 85 c0             	test   %rax,%rax
   10973:	0f 84 a3 05 00 00    	je     10f1c <mtgpu_dispc_component_bind+0xa3c>
   10979:	8b 4b 4c             	mov    0x4c(%rbx),%ecx
   1097c:	45 0f b6 4e fd       	movzbl -0x3(%r14),%r9d
   10981:	6a 00                	push   $0x0
   10983:	ba 01 00 00 00       	mov    $0x1,%edx
   10988:	41 0f be 46 fc       	movsbl -0x4(%r14),%eax
   1098d:	4d 89 f0             	mov    %r14,%r8
   10990:	48 89 ee             	mov    %rbp,%rsi
   10993:	d3 e2                	shl    %cl,%edx
   10995:	48 c7 c1 00 00 00 00 	mov    $0x0,%rcx
			10998: R_X86_64_32S	.rodata+0x27a0
   1099c:	50                   	push   %rax
   1099d:	49 8d 86 84 00 00 00 	lea    0x84(%r14),%rax
   109a4:	50                   	push   %rax
   109a5:	48 8b 7c 24 18       	mov    0x18(%rsp),%rdi
   109aa:	e8 00 00 00 00       	call   109af <mtgpu_dispc_component_bind+0x4cf>
			109ab: R_X86_64_PLT32	drm_universal_plane_init-0x4
   109af:	48 83 c4 18          	add    $0x18,%rsp
   109b3:	85 c0                	test   %eax,%eax
   109b5:	0f 85 4d 02 00 00    	jne    10c08 <mtgpu_dispc_component_bind+0x728>
   109bb:	44 89 e8             	mov    %r13d,%eax
   109be:	be 07 00 00 00       	mov    $0x7,%esi
   109c3:	48 89 ef             	mov    %rbp,%rdi
   109c6:	48 c7 85 c8 04 00 00 	movq   $0x0,0x4c8(%rbp)
   109cd:	00 00 00 00 
			109cd: R_X86_64_32S	.rodata+0x2820
   109d1:	49 89 2c c7          	mov    %rbp,(%r15,%rax,8)
   109d5:	e8 00 00 00 00       	call   109da <mtgpu_dispc_component_bind+0x4fa>
			109d6: R_X86_64_PLT32	drm_plane_create_blend_mode_property-0x4
   109da:	ba 01 00 00 00       	mov    $0x1,%edx
   109df:	be 01 00 00 00       	mov    $0x1,%esi
   109e4:	48 89 ef             	mov    %rbp,%rdi
   109e7:	e8 00 00 00 00       	call   109ec <mtgpu_dispc_component_bind+0x50c>
			109e8: R_X86_64_PLT32	drm_plane_create_rotation_property-0x4
   109ec:	48 89 ef             	mov    %rbp,%rdi
   109ef:	e8 00 00 00 00       	call   109f4 <mtgpu_dispc_component_bind+0x514>
			109f0: R_X86_64_PLT32	drm_plane_create_alpha_property-0x4
   109f4:	44 89 ee             	mov    %r13d,%esi
   109f7:	48 89 ef             	mov    %rbp,%rdi
   109fa:	e8 00 00 00 00       	call   109ff <mtgpu_dispc_component_bind+0x51f>
			109fb: R_X86_64_PLT32	drm_plane_create_zpos_immutable_property-0x4
   109ff:	41 8b b6 04 01 00 00 	mov    0x104(%r14),%esi
   10a06:	85 f6                	test   %esi,%esi
   10a08:	74 0b                	je     10a15 <mtgpu_dispc_component_bind+0x535>
   10a0a:	41 8b 96 08 01 00 00 	mov    0x108(%r14),%edx
   10a11:	85 d2                	test   %edx,%edx
   10a13:	75 13                	jne    10a28 <mtgpu_dispc_component_bind+0x548>
   10a15:	45 85 ed             	test   %r13d,%r13d
   10a18:	0f 85 08 ff ff ff    	jne    10926 <mtgpu_dispc_component_bind+0x446>
   10a1e:	48 89 6c 24 10       	mov    %rbp,0x10(%rsp)
   10a23:	e9 0e ff ff ff       	jmp    10936 <mtgpu_dispc_component_bind+0x456>
   10a28:	45 31 c0             	xor    %r8d,%r8d
   10a2b:	b9 01 00 00 00       	mov    $0x1,%ecx
   10a30:	48 89 ef             	mov    %rbp,%rdi
   10a33:	e8 00 00 00 00       	call   10a38 <mtgpu_dispc_component_bind+0x558>
			10a34: R_X86_64_PLT32	drm_plane_create_color_properties-0x4
   10a38:	eb db                	jmp    10a15 <mtgpu_dispc_component_bind+0x535>
   10a3a:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10a3f:	e9 56 fd ff ff       	jmp    1079a <mtgpu_dispc_component_bind+0x2ba>
   10a44:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10a47: R_X86_64_32S	.rodata+0x53710
   10a4b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10a4e: R_X86_64_32S	.rodata+0x3798d
   10a52:	4c 89 e7             	mov    %r12,%rdi
   10a55:	e8 00 00 00 00       	call   10a5a <mtgpu_dispc_component_bind+0x57a>
			10a56: R_X86_64_PLT32	drm_dev_printk-0x4
   10a5a:	e9 a0 fd ff ff       	jmp    107ff <mtgpu_dispc_component_bind+0x31f>
   10a5f:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10a66 <mtgpu_dispc_component_bind+0x586>
			10a62: R_X86_64_PC32	mtgpu_dispc_qy2-0x4
   10a66:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10a69: R_X86_64_32S	mtgpu_dispc_qy2
   10a6d:	e9 b1 fd ff ff       	jmp    10823 <mtgpu_dispc_component_bind+0x343>
   10a72:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10a75: R_X86_64_32S	.rodata+0x53740
   10a79:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10a7c: R_X86_64_32S	.rodata+0x3798d
   10a80:	4c 89 e7             	mov    %r12,%rdi
   10a83:	41 bf f4 fd ff ff    	mov    $0xfffffdf4,%r15d
   10a89:	e8 00 00 00 00       	call   10a8e <mtgpu_dispc_component_bind+0x5ae>
			10a8a: R_X86_64_PLT32	drm_dev_printk-0x4
   10a8e:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10a93:	e9 02 fd ff ff       	jmp    1079a <mtgpu_dispc_component_bind+0x2ba>
   10a98:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10a9f <mtgpu_dispc_component_bind+0x5bf>
			10a9b: R_X86_64_PC32	mtgpu_dispc_sudi-0x4
   10a9f:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10aa2: R_X86_64_32S	mtgpu_dispc_sudi
   10aa6:	e9 78 fd ff ff       	jmp    10823 <mtgpu_dispc_component_bind+0x343>
   10aab:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10ab0:	48 8b 40 40          	mov    0x40(%rax),%rax
   10ab4:	48 81 78 60 00 00 00 	cmpq   $0x0,0x60(%rax)
   10abb:	00 
			10ab8: R_X86_64_32S	pci_bus_type
   10abc:	0f 85 99 fd ff ff    	jne    1085b <mtgpu_dispc_component_bind+0x37b>
   10ac2:	66 81 b8 6c ff ff ff 	cmpw   $0x1ed5,-0x94(%rax)
   10ac9:	d5 1e 
   10acb:	0f 85 8a fd ff ff    	jne    1085b <mtgpu_dispc_component_bind+0x37b>
   10ad1:	66 81 b8 6e ff ff ff 	cmpw   $0x102,-0x92(%rax)
   10ad8:	02 01 
   10ada:	0f 85 7b fd ff ff    	jne    1085b <mtgpu_dispc_component_bind+0x37b>
   10ae0:	4c 89 74 24 40       	mov    %r14,0x40(%rsp)
   10ae5:	4c 8b 73 08          	mov    0x8(%rbx),%r14
   10ae9:	4d 85 f6             	test   %r14,%r14
   10aec:	0f 84 b1 04 00 00    	je     10fa3 <mtgpu_dispc_component_bind+0xac3>
   10af2:	41 8b 06             	mov    (%r14),%eax
   10af5:	83 f8 ff             	cmp    $0xffffffff,%eax
   10af8:	0f 84 9a 04 00 00    	je     10f98 <mtgpu_dispc_component_bind+0xab8>
   10afe:	31 c9                	xor    %ecx,%ecx
   10b00:	41 89 4e 1c          	mov    %ecx,0x1c(%r14)
   10b04:	41 8b 4e 1c          	mov    0x1c(%r14),%ecx
   10b08:	a8 01                	test   $0x1,%al
   10b0a:	0f 84 ec 03 00 00    	je     10efc <mtgpu_dispc_component_bind+0xa1c>
   10b10:	4d 8d 7e 18          	lea    0x18(%r14),%r15
   10b14:	b9 00 01 00 00       	mov    $0x100,%ecx
   10b19:	41 89 0f             	mov    %ecx,(%r15)
   10b1c:	41 8b 4e 18          	mov    0x18(%r14),%ecx
   10b20:	83 e0 fe             	and    $0xfffffffe,%eax
   10b23:	41 89 06             	mov    %eax,(%r14)
   10b26:	41 8b 06             	mov    (%r14),%eax
   10b29:	e8 00 00 00 00       	call   10b2e <mtgpu_dispc_component_bind+0x64e>
			10b2a: R_X86_64_PLT32	ktime_get-0x4
   10b2e:	4c 8d a8 00 65 cd 1d 	lea    0x1dcd6500(%rax),%r13
   10b35:	e8 00 00 00 00       	call   10b3a <mtgpu_dispc_component_bind+0x65a>
			10b36: R_X86_64_PLT32	__SCT__might_resched-0x4
   10b3a:	eb 24                	jmp    10b60 <mtgpu_dispc_component_bind+0x680>
   10b3c:	41 8b 07             	mov    (%r15),%eax
   10b3f:	89 c1                	mov    %eax,%ecx
   10b41:	f6 c4 01             	test   $0x1,%ah
   10b44:	0f 85 9d 03 00 00    	jne    10ee7 <mtgpu_dispc_component_bind+0xa07>
   10b4a:	ba 02 00 00 00       	mov    $0x2,%edx
   10b4f:	be e8 03 00 00       	mov    $0x3e8,%esi
   10b54:	bf fb 00 00 00       	mov    $0xfb,%edi
   10b59:	e8 00 00 00 00       	call   10b5e <mtgpu_dispc_component_bind+0x67e>
			10b5a: R_X86_64_PLT32	usleep_range_state-0x4
   10b5e:	f3 90                	pause
   10b60:	e8 00 00 00 00       	call   10b65 <mtgpu_dispc_component_bind+0x685>
			10b61: R_X86_64_PLT32	ktime_get-0x4
   10b65:	49 39 c5             	cmp    %rax,%r13
   10b68:	7d d2                	jge    10b3c <mtgpu_dispc_component_bind+0x65c>
   10b6a:	41 8b 46 18          	mov    0x18(%r14),%eax
   10b6e:	89 c1                	mov    %eax,%ecx
   10b70:	f6 c4 01             	test   $0x1,%ah
   10b73:	0f 85 6e 03 00 00    	jne    10ee7 <mtgpu_dispc_component_bind+0xa07>
   10b79:	41 bf 92 ff ff ff    	mov    $0xffffff92,%r15d
   10b7f:	44 89 f9             	mov    %r15d,%ecx
   10b82:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10b85: R_X86_64_32S	.rodata+0x53770
   10b89:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10b8c: R_X86_64_32S	.rodata+0x3798d
   10b90:	4c 89 e7             	mov    %r12,%rdi
   10b93:	e8 00 00 00 00       	call   10b98 <mtgpu_dispc_component_bind+0x6b8>
			10b94: R_X86_64_PLT32	drm_dev_printk-0x4
   10b98:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10b9d:	45 31 db             	xor    %r11d,%r11d
   10ba0:	4c 89 df             	mov    %r11,%rdi
   10ba3:	e8 00 00 00 00       	call   10ba8 <mtgpu_dispc_component_bind+0x6c8>
			10ba4: R_X86_64_PLT32	kfree-0x4
   10ba8:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
   10baf:	48 8b 40 18          	mov    0x18(%rax),%rax
   10bb3:	48 85 c0             	test   %rax,%rax
   10bb6:	0f 84 7e fe ff ff    	je     10a3a <mtgpu_dispc_component_bind+0x55a>
   10bbc:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
   10bc0:	e8 00 00 00 00       	call   10bc5 <mtgpu_dispc_component_bind+0x6e5>
			10bc1: R_X86_64_PLT32	__x86_indirect_thunk_rax-0x4
   10bc5:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10bca:	e9 cb fb ff ff       	jmp    1079a <mtgpu_dispc_component_bind+0x2ba>
   10bcf:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10bd6 <mtgpu_dispc_component_bind+0x6f6>
			10bd2: R_X86_64_PC32	mtgpu_dispc_qy1-0x4
   10bd6:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
			10bd9: R_X86_64_32S	mtgpu_dispc_qy1
   10bdd:	e9 41 fc ff ff       	jmp    10823 <mtgpu_dispc_component_bind+0x343>
   10be2:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10be5: R_X86_64_32S	.rodata+0x53808
   10be9:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10bec: R_X86_64_32S	.rodata+0x3798d
   10bf0:	4c 89 e7             	mov    %r12,%rdi
   10bf3:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10bf9:	e8 00 00 00 00       	call   10bfe <mtgpu_dispc_component_bind+0x71e>
			10bfa: R_X86_64_PLT32	drm_dev_printk-0x4
   10bfe:	45 31 db             	xor    %r11d,%r11d
   10c01:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10c06:	eb 98                	jmp    10ba0 <mtgpu_dispc_component_bind+0x6c0>
   10c08:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
   10c0d:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10c10: R_X86_64_32S	.rodata+0x53828
   10c14:	4c 89 3c 24          	mov    %r15,(%rsp)
   10c18:	41 89 c7             	mov    %eax,%r15d
   10c1b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10c1e: R_X86_64_32S	.rodata+0x3798d
   10c22:	45 89 ee             	mov    %r13d,%r14d
   10c25:	4c 89 e7             	mov    %r12,%rdi
   10c28:	e8 00 00 00 00       	call   10c2d <mtgpu_dispc_component_bind+0x74d>
			10c29: R_X86_64_PLT32	drm_dev_printk-0x4
   10c2d:	48 89 ef             	mov    %rbp,%rdi
   10c30:	e8 00 00 00 00       	call   10c35 <mtgpu_dispc_component_bind+0x755>
			10c31: R_X86_64_PLT32	kfree-0x4
   10c35:	4c 8b 1c 24          	mov    (%rsp),%r11
   10c39:	45 85 f6             	test   %r14d,%r14d
   10c3c:	0f 84 4c 03 00 00    	je     10f8e <mtgpu_dispc_component_bind+0xaae>
   10c42:	48 89 1c 24          	mov    %rbx,(%rsp)
   10c46:	41 8d 46 ff          	lea    -0x1(%r14),%eax
   10c4a:	4d 8d 6b f8          	lea    -0x8(%r11),%r13
   10c4e:	4d 89 de             	mov    %r11,%r14
   10c51:	49 8d 2c c3          	lea    (%r11,%rax,8),%rbp
   10c55:	48 8b 5d 00          	mov    0x0(%rbp),%rbx
   10c59:	48 83 ed 08          	sub    $0x8,%rbp
   10c5d:	48 89 df             	mov    %rbx,%rdi
   10c60:	e8 00 00 00 00       	call   10c65 <mtgpu_dispc_component_bind+0x785>
			10c61: R_X86_64_PLT32	drm_plane_cleanup-0x4
   10c65:	48 89 df             	mov    %rbx,%rdi
   10c68:	e8 00 00 00 00       	call   10c6d <mtgpu_dispc_component_bind+0x78d>
			10c69: R_X86_64_PLT32	kfree-0x4
   10c6d:	4c 39 ed             	cmp    %r13,%rbp
   10c70:	75 e3                	jne    10c55 <mtgpu_dispc_component_bind+0x775>
   10c72:	4d 89 f3             	mov    %r14,%r11
   10c75:	48 8b 1c 24          	mov    (%rsp),%rbx
   10c79:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10c7e:	e9 1d ff ff ff       	jmp    10ba0 <mtgpu_dispc_component_bind+0x6c0>
   10c83:	45 8d 74 24 01       	lea    0x1(%r12),%r14d
   10c88:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
   10c8d:	4c 89 7c 24 18       	mov    %r15,0x18(%rsp)
   10c92:	e8 00 00 00 00       	call   10c97 <mtgpu_dispc_component_bind+0x7b7>
			10c93: R_X86_64_PLT32	os_create_drm_crtc-0x4
   10c97:	4c 8b 5c 24 18       	mov    0x18(%rsp),%r11
   10c9c:	48 85 c0             	test   %rax,%rax
   10c9f:	48 89 03             	mov    %rax,(%rbx)
   10ca2:	48 89 c7             	mov    %rax,%rdi
   10ca5:	0f 84 d1 01 00 00    	je     10e7c <mtgpu_dispc_component_bind+0x99c>
   10cab:	48 89 de             	mov    %rbx,%rsi
   10cae:	4c 89 5c 24 18       	mov    %r11,0x18(%rsp)
   10cb3:	e8 00 00 00 00       	call   10cb8 <mtgpu_dispc_component_bind+0x7d8>
			10cb4: R_X86_64_PLT32	os_set_drm_crtc_drvdata-0x4
   10cb8:	48 8b 33             	mov    (%rbx),%rsi
   10cbb:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
   10cc0:	45 31 c9             	xor    %r9d,%r9d
   10cc3:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
   10cc8:	48 8b 3c 24          	mov    (%rsp),%rdi
   10ccc:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8
			10ccf: R_X86_64_32S	.rodata+0x2660
   10cd3:	e8 00 00 00 00       	call   10cd8 <mtgpu_dispc_component_bind+0x7f8>
			10cd4: R_X86_64_PLT32	drm_crtc_init_with_planes-0x4
   10cd8:	4c 8b 5c 24 18       	mov    0x18(%rsp),%r11
   10cdd:	85 c0                	test   %eax,%eax
   10cdf:	41 89 c7             	mov    %eax,%r15d
   10ce2:	4c 89 1c 24          	mov    %r11,(%rsp)
   10ce6:	0f 85 9b 01 00 00    	jne    10e87 <mtgpu_dispc_component_bind+0x9a7>
   10cec:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
   10cf3:	48 8b 3b             	mov    (%rbx),%rdi
   10cf6:	8b b0 48 04 00 00    	mov    0x448(%rax),%esi
   10cfc:	e8 00 00 00 00       	call   10d01 <mtgpu_dispc_component_bind+0x821>
			10cfd: R_X86_64_PLT32	drm_mode_crtc_set_gamma_size-0x4
   10d01:	48 8b 3b             	mov    (%rbx),%rdi
   10d04:	31 d2                	xor    %edx,%edx
   10d06:	31 f6                	xor    %esi,%esi
   10d08:	48 8b 87 a0 01 00 00 	mov    0x1a0(%rdi),%rax
   10d0f:	48 89 43 78          	mov    %rax,0x78(%rbx)
   10d13:	8b 8f 98 01 00 00    	mov    0x198(%rdi),%ecx
   10d19:	89 8b 80 00 00 00    	mov    %ecx,0x80(%rbx)
   10d1f:	e8 00 00 00 00       	call   10d24 <mtgpu_dispc_component_bind+0x844>
			10d20: R_X86_64_PLT32	drm_crtc_enable_color_mgmt-0x4
   10d24:	48 8b 03             	mov    (%rbx),%rax
   10d27:	48 89 d9             	mov    %rbx,%rcx
   10d2a:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8
			10d2d: R_X86_64_32S	.rodata+0x37a7c
   10d31:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10d34: R_X86_64_32S	.text+0xf540
   10d38:	48 c7 80 a8 01 00 00 	movq   $0x0,0x1a8(%rax)
   10d3f:	00 00 00 00 
			10d3f: R_X86_64_32S	.rodata+0x2720
   10d43:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10d48:	8b 73 48             	mov    0x48(%rbx),%esi
   10d4b:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10d4f:	e8 00 00 00 00       	call   10d54 <mtgpu_dispc_component_bind+0x874>
			10d50: R_X86_64_PLT32	mtgpu_register_interrupt-0x4
   10d54:	4c 8b 1c 24          	mov    (%rsp),%r11
   10d58:	85 c0                	test   %eax,%eax
   10d5a:	41 89 c7             	mov    %eax,%r15d
   10d5d:	0f 85 f4 00 00 00    	jne    10e57 <mtgpu_dispc_component_bind+0x977>
   10d63:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10d68:	8b 73 48             	mov    0x48(%rbx),%esi
   10d6b:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10d6f:	e8 00 00 00 00       	call   10d74 <mtgpu_dispc_component_bind+0x894>
			10d70: R_X86_64_PLT32	mtgpu_enable_interrupt-0x4
   10d74:	41 89 c7             	mov    %eax,%r15d
   10d77:	85 c0                	test   %eax,%eax
   10d79:	0f 85 a4 00 00 00    	jne    10e23 <mtgpu_dispc_component_bind+0x943>
   10d7f:	48 89 df             	mov    %rbx,%rdi
   10d82:	e8 00 00 00 00       	call   10d87 <mtgpu_dispc_component_bind+0x8a7>
			10d83: R_X86_64_PLT32	mtgpu_dispc_debugfs_create_files-0x4
   10d87:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10d8a: R_X86_64_32S	.rodata+0x53848
   10d8e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10d91: R_X86_64_32S	.rodata+0x37990
   10d95:	4c 89 e7             	mov    %r12,%rdi
   10d98:	e8 00 00 00 00       	call   10d9d <mtgpu_dispc_component_bind+0x8bd>
			10d99: R_X86_64_PLT32	drm_dev_printk-0x4
   10d9d:	48 8b 3c 24          	mov    (%rsp),%rdi
   10da1:	e8 00 00 00 00       	call   10da6 <mtgpu_dispc_component_bind+0x8c6>
			10da2: R_X86_64_PLT32	kfree-0x4
   10da6:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
   10dab:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10db0:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10db5:	e9 14 fa ff ff       	jmp    107ce <mtgpu_dispc_component_bind+0x2ee>
   10dba:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10dbd: R_X86_64_32S	.rodata+0x37a2d
   10dc1:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10dc4: R_X86_64_32S	.rodata+0x3798d
   10dc8:	4c 89 e7             	mov    %r12,%rdi
   10dcb:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10dd1:	e8 00 00 00 00       	call   10dd6 <mtgpu_dispc_component_bind+0x8f6>
			10dd2: R_X86_64_PLT32	drm_dev_printk-0x4
   10dd6:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
   10ddb:	e9 ba f9 ff ff       	jmp    1079a <mtgpu_dispc_component_bind+0x2ba>
   10de0:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			10de3: R_X86_64_32S	.rodata+0x37a48
   10de7:	4c 89 1c 24          	mov    %r11,(%rsp)
   10deb:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10df1:	e8 00 00 00 00       	call   10df6 <mtgpu_dispc_component_bind+0x916>
			10df2: R_X86_64_PLT32	__drm_err-0x4
   10df6:	4c 8b 1c 24          	mov    (%rsp),%r11
   10dfa:	e9 a1 fd ff ff       	jmp    10ba0 <mtgpu_dispc_component_bind+0x6c0>
   10dff:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10e02: R_X86_64_32S	.rodata+0x537d8
   10e06:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10e09: R_X86_64_32S	.rodata+0x3798d
   10e0d:	4c 89 e7             	mov    %r12,%rdi
   10e10:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10e16:	e8 00 00 00 00       	call   10e1b <mtgpu_dispc_component_bind+0x93b>
			10e17: R_X86_64_PLT32	drm_dev_printk-0x4
   10e1b:	45 31 db             	xor    %r11d,%r11d
   10e1e:	e9 7d fd ff ff       	jmp    10ba0 <mtgpu_dispc_component_bind+0x6c0>
   10e23:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10e28:	8b 73 48             	mov    0x48(%rbx),%esi
   10e2b:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10e2f:	e8 00 00 00 00       	call   10e34 <mtgpu_dispc_component_bind+0x954>
			10e30: R_X86_64_PLT32	mtgpu_disable_interrupt-0x4
   10e34:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10e39:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10e3d:	e8 00 00 00 00       	call   10e42 <mtgpu_dispc_component_bind+0x962>
			10e3e: R_X86_64_PLT32	mtgpu_drm_sync_irqs-0x4
   10e42:	49 8b 44 24 40       	mov    0x40(%r12),%rax
   10e47:	8b 73 48             	mov    0x48(%rbx),%esi
   10e4a:	48 8b 78 40          	mov    0x40(%rax),%rdi
   10e4e:	e8 00 00 00 00       	call   10e53 <mtgpu_dispc_component_bind+0x973>
			10e4f: R_X86_64_PLT32	mtgpu_unregister_interrupt-0x4
   10e53:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e57:	48 8b 3b             	mov    (%rbx),%rdi
   10e5a:	4c 89 1c 24          	mov    %r11,(%rsp)
   10e5e:	e8 00 00 00 00       	call   10e63 <mtgpu_dispc_component_bind+0x983>
			10e5f: R_X86_64_PLT32	drm_crtc_cleanup-0x4
   10e63:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e67:	48 8b 3b             	mov    (%rbx),%rdi
   10e6a:	4c 89 1c 24          	mov    %r11,(%rsp)
   10e6e:	e8 00 00 00 00       	call   10e73 <mtgpu_dispc_component_bind+0x993>
			10e6f: R_X86_64_PLT32	os_destroy_drm_crtc-0x4
   10e73:	4c 8b 1c 24          	mov    (%rsp),%r11
   10e77:	e9 bd fd ff ff       	jmp    10c39 <mtgpu_dispc_component_bind+0x759>
   10e7c:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10e82:	e9 b2 fd ff ff       	jmp    10c39 <mtgpu_dispc_component_bind+0x759>
   10e87:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10e8a: R_X86_64_32S	.rodata+0x37a5f
   10e8e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10e91: R_X86_64_32S	.rodata+0x3798d
   10e95:	4c 89 e7             	mov    %r12,%rdi
   10e98:	e8 00 00 00 00       	call   10e9d <mtgpu_dispc_component_bind+0x9bd>
			10e99: R_X86_64_PLT32	drm_dev_printk-0x4
   10e9d:	4c 8b 1c 24          	mov    (%rsp),%r11
   10ea1:	eb c4                	jmp    10e67 <mtgpu_dispc_component_bind+0x987>
   10ea3:	4c 89 5c 24 08       	mov    %r11,0x8(%rsp)
   10ea8:	e8 00 00 00 00       	call   10ead <mtgpu_dispc_component_bind+0x9cd>
			10ea9: R_X86_64_PLT32	os_create_drm_crtc-0x4
   10ead:	4c 8b 5c 24 08       	mov    0x8(%rsp),%r11
   10eb2:	48 85 c0             	test   %rax,%rax
   10eb5:	48 89 03             	mov    %rax,(%rbx)
   10eb8:	48 89 c7             	mov    %rax,%rdi
   10ebb:	74 1a                	je     10ed7 <mtgpu_dispc_component_bind+0x9f7>
   10ebd:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
   10ec4:	00 00 
   10ec6:	45 31 f6             	xor    %r14d,%r14d
   10ec9:	48 c7 44 24 10 00 00 	movq   $0x0,0x10(%rsp)
   10ed0:	00 00 
   10ed2:	e9 d4 fd ff ff       	jmp    10cab <mtgpu_dispc_component_bind+0x7cb>
   10ed7:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10edc:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10ee2:	e9 b9 fc ff ff       	jmp    10ba0 <mtgpu_dispc_component_bind+0x6c0>
   10ee7:	83 c1 01             	add    $0x1,%ecx
   10eea:	0f 84 a8 00 00 00    	je     10f98 <mtgpu_dispc_component_bind+0xab8>
   10ef0:	b8 00 01 00 00       	mov    $0x100,%eax
   10ef5:	41 89 07             	mov    %eax,(%r15)
   10ef8:	41 8b 46 18          	mov    0x18(%r14),%eax
   10efc:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10eff: R_X86_64_32S	.rodata+0x537a0
   10f03:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10f06: R_X86_64_32S	.rodata+0x37990
   10f0a:	4c 89 e7             	mov    %r12,%rdi
   10f0d:	e8 00 00 00 00       	call   10f12 <mtgpu_dispc_component_bind+0xa32>
			10f0e: R_X86_64_PLT32	drm_dev_printk-0x4
   10f12:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10f17:	e9 3f f9 ff ff       	jmp    1085b <mtgpu_dispc_component_bind+0x37b>
   10f1c:	4d 89 fb             	mov    %r15,%r11
   10f1f:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
   10f24:	45 89 ee             	mov    %r13d,%r14d
   10f27:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10f2d:	e9 07 fd ff ff       	jmp    10c39 <mtgpu_dispc_component_bind+0x759>
   10f32:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10f35: R_X86_64_32S	.rodata+0x536c8
   10f39:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10f3c: R_X86_64_32S	.rodata+0x3798d
   10f40:	4c 89 e7             	mov    %r12,%rdi
   10f43:	e8 00 00 00 00       	call   10f48 <mtgpu_dispc_component_bind+0xa68>
			10f44: R_X86_64_PLT32	drm_dev_printk-0x4
   10f48:	e9 47 f8 ff ff       	jmp    10794 <mtgpu_dispc_component_bind+0x2b4>
   10f4d:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10f50: R_X86_64_32S	.rodata+0x379bd
   10f54:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10f57: R_X86_64_32S	.rodata+0x3798d
   10f5b:	4c 89 e7             	mov    %r12,%rdi
   10f5e:	e8 00 00 00 00       	call   10f63 <mtgpu_dispc_component_bind+0xa83>
			10f5f: R_X86_64_PLT32	drm_dev_printk-0x4
   10f63:	e9 2c f8 ff ff       	jmp    10794 <mtgpu_dispc_component_bind+0x2b4>
   10f68:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			10f6b: R_X86_64_32S	.rodata+0x536a0
   10f6f:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			10f72: R_X86_64_32S	.rodata+0x3798d
   10f76:	4c 89 e7             	mov    %r12,%rdi
   10f79:	e8 00 00 00 00       	call   10f7e <mtgpu_dispc_component_bind+0xa9e>
			10f7a: R_X86_64_PLT32	drm_dev_printk-0x4
   10f7e:	e9 11 f8 ff ff       	jmp    10794 <mtgpu_dispc_component_bind+0x2b4>
   10f83:	41 bf f4 ff ff ff    	mov    $0xfffffff4,%r15d
   10f89:	e9 40 f8 ff ff       	jmp    107ce <mtgpu_dispc_component_bind+0x2ee>
   10f8e:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
   10f93:	e9 08 fc ff ff       	jmp    10ba0 <mtgpu_dispc_component_bind+0x6c0>
   10f98:	41 bf ed ff ff ff    	mov    $0xffffffed,%r15d
   10f9e:	e9 dc fb ff ff       	jmp    10b7f <mtgpu_dispc_component_bind+0x69f>
   10fa3:	41 bf ea ff ff ff    	mov    $0xffffffea,%r15d
   10fa9:	e9 d1 fb ff ff       	jmp    10b7f <mtgpu_dispc_component_bind+0x69f>

Disassembly of section .init.text:

Disassembly of section .exit.text:

Disassembly of section .altinstr_replacement:

Disassembly of section .altinstr_aux:

Disassembly of section .static_call.text:
