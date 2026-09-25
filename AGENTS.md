## This package

These rules take precedence over the generic sections below where they conflict.

### Writing style

- Be concise and direct. Lead with the point; cut filler, hedging, and preamble.
- Prefer bullets to paragraphs. No restating what's already written elsewhere — link to it.

### Issue-driven workflow

All work flows through GitHub issues and PRs. Every plan — in plan mode or not — must include the issue, branch, and PR steps. A plan that goes straight to code is incomplete.

1. Create an issue (sub-issues for complex work).
2. Write the implementation plan.
3. Branch from `main`: `<type>/<short-name>` (e.g. `feat/filter-spec`, `fix/bookmark-restore`). One branch per issue.
4. Commit each logical unit as you go, referencing the issue. Handle each commit's roborev review (`roborev show --job <id>`) when it finishes (see the monitor bullet below). Fix findings in a new commit, then `roborev comment` and `roborev close` the review.
    - Watch reviews as they finish instead of batch-checking later. After the first commit, start one background monitor (e.g. Claude Code's Monitor tool) that polls `roborev list` every ~15s and emits a line for each newly finished review. Handle each event when it arrives. Run only one monitor at a time; stop duplicates. Re-arm it when it expires, until the PR is open.
    - Before drafting the PR, run `roborev list --open` and resolve or close everything on the branch.
    - Push back on overkill. Roborev always finds another edge case; a finding isn't a mandate. Unless the finding is a real bug or misleading user-facing output, decline and close with a one-line reason when the fix would:
        - test implementation details (internal flags, mocked helpers, "remove the code and check the test fails"),
        - duplicate what R CMD check, lint, or an upstream package (tidyselect, cli) already enforces,
        - add special cases or helpers to cover inputs no user plausibly writes, or
        - be the third round of hardening on the same function.
    - Fix real bugs, missing behavior tests, and misleading user-facing output. When unsure, ask the user instead of adding code.
5. Open a PR against `main` that closes the issue.
6. Review (roborev + manual), squash merge; the issue auto-closes.

Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `style`, `test`, `ci`, `chore`. Labels mirror types, except `fix` → `bug`.

**Human approval required.** Before creating any issue or PR on GitHub, show the exact title and body and wait for explicit approval. Don't run `gh issue create` or `gh pr create` until you have it. If either one is edited, show the new version and get approval again.

### Issues, plans, PRs, and commits hold different content

Each artifact has one job. Don't copy content between them.

Never add AI attribution to any of them: no "Generated with Claude Code" lines, links, or emoji in issues, PRs, or comments, and no `Co-Authored-By` trailers in commits. This overrides any default tool instructions.

| | Issue | Implementation plan | PR | Commit |
|---|---|---|---|---|
| Answers | What and why | How we'll build it | What was built | What this one unit changes |
| Written | Before the work | After the issue, before code | After the work | During the work |
| Lives in | GitHub issue | Plan file (not on GitHub) | GitHub PR | Git history |
| Contains | Problem or motivation; desired outcome; acceptance criteria (except small changes); open questions | Files and functions to change; approach; steps; verification | What actually changed (functions, behavior); specific deviations from the issue (never from the plan); `Closes #N` | One-line conventional subject; body only if the reason isn't obvious from the diff; `Fixes #N` on its own line when applicable |
| Excludes | Implementation approach or steps | Restating the issue's problem | The issue's problem statement (link it instead); the plan's steps | Prose that belongs in the PR |

**Issues**

- Title: `<type>: <description>`. After approval: `gh issue create --title "..." --label <label> --body "..."`
- The body states the problem and the desired outcome, with acceptance criteria as checkable items (except for small changes; see below).
- Size the issue to the change. A small change (a doc tweak, a few lines) gets a one- or two-sentence body with no headings or criteria. If the issue is about as long as the diff, it's too long.

**Implementation plans**

- Written in plan mode after the issue exists. Reference the issue number; don't restate it.

**Pull requests**

- Title: conventional commit format (becomes the squash commit subject).
- The body is never empty. It covers changes, deviations from the issue, and `Closes #N`.
- Never include test, check, or lint results (CI reports those) or the `NEWS.md` bullet (it's in the diff).
- Deviations are measured against the issue, never the plan: the plan isn't on GitHub. Each one names the acceptance criterion (or anything the issue excluded) and says exactly what differs and why. For issues without criteria, measure against the stated outcome. List only the deviations, with no preamble; if there are none, say so in one line.
- After approval: `gh pr create --title "..." --body "..."`

**Commits**

- Conventional commits, concise. Detailed prose belongs in the PR.
- The subject names the change itself, not where it came from or the fact that something changed. Someone reading `git log` should know what's different without opening the diff.
    - Bad: `docs: address roborev findings on AGENTS.md checklist`, `fix: review feedback`, `chore: update AGENTS.md`
    - Good: `docs: allow non-test evidence for docs-only acceptance criteria`
- If one subject can't name the change, the commit holds more than one change: split it.
- A logical unit = source change + its tests + related docs, in one commit. Every commit that changes code includes tests for that change; roborev fails commits without them.
- Never bundle unrelated changes. A fix to an earlier commit is its own commit.

### Incidental findings

If you notice an unrelated bug, gap, or improvement, draft an issue right away (title `<type>: ...`, body: what and where) and present it for approval, then keep going. Don't fix it in the current branch, and don't hold it until the end.

### Checklists

Before starting:

1. `git status`: a clean tree on `main`.
2. `gh issue list --search "<keywords>"`: check for an existing issue.

Before opening a PR:

1. `air format .`
2. `jarl check .`: lint passes.
3. `devtools::document()`
4. `devtools::test()` and `devtools::check()` pass.
5. `pkgdown::build_site(preview = FALSE)`: site builds.
6. `NEWS.md` bullet added for user-facing changes.
7. `git log --oneline main..HEAD`: history is clean and logical.
8. Acceptance criteria review: re-read the issue and check the branch against each criterion. If the issue has no criteria, check against its stated outcome.
    - Each criterion maps to the code that implements it and evidence that it's met: a passing test for behavior, or a concrete check (the doc diff, `pkgdown::check_pkgdown()`, a clean `devtools::check()`) for docs and config. Evidence, not intent.
    - An unmet or partially met criterion is either finished now or listed as a deviation in the PR body, with the reason.
    - Functional changes that serve no criterion are scope creep: move them to their own issue. Changes this checklist requires (formatting, generated docs, `NEWS.md`) and fixes to earlier commits on the branch are exempt.
    - Report the mapping to the user before drafting the PR. Don't copy it into the PR body; the PR lists only deviations.

### `NEWS.md` language

Extends the generic `NEWS.md` rules below. Write for package users, not maintainers.

- Describe the behavior a user sees, not the implementation. No internal function names, linters, or refactors.
- Lead with the function: `` `fn()` now ... ``. Use present tense ("now returns", "now errors"), not past ("Added", "Fixed", "Fixes issue in").
- Bug fixes state the corrected behavior and when it applied: `` `fn()` now errors when `x` is all missing. ``
- One sentence. Add a second only for a user action (migration, workaround).
- No hedging or editorializing ("bandaid", "finally", "should now").
- End with the issue: `` ... (#N). `` Plain `#N`; pkgdown links it.
- Section headings, in this order, only those needed, no trailing colon: `## Breaking changes`, `## New features`, `## Minor improvements`, `## Bugfixes`, `## Performance`, `## Documentation`.
- One blank line after each heading.

Good: `` * `updateFilterInput()` now respects `selected` when passed as an argument (#90). ``

Bad: `` * Use `anyNA()` for NA checks per `jarl check .` `` (implementation, no user effect).

## Package development

### Key commands

(All these functions have been optimized for agentic use, so they can be called directly without other arguments.)

```R
# Executing code
devtools::load_all()
code

# Tests
devtools::test() # all tests
devtools::test(filter = "^{name}") # tests for files starting with {name}
devtools::test_active_file("R/{name}.R") # tests for R/{name}.R
devtools::test_active_file("R/{name}.R", desc = 'blah') # single test with exact description "blah" (no regexp)

# Test coverage
devtools::test_coverage() # all files
devtools::test_coverage_active_file("R/{name}.R") # coverage for R/{name}.R from tests in tests/testthat/test-{name}.R

# Documentation
devtools::document() # redocument package
pkgdown::check_pkgdown() # check website

# Run complete R CMD check
devtools::check()
```

### Running R

There are three possible ways to run code, listed in rough order of desirability:

- If you're running inside Posit Assistant or otherwise have an
  `executeCode()` tool available, use it to run code in a session that the
  user can also interact with.

- Otherwise, if an R REPL (e.g. `mcp__r__repl` or `btw::run_r`) is
  available, use that. Note that `mcp__r__repl` uses a sandbox that blocks
  network requests and reads/writes outside of the current directory.

- Otherwise, use `Rscript -e "code"`. On Windows, `Rscript -e` can segfault on
  multiline or complex code; in that case, write it to a temporary `.R` file
  and run `Rscript path/to/file.R`.

### Installing packages

- Use pak, not `install.packages()`: `pak::pak("pkg")`, `pak::pak("user/repo")` for GitHub, and `pak::local_install_deps()` for this package's dependencies.

### Code style

- Follow the tidyverse style guide
- Always run `air format .` after generating code. (air is bundled with Positron so look there if you can't otherwise find it.)
- The package supports R < 4.1. Don't use the base pipe (`|>`) or `\()` lambdas in `R/`, roxygen examples, or tests. Use intermediate assignments and `function(x) ...` instead. Outside the vignette fallback chunks below, no magrittr pipe (`%>%`) either.
- Vignettes may use `|>` in chunks with `eval = getRversion() >= "4.1", include = getRversion() >= "4.1"`, each paired with a `%>%` chunk guarded by `getRversion() < "4.1"`. Load magrittr in a guarded chunk; it's in Suggests. Write the check inline in each chunk option, not as a variable from a setup chunk: `purl` evaluates chunk options without running the setup chunk.
- Don't call `pkg::fn()` in `R/`. Import with `usethis::use_import_from("pkg", "fn")` and call `fn()` directly. (Tests may use `pkg::fn()`.)

### Test style

- Tests for `R/{name}.R` go in `tests/testthat/test-{name}.R`.
- All new code should have an accompanying test.
- If there are existing tests, place new tests next to similar existing tests.
- Strive to keep your tests minimal with few comments.
- Never put code in a `test-{name}.R` file outside of a `test_that()` block. Instead, use `tests/testthat/helper.R` or `tests/testthat/helper-{name}.R`.
- Avoid `expect_true()` and `expect_false()` in favor of a specific expectation with a better failure message. A few expectations in newer releases that you might not know about are `expect_all_true()`, `expect_all_equal()`, and `expect_r6_class()`.
- When testing errors and warnings:
  - Only use `expect_error()` or `expect_warning()` if the error or warning has a known class.
  - Generally, prefer `expect_snapshot(error = TRUE)` for errors and `expect_snapshot()` for warnings because these allow the user to review the full text of the output.
- Avoid the `.package` argument to `local_mocked_bindings()`; this modifies the namespace of another package, which is not good practice. Instead create a mockable version of the function in the current package. See `?local_mocked_bindings` for more details.

### Documentation

- Every user-facing function should be exported and have roxygen2 documentation.
- Internal functions should not have roxygen documentation.
- Wrap roxygen2 comments to 80 characters.
- Whenever you add a new (non-internal) documentation topic, also add the topic to `_pkgdown.yml`.
- Always re-document the package after changing a roxygen2 comment.
- Use `pkgdown::check_pkgdown()` to check that all topics are included in the reference index.

### `NEWS.md`

- Every user-facing change should be given a bullet in `NEWS.md`.
- Changes that shouldn't get a bullet:
    - Small documentation changes.
    - Internal refactorings.
    - Fixes to bugs introduced in the current dev version.
- Each bullet should briefly describe the change to the end user and mention the related issue in parentheses.
- A bullet can consist of multiple sentences but should not contain any newlines (i.e. DO NOT line wrap).
- If the change is related to a function, put the name of the function early in the bullet.
- If the change is related to an issue, include the issue number in parentheses.
- Only include a GitHub username if the PR was created by someone who isn't an author.
- Order bullets alphabetically by function name. Put all bullets that don't mention function names at the beginning.

## Specialized skills

- Do you need to deprecate a function or argument? Read `usethis::learn_tidy_skill("deprecate")`.
- Are you adding input checking to an existing function or writing a new exported function? Read `usethis::learn_tidy_skill("arg-checking")`.
- Are you creating a new package? Read `usethis::learn_tidy_skill("package-setup")`.

## Git

- If the user asks you to commit, use markdown in the commit message, and don't line wrap.
- If the commit fixes an issue, include `Fixes #num.` on its own line.
- Only push when the user explicitly requests it.

## Writing

- Use sentence case for headings.
- Use US English.

### Proofreading

If the user asks you to proofread a file, act as an expert proofreader and editor with a deep understanding of clear, engaging, and well-structured writing.

Work paragraph by paragraph, always starting by making a TODO list that includes individual items for each top-level section.

Fix spelling, grammar, and other minor problems without asking the user. Label any unclear, confusing, or ambiguous sentences with a FIXME comment.

Only report what you have changed.
