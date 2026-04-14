import { Link, useParams } from "react-router-dom";
import { TERMINOLOGIES } from "../config/demoConfig";
import { IcdWorkspace } from "../workspaces/IcdWorkspace";
import { LoincWorkspace } from "../workspaces/LoincWorkspace";
import { SnomedWorkspace } from "../workspaces/SnomedWorkspace";

export function TerminologyPage() {
  const { terminologyId } = useParams<{ terminologyId: string }>();
  const terminology = TERMINOLOGIES.find((entry) => entry.id === terminologyId);

  if (!terminology) {
    return (
      <main className="content-panel placeholder">
        <strong>Unknown terminology</strong>
        <p>The requested terminology route does not match the configured demo definitions.</p>
        <div className="button-row">
          <Link className="button button-secondary" to="/">
            Back Home
          </Link>
        </div>
      </main>
    );
  }

  if (terminology.id === "snomed") {
    return <SnomedWorkspace />;
  }

  if (terminology.id === "loinc") {
    return <LoincWorkspace />;
  }

  if (terminology.id === "icd") {
    return <IcdWorkspace />;
  }

  return (
    <main className="content-panel placeholder">
      <p className="eyebrow">{terminology.name}</p>
      <strong>{terminology.name} workspace</strong>
      <p>
        This route is in place so the home screen navigation already works. The next implementation step is the
        terminology workspace with native and FHIR action tabs.
      </p>
      <p>Planned route: {terminology.route}</p>
      <div className="button-row">
        <Link className="button button-secondary" to="/">
          Back Home
        </Link>
      </div>
    </main>
  );
}
