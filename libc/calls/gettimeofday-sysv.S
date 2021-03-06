/*-*- mode:unix-assembly; indent-tabs-mode:t; tab-width:8; coding:utf-8     -*-│
│vi: set et ft=asm ts=8 tw=8 fenc=utf-8                                     :vi│
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2020 Justine Alexandra Roberts Tunney                              │
│                                                                              │
│ Permission to use, copy, modify, and/or distribute this software for         │
│ any purpose with or without fee is hereby granted, provided that the         │
│ above copyright notice and this permission notice appear in all copies.      │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL                │
│ WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED                │
│ WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE             │
│ AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         │
│ DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR        │
│ PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER               │
│ TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR             │
│ PERFORMANCE OF THIS SOFTWARE.                                                │
╚─────────────────────────────────────────────────────────────────────────────*/
#include "libc/dce.h"
#include "libc/macros.h"

/	Returns system wall time in microseconds.
/
/	@param	rdi points to timeval that receives result
/	@param	rsi receives UTC timezone if non-NULL
/	@return	always zero
/	@see	clock_gettime() for nanosecond precision
/	@see	strftime() for string formatting
sys_gettimeofday:
	push	%rbp
	mov	%rsp,%rbp
	.profilable
	test	%rsi,%rsi
	jz	1f
	push	$0
	pop	(%rsi)
1:	xor	%esi,%esi			# no one zones this way.
	xor	%edx,%edx			# i64*mach_absolute_time
	call	__sys_gettimeofday
#if SupportsXnu()
	testb	IsXnu()				# XNU might do %rax:%rdx
	jz	1f
	test	%rdi,%rdi
	jz	1f
	test	%rax,%rax
	jz	1f
	mov	%rax,(%rdi)
	mov	%rdx,8(%rdi)
#endif
1:	xor	%eax,%eax			# nevar fail
	pop	%rbp
	ret
	.endfn	sys_gettimeofday,globl,hidden
