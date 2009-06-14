define([NTAB_ENTRY_SIZE], 32)
dnl
define([DEF_TAB],[define($1_COUNT, 0)])dnl
define([PUSH_EL],[define($1_AT[]$1_COUNT,$2)][define([$1_COUNT],incr($1_COUNT))])dnl
define([EL_COUNT], [$1_COUNT]) dnl
define([EL_AT], [indir($1_AT[]$2)])  dnl
define([K4_FORLOOP],
 	[ifelse(eval([($3) >= ($2)]),[1],
 		[pushdef([$1],eval([$2]))_K4_FORLOOP([$1],
 		eval([$3]),[$4])popdef([$1])])])dnl
dnl
define([_K4_FORLOOP],
 	[$3[]ifelse(indir([$1]),[$2],[],
   		[define([$1],incr(indir([$1])))$0($@)])])dnl
dnl
define([FOR_EACH], [K4_FORLOOP($2_i, 0, decr(EL_COUNT($1)),[pushdef([$2], EL_AT($1,$2_i))$3[]popdef([$1])])])dnl
dnl
define([BEGIN_DICT],[DEF_TAB(NAME_TAB)])
define([DEF_CODE],[PUSH_EL(NAME_TAB, $1)])
define([BUILD_NAME_TABLE],[var_ntab: .LONG ntab_end
ntab: 
FOR_EACH(NAME_TAB, arg,[.STRING "arg"
.FILL eval(NTAB_ENTRY_SIZE-len(arg))
])
ntab_end:
])
 
