# GrantFlow KE

A demo-safe Kenyan community grant review workspace. It uses seeded records and a deterministic Jac rules engine; core demo use requires no API keys, external services, uploads, or login.

## Demo script (5 minutes)

1. Open the Overview and note the three seeded applications.
2. Select Amina Wanjiku’s Nairobi classroom project, then choose **Run Review Agents**. Inspect the four scored agent results and audit entry.
3. Select the Kisumu community garden application to inspect missing constitution and bank evidence.
4. Select the Nakuru youth workshop to review its mismatched budget, concentrated cost, invalid dates, and safeguarding gap.
5. Record a reviewer decision, generate a deterministic decision report, and switch between Applicant and Reviewer roles.
6. Use **Reset Demo Data** to restore the three seeded scenarios.
7. Use Rules & guide to adjust the configurable general funding cap and follow the demo guide.

## Architecture

- `services/grants.jac` contains seeded application records, the four deterministic checks, recommendations, reports, role switch, cap update, and audit entries.
- `components/GrantReview.jac` owns the responsive review workspace and calls its Jac service functions.
- `main.jac` mounts the workspace and themed Tailwind stylesheet.
- Jac keeps the workflow local to the app. The rule engine is repeatable for identical input and reports its findings without an external model.

The seeded scenarios are initialized on app startup. Demo state is in-memory and resets when the service process restarts; the visible reset control restores the exact seeded set and clears generated audit and decision changes.

## Optional GenAI narrative

Narrative enhancement is intentionally disabled (`ENABLE_GENAI = False`). There is no provider call in this reliability-first build; deterministic scoring, recommendations, and report copy always work offline. If a provider enhancement is added later, it must remain narrative-only, have a timeout and exception fallback, and must never alter rule results. No environment variables are required for this demo.

## Run

Use Jac 0.34.23 or compatible. Install project dependencies with `jac install`, then start the app with `jac start --dev main.jac`.
