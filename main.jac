import from services.grants { list_applications, create_application, review_application, set_decision, get_report, switch_role, update_cap, reset_demo }
import ".styles.global.css";
import from .components.GrantReview { GrantReview }

def:pub app() -> JsxElement {
    return <GrantReview />;
}
