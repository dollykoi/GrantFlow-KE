import from datetime { datetime }

glob ENABLE_GENAI: bool = False;
glob ROLE: str = "Reviewer";
glob RULE_CAP: float = 500000.0;
glob APPLICATIONS: list[dict] = [];
glob AUDIT: list[dict] = [];
glob DECISIONS: dict = {};
glob AGENT_RUNS: dict = {};


def _seed() -> None {
    APPLICATIONS = [
        {"id": "GF-2026-001", "applicant": "Amina Wanjiku", "organization": "Tumaini Youth Learning", "project": "Digital learning kits for rural classrooms", "category": "education", "county": "Nairobi", "amount": 420000.0, "start": "2026-07-01", "end": "2026-11-30", "type": "registered_ngo", "summary": "Provide shared tablets, offline learning content, and teacher orientation for three community classrooms.", "constitution": True, "bank": True, "safeguarding": True, "prior": False, "prior_details": "", "status": "under_review", "budget": [{"name": "Learning tablets", "amount": 210000.0, "quantity": 6}, {"name": "Offline content setup", "amount": 90000.0, "quantity": 1}, {"name": "Teacher orientation", "amount": 70000.0, "quantity": 2}, {"name": "Transport and delivery", "amount": 50000.0, "quantity": 1}]},
        {"id": "GF-2026-002", "applicant": "Peter Odhiambo", "organization": "Kisumu Community Gardeners", "project": "Community kitchen garden starter", "category": "agriculture", "county": "Kisumu", "amount": 180000.0, "start": "2026-07-10", "end": "2026-10-15", "type": "community_group", "summary": "Establish shared vegetable beds and practical growing sessions for local households.", "constitution": False, "bank": False, "safeguarding": True, "prior": False, "prior_details": "", "status": "submitted", "budget": [{"name": "Water tanks and tools", "amount": 70000.0, "quantity": 2}, {"name": "Seeds and compost", "amount": 45000.0, "quantity": 1}, {"name": "Training sessions", "amount": 40000.0, "quantity": 4}, {"name": "Garden preparation", "amount": 25000.0, "quantity": 1}]},
        {"id": "GF-2026-003", "applicant": "Brian Kibet", "organization": "Nakuru Youth Makers", "project": "Youth repair workshop", "category": "youth", "county": "Nakuru", "amount": 300000.0, "start": "2026-08-20", "end": "2026-08-12", "type": "individual", "summary": "A youth-led workshop for repairing community bicycles and learning practical skills.", "constitution": True, "bank": True, "safeguarding": False, "prior": True, "prior_details": "", "status": "submitted", "budget": [{"name": "Workshop equipment", "amount": 220000.0, "quantity": 1}, {"name": "Safety supplies", "amount": 30000.0, "quantity": 0}, {"name": "Venue", "amount": 25000.0, "quantity": 1}]}
    ];
    AUDIT = [
        {"application": "GF-2026-001", "actor": "System", "action": "Demo application seeded", "time": "2026-06-01 09:00"},
        {"application": "GF-2026-002", "actor": "System", "action": "Demo application seeded", "time": "2026-06-01 09:01"},
        {"application": "GF-2026-003", "actor": "System", "action": "Demo application seeded", "time": "2026-06-01 09:02"}
    ];
    DECISIONS = {};
    AGENT_RUNS = {};
}


def _evaluate(app: dict) -> dict {
    completeness = 25;
    eligibility = 25;
    budget_score = 25;
    risk = 25;
    failed = False;
    missing_docs: list[str] = [];
    findings: list[str] = [];
    if not app["applicant"] or not app["project"] or not app["summary"] { completeness -= 8; findings.append("Required application details are incomplete."); }
    if not app["constitution"] and (app["type"] == "registered_ngo" or app["type"] == "community_group") { completeness -= 10; missing_docs.append("Provide a group constitution."); findings.append("Constitution is missing."); }
    if not app["bank"] { completeness -= 7; missing_docs.append("Provide verified bank details."); findings.append("Bank details are missing."); }
    if not app["safeguarding"] and (app["category"] == "youth" or app["category"] == "women" or app["category"] == "disability_inclusion" or app["category"] == "education" or app["category"] == "health") { completeness -= 5; findings.append("Safeguarding policy is missing for a sensitive project."); }
    if not (app["category"] in ["education", "health", "environment", "agriculture", "youth", "women", "disability_inclusion", "other"]) { eligibility = 0; failed = True; findings.append("Category is outside the published programme rules."); }
    if app["county"] == "" { eligibility -= 10; findings.append("County is required."); }
    if app["amount"] > RULE_CAP { eligibility -= 10; findings.append("Request exceeds the category funding cap."); }
    total = 0.0;
    largest = 0.0;
    for item in app["budget"] {
        total += item["amount"];
        if item["amount"] > largest { largest = item["amount"]; }
        if item["amount"] < 0 or item["quantity"] <= 0 { budget_score -= 8; findings.append("Budget includes a negative amount or zero quantity."); }
    }
    if total != app["amount"] { budget_score -= 10; findings.append("Budget total does not match the amount requested."); }
    if total > 0 and largest > total * 0.6 { budget_score -= 8; findings.append("A single budget line exceeds 60% of the total."); }
    if app["amount"] > RULE_CAP * 1.2 { failed = True; findings.append("Request is more than 20% above the funding cap."); }
    if app["type"] == "registered_ngo" or app["type"] == "community_group" {
        if not app["constitution"] { failed = True; }
    }
    if app["end"] <= app["start"] { risk -= 15; failed = True; findings.append("Project end date must follow its start date."); }
    if app["category"] == "youth" and not app["safeguarding"] { risk -= 8; findings.append("Youth project requires safeguarding arrangements."); }
    if app["prior"] and not app["prior_details"] { risk -= 5; findings.append("Prior funding is declared without outcome details."); }
    if len(findings) == 0 { findings.append("All core checks passed against the published rules."); }
    score = completeness + eligibility + budget_score + risk;
    recommendation = "approve" if score >= 85 else ("conditional" if score >= 70 or (failed and len(missing_docs) > 0) else "reject");
    if failed and len(missing_docs) == 0 { recommendation = "reject"; }
    conditions = missing_docs;
    if recommendation == "conditional" and len(conditions) == 0 { conditions = ["Resolve the flagged budget or risk findings before release."]; }
    if recommendation == "reject" { conditions = []; }
    return {"score": score, "completeness": completeness, "eligibility": eligibility, "budget_score": budget_score, "risk": risk, "recommendation": recommendation, "conditions": conditions, "findings": findings, "total": total};
}


