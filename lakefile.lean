import Lake
open Lake DSL

package «palomar_h3qm» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.11.0"

@[default_target]
lean_lib «H3QM» where
  roots := #[`H3QM]

lean_lib «PalomarH3QM» where
  roots := #[`solution]
