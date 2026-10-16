sv import from ..services.grants { list_applications, create_application, review_application, set_decision, get_report, switch_role, update_cap, reset_demo }
import from .ui.button { Button }
import from .ui.card { Card, CardHeader, CardTitle, CardDescription, CardContent }
import from .ui.badge { Badge }
import from .ui.input { Input }
import from .ui.textarea { Textarea }
import from .ui.separator { Separator }
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { DashboardSquare01Icon, File01Icon, UserGroupIcon, Settings01Icon, Clock01Icon, CheckmarkCircle01Icon, Alert01Icon, Add01Icon, Search01Icon, RefreshIcon, ArrowRight01Icon }

def:pub GrantReview() -> JsxElement {
    has dataset: dict = {"applications": [], "audit": [], "decisions": {}, "agents": {}, "role": "Reviewer", "cap": 500000.0};
    has selected: str = "GF-2026-001";
    has search: str = "";
    has page: str = "Overview";
    has new_open: bool = False;
    has applicant: str = "";
    has organization: str = "";
    has project: str = "";
    has category: str = "education";
    has county: str = "";
    has amount: str = "";
    has summary: str = "";
    has report_text: str = "";
    has cap_input: str = "500000";
    has error_text: str = "";

    async can with entry { dataset = await list_applications(); }
    async def refresh() -> None { dataset = await list_applications(); }
    async def handle_reset() -> None { dataset = await reset_demo(); selected = "GF-2026-001"; report_text = ""; error_text = ""; }
    async def handle_review() -> None { _ = await review_application(selected); dataset = await list_applications(); }
    async def handle_approve() -> None { _ = await set_decision(selected, "approve"); dataset = await list_applications(); }
    async def handle_conditional() -> None { _ = await set_decision(selected, "conditional"); dataset = await list_applications(); }
    async def handle_reject() -> None { _ = await set_decision(selected, "reject"); dataset = await list_applications(); }
    async def handle_report() -> None { report_data = await get_report(selected); report_text = report_data["text"]; dataset = await list_applications(); }
    async def handle_role() -> None { role = await switch_role("Applicant" if dataset["role"] == "Reviewer" else "Reviewer"); dataset = {**dataset, "role": role}; }
    async def handle_save_cap() -> None { cap = await update_cap(float(cap_input)); dataset = {**dataset, "cap": cap}; }
    async def handle_create() -> None {
        if not applicant or not organization or not project or not county or not summary or not amount {
            error_text = "Complete every field before submitting.";
        } else {
            _ = await create_application(applicant, organization, project, category, county, float(amount), summary);
            dataset = await list_applications();
            selected = dataset["applications"][len(dataset["applications"]) - 1]["id"];
            new_open = False;
            applicant = ""; organization = ""; project = ""; county = ""; summary = ""; amount = ""; error_text = "";
        }
    }
    def handle_search(e: ChangeEvent) { search = e.target.value; }
    def handle_applicant(e: ChangeEvent) { applicant = e.target.value; }
    def handle_organization(e: ChangeEvent) { organization = e.target.value; }
    def handle_project(e: ChangeEvent) { project = e.target.value; }
    def handle_county(e: ChangeEvent) { county = e.target.value; }
    def handle_amount(e: ChangeEvent) { amount = e.target.value; }
    def handle_summary(e: ChangeEvent) { summary = e.target.value; }
    def handle_cap(e: ChangeEvent) { cap_input = e.target.value; }

    apps = dataset["applications"] as list[dict];
    decision_map = dataset["decisions"] as dict;
    agent_map = dataset["agents"] as dict;
    current: dict = {};
    for item in apps { if item["id"] == selected { current = item; } }
    decision: dict = decision_map.get(selected, {});
    runs: list[dict] = agent_map.get(selected, []);
    total_amount = 0.0;
    pending = 0;
    approved_amount = 0.0;
    flagged = 0;
    for item in apps {
        total_amount += item["amount"] as float;
        if item["status"] == "submitted" or item["status"] == "under_review" { pending += 1; }
        if item["status"] == "approved" { approved_amount += item["amount"] as float; }
        if decision_map.get(item["id"], {}).get("recommendation", "") == "reject" { flagged += 1; }
    }
    return <div className="min-h-screen bg-[#F7F3EA] text-[#1F2937] md:flex">
        <aside className="border-b border-[#D8D2C4] bg-[#0B3D2E] text-white md:flex md:w-64 md:shrink-0 md:flex-col md:border-b-0 md:border-r md:p-5">
            <div className="flex items-center justify-between p-4 md:p-0"><div className="flex items-center gap-3"><div className="flex size-10 items-center justify-center rounded-xl bg-white/10 font-bold">GF</div><div><p className="font-semibold">GrantFlow KE</p><p className="text-xs text-white/65">Community fund review</p></div></div><span className="rounded-full bg-emerald-800 px-2 py-1 text-xs">Demo</span></div>
            <nav className="flex gap-2 overflow-x-auto p-3 md:mt-10 md:flex-col md:p-0">
                <button onClick={lambda { page = "Overview"; }} className={"flex shrink-0 items-center gap-3 rounded-lg px-3 py-2.5 text-sm " + ("bg-white/15 text-white" if page == "Overview" else "text-white/75 hover:bg-white/10")}><HugeiconsIcon icon={DashboardSquare01Icon} strokeWidth={2} className="size-4" />Overview</button>
                <button onClick={lambda { page = "Applications"; }} className={"flex shrink-0 items-center gap-3 rounded-lg px-3 py-2.5 text-sm " + ("bg-white/15 text-white" if page == "Applications" else "text-white/75 hover:bg-white/10")}><HugeiconsIcon icon={File01Icon} strokeWidth={2} className="size-4" />Applications</button>
                <button onClick={lambda { page = "Rules & guide"; }} className={"flex shrink-0 items-center gap-3 rounded-lg px-3 py-2.5 text-sm " + ("bg-white/15 text-white" if page == "Rules & guide" else "text-white/75 hover:bg-white/10")}><HugeiconsIcon icon={Settings01Icon} strokeWidth={2} className="size-4" />Rules & guide</button>
            </nav>
            <div className="hidden flex-1 md:block" />
            <div className="hidden border-t border-white/15 pt-4 md:block"><p className="text-xs text-white/60">SIGNED IN AS</p><button className="mt-2 rounded-md border border-white/20 px-3 py-2 text-sm" onClick={handle_role}>{dataset["role"]} · Switch role</button><p className="mt-4 text-xs text-white/50">Demo Mode: deterministic agents active</p></div>
        </aside>
        <main className="min-w-0 flex-1 p-4 sm:p-6 lg:p-9">
            <header className="mb-7 flex flex-wrap items-center justify-between gap-4"><div><p className="text-sm font-medium text-[#0B3D2E]">Grant review workspace</p><h1 className="mt-1 text-2xl font-semibold tracking-tight">{page}</h1><p className="mt-1 text-sm text-slate-600">Published rules, explainable decisions, a complete audit trail.</p></div><div className="flex flex-wrap items-center gap-2"><Button variant="outline" onClick={handle_role}>{dataset["role"]} role</Button><Button variant="outline" onClick={handle_reset}><HugeiconsIcon icon={RefreshIcon} strokeWidth={2} className="size-4" />Reset Demo Data</Button><Button onClick={lambda { new_open = not new_open; page = "Applications"; }}><HugeiconsIcon icon={Add01Icon} strokeWidth={2} className="size-4" />New application</Button></div></header>
            <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-white px-3 py-1.5 text-xs font-medium text-[#0B3D2E]"><span className="size-2 rounded-full bg-emerald-600" />Demo Mode: deterministic agents active</div>
                {if new_open {<Card className="mt-5 shadow-sm"><CardHeader><CardTitle>New funding application</CardTitle><CardDescription>Structured submission; review agents run automatically.</CardDescription></CardHeader><CardContent className="grid gap-4 sm:grid-cols-2"><label className="text-sm">Applicant name<Input value={applicant} onChange={handle_applicant} placeholder="e.g. Wanjiku Mwangi" /></label><label className="text-sm">Organization<Input value={organization} onChange={handle_organization} placeholder="Community organization" /></label><label className="text-sm">Project title<Input value={project} onChange={handle_project} placeholder="Project name" /></label><label className="text-sm">County<Input value={county} onChange={handle_county} placeholder="County" /></label><label className="text-sm">Category<select value={category} onChange={lambda (e: ChangeEvent) { category = e.target.value; }} className="mt-1 h-9 w-full rounded-md border border-input bg-background px-3"><option value="education">Education</option><option value="youth">Youth</option><option value="health">Health</option><option value="agriculture">Agriculture</option><option value="environment">Environment</option></select></label><label className="text-sm">Requested amount (KES)<Input type="number" value={amount} onChange={handle_amount} placeholder="250000" /></label><label className="text-sm sm:col-span-2">Project summary<Textarea value={summary} onChange={handle_summary} placeholder="Describe the community outcome and delivery plan." /></label><p className="text-sm text-destructive sm:col-span-2">{error_text}</p><div className="flex gap-2 sm:col-span-2"><Button onClick={handle_create}>Submit application and run review</Button><Button variant="outline" onClick={lambda { new_open = False; }}>Cancel</Button></div></CardContent></Card>}}
                <div className="grid gap-5 xl:grid-cols-5"><Card className="shadow-sm xl:col-span-2"><CardHeader><CardTitle>Application queue</CardTitle></CardHeader><CardContent className="flex flex-col gap-2">{for item in apps {<button onClick={lambda { selected = item["id"]; }} className="rounded-xl border bg-white p-3 text-left"><p className="font-medium">{item["project"]}</p><p className="text-xs text-slate-500">{item["applicant"]} · {item["county"]}</p></button>}}</CardContent></Card><Card className="shadow-sm xl:col-span-3"><CardHeader><CardTitle>{current["project"]}</CardTitle><CardDescription>{current["organization"]} · {current["county"]}</CardDescription></CardHeader><CardContent className="flex flex-col gap-4"><p>{current["summary"]}</p><p className="text-sm">Applicant: {current["applicant"]} · Requested KES {str(current["amount"])}</p><div className="flex flex-wrap gap-2"><Button onClick={handle_review}>Run Review Agents</Button><Button variant="outline" onClick={handle_approve}>Approve</Button><Button variant="outline" onClick={handle_conditional}>Approve with Conditions</Button><Button variant="outline" onClick={handle_reject}>Reject</Button><Button variant="outline" onClick={handle_report}>Generate Report</Button></div><h3 className="font-semibold">Agent results · Score {str(decision.get("score", "pending"))}/100</h3>{for run in runs {<p className="rounded border p-2 text-sm">{run["name"]}: {str(run["score"])}/25 · {str(run["findings"])[0:100]}</p>}}{if report_text {<p className="rounded-lg bg-amber-50 p-3 text-sm">{report_text}</p>}}<h3 className="font-semibold">Audit trail</h3>{for event in (dataset["audit"] as list[dict]) {if event["application"] == selected {<p className="border-l-2 border-emerald-600 pl-3 text-sm">{event["action"]} · {event["actor"]}</p>}}}</CardContent></Card></div>
        </main>
    </div>;
}
