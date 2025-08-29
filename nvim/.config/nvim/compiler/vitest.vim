if exists("current_compiler")
  finish
endif
let current_compiler = "vitest"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=npx\ vitest\ run\ --no-color
CompilerSet errorformat=%EAssertionError:\ %m,
      \%Z%.%#❯\ %f:%l:%c,
      \%C%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
