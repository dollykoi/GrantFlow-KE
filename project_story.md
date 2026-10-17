# Project Story

## Inspiration

I wanted to build something that felt useful in a Kenyan context, not just another demo app. Small funding programs are everywhere: community funds, student innovation funds, NGO mini grants, county youth funds, church funds, and school project funds. Many of them do important work, but the review process is often manual. Applications come in through forms, email, paper, or WhatsApp. Reviewers then have to check documents, budgets, eligibility, and risk by hand.

That creates a quiet problem. Strong projects can be delayed because a document is missing. Weak projects can move forward because the budget was not checked carefully. Decisions can also be hard to explain later, especially when different reviewers use different judgment.

GrantFlow KE came from that idea. I wanted to build a tool that gives small funds a fair first review process while keeping the final decision with a human reviewer.

## What I built

GrantFlow KE is a deterministic grant review assistant. It lets an applicant submit a structured funding request. A reviewer can then run four review agents, see a score breakdown, generate a decision report, record conditions or an override reason, and keep an audit trail.

The app has three seeded demo applications that show the main paths: approve, conditional, and reject. It also has applicant and reviewer views, a rules page, dashboard metrics, and a reset action for repeatable demos.

The review agents are:

1. Completeness Agent, for required fields and documents
2. Eligibility Agent, for category, applicant type, location, and timing
3. Budget Agent, for totals, category caps, and unrealistic items
4. Risk Agent, for timeline, safeguarding, prior funding, and conflict signals

Each agent returns a score from 0 to 25. The final score is:

\[
S = C + E + B + R
\]

Where \(C\) is completeness, \(E\) is eligibility, \(B\) is budget, and \(R\) is risk. The recommendation is based on the final score and critical failures. The reviewer still makes the final decision.

## How I built it

I built the project in Jac using Jac Hammer. The goal was to keep the core app inside the Jac and Jaseci workflow instead of stitching together many outside services. That mattered for two reasons. First, the hackathon required the code to be mostly Jac. Second, I wanted the demo to be reliable.

The main build steps were:

- Define the application data model
- Create seeded demo applications
- Build the dashboard and application queue
- Build the application detail view
- Add the four deterministic review agents
- Add score breakdown and findings
- Add agent recommendation and reviewer decision as separate concepts
- Add conditions and override reasons
- Add the printable decision report
- Add audit trail events
- Add applicant and reviewer roles
- Add Reset Demo Data for a repeatable demo

I made a deliberate choice not to depend on live GenAI for the core demo. GenAI could help polish wording later, but the score, recommendation, conditions, and reviewer decision should come from clear rules. For a grant review tool, explainability matters more than sounding smart.

## What I learned

I learned that agentic behavior does not have to mean unpredictable behavior. An agent can be a focused piece of logic with a clear job. In this project, the agents are useful because they separate concerns. Completeness does not try to judge risk. Budget does not try to decide eligibility. That separation makes the system easier to explain and easier to debug.

I also learned that demo reliability is a feature. It is easy to add ideas that sound impressive but fail during a live demo. For this project, I had to keep asking: will this work every time? If the answer was no, I cut it or made it optional.

Finally, I learned more about Jac and Jac Hammer as a workflow. Building the app in one environment forced me to think carefully about state, data flow, and the exact path a reviewer would take.

## Challenges I faced

The biggest challenge was scope. I had many ideas: uploads, notifications, maps, payments, GenAI summaries, and more. Under a 24 hour deadline, those ideas could have made the project unstable. I chose a smaller workflow that could be finished well.

The second challenge was state management. During testing, stale content could appear when moving between applications. A report from one application could show under another application if the UI was not reset correctly. That had to be fixed because trust is the whole point of the app.

The third challenge was making the agents feel real without making them unpredictable. I did not want hardcoded demo outcomes, but I also did not want a live external model deciding the result. The answer was a deterministic evaluator based on application data, with seeded examples chosen to show different outcomes.

The fourth challenge was governance. If the agents recommend one thing and the reviewer chooses another, the app should not hide that. I added an override reason so disagreement becomes part of the record instead of a quiet click.

## Why this matters

Grant review is not only about saying yes or no. It is about fairness, consistency, and memory. A small fund may not have a large team, but it still deserves a clear process. Applicants also deserve feedback that makes sense.

GrantFlow KE is a prototype, but it shows a practical direction: use agentic workflows for structured review, keep humans responsible for final decisions, and make the record easy to audit.

## What is next

The next steps are secure authentication, document upload, configurable funding programs, reviewer comments, PDF and CSV export, and optional GenAI wording polish with deterministic fallback. I would also like to test the rules with real grant administrators and adjust the scoring to match real programs.