def:pub list_applications() -> dict {
    if len(APPLICATIONS) == 0 { _seed(); }
    return {"applications": APPLICATIONS, "audit": AUDIT, "decisions": DECISIONS, "agents": AGENT_RUNS, "role": ROLE, "cap": RULE_CAP};
}


def:pub create_application(applicant: str, organization: str, project: str, category: str, county: str, amount: float, summary: str) -> dict {
    if len(APPLICATIONS) == 0 { _seed(); }
    id = f"GF-2026-{len(APPLICATIONS) + 1:03}";
    app = {"id": id, "applicant": applicant, "organization": organization, "project": project, "category": category, "county": county, "amount": amount, "start": "2026-07-01", "end": "2026-10-01", "type": "community_group", "summary": summary, "constitution": True, "bank": True, "safeguarding": True, "prior": False, "prior_details": "", "status": "under_review", "budget": [{"name": "Project delivery", "amount": amount, "quantity": 1}]};
    APPLICATIONS.append(app);
    review_application(id);
    AUDIT.append({"application": id, "actor": ROLE, "action": "Application submitted and agents run", "time": "2026-06-18 10:30"});
    return app;
}


def:pub review_application(application_id: str) -> dict {
    if len(APPLICATIONS) == 0 { _seed(); }
    for app in APPLICATIONS {
        if app["id"] == application_id {
            result = _evaluate(app);
            DECISIONS[application_id] = result;
            AGENT_RUNS[application_id] = [
                {"name": "Completeness", "score": result["completeness"], "findings": result["findings"]},
                {"name": "Eligibility", "score": result["eligibility"], "findings": result["findings"]},
                {"name": "Budget", "score": result["budget_score"], "findings": result["findings"]},
                {"name": "Risk", "score": result["risk"], "findings": result["findings"]}
            ];
            app["status"] = "under_review";
            AUDIT.append({"application": application_id, "actor": ROLE, "action": "Four deterministic review agents completed", "time": "2026-06-18 10:30"});
            return result;
        }
    }
    return {"error": "Application not found"};
}


def:pub set_decision(application_id: str, decision: str) -> dict {
    for app in APPLICATIONS {
        if app["id"] == application_id {
            app["status"] = "approved" if decision == "approve" else ("conditional" if decision == "conditional" else "rejected");
            result = DECISIONS.get(application_id, _evaluate(app));
            result["recommendation"] = decision;
            DECISIONS[application_id] = result;
            AUDIT.append({"application": application_id, "actor": ROLE, "action": f"Reviewer recorded {decision} decision", "time": "2026-06-18 10:35"});
            return result;
        }
    }
    return {"error": "Application not found"};
}


def:pub get_report(application_id: str) -> dict {
    for app in APPLICATIONS {
        if app["id"] == application_id {
            result = DECISIONS.get(application_id, _evaluate(app));
            findings = str(result["findings"]);
            conditions = str(result["conditions"]) if len(result["conditions"]) > 0 else "No additional conditions";
            decision = app["status"] if app["status"] == "approved" or app["status"] == "conditional" or app["status"] == "rejected" else result["recommendation"];
            text = f"After automated review and reviewer confirmation, GrantFlow KE recommends {decision.upper()} for {app['project']}. Final score: {result['score']}/100. Key findings: {findings}. Conditions: {conditions}. This recommendation is generated from published rules and recorded in the audit trail.";
            AUDIT.append({"application": application_id, "actor": ROLE, "action": "Deterministic decision report generated", "time": "2026-06-18 10:40"});
            return {"text": text, "application": app, "decision": result};
        }
    }
    return {"text": "Application not found", "application": {}, "decision": {}};
}


def:pub switch_role(role: str) -> str {
    ROLE = "Applicant" if role == "Applicant" else "Reviewer";
    AUDIT.append({"application": "Workspace", "actor": ROLE, "action": f"Role switched to {ROLE}", "time": "2026-06-18 10:45"});
    return ROLE;
}


def:pub update_cap(cap: float) -> float {
    if cap >= 10000 and cap <= 2000000 { RULE_CAP = cap; }
    return RULE_CAP;
}


def:pub reset_demo() -> dict {
    _seed();
    ROLE = "Reviewer";
    return list_applications();
}

with entry { _seed(); }
