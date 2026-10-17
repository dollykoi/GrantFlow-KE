# GrantFlow KE

GrantFlow KE is a deterministic grant review assistant for small funding programs in Kenya. It helps reviewers process structured applications, run rule based review agents, generate decision reports, and keep an audit trail.

Built for JacHacks Kenya.

## Overview

Small grant programs often review applications manually. This can lead to inconsistent decisions, missing documents, weak budget checks, and poor records. GrantFlow KE gives reviewers a consistent first pass while keeping the final decision with a human reviewer.

The app supports two roles:

- Applicant: submits applications and views outcomes
- Reviewer: runs agents, reviews findings, records decisions, and generates reports

## Core features

- Dashboard with application KPIs
- Applications list with status tracking
- Structured application form
- Four deterministic review agents
- Agent score breakdown and findings
- Agent recommendation separated from reviewer decision
- Approval, conditional approval, rejection, conditions, and override reason
- Printable decision report
- Audit trail
- Rules and guide page
- Seeded demo applications
- Reset Demo Data action

## Demo applications

The seeded data includes three demo paths:

1. Digital learning kits for community library: strong application, expected approval path
2. Community kitchen garden starter: missing documents, expected conditional path
3. Youth repair workshop: budget and risk concerns, expected reject path

## Review agents

Each application is reviewed by four deterministic agents. Each agent returns a score from 0 to 25.

### Completeness Agent

Checks required fields and required documents.

### Eligibility Agent

Checks category, applicant type, location, and timing.

### Budget Agent

Checks requested amount, budget total, category caps, and unrealistic items.

### Risk Agent

Checks timeline, safeguarding, prior funding details, and conflict signals.

## Scoring

Final score is the sum of the four agent scores.

Recommended interpretation:

- 85 to 100: approve
- 70 to 84: conditional
- Below 70: reject

Critical failures can lower the recommendation even when the total score looks acceptable. The reviewer still makes the final decision. If the reviewer chooses a different outcome from the agent recommendation, the app asks for an override reason.

## Tech stack

- Jac for the core application
- Jaseci ecosystem concepts for agent style workflow
- Jac Hammer for browser based building, preview, and hosting
- No external services required for the core demo

## Project structure

Recommended source tree for the GitHub submission. Internal Jac Hammer artifacts such as `.jaccoder/`, `tool-results/`, `screenshots/`, `agent_journal.md`, `build_plan.json`, and `dist/` are not required in the repo unless your deployment step explicitly needs them.

```text
.
├── AGENTS.md
├── README.md
├── jac.toml
├── main.jac
├── frontend.cl.jac
├── components/
│   └── ui/
│       ├── button.jac
│       ├── card.jac
│       └── skeleton.jac
├── lib/
│   └── utils.jac
├── styles/
│   └── global.css
├── final_demo_script.md
├── written_description.md
├── project_story.md
└── pitch_deck/
    └── grantflow_ke_pitch.pptd
```

If your local file names differ, keep the same rule: commit source, docs, config, and presentation files; exclude tool logs and generated preview output.

## Setup

This project is designed to run in Jac Hammer.

1. Open the project in Jac Hammer.
2. Confirm the app builds successfully.
3. Run `jac check main.jac` if the workspace supports it.
4. Open the preview.
5. Click Reset Demo Data before demo use.

## Environment variables

The core demo does not require environment variables.

If an optional GenAI narrative layer is added later, use safe defaults:

```env
ENABLE_GENAI=false
GENAI_PROVIDER=none
GENAI_TIMEOUT_MS=8000
```

Only enable GenAI if the code has a deterministic fallback. GenAI output should never change scores, recommendations, conditions, or reviewer decisions.

## Demo flow

1. Open the app fresh.
2. Click Reset Demo Data.
3. Start in Reviewer role.
4. Show Overview KPIs.
5. Open Digital learning kits for community library.
6. Click Run Review Agents.
7. Click Generate Report.
8. Approve the application.
9. Open Community kitchen garden starter.
10. Run agents and approve with conditions.
11. Open Youth repair workshop.
12. Run agents and reject with a reason.
13. Switch to Applicant role and show the outcome view.
14. Open Rules & guide.

## Reliability notes

This prototype was built to be demo safe. It avoids live external dependencies for the main flow. The review is deterministic, seeded, and repeatable.

If the preview looks stale or duplicated, refresh the browser and click Reset Demo Data.

## Known limitations

- No real authentication system yet
- No document upload or verification
- No SMS, email, or WhatsApp notifications
- No payment or bank verification
- Rules are simplified for demo purposes
- Optional GenAI narrative polish is not part of the core demo

## Next steps

- Add secure authentication
- Add document upload and review
- Add funding program configuration
- Add reviewer comments and assignments
- Add export to PDF and CSV
- Add optional GenAI wording polish with deterministic fallback
- Add analytics for fund managers

## Submission assets

Update these before final submission:

- GitHub link: add your repo link here
- Hosted preview: add your Jac Hammer link here
- Demo video: add your video link here
- Pitch deck: use the included pitch deck file
- Written description: use the included written description

## Hackathon statement

GrantFlow KE was built for JacHacks Kenya. The project uses Jac and Jaseci tools for the core application and focuses on practical agentic workflow, explainable decisions, and demo reliability.