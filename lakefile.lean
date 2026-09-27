import Lake
open Lake DSL

package «palomar_h3qm» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.35.0-rc2"

@[default_target]
lean_lib «Challenge» where
  roots := #[`Challenge]

@[default_target]
lean_lib «Solution» where
  roots := #[`Solution]

@[default_target]
lean_lib «PalomarH3QM» where
  roots := #[`Solution]

@[default_target]
lean_lib «H3QM» where
  roots := #[`H3QM]
