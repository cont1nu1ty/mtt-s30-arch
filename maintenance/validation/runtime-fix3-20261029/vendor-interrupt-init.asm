
work/mtgpu-3.1.0/objs/x86_64/mtgpu_core.o_binary:     file format elf64-x86-64


Disassembly of section .text:

0000000000096fd0 <mtgpu_interrupt_init>:
   96fd0:	f3 0f 1e fa          	endbr64
   96fd4:	e8 00 00 00 00       	call   96fd9 <mtgpu_interrupt_init+0x9>
			96fd5: R_X86_64_PLT32	__fentry__-0x4
   96fd9:	55                   	push   %rbp
   96fda:	48 89 e5             	mov    %rsp,%rbp
   96fdd:	41 57                	push   %r15
   96fdf:	41 56                	push   %r14
   96fe1:	41 55                	push   %r13
   96fe3:	49 89 fd             	mov    %rdi,%r13
   96fe6:	bf 48 00 00 00       	mov    $0x48,%edi
   96feb:	41 54                	push   %r12
   96fed:	53                   	push   %rbx
   96fee:	48 83 ec 30          	sub    $0x30,%rsp
   96ff2:	e8 00 00 00 00       	call   96ff7 <mtgpu_interrupt_init+0x27>
			96ff3: R_X86_64_PLT32	os_kzalloc-0x4
   96ff7:	48 85 c0             	test   %rax,%rax
   96ffa:	74 58                	je     97054 <mtgpu_interrupt_init+0x84>
   96ffc:	48 8d 78 28          	lea    0x28(%rax),%rdi
   97000:	49 89 c4             	mov    %rax,%r12
   97003:	e8 00 00 00 00       	call   97008 <mtgpu_interrupt_init+0x38>
			97004: R_X86_64_PLT32	os_spin_lock_create-0x4
   97008:	85 c0                	test   %eax,%eax
   9700a:	74 24                	je     97030 <mtgpu_interrupt_init+0x60>
   9700c:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 97013 <mtgpu_interrupt_init+0x43>
			9700f: R_X86_64_PC32	os_value+0x504
   97013:	41 f7 de             	neg    %r14d
   97016:	4c 89 e7             	mov    %r12,%rdi
   97019:	e8 00 00 00 00       	call   9701e <mtgpu_interrupt_init+0x4e>
			9701a: R_X86_64_PLT32	os_kfree-0x4
   9701e:	48 83 c4 30          	add    $0x30,%rsp
   97022:	44 89 f0             	mov    %r14d,%eax
   97025:	5b                   	pop    %rbx
   97026:	41 5c                	pop    %r12
   97028:	41 5d                	pop    %r13
   9702a:	41 5e                	pop    %r14
   9702c:	41 5f                	pop    %r15
   9702e:	5d                   	pop    %rbp
   9702f:	c3                   	ret
   97030:	49 8d 7c 24 30       	lea    0x30(%r12),%rdi
   97035:	e8 00 00 00 00       	call   9703a <mtgpu_interrupt_init+0x6a>
			97036: R_X86_64_PLT32	os_spin_lock_create-0x4
   9703a:	85 c0                	test   %eax,%eax
   9703c:	74 22                	je     97060 <mtgpu_interrupt_init+0x90>
   9703e:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 97045 <mtgpu_interrupt_init+0x75>
			97041: R_X86_64_PC32	os_value+0x504
   97045:	41 f7 de             	neg    %r14d
   97048:	49 8b 7c 24 28       	mov    0x28(%r12),%rdi
   9704d:	e8 00 00 00 00       	call   97052 <mtgpu_interrupt_init+0x82>
			9704e: R_X86_64_PLT32	os_spin_lock_destroy-0x4
   97052:	eb c2                	jmp    97016 <mtgpu_interrupt_init+0x46>
   97054:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 9705b <mtgpu_interrupt_init+0x8b>
			97057: R_X86_64_PC32	os_value+0x504
   9705b:	41 f7 de             	neg    %r14d
   9705e:	eb be                	jmp    9701e <mtgpu_interrupt_init+0x4e>
   97060:	41 c7 44 24 08 62 00 	movl   $0x62,0x8(%r12)
   97067:	00 00 
   97069:	bf 10 03 00 00       	mov    $0x310,%edi
   9706e:	e8 00 00 00 00       	call   97073 <mtgpu_interrupt_init+0xa3>
			9706f: R_X86_64_PLT32	os_kzalloc-0x4
   97073:	49 89 44 24 18       	mov    %rax,0x18(%r12)
   97078:	48 85 c0             	test   %rax,%rax
   9707b:	0f 84 f3 00 00 00    	je     97174 <mtgpu_interrupt_init+0x1a4>
   97081:	41 8b 7c 24 08       	mov    0x8(%r12),%edi
   97086:	48 c1 e7 04          	shl    $0x4,%rdi
   9708a:	e8 00 00 00 00       	call   9708f <mtgpu_interrupt_init+0xbf>
			9708b: R_X86_64_PLT32	os_kzalloc-0x4
   9708f:	49 89 44 24 10       	mov    %rax,0x10(%r12)
   97094:	48 85 c0             	test   %rax,%rax
   97097:	0f 84 d7 02 00 00    	je     97374 <mtgpu_interrupt_init+0x3a4>
   9709d:	49 8b 45 00          	mov    0x0(%r13),%rax
   970a1:	4d 89 a5 80 06 00 00 	mov    %r12,0x680(%r13)
   970a8:	48 89 c7             	mov    %rax,%rdi
   970ab:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
   970af:	e8 00 00 00 00       	call   970b4 <mtgpu_interrupt_init+0xe4>
			970b0: R_X86_64_PLT32	os_to_pci_dev-0x4
   970b4:	49 8b 9d 80 06 00 00 	mov    0x680(%r13),%rbx
   970bb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   970bf:	8b 73 04             	mov    0x4(%rbx),%esi
   970c2:	85 f6                	test   %esi,%esi
   970c4:	0f 84 c3 00 00 00    	je     9718d <mtgpu_interrupt_init+0x1bd>
   970ca:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 970d1 <mtgpu_interrupt_init+0x101>
			970cd: R_X86_64_PC32	os_value+0x524
   970d1:	41 f7 de             	neg    %r14d
   970d4:	45 85 f6             	test   %r14d,%r14d
   970d7:	0f 85 7e 02 00 00    	jne    9735b <mtgpu_interrupt_init+0x38b>
   970dd:	e8 00 00 00 00       	call   970e2 <mtgpu_interrupt_init+0x112>
			970de: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   970e2:	83 f8 01             	cmp    $0x1,%eax
   970e5:	74 1a                	je     97101 <mtgpu_interrupt_init+0x131>
   970e7:	49 8b 85 f0 05 00 00 	mov    0x5f0(%r13),%rax
   970ee:	4c 89 ef             	mov    %r13,%rdi
   970f1:	48 8b 00             	mov    (%rax),%rax
   970f4:	ff d0                	call   *%rax
   970f6:	41 89 c6             	mov    %eax,%r14d
   970f9:	85 c0                	test   %eax,%eax
   970fb:	0f 85 21 05 00 00    	jne    97622 <mtgpu_interrupt_init+0x652>
   97101:	49 8b 7d 00          	mov    0x0(%r13),%rdi
   97105:	e8 00 00 00 00       	call   9710a <mtgpu_interrupt_init+0x13a>
			97106: R_X86_64_PLT32	os_to_pci_dev-0x4
   9710a:	48 89 c7             	mov    %rax,%rdi
   9710d:	e8 00 00 00 00       	call   97112 <mtgpu_interrupt_init+0x142>
			9710e: R_X86_64_PLT32	os_get_pci_device_id-0x4
   97112:	30 c0                	xor    %al,%al
   97114:	66 3d 00 04          	cmp    $0x400,%ax
   97118:	74 52                	je     9716c <mtgpu_interrupt_init+0x19c>
   9711a:	e8 00 00 00 00       	call   9711f <mtgpu_interrupt_init+0x14f>
			9711b: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   9711f:	83 f8 01             	cmp    $0x1,%eax
   97122:	74 48                	je     9716c <mtgpu_interrupt_init+0x19c>
   97124:	e8 00 00 00 00       	call   97129 <mtgpu_interrupt_init+0x159>
			97125: R_X86_64_PLT32	os_create_timer_list-0x4
   97129:	4c 89 ee             	mov    %r13,%rsi
   9712c:	49 89 44 24 38       	mov    %rax,0x38(%r12)
   97131:	48 89 c7             	mov    %rax,%rdi
   97134:	e8 00 00 00 00       	call   97139 <mtgpu_interrupt_init+0x169>
			97135: R_X86_64_PLT32	os_set_timer_list_drvdata-0x4
   97139:	49 8b 7c 24 38       	mov    0x38(%r12),%rdi
   9713e:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			97141: R_X86_64_32S	.text+0x968f0
   97145:	31 d2                	xor    %edx,%edx
   97147:	e8 00 00 00 00       	call   9714c <mtgpu_interrupt_init+0x17c>
			97148: R_X86_64_PLT32	os_timer_setup-0x4
   9714c:	e8 00 00 00 00       	call   97151 <mtgpu_interrupt_init+0x181>
			9714d: R_X86_64_PLT32	os_get_jiffies-0x4
   97151:	bf a0 0f 00 00       	mov    $0xfa0,%edi
   97156:	48 89 c3             	mov    %rax,%rbx
   97159:	e8 00 00 00 00       	call   9715e <mtgpu_interrupt_init+0x18e>
			9715a: R_X86_64_PLT32	os_msecs_to_jiffies-0x4
   9715e:	49 8b 7c 24 38       	mov    0x38(%r12),%rdi
   97163:	48 8d 34 03          	lea    (%rbx,%rax,1),%rsi
   97167:	e8 00 00 00 00       	call   9716c <mtgpu_interrupt_init+0x19c>
			97168: R_X86_64_PLT32	os_mod_timer-0x4
   9716c:	45 31 f6             	xor    %r14d,%r14d
   9716f:	e9 aa fe ff ff       	jmp    9701e <mtgpu_interrupt_init+0x4e>
   97174:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 9717b <mtgpu_interrupt_init+0x1ab>
			97177: R_X86_64_PC32	os_value+0x504
   9717b:	41 f7 de             	neg    %r14d
   9717e:	49 8b 7c 24 30       	mov    0x30(%r12),%rdi
   97183:	e8 00 00 00 00       	call   97188 <mtgpu_interrupt_init+0x1b8>
			97184: R_X86_64_PLT32	os_spin_lock_destroy-0x4
   97188:	e9 bb fe ff ff       	jmp    97048 <mtgpu_interrupt_init+0x78>
   9718d:	49 8b 7d 00          	mov    0x0(%r13),%rdi
   97191:	e8 00 00 00 00       	call   97196 <mtgpu_interrupt_init+0x1c6>
			97192: R_X86_64_PLT32	os_dev_is_pci-0x4
   97196:	84 c0                	test   %al,%al
   97198:	0f 84 e2 01 00 00    	je     97380 <mtgpu_interrupt_init+0x3b0>
   9719e:	49 8b 7d 00          	mov    0x0(%r13),%rdi
   971a2:	e8 00 00 00 00       	call   971a7 <mtgpu_interrupt_init+0x1d7>
			971a3: R_X86_64_PLT32	os_dev_to_node-0x4
   971a7:	4c 8b 7d c0          	mov    -0x40(%rbp),%r15
   971ab:	89 45 b8             	mov    %eax,-0x48(%rbp)
   971ae:	4c 89 ff             	mov    %r15,%rdi
   971b1:	e8 00 00 00 00       	call   971b6 <mtgpu_interrupt_init+0x1e6>
			971b2: R_X86_64_PLT32	os_pci_msix_vec_count-0x4
   971b6:	4c 89 ff             	mov    %r15,%rdi
   971b9:	89 45 bc             	mov    %eax,-0x44(%rbp)
   971bc:	41 89 c6             	mov    %eax,%r14d
   971bf:	e8 00 00 00 00       	call   971c4 <mtgpu_interrupt_init+0x1f4>
			971c0: R_X86_64_PLT32	os_pci_msi_vec_count-0x4
   971c4:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 971cb <mtgpu_interrupt_init+0x1fb>
			971c7: R_X86_64_PC32	os_value+0xc
   971cb:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 971d2 <mtgpu_interrupt_init+0x202>
			971ce: R_X86_64_PC32	os_value+0x4
   971d2:	41 89 c0             	mov    %eax,%r8d
   971d5:	45 85 f6             	test   %r14d,%r14d
   971d8:	0f 8e 8e 02 00 00    	jle    9746c <mtgpu_interrupt_init+0x49c>
   971de:	89 0b                	mov    %ecx,(%rbx)
   971e0:	89 c8                	mov    %ecx,%eax
   971e2:	45 31 f6             	xor    %r14d,%r14d
   971e5:	48 39 c8             	cmp    %rcx,%rax
   971e8:	0f 84 a1 03 00 00    	je     9758f <mtgpu_interrupt_init+0x5bf>
   971ee:	49 39 c7             	cmp    %rax,%r15
   971f1:	0f 84 d2 03 00 00    	je     975c9 <mtgpu_interrupt_init+0x5f9>
   971f7:	e8 00 00 00 00       	call   971fc <mtgpu_interrupt_init+0x22c>
			971f8: R_X86_64_PLT32	mtgpu_get_driver_mode-0x4
   971fc:	48 c7 c2 00 00 00 00 	mov    $0x0,%rdx
			971ff: R_X86_64_32S	.text+0x96620
   97203:	49 8b 7d 00          	mov    0x0(%r13),%rdi
   97207:	83 f8 01             	cmp    $0x1,%eax
   9720a:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
			9720d: R_X86_64_32S	.text+0x965c0
   97211:	48 0f 45 c2          	cmovne %rdx,%rax
   97215:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
   97219:	e8 00 00 00 00       	call   9721e <mtgpu_interrupt_init+0x24e>
			9721a: R_X86_64_PLT32	os_to_pci_dev-0x4
   9721e:	48 89 c7             	mov    %rax,%rdi
   97221:	e8 00 00 00 00       	call   97226 <mtgpu_interrupt_init+0x256>
			97222: R_X86_64_PLT32	os_get_pci_device_id-0x4
   97226:	30 c0                	xor    %al,%al
   97228:	66 3d 00 01          	cmp    $0x100,%ax
   9722c:	0f 84 4d 02 00 00    	je     9747f <mtgpu_interrupt_init+0x4af>
   97232:	45 85 f6             	test   %r14d,%r14d
   97235:	0f 8e 33 03 00 00    	jle    9756e <mtgpu_interrupt_init+0x59e>
   9723b:	8b 55 bc             	mov    -0x44(%rbp),%edx
   9723e:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
			97241: R_X86_64_32S	.rodata.str1.1+0x612c
   97245:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   97249:	48 c7 c1 00 00 00 00 	mov    $0x0,%rcx
			9724c: R_X86_64_32S	.rodata.str1.1+0x6128
   97250:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			97253: R_X86_64_32S	.rodata.str1.1+0x6156
   97257:	85 d2                	test   %edx,%edx
   97259:	44 89 f2             	mov    %r14d,%edx
   9725c:	48 0f 49 c8          	cmovns %rax,%rcx
   97260:	e8 00 00 00 00       	call   97265 <mtgpu_interrupt_init+0x295>
			97261: R_X86_64_PLT32	_os_dev_info-0x4
   97265:	44 89 73 04          	mov    %r14d,0x4(%rbx)
   97269:	49 63 fe             	movslq %r14d,%rdi
   9726c:	48 c1 e7 05          	shl    $0x5,%rdi
   97270:	e8 00 00 00 00       	call   97275 <mtgpu_interrupt_init+0x2a5>
			97271: R_X86_64_PLT32	os_kzalloc-0x4
   97275:	48 89 43 20          	mov    %rax,0x20(%rbx)
   97279:	48 85 c0             	test   %rax,%rax
   9727c:	0f 84 ad 03 00 00    	je     9762f <mtgpu_interrupt_init+0x65f>
   97282:	8b 43 04             	mov    0x4(%rbx),%eax
   97285:	45 31 ff             	xor    %r15d,%r15d
   97288:	85 c0                	test   %eax,%eax
   9728a:	75 1b                	jne    972a7 <mtgpu_interrupt_init+0x2d7>
   9728c:	e9 4c fe ff ff       	jmp    970dd <mtgpu_interrupt_init+0x10d>
   97291:	8b 75 b8             	mov    -0x48(%rbp),%esi
   97294:	41 83 c7 01          	add    $0x1,%r15d
   97298:	e8 83 f7 ff ff       	call   96a20 <mtgpu_irq_set_numa_affinity>
   9729d:	44 39 7b 04          	cmp    %r15d,0x4(%rbx)
   972a1:	0f 86 36 fe ff ff    	jbe    970dd <mtgpu_interrupt_init+0x10d>
   972a7:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   972ab:	44 89 fe             	mov    %r15d,%esi
   972ae:	e8 00 00 00 00       	call   972b3 <mtgpu_interrupt_init+0x2e3>
			972af: R_X86_64_PLT32	os_pci_irq_vector-0x4
   972b3:	4d 63 c7             	movslq %r15d,%r8
   972b6:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
   972ba:	31 d2                	xor    %edx,%edx
   972bc:	89 c7                	mov    %eax,%edi
   972be:	48 8b 43 20          	mov    0x20(%rbx),%rax
   972c2:	49 c1 e0 05          	shl    $0x5,%r8
   972c6:	48 c7 c1 00 00 00 00 	mov    $0x0,%rcx
			972c9: R_X86_64_32S	.rodata.str1.1+0x6150
   972cd:	89 7d bc             	mov    %edi,-0x44(%rbp)
   972d0:	46 89 3c 00          	mov    %r15d,(%rax,%r8,1)
   972d4:	48 8b 43 20          	mov    0x20(%rbx),%rax
   972d8:	42 89 7c 00 04       	mov    %edi,0x4(%rax,%r8,1)
   972dd:	48 8b 43 20          	mov    0x20(%rbx),%rax
   972e1:	4e 89 6c 00 18       	mov    %r13,0x18(%rax,%r8,1)
   972e6:	4c 03 43 20          	add    0x20(%rbx),%r8
   972ea:	e8 00 00 00 00       	call   972ef <mtgpu_interrupt_init+0x31f>
			972eb: R_X86_64_PLT32	os_request_irq-0x4
   972ef:	8b 7d bc             	mov    -0x44(%rbp),%edi
   972f2:	85 c0                	test   %eax,%eax
   972f4:	41 89 c6             	mov    %eax,%r14d
   972f7:	74 98                	je     97291 <mtgpu_interrupt_init+0x2c1>
   972f9:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   972fd:	44 89 fa             	mov    %r15d,%edx
   97300:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			97303: R_X86_64_32S	.rodata.str1.8+0x10378
   97307:	e8 00 00 00 00       	call   9730c <mtgpu_interrupt_init+0x33c>
			97308: R_X86_64_PLT32	_os_dev_err-0x4
   9730c:	41 8d 57 ff          	lea    -0x1(%r15),%edx
   97310:	4c 63 ea             	movslq %edx,%r13
   97313:	49 c1 e5 05          	shl    $0x5,%r13
   97317:	85 d2                	test   %edx,%edx
   97319:	78 2e                	js     97349 <mtgpu_interrupt_init+0x379>
   9731b:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
   9731f:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   97323:	89 d6                	mov    %edx,%esi
   97325:	89 55 bc             	mov    %edx,-0x44(%rbp)
   97328:	e8 00 00 00 00       	call   9732d <mtgpu_interrupt_init+0x35d>
			97329: R_X86_64_PLT32	os_pci_irq_vector-0x4
   9732d:	4d 01 ef             	add    %r13,%r15
   97330:	49 83 ed 20          	sub    $0x20,%r13
   97334:	89 c7                	mov    %eax,%edi
   97336:	4c 89 fe             	mov    %r15,%rsi
   97339:	e8 00 00 00 00       	call   9733e <mtgpu_interrupt_init+0x36e>
			9733a: R_X86_64_PLT32	os_free_irq-0x4
   9733e:	8b 55 bc             	mov    -0x44(%rbp),%edx
   97341:	83 ea 01             	sub    $0x1,%edx
   97344:	83 fa ff             	cmp    $0xffffffff,%edx
   97347:	75 d2                	jne    9731b <mtgpu_interrupt_init+0x34b>
   97349:	48 8b 7b 20          	mov    0x20(%rbx),%rdi
   9734d:	e8 00 00 00 00       	call   97352 <mtgpu_interrupt_init+0x382>
			9734e: R_X86_64_PLT32	os_kfree-0x4
   97352:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   97356:	e8 00 00 00 00       	call   9735b <mtgpu_interrupt_init+0x38b>
			97357: R_X86_64_PLT32	os_pci_free_irq_vectors-0x4
   9735b:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
   97360:	e8 00 00 00 00       	call   97365 <mtgpu_interrupt_init+0x395>
			97361: R_X86_64_PLT32	os_kfree-0x4
   97365:	49 8b 7c 24 18       	mov    0x18(%r12),%rdi
   9736a:	e8 00 00 00 00       	call   9736f <mtgpu_interrupt_init+0x39f>
			9736b: R_X86_64_PLT32	os_kfree-0x4
   9736f:	e9 0a fe ff ff       	jmp    9717e <mtgpu_interrupt_init+0x1ae>
   97374:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 9737b <mtgpu_interrupt_init+0x3ab>
			97377: R_X86_64_PC32	os_value+0x504
   9737b:	41 f7 de             	neg    %r14d
   9737e:	eb e5                	jmp    97365 <mtgpu_interrupt_init+0x395>
   97380:	49 8b 45 00          	mov    0x0(%r13),%rax
   97384:	4d 8b bd 80 06 00 00 	mov    0x680(%r13),%r15
   9738b:	48 89 c7             	mov    %rax,%rdi
   9738e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   97392:	e8 00 00 00 00       	call   97397 <mtgpu_interrupt_init+0x3c7>
			97393: R_X86_64_PLT32	os_to_platform_device-0x4
   97397:	48 89 c7             	mov    %rax,%rdi
   9739a:	e8 00 00 00 00       	call   9739f <mtgpu_interrupt_init+0x3cf>
			9739b: R_X86_64_PLT32	os_platform_irq_count-0x4
   9739f:	41 89 47 04          	mov    %eax,0x4(%r15)
   973a3:	89 c2                	mov    %eax,%edx
   973a5:	85 c0                	test   %eax,%eax
   973a7:	0f 84 46 02 00 00    	je     975f3 <mtgpu_interrupt_init+0x623>
   973ad:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   973b1:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			973b4: R_X86_64_32S	.rodata.str1.1+0x6132
   973b8:	e8 00 00 00 00       	call   973bd <mtgpu_interrupt_init+0x3ed>
			973b9: R_X86_64_PLT32	_os_dev_info-0x4
   973bd:	41 8b 7f 04          	mov    0x4(%r15),%edi
   973c1:	48 c1 e7 05          	shl    $0x5,%rdi
   973c5:	e8 00 00 00 00       	call   973ca <mtgpu_interrupt_init+0x3fa>
			973c6: R_X86_64_PLT32	os_kzalloc-0x4
   973ca:	49 89 47 20          	mov    %rax,0x20(%r15)
   973ce:	48 85 c0             	test   %rax,%rax
   973d1:	0f 84 f4 02 00 00    	je     976cb <mtgpu_interrupt_init+0x6fb>
   973d7:	41 8b 4f 04          	mov    0x4(%r15),%ecx
   973db:	31 db                	xor    %ebx,%ebx
   973dd:	85 c9                	test   %ecx,%ecx
   973df:	75 5a                	jne    9743b <mtgpu_interrupt_init+0x46b>
   973e1:	e9 f7 fc ff ff       	jmp    970dd <mtgpu_interrupt_init+0x10d>
   973e6:	49 8b 47 20          	mov    0x20(%r15),%rax
   973ea:	4c 63 c3             	movslq %ebx,%r8
   973ed:	44 89 f7             	mov    %r14d,%edi
   973f0:	31 d2                	xor    %edx,%edx
   973f2:	49 c1 e0 05          	shl    $0x5,%r8
   973f6:	48 c7 c1 00 00 00 00 	mov    $0x0,%rcx
			973f9: R_X86_64_32S	.rodata.str1.1+0x6150
   973fd:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			97400: R_X86_64_32S	.text+0x96620
   97404:	42 89 1c 00          	mov    %ebx,(%rax,%r8,1)
   97408:	49 8b 47 20          	mov    0x20(%r15),%rax
   9740c:	46 89 74 00 04       	mov    %r14d,0x4(%rax,%r8,1)
   97411:	49 8b 47 20          	mov    0x20(%r15),%rax
   97415:	4e 89 6c 00 18       	mov    %r13,0x18(%rax,%r8,1)
   9741a:	4d 03 47 20          	add    0x20(%r15),%r8
   9741e:	e8 00 00 00 00       	call   97423 <mtgpu_interrupt_init+0x453>
			9741f: R_X86_64_PLT32	os_request_irq-0x4
   97423:	41 89 c6             	mov    %eax,%r14d
   97426:	85 c0                	test   %eax,%eax
   97428:	0f 85 20 02 00 00    	jne    9764e <mtgpu_interrupt_init+0x67e>
   9742e:	83 c3 01             	add    $0x1,%ebx
   97431:	41 3b 5f 04          	cmp    0x4(%r15),%ebx
   97435:	0f 83 a2 fc ff ff    	jae    970dd <mtgpu_interrupt_init+0x10d>
   9743b:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   9743f:	e8 00 00 00 00       	call   97444 <mtgpu_interrupt_init+0x474>
			97440: R_X86_64_PLT32	os_to_platform_device-0x4
   97444:	89 de                	mov    %ebx,%esi
   97446:	48 89 c7             	mov    %rax,%rdi
   97449:	e8 00 00 00 00       	call   9744e <mtgpu_interrupt_init+0x47e>
			9744a: R_X86_64_PLT32	os_platform_get_irq-0x4
   9744e:	41 89 c6             	mov    %eax,%r14d
   97451:	85 c0                	test   %eax,%eax
   97453:	79 91                	jns    973e6 <mtgpu_interrupt_init+0x416>
   97455:	49 8b 7d 00          	mov    0x0(%r13),%rdi
   97459:	89 c2                	mov    %eax,%edx
   9745b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			9745e: R_X86_64_32S	.rodata.str1.8+0x10268
   97462:	e8 00 00 00 00       	call   97467 <mtgpu_interrupt_init+0x497>
			97463: R_X86_64_PLT32	_os_dev_err-0x4
   97467:	e9 ef fe ff ff       	jmp    9735b <mtgpu_interrupt_init+0x38b>
   9746c:	85 c0                	test   %eax,%eax
   9746e:	0f 8e 9e 01 00 00    	jle    97612 <mtgpu_interrupt_init+0x642>
   97474:	44 89 3b             	mov    %r15d,(%rbx)
   97477:	44 89 f8             	mov    %r15d,%eax
   9747a:	e9 63 fd ff ff       	jmp    971e2 <mtgpu_interrupt_init+0x212>
   9747f:	45 31 ff             	xor    %r15d,%r15d
   97482:	45 85 f6             	test   %r14d,%r14d
   97485:	7f 12                	jg     97499 <mtgpu_interrupt_init+0x4c9>
   97487:	e9 e2 00 00 00       	jmp    9756e <mtgpu_interrupt_init+0x59e>
   9748c:	41 83 c7 01          	add    $0x1,%r15d
   97490:	45 39 f7             	cmp    %r14d,%r15d
   97493:	0f 84 a2 fd ff ff    	je     9723b <mtgpu_interrupt_init+0x26b>
   97499:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   9749d:	44 89 fe             	mov    %r15d,%esi
   974a0:	e8 00 00 00 00       	call   974a5 <mtgpu_interrupt_init+0x4d5>
			974a1: R_X86_64_PLT32	os_pci_irq_vector-0x4
   974a5:	89 c7                	mov    %eax,%edi
   974a7:	e8 00 00 00 00       	call   974ac <mtgpu_interrupt_init+0x4dc>
			974a8: R_X86_64_PLT32	os_irq_get_msi_desc-0x4
   974ac:	48 8d 4d d4          	lea    -0x2c(%rbp),%rcx
   974b0:	48 8d 55 cc          	lea    -0x34(%rbp),%rdx
   974b4:	48 89 c7             	mov    %rax,%rdi
   974b7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
   974bb:	e8 00 00 00 00       	call   974c0 <mtgpu_interrupt_init+0x4f0>
			974bc: R_X86_64_PLT32	os_get_msi_message_from_desc-0x4
   974c0:	81 7d cc ff 00 00 00 	cmpl   $0xff,-0x34(%rbp)
   974c7:	76 c3                	jbe    9748c <mtgpu_interrupt_init+0x4bc>
   974c9:	4c 8b 7d c0          	mov    -0x40(%rbp),%r15
   974cd:	4c 89 ff             	mov    %r15,%rdi
   974d0:	e8 00 00 00 00       	call   974d5 <mtgpu_interrupt_init+0x505>
			974d1: R_X86_64_PLT32	os_pci_free_irq_vectors-0x4
   974d5:	4c 89 ff             	mov    %r15,%rdi
   974d8:	e8 00 00 00 00       	call   974dd <mtgpu_interrupt_init+0x50d>
			974d9: R_X86_64_PLT32	os_get_pci_irq-0x4
   974dd:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   974e1:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			974e4: R_X86_64_32S	.rodata.str1.8+0x102c0
   974e8:	41 89 c7             	mov    %eax,%r15d
   974eb:	e8 00 00 00 00       	call   974f0 <mtgpu_interrupt_init+0x520>
			974ec: R_X86_64_PLT32	_os_dev_info-0x4
   974f0:	bf 20 00 00 00       	mov    $0x20,%edi
   974f5:	e8 00 00 00 00       	call   974fa <mtgpu_interrupt_init+0x52a>
			974f6: R_X86_64_PLT32	os_kzalloc-0x4
   974fa:	48 89 43 20          	mov    %rax,0x20(%rbx)
   974fe:	48 85 c0             	test   %rax,%rax
   97501:	0f 84 28 01 00 00    	je     9762f <mtgpu_interrupt_init+0x65f>
   97507:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 9750e <mtgpu_interrupt_init+0x53e>
			9750a: R_X86_64_PC32	os_value-0x4
   9750e:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%rbx)
   97515:	44 89 ff             	mov    %r15d,%edi
   97518:	48 c7 c1 00 00 00 00 	mov    $0x0,%rcx
			9751b: R_X86_64_32S	.rodata.str1.1+0x6150
   9751f:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
   97523:	89 13                	mov    %edx,(%rbx)
   97525:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 9752c <mtgpu_interrupt_init+0x55c>
			97528: R_X86_64_PC32	os_value+0x35c
   9752c:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   97532:	48 8b 43 20          	mov    0x20(%rbx),%rax
   97536:	44 89 78 04          	mov    %r15d,0x4(%rax)
   9753a:	48 8b 43 20          	mov    0x20(%rbx),%rax
   9753e:	4c 89 68 18          	mov    %r13,0x18(%rax)
   97542:	4c 8b 43 20          	mov    0x20(%rbx),%r8
   97546:	e8 00 00 00 00       	call   9754b <mtgpu_interrupt_init+0x57b>
			97547: R_X86_64_PLT32	os_request_irq-0x4
   9754b:	41 89 c6             	mov    %eax,%r14d
   9754e:	85 c0                	test   %eax,%eax
   97550:	0f 85 49 01 00 00    	jne    9769f <mtgpu_interrupt_init+0x6cf>
   97556:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   9755a:	e8 00 00 00 00       	call   9755f <mtgpu_interrupt_init+0x58f>
			9755b: R_X86_64_PLT32	os_get_pci_irq-0x4
   9755f:	8b 75 b8             	mov    -0x48(%rbp),%esi
   97562:	89 c7                	mov    %eax,%edi
   97564:	e8 b7 f4 ff ff       	call   96a20 <mtgpu_irq_set_numa_affinity>
   97569:	e9 6f fb ff ff       	jmp    970dd <mtgpu_interrupt_init+0x10d>
   9756e:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   97572:	e8 00 00 00 00       	call   97577 <mtgpu_interrupt_init+0x5a7>
			97573: R_X86_64_PLT32	os_get_pci_irq-0x4
   97577:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   9757b:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			9757e: R_X86_64_32S	.rodata.str1.8+0x102f8
   97582:	41 89 c7             	mov    %eax,%r15d
   97585:	e8 00 00 00 00       	call   9758a <mtgpu_interrupt_init+0x5ba>
			97586: R_X86_64_PLT32	_os_dev_warn-0x4
   9758a:	e9 61 ff ff ff       	jmp    974f0 <mtgpu_interrupt_init+0x520>
   9758f:	8b 45 bc             	mov    -0x44(%rbp),%eax
   97592:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   97596:	be 01 00 00 00       	mov    $0x1,%esi
   9759b:	44 89 45 b0          	mov    %r8d,-0x50(%rbp)
   9759f:	39 05 00 00 00 00    	cmp    %eax,0x0(%rip)        # 975a5 <mtgpu_interrupt_init+0x5d5>
			975a1: R_X86_64_PC32	irq_vector_cnt-0x4
   975a5:	89 c2                	mov    %eax,%edx
   975a7:	0f 4e 15 00 00 00 00 	cmovle 0x0(%rip),%edx        # 975ae <mtgpu_interrupt_init+0x5de>
			975aa: R_X86_64_PC32	irq_vector_cnt-0x4
   975ae:	e8 00 00 00 00       	call   975b3 <mtgpu_interrupt_init+0x5e3>
			975af: R_X86_64_PLT32	os_pci_alloc_irq_vectors-0x4
   975b3:	44 8b 45 b0          	mov    -0x50(%rbp),%r8d
   975b7:	85 c0                	test   %eax,%eax
   975b9:	41 89 c6             	mov    %eax,%r14d
   975bc:	0f 88 fe 00 00 00    	js     976c0 <mtgpu_interrupt_init+0x6f0>
   975c2:	8b 03                	mov    (%rbx),%eax
   975c4:	e9 25 fc ff ff       	jmp    971ee <mtgpu_interrupt_init+0x21e>
   975c9:	44 89 c2             	mov    %r8d,%edx
   975cc:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   975d0:	44 89 f9             	mov    %r15d,%ecx
   975d3:	be 01 00 00 00       	mov    $0x1,%esi
   975d8:	44 39 05 00 00 00 00 	cmp    %r8d,0x0(%rip)        # 975df <mtgpu_interrupt_init+0x60f>
			975db: R_X86_64_PC32	irq_vector_cnt-0x4
   975df:	0f 4e 15 00 00 00 00 	cmovle 0x0(%rip),%edx        # 975e6 <mtgpu_interrupt_init+0x616>
			975e2: R_X86_64_PC32	irq_vector_cnt-0x4
   975e6:	e8 00 00 00 00       	call   975eb <mtgpu_interrupt_init+0x61b>
			975e7: R_X86_64_PLT32	os_pci_alloc_irq_vectors-0x4
   975eb:	41 89 c6             	mov    %eax,%r14d
   975ee:	e9 04 fc ff ff       	jmp    971f7 <mtgpu_interrupt_init+0x227>
   975f3:	49 8b 7d 00          	mov    0x0(%r13),%rdi
   975f7:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			975fa: R_X86_64_32S	.rodata.str1.8+0x10218
   975fe:	e8 00 00 00 00       	call   97603 <mtgpu_interrupt_init+0x633>
			975ff: R_X86_64_PLT32	_os_dev_err-0x4
   97603:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 9760a <mtgpu_interrupt_init+0x63a>
			97606: R_X86_64_PC32	os_value+0x554
   9760a:	41 f7 de             	neg    %r14d
   9760d:	e9 c2 fa ff ff       	jmp    970d4 <mtgpu_interrupt_init+0x104>
   97612:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 97619 <mtgpu_interrupt_init+0x649>
			97615: R_X86_64_PC32	os_value-0x4
   97619:	89 13                	mov    %edx,(%rbx)
   9761b:	89 d0                	mov    %edx,%eax
   9761d:	e9 c0 fb ff ff       	jmp    971e2 <mtgpu_interrupt_init+0x212>
   97622:	4c 89 ef             	mov    %r13,%rdi
   97625:	e8 06 f5 ff ff       	call   96b30 <mtgpu_free_irq>
   9762a:	e9 2c fd ff ff       	jmp    9735b <mtgpu_interrupt_init+0x38b>
   9762f:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 97636 <mtgpu_interrupt_init+0x666>
			97632: R_X86_64_PC32	os_value+0x504
   97636:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   9763a:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			9763d: R_X86_64_32S	.rodata.str1.8+0x10240
   97641:	41 f7 de             	neg    %r14d
   97644:	e8 00 00 00 00       	call   97649 <mtgpu_interrupt_init+0x679>
			97645: R_X86_64_PLT32	_os_dev_err-0x4
   97649:	e9 86 fa ff ff       	jmp    970d4 <mtgpu_interrupt_init+0x104>
   9764e:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   97652:	89 da                	mov    %ebx,%edx
   97654:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			97657: R_X86_64_32S	.rodata.str1.8+0x10290
   9765b:	e8 00 00 00 00       	call   97660 <mtgpu_interrupt_init+0x690>
			9765c: R_X86_64_PLT32	_os_dev_err-0x4
   97660:	83 eb 01             	sub    $0x1,%ebx
   97663:	0f 88 f2 fc ff ff    	js     9735b <mtgpu_interrupt_init+0x38b>
   97669:	48 63 c3             	movslq %ebx,%rax
   9766c:	89 db                	mov    %ebx,%ebx
   9766e:	49 89 c5             	mov    %rax,%r13
   97671:	48 29 d8             	sub    %rbx,%rax
   97674:	48 89 c3             	mov    %rax,%rbx
   97677:	49 c1 e5 05          	shl    $0x5,%r13
   9767b:	48 c1 e3 05          	shl    $0x5,%rbx
   9767f:	49 8b 77 20          	mov    0x20(%r15),%rsi
   97683:	4c 01 ee             	add    %r13,%rsi
   97686:	8b 7e 04             	mov    0x4(%rsi),%edi
   97689:	e8 00 00 00 00       	call   9768e <mtgpu_interrupt_init+0x6be>
			9768a: R_X86_64_PLT32	os_free_irq-0x4
   9768e:	4c 89 e8             	mov    %r13,%rax
   97691:	49 83 ed 20          	sub    $0x20,%r13
   97695:	48 39 c3             	cmp    %rax,%rbx
   97698:	75 e5                	jne    9767f <mtgpu_interrupt_init+0x6af>
   9769a:	e9 bc fc ff ff       	jmp    9735b <mtgpu_interrupt_init+0x38b>
   9769f:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   976a3:	44 89 fa             	mov    %r15d,%edx
   976a6:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			976a9: R_X86_64_32S	.rodata.str1.8+0x10348
   976ad:	e8 00 00 00 00       	call   976b2 <mtgpu_interrupt_init+0x6e2>
			976ae: R_X86_64_PLT32	_os_dev_err-0x4
   976b2:	48 8b 7b 20          	mov    0x20(%rbx),%rdi
   976b6:	e8 00 00 00 00       	call   976bb <mtgpu_interrupt_init+0x6eb>
			976b7: R_X86_64_PLT32	os_kfree-0x4
   976bb:	e9 9b fc ff ff       	jmp    9735b <mtgpu_interrupt_init+0x38b>
   976c0:	44 89 3b             	mov    %r15d,(%rbx)
   976c3:	44 89 f8             	mov    %r15d,%eax
   976c6:	e9 23 fb ff ff       	jmp    971ee <mtgpu_interrupt_init+0x21e>
   976cb:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
   976cf:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
			976d2: R_X86_64_32S	.rodata.str1.8+0x10240
   976d6:	e8 00 00 00 00       	call   976db <mtgpu_interrupt_init+0x70b>
			976d7: R_X86_64_PLT32	_os_dev_err-0x4
   976db:	44 8b 35 00 00 00 00 	mov    0x0(%rip),%r14d        # 976e2 <mtgpu_interrupt_init+0x712>
			976de: R_X86_64_PC32	os_value+0x504
   976e2:	41 f7 de             	neg    %r14d
   976e5:	e9 ea f9 ff ff       	jmp    970d4 <mtgpu_interrupt_init+0x104>
