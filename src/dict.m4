# FourK - Concatenative, stack based, Forth like language optimised for 
#        non-interactive 4KB size demoscene presentations.

# Copyright (C) 2009, 2010 Wojciech Meyer, Josef P. Bernhart

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
dnl Section defintion
define([MARKER],[
	jmp	9f
	.ASCII "@@!", $1, "!@@"
9:
])
define([MAX_VALID_TOKEN], [256])dnl
define([COMPILE_TOKEN],[10])dnl
define([EXECUTE_TOKEN],[11])dnl
define([INTERPRET_TOKEN],[12])dnl
define([EOW_TOKEN],[0])dnl
define([EOD_TOKEN],[1])dnl
define([PREFIX_TOKEN],[2])dnl
define([LIT_TOKEN],[3])dnl
define([LIT4_TOKEN],[4])dnl
define([NTAB_ENTRY_SIZE], 32)dnl
define([MAX_WORDS],512)dnl
define([DICT_SIZE], 8*1024)dnl
define([NEXT_WORD], [jmp *%ebp])dnl
define([CORE_COUNT],[0])dnl
dnl
define([BEGIN_DICT])dnl
dnl
define([NORMAL_SEMANTICS],
[
	divert(2)
	.BYTE COMPILE_TOKEN, EXECUTE_TOKEN
	STD_DIVERT
])dnl
define([IMMEDIATE_SEMANTICS],
[
	divert(2)
	.BYTE EXECUTE_TOKEN, EXECUTE_TOKEN
	STD_DIVERT
])dnl
define([_DEF_CODE],
[
	define([LAST_WORD], $1)dnl
	divert(1)dnl
		define([CORE_COUNT], incr(CORE_COUNT))dnl
		.ASCII $2
		.FILL eval(NTAB_ENTRY_SIZE - len($2) + 2)
	STD_DIVERT
	word_$1: .BYTE codeend_$1 - code_$1
	code_$1:
])
define([DEF_CODE],
[
	_DEF_CODE($1,$2) dnl
	NORMAL_SEMANTICS dnl
])
define([END_CODE],
[
	NEXT_WORD
	codeend_[]LAST_WORD:
])
define([DEF_VAR],[
	DEF_CODE($1,"$1")dnl
	sub	$ 4,%ebx
	call	1f
1:
	pop	%eax
	add	$(1f-1b),%eax
	mov	%eax,(%ebx)
	jmp	*%ebp
1:
var_$1:
	.long	$2
#	divert(3)
#	var_$1:	.long $2
#	divert
	END_CODE dnl
])
define([DEF_IMM],
[
	_DEF_CODE($1,$2) dnl
	IMMEDIATE_SEMANTICS dnl
])

define([END_DICT],
[
	here:
	.BYTE EOD_TOKEN
	.FILL DICT_SIZE
	.equ NCORE_WORDS, CORE_COUNT
	

	SECTION(name)
	ntab:
	undivert(1)
	ntab_end:
	.FILL NTAB_ENTRY_SIZE*MAX_WORDS

	SECTION(dsptch)
	dsptch:		.FILL NCORE_WORDS*4
	dsptch_end: 	.FILL 4*MAX_WORDS

	SECTION(semantic)
	semantic:
	undivert(2)
        semantic_end:
       .FILL 8*MAX_WORDS*4
	.align 4
	undivert(3)
	SECTION(there)
	there:
       	.FILL 2*8192
])

