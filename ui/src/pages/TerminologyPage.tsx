import { Link, useParams } from "react-router-dom";
import { TERMINOLOGIES } from "../config/demoConfig";
import { IcdWorkspace } from "../workspaces/IcdWorkspace";
import { LoincWorkspace } from "../workspaces/LoincWorkspace";
import { SnomedWorkspace } from "../workspaces/SnomedWorkspace";
import { VectorWorkspace } from "../workspaces/VectorWorkspace";

export function TerminologyPage() {
  const { terminologyId } = useParams<{ terminologyId: string }>();
  const terminology = TERMINOLOGIES.find((entry) => entry.id === terminologyId);

  if (!terminology) {
    return (
      <section className="content-panel placeholder">
        <strong>Unknown terminology</strong>
        <p>
          The requested terminology route does not match the configured demo
          definitions.
        </p>
        <Link className="button button-secondary" to="/">
          Back Home
        </Link>
      </section>
    );
  }

  if (terminology.id === "snomed") return <SnomedWorkspace />;
  if (terminology.id === "loinc") return <LoincWorkspace />;
  if (terminology.id === "icd") return <IcdWorkspace />;
  if (terminology.id === "vector") return <VectorWorkspace />;

  return null;
}